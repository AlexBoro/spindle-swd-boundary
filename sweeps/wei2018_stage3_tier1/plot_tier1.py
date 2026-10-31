# Stage 3 tier-1 summary figure: per-axis response of N2 and awake branches, 3 seeds, both SWD bands.
# Expects DataFrame D2 (one row per branch x seed; columns state, axis, val, rate_PY, swd_s_human, swd_s_rodent).
import numpy as np, matplotlib.pyplot as plt
STATE_COL = {"n2": "#5b2a86", "awake": "#9a9a9a"}
STATE_LAB = {"n2": "N2", "awake": "awake"}
AX = [("A", "RE→TC inhibition (× baseline)", True, 1.0),
      ("B", "Ih activation shift (mV; + = less Ih)", False, 0.0),
      ("C", "cortical GABA-A (× baseline)", True, 1.0)]
ROWS = [("rate_PY", "PY rate (Hz)"),
        ("swd_s_rodent", "SWD-like time,\n7–11 Hz band (s / 60 s)"),
        ("swd_s_human", "SWD-like time,\n2–5.5 Hz band (s / 60 s)")]

def plot_tier1(D2, path, n_note):
    fig, axs = plt.subplots(len(ROWS), 3, figsize=(7.2, 5.6), sharey="row", gridspec_kw=dict(hspace=0.18, wspace=0.08))
    rng = np.random.default_rng(0)
    for j, (ax_id, xlab, logx, neutral) in enumerate(AX):
        for i, (col, ylab) in enumerate(ROWS):
            a = axs[i, j]
            for st in ("awake", "n2"):
                d = D2[(D2.axis == ax_id) & (D2.state == st)]
                if d.empty: continue
                x = np.log2(d.val) if logx else d.val
                jit = rng.uniform(-0.06, 0.06, len(d)) * (1 if logx else 1.5)
                a.scatter(x + jit, d[col], s=7, color=STATE_COL[st], alpha=0.55, lw=0, zorder=2)
                m = d.groupby("val")[col].mean()
                xm = np.log2(m.index) if logx else m.index
                a.plot(xm, m.values, color=STATE_COL[st], lw=1.3, zorder=3)
            a.axvline(np.log2(neutral) if logx else neutral, color="0.8", lw=0.6, zorder=1)
            if logx:
                tv = sorted(D2[D2.axis == ax_id].val.unique())
                a.set_xticks(np.log2(tv)); a.set_xticklabels([f"{v:g}" for v in tv])
            if i < len(ROWS) - 1: a.tick_params(labelbottom=False)
            else: a.set_xlabel(xlab)
            if j == 0: a.set_ylabel(ylab)
            a.spines["top"].set_visible(False); a.spines["right"].set_visible(False)
            a.margins(x=0.06)
    for i in (1, 2): axs[i, 0].set_ylim(-0.6, 16)
    axs[0, 0].text(0.03, 0.95, "N2", color=STATE_COL["n2"], transform=axs[0, 0].transAxes, va="top")
    axs[0, 0].text(0.03, 0.80, "awake", color=STATE_COL["awake"], transform=axs[0, 0].transAxes, va="top")
    axs[2, 0].text(0.03, 0.9, "0 in all branches", transform=axs[2, 0].transAxes, va="top", fontsize=6, color="0.35")
    for j, t in enumerate(["A  thalamic inhibition", "B  thalamic Ih", "C  cortical inhibition"]):
        axs[0, j].set_title(t, loc="left")
    fig.text(0.99, 0.005, n_note, ha="right", va="bottom", fontsize=6, color="0.35")
    fig.savefig(path, dpi=300, bbox_inches="tight")
    return fig
