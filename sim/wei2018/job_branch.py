"""Run many branches from one checkpoint on one host, then screen each for SWDs (Stage 3 tier 1).

usage: python job_branch.py <src.tar.gz> <checkpoint> <seed> <threads_per_run> <max_parallel> <spec.json>
spec.json: [{"name": ..., "protocol": "swd_n2_70s", "args": ["-gh_tc_n2", "0"], "cfg": ["RE:TC:GABA_B:strength=0.00001"]}, ...]
Each branch runs job_run.py in its own directory (so network.cfg overrides stay separate), loading
the checkpoint; outputs persist through WEI_PERSIST_DIR as usual. Afterwards every branch is screened
with analysis/swd_wei.py over [load time + SETTLE_MS, tmax) and the results go to
out/swd_tier1_s<seed>.csv (one row per branch) and out/swd_windows_s<seed>.csv (every window).
"""
import concurrent.futures as cf, glob, json, os, subprocess, sys, time
import numpy as np
src, ckpt, seed, thr, par, specf = sys.argv[1], os.path.abspath(sys.argv[2]), int(sys.argv[3]), int(sys.argv[4]), int(sys.argv[5]), sys.argv[6]
spec = json.load(open(specf)); here = os.path.dirname(os.path.abspath(__file__))
SETTLE_MS = float(os.environ.get("SWD_SETTLE_MS", "10000"))
os.makedirs("out", exist_ok=True)

def run(b):
    d = os.path.abspath(b["name"]); os.makedirs(d, exist_ok=True)
    cmd = [sys.executable, os.path.join(here, "job_run.py"), os.path.abspath(src), b["protocol"], str(seed), str(thr),
           "-plasticity_start", "1e12", "-stdp_factor_n2", "1", "-stdp_factor_n3", "0.75", "-ckpt_load_path", ckpt] + b.get("args", []) + ["@" + c for c in b.get("cfg", [])]
    t0 = time.time()
    with open(os.path.join(d, "run.log"), "w") as lg:
        rc = subprocess.run(cmd, cwd=d, stdout=lg, stderr=subprocess.STDOUT).returncode
    return b["name"], rc, time.time() - t0

with cf.ThreadPoolExecutor(par) as ex:
    for name, rc, w in ex.map(run, spec):
        print("BRANCH", name, "rc", rc, "wall_s", round(w), flush=True)

sys.path.insert(0, here)
import swd_wei as S
rows, wins = [], []
for b in spec:
    f = glob.glob(os.path.join(b["name"], "out", "*.npz"))
    if not f: rows.append(dict(name=b["name"], error="no npz")); continue
    d = np.load(f[0]); meta = json.load(open(f[0][:-4] + ".json"))
    t_load = float([l for l in meta.get("ckpt_log", []) if l.startswith("CKPT_LOADED")][0].split("t=")[1].split()[0])
    t_end = float(d["lfp"][-1, 0])
    out, w, eps = S.screen(d, t_load + SETTLE_MS, t_end)
    out.update(name=b["name"], protocol=b["protocol"], args=" ".join(b.get("args", [])), cfg=" ".join(b.get("cfg", [])),
               run_id=meta["run_id"], t0=t_load + SETTLE_MS, t1=t_end, episodes=json.dumps(eps),
               overrides=" | ".join(l for l in meta.get("ckpt_log", []) if "OVERRIDE" in l))
    rows.append(out)
    for x in w: x.update(name=b["name"]); wins.append(x)
import pandas as pd
pd.DataFrame(rows).to_csv(f"out/swd_tier1_s{seed}.csv", index=False)
pd.DataFrame(wins).to_csv(f"out/swd_windows_s{seed}.csv", index=False)
pdir = os.environ.get("WEI_PERSIST_DIR")
if pdir:
    import shutil
    for f in (f"out/swd_tier1_s{seed}.csv", f"out/swd_windows_s{seed}.csv"): shutil.copy2(f, os.path.join(pdir, os.path.basename(f)))
print("SCREENED", len(rows), flush=True)
