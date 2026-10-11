"""Score Wei 2018 Fig 2/3 reproduction runs.

usage: python sim/wei2018/score_fig3.py <runs.csv> <out_dir>
runs.csv columns: condition, seed, npz (path to the reduced run file)

Writes <out_dir>/per_run.csv, <out_dir>/criteria.csv and <out_dir>/fig3_reproduction.png.
Paper time t = file time - 12 s (warm-up).
"""
import sys, os, csv
import numpy as np
from scipy import stats

sys.path.insert(0, os.path.join(os.path.dirname(__file__), "..", ".."))
from analysis import wei2018 as W

W0 = 12000.0
SLEEP = (W0 + 200000, W0 + 500000)
N2N3_SPLIT = W0 + 350000
TARGET = {  # read off Wei 2018 Fig 2E and Fig 3B/C (approximate, from the figure)
    "perf_before": 13.8, "perf_after_train": 22.6,
    "perf_after_sleep": {"n2n3": 49.0, "awake": 24.0, "n2": 30.0, "n3": 64.0},
    "dw_after_train": 25.0,
    "dw_after_sleep": {"n2n3": 53.0, "awake": 27.0, "n2": 35.0, "n3": 65.0},
}


def score_run(path, cond):
    d = W.load(path)
    rec = W.recall_performance(d, 1)
    assert len(rec) == 3, f"{path}: expected 3 test sessions, got {len(rec)}"
    t, fwd, rev = W.weight_change(d, 1)

    def dw_at(tt):
        return float(fwd[np.argmin(np.abs(t - tt))])

    out = {"perf_before": 100 * rec[0]["perf"], "perf_after_train": 100 * rec[1]["perf"],
           "perf_after_sleep": 100 * rec[2]["perf"],
           "sm_before": rec[0]["mean_sm"], "sm_after_train": rec[1]["mean_sm"], "sm_after_sleep": rec[2]["mean_sm"],
           "dw_after_train": dw_at(W0 + 150000), "dw_sleep_start": dw_at(SLEEP[0]),
           "dw_after_sleep": dw_at(SLEEP[1]), "dw_end": float(fwd[-1]),
           "dw_rev_after_sleep": float(rev[np.argmin(np.abs(t - SLEEP[1]))]),
           "awake_py_rate": W.rate(d, W.PY, W0 + 150000, W0 + 200000, 500)}
    rp = W.replay_summary(d, 1, *SLEEP)
    out.update({f"replay_{k}": v for k, v in rp.items()})
    if cond == "n2n3":
        for nm, (a, b) in {"n2": (SLEEP[0], N2N3_SPLIT), "n3": (N2N3_SPLIT, SLEEP[1])}.items():
            r = W.replay_summary(d, 1, a, b)
            out[f"replay_{nm}part_n_correct"] = r["n_correct"]
            out[f"replay_{nm}part_frac_correct"] = r["frac_correct"]
    out["_traj"] = (t, fwd)
    return out


