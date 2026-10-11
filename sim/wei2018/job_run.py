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
"""
import hashlib, json, os, re, subprocess, sys, tarfile, time
import numpy as np

src, proto, seed, threads = sys.argv[1], sys.argv[2], int(sys.argv[3]), int(sys.argv[4])
extra = sys.argv[5:]
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
subprocess.run(["make", "-s", "mindcurrent"], cwd=M, check=True)
subprocess.run("g++ -O2 generate_network.cpp -o generate_network 2>/dev/null && "
               "./generate_network > connection_info2 2>gen.log", shell=True, cwd=M, check=True)
meta["binary_sha256"] = hashlib.sha256(open(os.path.join(M, "mindcurrent"), "rb").read()).hexdigest()

pfile = os.path.join(M, "protocols", proto + ".txt")
tmax = int(re.search(r"tmax = (\d+) ms", open(pfile).read()).group(1)) if "tmax =" in open(pfile).read() else None
args = ["-sim_seed", str(seed), "-num_mp_threads", str(threads)]
if tmax is not None and "-tmax" not in extra:
    args += ["-tmax", str(tmax)]
args += extra
meta["args"] = args
run_id = f"{proto}_s{seed}" + ("_" + hashlib.sha1(" ".join(extra).encode()).hexdigest()[:6] if extra else "")
raw = os.path.abspath("raw"); os.makedirs(raw, exist_ok=True)
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
order = np.lexsort((sp[:, 2], sp[:, 0])) if len(sp) else np.arange(0)
sp = sp[order]
d["spk_t"] = sp[:, 0].astype(np.float64)
d["spk_type"] = sp[:, 1].astype(np.int8)
d["spk_m"] = sp[:, 2].astype(np.int16)
lfp = np.fromfile(os.path.join(raw, "lfp.f32"), dtype=np.float32)
d["lfp"] = lfp[: len(lfp) // 5 * 5].reshape(-1, 5)
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
meta["run_id"] = run_id
json.dump(meta, open(os.path.join("out", run_id + ".json"), "w"), indent=1)
for f in ["sim_stdout.log", "sim_stderr.log"]:
    lines = open(f).read().splitlines()
    open(os.path.join("out", run_id + "_" + f), "w").write("\n".join(lines[:80] + ["..."] + lines[-40:]))
print("DONE", run_id, "spikes", len(sp), "lfp", d["lfp"].shape, "w", d["w_g"].shape, flush=True)
