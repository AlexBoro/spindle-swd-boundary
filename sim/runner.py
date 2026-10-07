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
    """Apply conductance overrides of the form {"TCcell.hoc": {"gcabar_it": 0.0022}}.

    Matches on variable NAME, never line number -- upstream line numbers drift
    between versions. Raises if a name is absent or ambiguous.
    """
    applied = {}
    for fname, params in overrides.items():
        path = os.path.join(model_dir, fname)
        with open(path) as fh:
            src = fh.read()
        for var, val in params.items():
            pat = re.compile(r"(^[ \t]*(?:\w+\.)?%s\s*=\s*)([-\d.eE+]+)" % re.escape(var),
                             re.MULTILINE)
            hits = pat.findall(src)
            if len(hits) != 1:
                raise ValueError("%s: %r matched %d times, expected 1"
                                 % (fname, var, len(hits)))
            src = pat.sub(lambda m: m.group(1) + repr(val), src, count=1)
            applied["%s:%s" % (fname, var)] = val
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
