"""In-container driver for several Wei 2018 runs that share a prefix (exact checkpoint/fork).

usage: python job_fork.py <src.tar.gz> <seed> <threads> <fork_at_ms> <child_threads> <child> [<child> ...] [-- common params]

  <child> = <protocol>[:<param>=<value>,<param>=<value>...]   e.g.  fig3_n2:stdp_factor_n2=1

The model is compiled and the network generated exactly as in job_run.py.  One mindcurrent process
simulates [0, fork_at) with <threads> OpenMP threads (using the FIRST child's protocol), then fork()s
one process per child (model/wei2018/fork.cpp); each child continues with its own protocol and
parameter overrides on <child_threads> threads.  Every protocol must agree before fork_at (checked
in C++).  Each child's output is reduced to out/<run_id>.npz + .json with the same run_id that
job_run.py would give the unforked run, so results are interchangeable with unforked runs.
"""
import hashlib, json, os, re, subprocess, sys, tarfile, time
import numpy as np

src, seed, threads, fork_at, cthreads = sys.argv[1], int(sys.argv[2]), int(sys.argv[3]), float(sys.argv[4]), int(sys.argv[5])
rest = sys.argv[6:]
common = rest[rest.index("--") + 1:] if "--" in rest else []
specs = rest[:rest.index("--")] if "--" in rest else rest
work = os.path.abspath("build"); os.makedirs(work, exist_ok=True); os.makedirs("out", exist_ok=True)
with tarfile.open(src) as t:
    t.extractall(work)
M = os.path.join(work, "model", "wei2018")
meta0 = {"seed": seed, "threads": threads, "fork_at": fork_at, "child_threads": cthreads, "common": common,
         "src_sha256": hashlib.sha256(open(src, "rb").read()).hexdigest()}
if os.path.exists(os.path.join(work, "GIT_SHA")):
    meta0["git_sha"] = open(os.path.join(work, "GIT_SHA")).read().strip()
meta0["gxx"] = subprocess.run(["g++", "--version"], capture_output=True, text=True).stdout.splitlines()[0]
subprocess.run("make -s mindcurrent > build.log 2>&1 || (cat build.log; exit 1)", shell=True, cwd=M, check=True)
subprocess.run("g++ -O2 generate_network.cpp -o generate_network 2>/dev/null && "
               "./generate_network > connection_info2 2>gen.log", shell=True, cwd=M, check=True)
meta0["binary_sha256"] = hashlib.sha256(open(os.path.join(M, "mindcurrent"), "rb").read()).hexdigest()

def tmax_of(proto):
    txt = open(os.path.join(M, "protocols", proto + ".txt")).read()
    m = re.search(r"tmax = (\d+) ms", txt); return int(m.group(1)) if m else None

kids = []
for s in specs:
    proto, _, ov = s.partition(":")
    extra = []
    for kv in [x for x in ov.split(",") if x]:
        k, v = kv.split("="); extra += ["-" + k, v]
    tm = tmax_of(proto)
    child_args = list(extra) + ([] if "-tmax" in extra or tm is None else ["-tmax", str(tm)])
    # run_id exactly as job_run.py names the unforked run (its tag = the extra args, without -tmax
    # when -tmax comes from the protocol header)
    tag = " ".join(common + extra)
    run_id = f"{proto}_s{seed}" + ("_" + hashlib.sha1(tag.encode()).hexdigest()[:6] if tag else "")
    kids.append({"proto": proto, "extra": extra, "args": child_args, "run_id": run_id})
assert len({k["run_id"] for k in kids}) == len(kids), "duplicate children"

raw0 = os.path.abspath("raw_prefix"); os.makedirs(raw0, exist_ok=True)
with open("fork_list.txt", "w") as f:
    for k in kids:
        d = os.path.abspath(k["run_id"]); os.makedirs(os.path.join(d, "raw"), exist_ok=True)
        k["dir"] = d
        f.write(" ".join([k["run_id"], os.path.join(d, "raw"), os.path.join(d, "sim_stdout.log"),
                          os.path.join(M, "protocols", k["proto"] + ".txt")] + k["args"]) + "\n")
first = kids[0]["proto"]
tmax_all = max(int(k["args"][k["args"].index("-tmax") + 1]) for k in kids if "-tmax" in k["args"])
args = ["-sim_seed", str(seed), "-num_mp_threads", str(threads), "-tmax", str(tmax_all),
        "-fork_at", str(fork_at), "-fork_threads", str(cthreads)] + common