def main(runs_csv, out_dir):
    os.makedirs(out_dir, exist_ok=True)
    rows = list(csv.DictReader(open(runs_csv)))
    res = []
    for r in rows:
        s = score_run(r["npz"], r["condition"])
        s["condition"], s["seed"] = r["condition"], int(r["seed"])
        res.append(s)
    keys = [k for k in res[0] if not k.startswith("_") and k not in ("condition", "seed")]
    allk = sorted({k for s in res for k in s if not k.startswith("_")} - {"condition", "seed"})
    with open(os.path.join(out_dir, "per_run.csv"), "w", newline="") as f:
        w = csv.writer(f)
        w.writerow(["condition", "seed"] + allk)
        for s in sorted(res, key=lambda s: (s["condition"], s["seed"])):
            w.writerow([s["condition"], s["seed"]] + [s.get(k, "") for k in allk])

    conds = ["n2n3", "awake", "n2", "n3"]
    by = {c: [s for s in res if s["condition"] == c] for c in conds}
    crit = []

    def add(cid, claim, value, target, verdict, note=""):
        crit.append({"id": cid, "claim": claim, "measured": value, "paper": target, "verdict": verdict, "note": note})

    def ms(x):
        x = np.asarray(x, float)
        return f"{x.mean():.1f} +/- {x.std(ddof=1) / np.sqrt(len(x)):.1f} (n={len(x)})" if len(x) > 1 else f"{x.mean():.1f} (n={len(x)})"

    # Fig 2E: three test sessions (pool all conditions for before/after training; N2+N3 for after sleep)
    pool = res
    pb = [s["perf_before"] for s in pool]; pt = [s["perf_after_train"] for s in pool]
    add("F2E.1", "training raises recall above baseline", f"{ms(pb)} -> {ms(pt)}",
        f"{TARGET['perf_before']} -> {TARGET['perf_after_train']} %",
        "PASS" if (len(pb) > 1 and stats.ttest_rel(pt, pb).pvalue < 0.05 and np.mean(pt) > np.mean(pb)) else "FAIL",
        f"paired t p={stats.ttest_rel(pt, pb).pvalue:.2g}" if len(pb) > 1 else "")
    for c in conds:
        g = by[c]
        if not g:
            continue
        a = [s["perf_after_train"] for s in g]; b = [s["perf_after_sleep"] for s in g]
        p = stats.ttest_rel(b, a).pvalue if len(g) > 1 else np.nan
        sig_up = (np.mean(b) > np.mean(a)) and p < 0.05
        expect_up = c != "awake"
        add(f"F3C.{c}", f"recall after {c} vs after training", f"{ms(a)} -> {ms(b)}",
            f"{TARGET['perf_after_train']} -> {TARGET['perf_after_sleep'][c]} %",
            "PASS" if sig_up == expect_up else "FAIL", f"paired t p={p:.2g}; paper: {'increase' if expect_up else 'n.s.'}")
        dt = [s["dw_after_train"] for s in g]; ds = [s["dw_after_sleep"] for s in g]
        add(f"F3B.{c}", f"synaptic change after training -> after {c}", f"{ms(dt)} -> {ms(ds)}",
            f"{TARGET['dw_after_train']} -> {TARGET['dw_after_sleep'][c]} %", "INFO")
    # ordering claims
    if all(by[c] for c in conds):
        gain = {c: np.mean([s["perf_after_sleep"] - s["perf_after_train"] for s in by[c]]) for c in conds}
        add("F3C.order", "recall gain N3 > N2+N3 > N2 > awake", " / ".join(f"{c} {gain[c]:+.1f}" for c in ["n3", "n2n3", "n2", "awake"]),
            "n3 +41 / n2n3 +26 / n2 +7 / awake +1", "PASS" if gain["n3"] > gain["n2"] > gain["awake"] and gain["n2n3"] > gain["awake"] else "FAIL",
            "the paper's ordering; strict n2n3 position not required")
        rep = {c: [s["replay_frac_correct"] for s in by[c]] for c in conds}
        ok = all(np.mean(rep[c]) > np.mean(rep["awake"]) for c in ["n2n3", "n2", "n3"])
        add("F3E.1", "fraction of correct replay higher in every sleep condition than awake",
            " / ".join(f"{c} {np.mean(rep[c]):.2f}" for c in conds), "n2n3 ~0.42 / awake 0 / n2 ~0.2 / n3 ~0.47",
            "PASS" if ok else "FAIL")
        add("F3E.2", "more correct replays in N3-only than N2-only",
            f"n3 {np.mean([s['replay_n_correct'] for s in by['n3']]):.0f} vs n2 {np.mean([s['replay_n_correct'] for s in by['n2']]):.0f}",
            "N3 > N2", "PASS" if np.mean([s['replay_n_correct'] for s in by['n3']]) > np.mean([s['replay_n_correct'] for s in by['n2']]) else "FAIL")
    with open(os.path.join(out_dir, "criteria.csv"), "w", newline="") as f:
        w = csv.DictWriter(f, fieldnames=["id", "claim", "measured", "paper", "verdict", "note"])
        w.writeheader(); w.writerows(crit)
    make_figure(res, by, conds, os.path.join(out_dir, "fig3_reproduction.png"))
    return res, crit


def make_figure(res, by, conds, path):
    import matplotlib
    matplotlib.use("Agg")
    import matplotlib.pyplot as plt
    col = {"n2n3": "#4d4d4d", "awake": "#d98c8c", "n2": "#6a3d7a", "n3": "#3b7d23"}
    lab = {"n2n3": "N2+N3", "awake": "awake (no sleep)", "n2": "N2 only", "n3": "N3 only"}
    fig, ax = plt.subplots(2, 4, figsize=(13, 6.2), gridspec_kw={"height_ratios": [1, 1]})
    for i, c in enumerate(conds):
        a = ax[0, i]
        for s in by[c]:
            t, f = s["_traj"]
            a.plot((t - W0) / 1000, f, color=col[c], lw=0.8, alpha=0.6)
        a.axvspan(50, 150, color="#f2b46b", alpha=0.3, lw=0)
        a.axvspan(200, 500, color=col[c], alpha=0.08, lw=0)
        a.axhline(TARGET["dw_after_sleep"][c], color=col[c], ls=":", lw=1)
        a.set_title(f"{lab[c]}: synaptic change", loc="left")
        a.set_xlabel("paper time (s)")
        if i == 0:
            a.set_ylabel("trained-direction\nweight change (%)")
        a = ax[1, i]
        x = np.arange(3)
        vals = np.array([[s["perf_before"], s["perf_after_train"], s["perf_after_sleep"]] for s in by[c]])
        if len(vals):
            a.bar(x, vals.mean(0), color=["#bbbbbb", "#888888", col[c]], width=0.6)
            for v in vals:
                a.plot(x, v, "o-", color="k", ms=2.5, lw=0.5, alpha=0.6)
        tgt = [TARGET["perf_before"], TARGET["perf_after_train"], TARGET["perf_after_sleep"][c]]
        a.plot(x, tgt, "_", color="#d62728", ms=22, mew=2)
        a.set_xticks(x); a.set_xticklabels(["before\ntraining", "after\ntraining", "after\n" + lab[c].split(" ")[0]])
        a.set_ylim(0, 100)
        if i == 0:
            a.set_ylabel("recall performance (% SM >= 0.8)")
    ax[1, 0].text(0.02, 0.97, "red tick = paper value", transform=ax[1, 0].transAxes, va="top", fontsize=7, color="#d62728")
    ax[0, 0].text(0.02, 0.97, "dotted = paper end value", transform=ax[0, 0].transAxes, va="top", fontsize=7)
    fig.tight_layout()
    fig.savefig(path, dpi=200)


if __name__ == "__main__":
    res, crit = main(sys.argv[1], sys.argv[2])
    for c in crit:
        print(c["id"], c["verdict"], "|", c["measured"], "| paper", c["paper"], "|", c["note"])
