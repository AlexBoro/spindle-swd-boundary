"""Eye-inspection figures for Wei 2018 runs (Stage 3 SWD screen validation).

Works on the reduced run npz written by job_run.py (spk_t, spk_type, spk_m, lfp). The model has no
EEG; following Wei et al. 2018 Fig 2b, the "LFP" here is the population-mean PY soma voltage
(lfp column 1, 1 ms sampling). Every spike of every population is saved, so rasters are exact.

  state_overview(panels, path)   Fig 2b-style row: one column per state, PY raster above LFP.
  inspect_window(d, t0, t1, ...) one candidate window: PY/TC/RE rasters, LFP, mean TC/RE voltage,
                                 PY population rate, and the SWD-screen windows (pass/fail) on top.
"""
import numpy as np
import matplotlib as mpl
import matplotlib.pyplot as plt
from scipy.ndimage import gaussian_filter1d

PY, IN, TC, RE = 4, 7, 2, 0
NCELL = {PY: 500, IN: 100, TC: 100, RE: 100}
LFP_COL = {PY: 1, IN: 2, TC: 3, RE: 4}
POP_NAME = {PY: "PY", IN: "IN", TC: "TC", RE: "RE"}
POP_COLOR = {PY: "#1f3a93", IN: "#5b8bd0", TC: "#b5651d", RE: "#6a3d9a"}
SWD_COLOR = "#d62728"   # alarm hue: screen-positive windows / episodes only


def load(path):
    d = np.load(path)
    return {k: d[k] for k in d.files}


def _sel(d, ty, t0, t1):
    k = (d["spk_type"] == ty) & (d["spk_t"] >= t0) & (d["spk_t"] < t1)
    return d["spk_t"][k], d["spk_m"][k]


def raster(ax, d, ty, t0, t1, ms=0.6, color=None, tref=None):
    """Spike raster of one population; x in s relative to tref (default t0)."""
    tref = t0 if tref is None else tref
    t, m = _sel(d, ty, t0, t1)
    ax.scatter((t - tref) / 1000, m, s=ms, marker="|" if len(t) < 2e4 else ".", lw=0.4,
               color=color or POP_COLOR[ty], rasterized=True)
    ax.set_ylim(NCELL[ty] - 0.5, -0.5)          # neuron 0 at the top, as in Wei Fig 2b
    ax.set_xlim(0, (t1 - t0) / 1000)


def lfp_trace(ax, d, t0, t1, ty=PY, color="k", lw=0.7, tref=None):
    tref = t0 if tref is None else tref
    L = d["lfp"]; k = (L[:, 0] >= t0) & (L[:, 0] < t1)
    ax.plot((L[k, 0] - tref) / 1000, L[k, LFP_COL[ty]], color=color, lw=lw)
    ax.set_xlim(0, (t1 - t0) / 1000)


def pop_rate(d, ty, t0, t1, bin_ms=5.0, sigma_ms=8.0):
    t, _ = _sel(d, ty, t0, t1)
    e = np.arange(t0, t1 + bin_ms, bin_ms)
    r, _ = np.histogram(t, e)
    r = r / NCELL[ty] / (bin_ms / 1000)                     # spikes / cell / s
    return e[:-1] + bin_ms / 2, gaussian_filter1d(r.astype(float), sigma_ms / bin_ms)


def _scalebar(ax, length_s, label, y=-0.06):
    """Time scale bar just below the axes (bottom-right), label underneath."""
    x1 = ax.get_xlim()[1]; x0 = x1 - length_s
    ax.plot([x0, x1], [y, y], transform=ax.get_xaxis_transform(), color="k", lw=1.5, clip_on=False)
    ax.text((x0 + x1) / 2, y - 0.04, label, transform=ax.get_xaxis_transform(), ha="center", va="top")