env = dict(os.environ, WEI_FORK_LIST=os.path.abspath("fork_list.txt"))
t0 = time.time()
with open("parent_stdout.log", "w") as so, open("parent_stderr.log", "w") as se:
    rc = subprocess.run([os.path.join(M, "mindcurrent"), os.path.join(M, "wei2018_params.txt"), raw0 + "/",
                         os.path.join(M, "connection_info2"), os.path.join(M, "protocols", first + ".txt")] + args,
                        stdout=so, stderr=se, env=env).returncode
print("PARENT RC", rc, "wall_s", round(time.time() - t0), flush=True)

def reduce(raw, run_id, meta):
    d = {}
    sp = np.loadtxt(os.path.join(raw, "spike_time"), ndmin=2) if os.path.getsize(os.path.join(raw, "spike_time")) else np.zeros((0, 4))
    order = np.lexsort((sp[:, 2], sp[:, 1], sp[:, 0])) if len(sp) else np.arange(0)
    sp = sp[order]
    d["spk_t"] = sp[:, 0].astype(np.float64); d["spk_type"] = sp[:, 1].astype(np.int8); d["spk_m"] = sp[:, 2].astype(np.int16)
    lfp = np.fromfile(os.path.join(raw, "lfp.f32"), dtype=np.float32); d["lfp"] = lfp[: len(lfp) // 5 * 5].reshape(-1, 5)
    ra = os.path.join(raw, "rec_area.f32")
    if os.path.exists(ra):
        a = np.fromfile(ra, dtype=np.float32); d["rec_area"] = a[: len(a) // 15 * 15].reshape(-1, 15)
    idx = np.loadtxt(os.path.join(raw, "weights_index.txt"), dtype=np.int32, ndmin=2)
    d["w_pre"], d["w_post"] = idx[:, 0], idx[:, 1]
    n = len(idx) + 1
    for nm in ["g", "mini"]:
        w = np.fromfile(os.path.join(raw, f"weights_{nm}.f32"), dtype=np.float32); w = w[: len(w) // n * n].reshape(-1, n)
        d[f"w_{nm}_t"], d[f"w_{nm}"] = w[:, 0], w[:, 1:]
    d["protocol_used"] = np.array(open(os.path.join(raw, "protocol_used.txt")).read())
    np.savez_compressed(os.path.join("out", run_id + ".npz"), **d)
    meta["n_spikes"] = int(len(sp)); meta["run_id"] = run_id
    json.dump(meta, open(os.path.join("out", run_id + ".json"), "w"), indent=1)
    return d

pdir = os.environ.get("WEI_PERSIST_DIR")
for k in kids:
    log = open(os.path.join(k["dir"], "sim_stdout.log")).read()
    meta = dict(meta0, protocol=k["proto"], extra=k["extra"], args=k["args"])
    meta["completed"] = "Computation time" in log
    last = re.findall(r"milliseconds of sim = ([0-9.]+)", log); meta["last_ms"] = float(last[-1]) if last else None
    ct = re.findall(r"Computation time: (\d+) s", log); meta["child_wall_s"] = int(ct[-1]) if ct else None
    try:
        d = reduce(os.path.join(k["dir"], "raw"), k["run_id"], meta)
        print("DONE", k["run_id"], "completed", meta["completed"], "spikes", meta["n_spikes"], "child_wall_s", meta["child_wall_s"], flush=True)
    except Exception as e:
        print("REDUCE FAILED", k["run_id"], repr(e), flush=True); continue
    lines = log.splitlines()
    open(os.path.join("out", k["run_id"] + "_sim_stdout.log"), "w").write("\n".join(lines[:80] + ["..."] + lines[-40:]))
    if pdir:
        import shutil
        dst = os.path.join(pdir, k["run_id"]); os.makedirs(dst, exist_ok=True)
        for f in os.listdir("out"):
            if f.startswith(k["run_id"]): shutil.copy2(os.path.join("out", f), os.path.join(dst, f))
        open(os.path.join(dst, "PERSISTED"), "w").write(time.strftime("%Y-%m-%dT%H:%M:%SZ", time.gmtime()))
sys.exit(0 if rc == 0 else 1)
