"""Run one simulation of the vendored corticothalamic model.

One JSON config + one seed = one run. The config names the init.hoc scalar
knobs and any conductance overrides; the runner patches a scratch copy of the
model tree, runs it, reduces the output, and writes a record keyed on
(config hash, seed, git SHA).

Usage:
    python sim/runner.py --config sim/configs/baseline_spindles.json --seed 0 \
                        --model model/thalamocortical2 --out runs/
"""
import argparse
import hashlib
import json
import os
import re
import shutil
import subprocess
import sys
import time


def patch_init(init_path, knobs):
    """Rewrite top-level scalar assignments in init.hoc, preserving indentation
    and trailing comments. Raises if a requested variable is absent."""
    with open(init_path) as fh:
        lines = fh.read().split("\n")
    changed = {}
    for var, val in knobs.items():
        pat = re.compile(r"^(\s*)" + re.escape(var) + r"\s*=")
        hit = next((i for i, l in enumerate(lines) if pat.match(l)), None)
        if hit is None:
            raise ValueError("init.hoc has no top-level %r" % var)
        old = lines[hit]
        indent = pat.match(old).group(1)
        rhs = '"%s"' % val if isinstance(val, str) else repr(val)
        comment = "  " + old[old.index("//"):] if "//" in old else ""
        lines[hit] = "%s%s = %s%s" % (indent, var, rhs, comment)
        changed[var] = lines[hit].strip()
    with open(init_path, "w") as fh:
        fh.write("\n".join(lines))
    return changed


def patch_conductance(model_dir, overrides):
    """Apply conductance overrides to the vendored .hoc sources.

    Matches on variable NAME, never line number -- upstream line numbers drift
    between versions.

    Config forms, per file::

        {"TCcell.hoc": {"gcabar_it": 0.0022}}                      # must be unique
        {"TCcell.hoc": {"gcabar_it": {"value": 0.0042,
                                      "after": 'section, "HO"'}}}  # disambiguated
        {"TCcell.hoc": {"gcabar_it": {"value": 0.0042,
                                      "occurrence": 2}}}           # 1-based

    Several conductances in this model are assigned more than once -- once per
    thalamic order, inside `if (!strcmp(section, "FO"))` / `else if (... "HO")`
    branches. `gcabar_it` is the important case: TC_HO carries twice the
    baseline T-type Ca conductance of TC_FO (`2*0.0021` vs `0.0021`), and the
    FO/HO distinction is load-bearing for this project. An un-disambiguated
    override of an ambiguous name therefore raises, listing every candidate with
    its line number and current right-hand side.

    Right-hand sides may be expressions, not just literals (`2*0.0021`), so the
    whole RHS up to any trailing `//` comment is replaced and the original text
    is recorded for provenance.
    """
    applied = {}
    for fname, params in overrides.items():
        path = os.path.join(model_dir, fname)
        with open(path) as fh:
            src = fh.read()
        for var, spec in params.items():
            if isinstance(spec, dict):
                val = spec["value"]
                after = spec.get("after")
                occurrence = spec.get("occurrence")
            else:
                val, after, occurrence = spec, None, None

            # RHS = everything after '=' up to a trailing comment or line end.
            pat = re.compile(
                r"(?P<head>^[ \t]*(?:\w+\.)?%s[ \t]*=[ \t]*)(?P<rhs>[^/\n]*?)(?P<tail>[ \t]*(?://.*)?$)"
                % re.escape(var), re.MULTILINE)
            cands = [m for m in pat.finditer(src) if m.group("rhs").strip()]
            if not cands:
                raise ValueError("%s: no assignment to %r found" % (fname, var))

            if after is not None:
                # For each anchor match, take the first assignment that follows
                # it. Require all anchor matches to agree on one assignment --
                # a loose anchor that selects several raises, telling the caller
                # to tighten it rather than silently picking one.
                anchors = list(re.finditer(after, src))
                if not anchors:
                    raise ValueError("%s: anchor %r not found" % (fname, after))
                picks = []
                for a in anchors:
                    nxt = [m for m in cands if m.start() > a.start()]
                    if nxt:
                        picks.append(min(nxt, key=lambda m: m.start()))
                starts = sorted({m.start() for m in picks})
                if not starts:
                    raise ValueError("%s: no assignment to %r follows anchor %r"
                                     % (fname, var, after))
                if len(starts) > 1:
                    detail = "; ".join("line %d" % (src[:s].count("\n") + 1) for s in starts)
                    raise ValueError(
                        "%s: anchor %r is ambiguous for %r -- it selects %d "
                        "different assignments (%s). Tighten the anchor."
                        % (fname, after, var, len(starts), detail))
                cands = [m for m in picks if m.start() == starts[0]][:1]
            elif occurrence is not None:
                if not 1 <= occurrence <= len(cands):
                    raise ValueError("%s: %r occurrence %d out of range (1..%d)"
                                     % (fname, var, occurrence, len(cands)))
                cands = [cands[occurrence - 1]]
            elif len(cands) > 1:
                detail = "; ".join(
                    "line %d: %s" % (src[:m.start()].count("\n") + 1, m.group("rhs").strip())
                    for m in cands)
                raise ValueError(
                    "%s: %r is assigned %d times -- disambiguate with 'after' or "
                    "'occurrence'. Candidates: %s"
                    % (fname, var, len(cands), detail))

            m = cands[0]
            line_no = src[:m.start()].count("\n") + 1
            old_rhs = m.group("rhs").strip()
            new_rhs = repr(val) if not isinstance(val, str) else val
            src = src[:m.start("rhs")] + new_rhs + src[m.end("rhs"):]
            applied["%s:%s" % (fname, var)] = {
                "line": line_no, "from": old_rhs, "to": new_rhs,
                "disambiguator": ("after=%s" % after) if after else
                                 ("occurrence=%d" % occurrence) if occurrence else None,
            }
        with open(path, "w") as fh:
            fh.write(src)
    return applied