def state_overview(panels, path=None, width_in=7.2, scalebar_s=1.0):
    """panels: list of (label, d, t0_ms, t1_ms, annotation). Wei Fig 2b layout: PY raster over LFP."""
    n = len(panels)
    fig, axs = plt.subplots(2, n, figsize=(width_in, 2.9), gridspec_kw=dict(height_ratios=[2.2, 1], hspace=0.08, wspace=0.12),
                            squeeze=False)
    lo, hi = np.inf, -np.inf
    for j, (lab, d, t0, t1, note) in enumerate(panels):
        raster(axs[0, j], d, PY, t0, t1)
        axs[0, j].set_title(lab, loc="left")
        lfp_trace(axs[1, j], d, t0, t1)
        L = d["lfp"]; k = (L[:, 0] >= t0) & (L[:, 0] < t1)
        lo, hi = min(lo, L[k, 1].min()), max(hi, L[k, 1].max())
        if note: axs[1, j].text(0.02, 0.97, note, transform=axs[1, j].transAxes, va="top", ha="left")
        for ax in axs[:, j]:
            ax.set_xticks([])
            for s in ("top", "right", "bottom"): ax.spines[s].set_visible(False)
        if j:
            axs[0, j].set_yticklabels([]); axs[1, j].set_yticklabels([])
    pad = 0.05 * (hi - lo)
    for ax in axs[1]: ax.set_ylim(lo - pad, hi + pad)
    axs[0, 0].set_ylabel("PY neuron"); axs[1, 0].set_ylabel("LFP (mV)")
    axs[0, 0].set_yticks([0, 250, 499])
    _scalebar(axs[1, -1], scalebar_s, f"{scalebar_s:g} s")
    if path: fig.savefig(path, dpi=300, bbox_inches="tight")
    return fig


def inspect_window(d, t0, t1, windows=None, episodes=None, title=None, path=None, width_in=7.2):
    """One candidate window. windows: SWD-screen rows (dicts with t0, t1, f0, swd) from swd_wei.screen;
    episodes: list of (a, b) ms. Rows: screen strip, PY/TC/RE rasters, LFP, mean TC/RE V, PY rate."""
    hr = [0.35, 2.0, 0.8, 0.8, 0.9, 0.9, 0.7]
    fig, ax = plt.subplots(len(hr), 1, figsize=(width_in, 6.6), sharex=True, gridspec_kw=dict(height_ratios=hr, hspace=0.12))
    x = lambda t: (np.asarray(t) - t0) / 1000
    # screen strip: each 2 s window's dominant frequency, red if it passed all four criteria
    a = ax[0]
    if windows:
        w = [r for r in windows if r["t1"] > t0 and r["t0"] < t1]
        c = [(r["t0"] + r["t1"]) / 2 for r in w]
        a.scatter(x(c), [r["f0"] for r in w], s=6, c=[SWD_COLOR if r["swd"] else "0.6" for r in w], zorder=3)
        a.axhspan(2, 5.5, color=SWD_COLOR, alpha=0.08, lw=0)
        a.set_ylim(0, 15); a.set_yticks([0, 5.5, 15]); a.set_yticklabels(["0", "5.5", "15"]); a.set_ylabel("f₀ (Hz)")
        a.text(1.005, 0.75, "● passes all 4", color=SWD_COLOR, transform=a.transAxes, va="center", fontsize=6)
        a.text(1.005, 0.25, "● fails", color="0.6", transform=a.transAxes, va="center", fontsize=6)
    else:
        a.set_axis_off()
    raster(ax[1], d, PY, t0, t1); ax[1].set_ylabel("PY"); ax[1].set_yticks([0, 499])
    raster(ax[2], d, TC, t0, t1); ax[2].set_ylabel("TC"); ax[2].set_yticks([0, 99])
    raster(ax[3], d, RE, t0, t1); ax[3].set_ylabel("RE"); ax[3].set_yticks([0, 99])
    lfp_trace(ax[4], d, t0, t1); ax[4].set_ylabel("LFP\n(mV)")
    lfp_trace(ax[5], d, t0, t1, ty=TC, color=POP_COLOR[TC]); lfp_trace(ax[5], d, t0, t1, ty=RE, color=POP_COLOR[RE])
    ax[5].set_ylabel("mean V\n(mV)")
    ax[5].text(1.005, 0.7, "TC", color=POP_COLOR[TC], transform=ax[5].transAxes, va="center")
    ax[5].text(1.005, 0.3, "RE", color=POP_COLOR[RE], transform=ax[5].transAxes, va="center")
    tr, r = pop_rate(d, PY, t0, t1); ax[6].plot(x(tr), r, color=POP_COLOR[PY], lw=0.6)
    ax[6].set_ylabel("PY rate\n(Hz)"); ax[6].set_xlabel(f"time from {t0 / 1000:g} s (s)")
    for e0, e1 in (episodes or []):
        if e1 > t0 and e0 < t1:
            for k in range(1, len(hr)): ax[k].axvspan(x(max(e0, t0)), x(min(e1, t1)), color=SWD_COLOR, alpha=0.10, lw=0)
    for k in range(len(hr)):
        ax[k].spines["top"].set_visible(False); ax[k].spines["right"].set_visible(False)
    ax[-1].set_xlim(0, (t1 - t0) / 1000)
    if title: ax[0].set_title(title, loc="left")
    fig.align_ylabels(ax)
    if path: fig.savefig(path, dpi=300, bbox_inches="tight")
    return fig
