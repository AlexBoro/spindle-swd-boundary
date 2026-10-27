"""In-container driver for one Wei 2018 run (Modal or local).

usage: python job_run.py <src.tar.gz> <protocol_name> <seed> <threads> [extra -param value ...]

1. unpack the model source (git archive of model/wei2018 at a known SHA) and
   compile it with the image's g++ (toolchain pinned by the image)
2. generate the network from network.cfg (deterministic: every projection has p = 1)
3. run mindcurrent with wei2018_params.txt, the named protocol, -sim_seed and
   -num_mp_threads; tmax is read from the protocol header
4. reduce raw output into out/<run_id>.npz plus out/<run_id>.json

Raw outputs: spike_time (text 't type m n'), lfp.f32 (t, mean V PY/IN/TC/RE),
weights_g.f32 / weights_mini.f32 (t, then one value per PY-PY AMPA_D3 synapse),
weights_index.txt (pre post).

Checkpoints (model/wei2018/checkpoint.h): pass "-ckpt_save_at T -ckpt_save_path NAME" to write the
full state at t = T into out/<run_id>_NAME (persisted with the run); add "-ckpt_exit_after_save 1" to
stop there. Pass "-ckpt_load_path FILE" to branch from a saved state; its sha256 goes into the json.
"""
import hashlib, json, os, re, subprocess, sys, tarfile, time
import numpy as np

src, proto, seed, threads = sys.argv[1], sys.argv[2], int(sys.argv[3]), int(sys.argv[4])
extra = [a for a in sys.argv[5:] if not a.startswith(("@", "%"))]
# '%FILE' copies a 'pre post g mini' weight file to protocols/weights.txt, where the
# protocol's 'weights weights.txt' directive picks it up (Stage 1 test-only runs)
wfile = [a[1:] for a in sys.argv[5:] if a.startswith("%")]
# '@FROM:TO:SYN:FIELD=VALUE' rewrites one field of a network.cfg connection row,
# FIELD in {radius, prob, strength, mini_s, mini_f}; e.g. @CX:CX:AMPA_D3:mini_s=0.0002
cfg_over = [a[1:] for a in sys.argv[5:] if a.startswith("@")]
work = os.path.abspath("build"); os.makedirs(work, exist_ok=True)
os.makedirs("out", exist_ok=True)
with tarfile.open(src) as t:
    t.extractall(work)
M = os.path.join(work, "model", "wei2018")
meta = {"protocol": proto, "seed": seed, "threads": threads, "extra": extra}
meta["src_sha256"] = hashlib.sha256(open(src, "rb").read()).hexdigest()
if os.path.exists(os.path.join(work, "GIT_SHA")):
    meta["git_sha"] = open(os.path.join(work, "GIT_SHA")).read().strip()
meta["gxx"] = subprocess.run(["g++", "--version"], capture_output=True, text=True).stdout.splitlines()[0]
subprocess.run("make -s mindcurrent > build.log 2>&1 || (cat build.log; exit 1)", shell=True, cwd=M, check=True)
FIELDS = {"radius": 3, "prob": 5, "strength": 8, "mini_s": 9, "mini_f": 10}
if cfg_over:
    cfg = open(os.path.join(M, "network.cfg")).read().splitlines()
    for o in cfg_over:
        key, val = o.split("=")
        fr, to, syn, field = key.split(":")
        hits = [i for i, l in enumerate(cfg) if l.split()[:3] == [fr, to, syn]]
        assert len(hits) == 1, f"{key}: {len(hits)} matching rows"
        f = cfg[hits[0]].split()
        old_v = f[FIELDS[field]]; f[FIELDS[field]] = val
        cfg[hits[0]] = "  " + "  ".join(f)
        print("CFG", key, old_v, "->", val, flush=True)
    open(os.path.join(M, "network.cfg"), "w").write("\n".join(cfg) + "\n")
meta["cfg_overrides"] = cfg_over
if wfile:
    import shutil
    assert len(wfile) == 1, wfile
    shutil.copy(wfile[0], os.path.join(M, "protocols", "weights.txt"))
    meta["weights_file"] = os.path.basename(wfile[0])
    meta["weights_sha256"] = hashlib.sha256(open(wfile[0], "rb").read()).hexdigest()
subprocess.run("g++ -O2 generate_network.cpp -o generate_network 2>/dev/null && "
               "./generate_network > connection_info2 2>gen.log", shell=True, cwd=M, check=True)
meta["binary_sha256"] = hashlib.sha256(open(os.path.join(M, "mindcurrent"), "rb").read()).hexdigest()

pfile = os.path.join(M, "protocols", proto + ".txt")
tmax = int(re.search(r"tmax = (\d+) ms", open(pfile).read()).group(1)) if "tmax =" in open(pfile).read() else None
args = ["-sim_seed", str(seed), "-num_mp_threads", str(threads)]
if tmax is not None and "-tmax" not in extra:
    args += ["-tmax", str(tmax)]
args += extra
ckpt_name = None
if "-ckpt_save_path" in args:          # write the checkpoint next to the raw output, keep the name for out/
    k = args.index("-ckpt_save_path") + 1; ckpt_name = os.path.basename(args[k])
    args = args[:k] + [os.path.join(os.path.abspath("raw"), ckpt_name)] + args[k + 1:]
if "-ckpt_load_path" in args:
    cp = args[args.index("-ckpt_load_path") + 1]
    meta["ckpt_load_sha256"] = hashlib.sha256(open(cp, "rb").read()).hexdigest()
