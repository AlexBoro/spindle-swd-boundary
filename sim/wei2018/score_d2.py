"""Stage 2 D2 scoring (N3 STDP factor 0.75; N2+N3 also with full N2 STDP), tag d2.
Compares with the original Fig 3 runs (N3 factor 0.5, N2 halved) and with D1 (N2 full, N3 0.5).
Run from the directory holding hpc/d2/ (fetched run files) and the spindle-swd-boundary checkout; writes d2/."""
import glob, os, re, json, subprocess, sys
import numpy as np, pandas as pd
from scipy import stats
R = "spindle-swd-boundary"; os.makedirs("d2/s1", exist_ok=True)
rows = []
for f in sorted(set(glob.glob("hpc/d2/**/fig3_n*_s[0-9]_*.npz", recursive=True))):
    m = re.match(r"fig3_(n2n3|n3)_s(\d)_([0-9a-f]{6})\.npz", os.path.basename(f))
    if m: rows.append(dict(condition=m.group(1), seed=int(m.group(2)), npz=f))
runs = pd.DataFrame(rows).drop_duplicates(["condition", "seed"]).sort_values(["condition", "seed"]); runs.to_csv("d2/runs_d2.csv", index=False)
print("runs:", runs.groupby("condition").seed.apply(list).to_dict())
subprocess.run([sys.executable, f"{R}/sim/wei2018/score_fig3.py", "d2/runs_d2.csv", "d2/fig3_d2"], check=True, capture_output=True)
new = pd.read_csv("d2/fig3_d2/per_run.csv")
orig = pd.read_csv(f"{R}/sweeps/wei2018_fig3/per_run.csv")
d1 = pd.read_csv(f"{R}/sweeps/wei2018_stage2/d1/fig3_paired.csv")
cols = ["dw_after_sleep", "perf_after_sleep"]
m = new[["condition", "seed"] + cols].rename(columns={c: c + "_d2" for c in cols})
m = m.merge(orig[["condition", "seed"] + cols].rename(columns={c: c + "_orig" for c in cols}), on=["condition", "seed"])
d1r = d1[d1.condition == "n2n3"][["condition", "seed", "dw_after_sleep_f1", "perf_after_sleep_f1"]].rename(columns={"dw_after_sleep_f1": "dw_after_sleep_d1", "perf_after_sleep_f1": "perf_after_sleep_d1"})
m = m.merge(d1r, on=["condition", "seed"], how="left"); m.to_csv("d2/fig3_paired_d2.csv", index=False)
pc = pd.DataFrame([json.load(open(f)) for f in glob.glob("hpc/d2/**/prefix_check_*d2_s[0-9].json", recursive=True)]).drop_duplicates("run")
pc.to_csv("d2/prefix_checks_d2.csv", index=False)
for f in glob.glob("hpc/d2/**/stage1_curve_*d2_s[0-9]_block_*.npz", recursive=True):
    dst = f"d2/s1/{os.path.basename(f)}"
    if not os.path.exists(dst): os.symlink(os.path.abspath(f), dst)
subprocess.run([sys.executable, f"{R}/sim/wei2018/score_stage1.py", "d2/s1", "d2/stage1_trials_d2.csv"], check=True, capture_output=True)
def per_seed(t, strip):
    t = t.assign(cond=t.wset.str.replace(strip, "", regex=False), succ=(t.sm >= 0.8) * 100.0, exact=(t.sm == 1) * 100.0)
    return t.groupby(["cond", "seed"])[["succ", "exact"]].mean()
t2 = per_seed(pd.read_csv("d2/stage1_trials_d2.csv"), "d2").add_suffix("_d2")
t0 = pd.read_csv(f"{R}/sweeps/wei2018_stage1/stage1_trials.csv"); t0 = per_seed(t0[t0.protocol == "stage1_curve"], "@@").add_suffix("_orig")
t1 = per_seed(pd.read_csv(f"{R}/sweeps/wei2018_stage2/d1/stage1_trials_f1.csv"), "f1").add_suffix("_d1")
rc = t2.join(t0, how="left").join(t1, how="left").reset_index(); rc.to_csv("d2/recall_paired_d2.csv", index=False)
PAPER = {"dw": {"n3": 65.0, "n2n3": 53.0}, "perf": {"n3": 64.0, "n2n3": 49.0}}
def pt(a, b):
    k = ~(np.isnan(a) | np.isnan(b)); return stats.ttest_rel(a[k], b[k]).pvalue if k.sum() > 1 else np.nan
out = []
for c in ["n3", "n2n3"]:
    a = m[m.condition == c]; r = rc[rc.cond == c]
    for met, key, d2c, oc, d1c in [("dw forward after sleep (%)", "dw", "dw_after_sleep_d2", "dw_after_sleep_orig", "dw_after_sleep_d1"),
                                   ("in-run recall after sleep, SM>=0.8 (%)", "perf", "perf_after_sleep_d2", "perf_after_sleep_orig", "perf_after_sleep_d1")]:
        x = a[d2c].values; o = a[oc].values; p1 = a[d1c].values if c == "n2n3" else np.full(len(a), np.nan)
        out.append(dict(cond=c, metric=met, orig=o.mean(), d1=np.nanmean(p1) if c == "n2n3" else np.nan, d2=x.mean(), d2_sd=x.std(ddof=1),
                        p_vs_orig=pt(x, o), p_vs_d1=pt(x, p1), paper=PAPER[key][c], n=len(a)))
    for met, col in [("fresh-state recall, SM>=0.8 (%)", "succ"), ("fresh-state recall, exact ABCDE (%)", "exact")]:
        x = r[col + "_d2"].values; o = r[col + "_orig"].values; p1 = r[col + "_d1"].values if c == "n2n3" else np.full(len(r), np.nan)
        out.append(dict(cond=c, metric=met, orig=o.mean(), d1=np.nanmean(p1) if c == "n2n3" else np.nan, d2=x.mean(), d2_sd=x.std(ddof=1),
                        p_vs_orig=pt(x, o), p_vs_d1=pt(x, p1), paper=np.nan, n=len(r)))
S = pd.DataFrame(out); S.to_csv("d2/d2_contrasts.csv", index=False)
pd.set_option("display.width", 250); print(S.round(3).to_string(index=False))
print("prefix all identical:", len(pc), bool(pc.prefix_spikes_identical.all() and pc.prefix_weights_identical.all()))
print(m.round(1).to_string(index=False)); print(rc.round(1).to_string(index=False))
