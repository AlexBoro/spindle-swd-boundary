"""Stage 2 D1 scoring (full N2 STDP, tag f1) against the Stage 1 / Fig 3 baselines.
Run from the directory holding hpc/ (fetched run files) and the spindle-swd-boundary checkout; writes d1/."""
import glob, os, re, json, subprocess, sys
import numpy as np, pandas as pd
from scipy import stats
R = "spindle-swd-boundary"
os.makedirs("d1", exist_ok=True)
# --- locate files
fig = sorted(set(glob.glob("hpc/**/fig3_n2*_s[0-9]_8c6045.npz", recursive=True)))
fig = {os.path.basename(f): f for f in fig}
rows = []
for b, f in fig.items():
    m = re.match(r"fig3_(n2n3|n2)_s(\d)_8c6045\.npz", b); rows.append(dict(condition=m.group(1), seed=int(m.group(2)), npz=f))
runs = pd.DataFrame(rows).sort_values(["condition", "seed"]); runs.to_csv("d1/runs_f1.csv", index=False)
print("fig3 runs:", runs.groupby("condition").seed.apply(list).to_dict())
subprocess.run([sys.executable, f"{R}/sim/wei2018/score_fig3.py", "d1/runs_f1.csv", "d1/fig3_f1"], check=True, capture_output=True)
new = pd.read_csv("d1/fig3_f1/per_run.csv"); old = pd.read_csv(f"{R}/sweeps/wei2018_fig3/per_run.csv")
cols = ["dw_after_train", "dw_sleep_start", "dw_after_sleep", "perf_after_train", "perf_after_sleep"]
m = new[["condition", "seed"] + cols].merge(old[["condition", "seed"] + cols], on=["condition", "seed"], suffixes=("_f1", "_old"))
m.to_csv("d1/fig3_paired.csv", index=False)
# --- prefix checks (from job logs)
pc = []
for f in glob.glob("hpc/**/prefix_check_*f1_s[0-9].json", recursive=True):
    pc.append(json.load(open(f)))
pc = pd.DataFrame(pc).drop_duplicates("run") if pc else pd.DataFrame()
pc.to_csv("d1/prefix_checks.csv", index=False)
# --- fresh-state recall tests
os.makedirs("d1/s1", exist_ok=True)
for f in glob.glob("hpc/**/stage1_curve_*f1_s[0-9]_block_*.npz", recursive=True):
    dst = f"d1/s1/{os.path.basename(f)}"
    if not os.path.exists(dst): os.symlink(os.path.abspath(f), dst)
subprocess.run([sys.executable, f"{R}/sim/wei2018/score_stage1.py", "d1/s1", "d1/stage1_trials_f1.csv"], check=True, capture_output=True)
t1 = pd.read_csv("d1/stage1_trials_f1.csv"); t0 = pd.read_csv(f"{R}/sweeps/wei2018_stage1/stage1_trials.csv")
t0 = t0[t0.protocol == "stage1_curve"]
t1["cond"] = t1.wset.str.replace("f1", ""); t0["cond"] = t0.wset
def per_seed(t):
    t = t.assign(succ=(t.sm >= 0.8) * 100.0, exact=(t.sm == 1) * 100.0)
    return t.groupby(["cond", "seed"])[["succ", "exact", "BE"]].mean().reset_index()
p1, p0 = per_seed(t1), per_seed(t0)
rc = p1.merge(p0, on=["cond", "seed"], suffixes=("_f1", "_old")); rc.to_csv("d1/recall_paired.csv", index=False)
# --- summary
PAPER_DW = {"n2": 35.0, "n2n3": 53.0}; PAPER_PERF = {"n2": 30.0, "n2n3": 49.0}
out = []
for c in ["n2", "n2n3"]:
    a = m[m.condition == c]; r = rc[rc.cond == c]
    def pt(x, y):
        return stats.ttest_rel(x, y).pvalue if len(x) > 1 else np.nan
    out.append(dict(cond=c, n_seeds=len(a), seeds=",".join(map(str, sorted(a.seed))),
        dw_f1=a.dw_after_sleep_f1.mean(), dw_f1_sd=a.dw_after_sleep_f1.std(), dw_old_same_seeds=a.dw_after_sleep_old.mean(),
        dw_diff=(a.dw_after_sleep_f1 - a.dw_after_sleep_old).mean(), dw_p=pt(a.dw_after_sleep_f1, a.dw_after_sleep_old), dw_paper=PAPER_DW[c],
        perf_inrun_f1=a.perf_after_sleep_f1.mean(), perf_inrun_old=a.perf_after_sleep_old.mean(), perf_paper=PAPER_PERF[c],
        n_recall_seeds=len(r), recall_f1=r.succ_f1.mean(), recall_old=r.succ_old.mean(), recall_diff=(r.succ_f1 - r.succ_old).mean(),
        recall_p=pt(r.succ_f1, r.succ_old), exact_f1=r.exact_f1.mean(), exact_old=r.exact_old.mean()))
S = pd.DataFrame(out); S.to_csv("d1/d1_summary.csv", index=False)
pd.set_option("display.width", 250); print(S.round(3).T.to_string())
print("prefix:", pc[["run", "prefix_spikes_identical", "prefix_weights_identical"]].to_string(index=False) if len(pc) else "none found")