def git_sha(repo_root):
    try:
        return subprocess.run(["git", "-C", repo_root, "rev-parse", "HEAD"],
                              capture_output=True, text=True, check=True).stdout.strip()
    except Exception:
        return "unknown"


def run_id(config, seed):
    payload = json.dumps({"config": config, "seed": seed}, sort_keys=True)
    return hashlib.sha256(payload.encode()).hexdigest()[:16]


def main(argv=None):
    ap = argparse.ArgumentParser()
    ap.add_argument("--config", required=True)
    ap.add_argument("--seed", type=int, default=0)
    ap.add_argument("--model", default="model/thalamocortical2")
    ap.add_argument("--out", default="runs")
    ap.add_argument("--keep-traces", action="store_true",
                    help="retain raw .dat output (75 MB per model-second -- "
                         "exemplar runs only, never a sweep)")
    args = ap.parse_args(argv)

    with open(args.config) as fh:
        config = json.load(fh)
    rid = run_id(config, args.seed)
    outdir = os.path.join(args.out, rid)
    if os.path.exists(os.path.join(outdir, "record.json")):
        print("[runner] %s already complete, skipping" % rid)
        return 0
    os.makedirs(outdir, exist_ok=True)

    scratch = os.path.join(outdir, "model")
    if os.path.exists(scratch):
        shutil.rmtree(scratch)
    shutil.copytree(args.model, scratch)

    knobs = dict(config.get("init", {}))
    knobs["globalIndex"] = args.seed          # Random123 replicate seed
    patched = patch_init(os.path.join(scratch, "init.hoc"), knobs)
    conductances = patch_conductance(scratch, config.get("conductances", {}))

    special = os.path.join(scratch, "x86_64", "special")
    if not os.path.exists(special):
        subprocess.run(["nrnivmodl", "."], cwd=scratch, check=True,
                       capture_output=True, text=True)

    t0 = time.time()
    proc = subprocess.run([os.path.abspath(special), "-nogui", "init.hoc"],
                          cwd=scratch, capture_output=True, text=True)
    wall = time.time() - t0

    record = {
        "run_id": rid,
        "config_path": args.config,
        "config": config,
        "seed": args.seed,
        "init_patched": patched,
        "conductances_patched": conductances,
        "git_sha": git_sha(os.path.dirname(os.path.abspath(args.model)) or "."),
        "wall_seconds": wall,
        "exit_code": proc.returncode,
        "stdout_tail": proc.stdout[-4000:],
        "stderr_tail": proc.stderr[-4000:],
    }

    # TODO(analysis): reduce in-worker to EEG proxy, spike times, weight
    # checkpoints and scalar measures before discarding traces. Until the
    # reducer lands, --keep-traces is the only way to retain output.
    if not args.keep_traces:
        for f in os.listdir(scratch):
            if f.endswith(".dat"):
                os.remove(os.path.join(scratch, f))
        record["traces_discarded"] = True

    with open(os.path.join(outdir, "record.json"), "w") as fh:
        json.dump(record, fh, indent=2)
    print("[runner] %s exit=%d wall=%.1fs" % (rid, proc.returncode, wall))
    return proc.returncode


if __name__ == "__main__":
    sys.exit(main())