meta["args"] = args
tag = " ".join(extra + cfg_over)
run_id = f"{proto}_s{seed}" + ("_" + hashlib.sha1(tag.encode()).hexdigest()[:6] if tag else "")
if wfile:   # Stage 1: name the run by its weight set (which already carries the seed)
    run_id = f"{proto}_" + os.path.splitext(os.path.basename(wfile[0]))[0] + ("_" + hashlib.sha1(tag.encode()).hexdigest()[:6] if tag else "")
raw = os.path.abspath("raw"); os.makedirs(raw, exist_ok=True)
if os.environ.get("WEI_PERSIST_DIR"):
    _d = os.path.join(os.environ["WEI_PERSIST_DIR"], run_id); os.makedirs(_d, exist_ok=True)
    json.dump(meta, open(os.path.join(_d, "STARTED.json"), "w"))
t0 = time.time()
with open("sim_stdout.log", "w") as so, open("sim_stderr.log", "w") as se:
    rc = subprocess.run([os.path.join(M, "mindcurrent"), os.path.join(M, "wei2018_params.txt"),
                         raw + "/", os.path.join(M, "connection_info2"), pfile] + args,
                        stdout=so, stderr=se).returncode
meta["wall_s"] = time.time() - t0
meta["returncode"] = rc
log = open("sim_stdout.log").read()
meta["completed"] = "Computation time" in log
last = re.findall(r"milliseconds of sim = ([0-9.]+)", log)
meta["last_ms"] = float(last[-1]) if last else None
print("RC", rc, "completed", meta["completed"], "wall_s", round(meta["wall_s"]), "last_ms", meta["last_ms"], flush=True)

# ---- reduce ----
d = {}
sp = np.loadtxt(os.path.join(raw, "spike_time"), ndmin=2) if os.path.getsize(os.path.join(raw, "spike_time")) else np.zeros((0, 4))
# full key (t, type, cell): spikes of one step are written in thread order
order = np.lexsort((sp[:, 2], sp[:, 1], sp[:, 0])) if len(sp) else np.arange(0)
sp = sp[order]
d["spk_t"] = sp[:, 0].astype(np.float64)
d["spk_type"] = sp[:, 1].astype(np.int8)
d["spk_m"] = sp[:, 2].astype(np.int16)
lfp = np.fromfile(os.path.join(raw, "lfp.f32"), dtype=np.float32)
d["lfp"] = lfp[: len(lfp) // 5 * 5].reshape(-1, 5)
ra = os.path.join(raw, "rec_area.f32")
if os.path.exists(ra):   # -rec_area 1: t + 2 regions x 7 trained-area state columns (see main.cpp area_step)
    a = np.fromfile(ra, dtype=np.float32); d["rec_area"] = a[: len(a) // 15 * 15].reshape(-1, 15)
idx = np.loadtxt(os.path.join(raw, "weights_index.txt"), dtype=np.int32, ndmin=2)
d["w_pre"], d["w_post"] = idx[:, 0], idx[:, 1]
n = len(idx) + 1
for nm in ["g", "mini"]:
    w = np.fromfile(os.path.join(raw, f"weights_{nm}.f32"), dtype=np.float32)
    w = w[: len(w) // n * n].reshape(-1, n)
    d[f"w_{nm}_t"], d[f"w_{nm}"] = w[:, 0], w[:, 1:]
d["protocol_used"] = np.array(open(os.path.join(raw, "protocol_used.txt")).read())
np.savez_compressed(os.path.join("out", run_id + ".npz"), **d)
meta["n_spikes"] = int(len(sp))
for l in log.splitlines():
    if l.startswith(("CKPT_SAVED", "CKPT_LOADED", "CKPT_PARAM_OVERRIDE")): meta.setdefault("ckpt_log", []).append(l)
if ckpt_name:
    import shutil
    shutil.copy2(os.path.join(raw, ckpt_name), os.path.join("out", run_id + "_" + ckpt_name))
    meta["ckpt_saved_sha256"] = hashlib.sha256(open(os.path.join(raw, ckpt_name), "rb").read()).hexdigest()
meta["run_id"] = run_id
json.dump(meta, open(os.path.join("out", run_id + ".json"), "w"), indent=1)
for f in ["sim_stdout.log", "sim_stderr.log"]:
    lines = open(f).read().splitlines()
    open(os.path.join("out", run_id + "_" + f), "w").write("\n".join(lines[:80] + ["..."] + lines[-40:]))
# persist to a Modal Volume (or any directory) named by WEI_PERSIST_DIR, so results
# survive even if the host is offline when the job ends and the harvest never happens
pdir = os.environ.get("WEI_PERSIST_DIR")
if pdir:
    import shutil
    dst = os.path.join(pdir, run_id); os.makedirs(dst, exist_ok=True)
    for f in os.listdir("out"):
        if f.startswith(run_id):
            shutil.copy2(os.path.join("out", f), os.path.join(dst, f))   # copy2: /work -> /vol is cross-device
    open(os.path.join(dst, "PERSISTED"), "w").write(time.strftime("%Y-%m-%dT%H:%M:%SZ", time.gmtime()))
    print("PERSISTED", dst, flush=True)
print("DONE", run_id, "spikes", len(sp), "lfp", d["lfp"].shape, "w", d["w_g"].shape, flush=True)
