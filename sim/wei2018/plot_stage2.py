"""Stage 2 summary figure: original settings vs adopted settings (D1 + D2) against the paper, all four Fig 3 conditions.
Run from the directory holding the spindle-swd-boundary checkout (needs figure-style helpers apply_figure_style, panel_letter)."""
import pandas as pd, numpy as np, matplotlib.pyplot as plt
R = "spindle-swd-boundary"; S2 = f"{R}/sweeps/wei2018_stage2"
orig = pd.read_csv(f"{R}/sweeps/wei2018_fig3/per_run.csv")
d1 = pd.read_csv(f"{S2}/d1/fig3_paired.csv"); d2 = pd.read_csv(f"{S2}/d2/fig3_paired_d2.csv")
r1 = pd.read_csv(f"{S2}/d1/recall_paired.csv"); r2 = pd.read_csv(f"{S2}/d2/recall_paired_d2.csv")
t0 = pd.read_csv(f"{R}/sweeps/wei2018_stage1/stage1_trials.csv"); t0 = t0[t0.protocol == "stage1_curve"]
fresh0 = t0.assign(s=(t0.sm >= .8) * 100).groupby(["wset", "seed"]).s.mean()
CONDS = ["awake", "n2", "n2n3", "n3"]; LAB = {"awake": "Awake", "n2": "N2", "n2n3": "N2+N3", "n3": "N3"}
COL = {"awake": "#c98b9b", "n2": "#5b3a8c", "n2n3": "#4d4d4d", "n3": "#3d7a33"}
PAPER = {"dw": {"awake": 27, "n2": 35, "n2n3": 53, "n3": 65}, "perf": {"awake": 24, "n2": 30, "n2n3": 49, "n3": 64}}
def get(c, key):
    o = orig[orig.condition == c].sort_values("seed")
    if key == "fresh":
        yo = fresh0.loc[c].sort_index().values
        if c == "awake": return yo, yo
        if c == "n2": return yo, r1[r1.cond == "n2"].sort_values("seed").succ_f1.values
        return yo, r2[r2.cond == c].sort_values("seed").succ_d2.values
    col = {"dw": "dw_after_sleep", "perf": "perf_after_sleep"}[key]
    if c == "awake": return o[col].values, o[col].values
    if c == "n2": return o[col].values, d1[d1.condition == "n2"].sort_values("seed")[col + "_f1"].values
    return o[col].values, d2[d2.condition == c].sort_values("seed")[col + "_d2"].values
def plot(fig_path):
    apply_figure_style(sizes=(8, 7, 6))
    fig, axs = plt.subplots(1, 3, figsize=(7.1, 2.6)); fig.subplots_adjust(wspace=0.6)
    panels = [("dw", "Forward weight change\nafter sleep (%)", "Weight change matches the paper"),
              ("perf", "In-run recall after sleep\n(% trials SM ≥ 0.8)", "In-run recall: N3 still short"),
              ("fresh", "Fresh-state recall\n(% trials SM ≥ 0.8)", "Fresh-state recall keeps the order")]
    for ax, (key, ylab, title), L in zip(axs, panels, "abc"):
        for i, c in enumerate(CONDS):
            yo, yn = get(c, key); x0, x1 = i - 0.17, i + 0.17
            if c == "awake":
                ax.scatter([i] * len(yo), yo, s=12, color=COL[c], zorder=2); ax.hlines(yo.mean(), i - .1, i + .1, color=COL[c], lw=1.6, zorder=3)
            else:
                for a, b in zip(yo, yn): ax.plot([x0, x1], [a, b], color="0.8", lw=0.6, zorder=1)
                ax.scatter([x0] * len(yo), yo, s=12, color="#a8a8a8", zorder=2, label="original settings" if i == 1 else None)
                ax.scatter([x1] * len(yn), yn, s=12, color=COL[c], zorder=2, label="adopted settings (D1 + D2), coloured by condition" if i == 1 else None)
                ax.hlines(yo.mean(), x0 - .1, x0 + .1, color="#a8a8a8", lw=1.6, zorder=3); ax.hlines(yn.mean(), x1 - .1, x1 + .1, color=COL[c], lw=1.6, zorder=3)
            if key in PAPER: ax.hlines(PAPER[key][c], i - .32, i + .32, color="k", lw=0.9, ls=(0, (2, 1.5)), zorder=0, label="paper" if i == 0 else None)
        ax.set_xticks(range(4), [LAB[c] for c in CONDS]); ax.set_xlim(-0.5, 3.5); ax.set_ylabel(ylab)
        ax.set_title(title, loc="left", fontsize=7, pad=8); ax.margins(y=0.08); panel_letter(ax, L)
    h, l = axs[0].get_legend_handles_labels()
    fig.legend(h, l, frameon=False, loc="upper center", bbox_to_anchor=(0.5, -0.02), ncol=3, fontsize=7)
    fig.savefig(fig_path, dpi=300, bbox_inches="tight"); return fig
def table():
    rows = []
    for c in CONDS:
        for key in ["dw", "perf", "fresh"]:
            yo, yn = get(c, key)
            rows.append(dict(cond=c, metric=key, original=yo.mean(), adopted=yn.mean(), adopted_sd=yn.std(ddof=1), paper=PAPER.get(key, {}).get(c, np.nan), n=len(yn)))
    return pd.DataFrame(rows)
