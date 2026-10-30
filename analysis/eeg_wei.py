"""Simulated EEG for the Wei 2018 network (Stage 3), from the rec_eeg source currents.

The model writes, every 1 ms, for each of NB blocks of consecutive PY cells along the 1-D chain:
  ax  : summed dendro-somatic axial current (v_SOMA - v_DEND)/kappa  (uA; + = soma -> dendrite inside)
  syn : summed total synaptic current into the dendrites, -sum(I_syn) (+ = inward / depolarising)
  gab : summed IN->PY GABA_A current I (+ = outward), so the excitatory part is syn + gab
(main.cpp eeg_open). From these, three EEG estimates at virtual electrodes above the chain:

  dipole   : current-dipole far field of the two-compartment PY cells. Each block is a dipole
             p_b = ax_b * d oriented along the cortical depth axis (dendrite superficial), so a
             surface electrode at lateral offset x and height h sees  phi = sum_b p_b h / R^3.
             Sign: dendritic excitation (inward current at the dendrite, Vd > Vs, ax < 0) gives a
             surface-NEGATIVE deflection, the EEG convention.
  destexhe : Destexhe-style Coulomb sum of the synaptic current sources in the PY dendrites,
             phi = -sum_b syn_b / R  (an inward, excitatory current is a sink -> negative).
  erws1    : Martinez-Canada et al. 2021 (PLoS Comput Biol 17:e1008893) causal ERWS1 proxy on PY,
             |AMPA|(t) - 0.1 |GABA|(t - 3.1 ms), spatially weighted like the dipole and sign-flipped
             to the same convention. Their fit used AMPA/GABA_A LIF networks; here "AMPA" is all
             excitatory current (AMPA + NMDA), so this is a cross-check, not ground truth.

Units are arbitrary (cell spacing and dipole length are not specified by the model); traces are
compared after z-scoring. Geometry defaults: 20 um per PY cell along the chain (10 mm for 500
cells), electrodes 2 mm above the dendritic layer. A 40 Hz zero-phase low-pass is applied, as in
the Dervinis-Crunelli EEG forward model (analysis/eeg.py).
"""
import json
import numpy as np
from scipy import signal

DX_UM = 20.0
H_UM = 2000.0
LP_HZ = 40.0
FS = 1000.0


def load(d):
    """d: run npz/dict with 'eeg' and 'eeg_info'. Returns t (ms), ax, syn, gab (T x NB), info."""
    info = json.loads(str(d["eeg_info"]))
    nb = int(info["nb"]); E = np.asarray(d["eeg"], dtype=np.float64)
    blk = E[:, 1:1 + 3 * nb].reshape(len(E), nb, 3)
    return E[:, 0], blk[:, :, 0], blk[:, :, 1], blk[:, :, 2], info


def block_x(info, dx_um=DX_UM):
    nb, npy = int(info["nb"]), int(info["npy"])
    per = npy / nb
    return (np.arange(nb) + 0.5) * per * dx_um            # block centres along the chain (um)


def electrodes(info, n=5, dx_um=DX_UM):
    L = int(info["npy"]) * dx_um
    return (np.arange(n) + 0.5) / n * L                   # evenly spaced along the chain (um)


def _lp(x, hz=LP_HZ):
    b, a = signal.butter(4, hz / (FS / 2))
    return signal.filtfilt(b, a, x, axis=0)


def eeg(d, kind="dipole", ex=None, h_um=H_UM, dx_um=DX_UM, lowpass=True):
    """Returns t (ms), V (T x n_electrodes), electrode x positions (um)."""
    t, ax, syn, gab, info = load(d)
    xb = block_x(info, dx_um); ex = electrodes(info, dx_um=dx_um) if ex is None else np.asarray(ex)
    R = np.sqrt((xb[None, :] - ex[:, None]) ** 2 + h_um ** 2)          # n_el x NB
    if kind == "dipole":
        V = ax @ (h_um / R ** 3).T
    elif kind == "destexhe":
        V = -syn @ (1.0 / R).T
    elif kind == "erws1":
        exc = syn + gab; lag = int(round(3.1))                         # 1 ms samples
        g = np.vstack([np.repeat(gab[:1], lag, 0), gab[:-lag]])
        V = -(exc - 0.1 * g) @ (h_um / R ** 3).T
    else:
        raise ValueError(kind)
    if lowpass: V = _lp(V)
    return t, V, ex


def zscore(x, ref=None):
    ref = x if ref is None else ref
    return (x - ref.mean()) / ref.std()


# ---------------------------------------------------------------- figures
KIND_LAB = {"destexhe": "Destexhe", "dipole": "dipole", "erws1": "ERWS1"}
KIND_COL = {"destexhe": "#1b7837", "dipole": "#000000", "erws1": "#7f7f7f"}


def _rows_z(panels, key):
    """Pool every panel's trace for one row to z-score with a common reference (keeps relative amplitudes)."""
    xs = np.concatenate([p[key] for p in panels]); return xs.mean(), xs.std()


def calibration_figure(runs, path=None, width_in=7.2, electrode=2, kinds=("destexhe", "dipole", "erws1")):
    """runs: list of (label, d, t0_ms, t1_ms). Columns = runs; rows = PY raster, mean-V LFP, each EEG estimate
    at one electrode (index into the default 5). Each row is z-scored with one reference across columns."""
    import matplotlib.pyplot as plt
    from inspect_wei import raster, PY
    P = []
    for lab, d, t0, t1 in runs:
        L = d["lfp"]; k = (L[:, 0] >= t0) & (L[:, 0] < t1); p = dict(lab=lab, d=d, t0=t0, t1=t1, lfp_t=L[k, 0], lfp=L[k, 1])
        for kd in kinds:
            t, V, _ = eeg(d, kd); m = (t >= t0) & (t < t1); p[kd + "_t"], p[kd] = t[m], V[m, electrode]
        P.append(p)
    rows = [("lfp", "mean V\n(mV)")] + [(kd, KIND_LAB[kd]) for kd in kinds]
    fig, axs = plt.subplots(1 + len(rows), len(P), figsize=(width_in, 1.1 + 0.85 * len(rows)), squeeze=False,
                            gridspec_kw=dict(height_ratios=[2.0] + [1] * len(rows), hspace=0.12, wspace=0.14))
    for j, p in enumerate(P):
        raster(axs[0, j], p["d"], PY, p["t0"], p["t1"]); axs[0, j].set_title(p["lab"], loc="left")
        for i, (key, lab) in enumerate(rows, start=1):
            a = axs[i, j]; tt = p["lfp_t"] if key == "lfp" else p[key + "_t"]
            if key == "lfp": y = p["lfp"]
            else: mu, sd = _rows_z(P, key); y = (p[key] - mu) / sd
            a.plot((tt - p["t0"]) / 1000, y, color=KIND_COL.get(key, "k"), lw=0.6)
            a.set_xlim(0, (p["t1"] - p["t0"]) / 1000)
            if j == 0: a.set_ylabel(lab if key == "lfp" else lab + "\n(z)")
    for i in range(1 + len(rows)):
        lo = min(a.get_ylim()[0] for a in axs[i]); hi = max(a.get_ylim()[1] for a in axs[i])
        for j, a in enumerate(axs[i]):
            a.set_ylim(lo, hi); a.spines["top"].set_visible(False); a.spines["right"].set_visible(False)
            if j: a.set_yticklabels([])
            if i < len(rows): a.set_xticklabels([])
    axs[0, 0].set_ylabel("PY neuron"); axs[0, 0].set_yticks([0, 499])
    for a in axs[-1]:
        a.set_xlabel("time (s)"); xt = [v for v in a.get_xticks() if 0 <= v < a.get_xlim()[1] - 1e-9]; a.set_xticks(xt)
    axs[1, 0].figure.text(0.01, 0.005, "EEG: negative = surface-negative (dendritic inward current); electrode at the chain "
                          "midpoint, 2 mm above; 40 Hz low-pass", fontsize=6, color="0.35")
    if path: fig.savefig(path, dpi=300, bbox_inches="tight")
    return fig


def inspect_eeg(d, t0, t1, episodes=None, marks=None, zoom=None, title=None, path=None, kind="dipole",
                n_el=5, width_in=7.2):
    """Detector-validation view: EEG at n_el electrodes along the chain (stacked, z-scored with one reference),
    the second estimate overlaid on the middle electrode, PY/TC/RE rasters; episodes (list of (a, b) ms)
    shaded; marks (array of ms, e.g. detected spike times) as ticks on the EEG; zoom=(a, b) ms adds a
    close-up panel of the middle electrode over the PY raster."""
    import matplotlib.pyplot as plt
    from inspect_wei import raster, PY, TC, RE, SWD_COLOR
    t, V, ex = eeg(d, kind); m = (t >= t0) & (t < t1)
    mu, sd = V[m].mean(), V[m].std(); Z = (V - mu) / sd
    other = "destexhe" if kind == "dipole" else "dipole"
    t2, V2, _ = eeg(d, other); Z2 = (V2 - V2[m].mean()) / V2[m].std()
    hr = [2.6, 1.6, 0.6, 0.6] + ([1.8] if zoom else [])
    fig = plt.figure(figsize=(width_in, 6.8 if zoom else 5.4))
    gs = fig.add_gridspec(len(hr), 1, height_ratios=hr, hspace=0.18)
    a0 = fig.add_subplot(gs[0]); axs = [a0] + [fig.add_subplot(gs[i], sharex=a0) for i in (1, 2, 3)]
    x = lambda tt: (np.asarray(tt) - t0) / 1000
    off = 6.0; mid = n_el // 2
    for k in range(n_el):
        y = Z[m, k] - k * off
        axs[0].plot(x(t[m]), y, color=KIND_COL[kind], lw=0.5)
        axs[0].text(x(t1) + 0.005 * (t1 - t0) / 1000, -k * off, f"{ex[k] / 1000:.0f} mm", va="center", fontsize=6)
    axs[0].plot(x(t[m]), Z2[m, mid] - mid * off, color=KIND_COL[other], lw=0.5, alpha=0.8)
    axs[0].set_yticks([]); axs[0].set_ylabel("EEG (z)")
    axs[0].text(0.0, 1.0, f"{kind} EEG at 5 electrodes along the chain; {other} overlaid in colour at {ex[mid] / 1000:.0f} mm",
                transform=axs[0].transAxes, fontsize=6, color="0.35", va="bottom")
    if marks is not None:
        mk = np.asarray(marks); mk = mk[(mk >= t0) & (mk < t1)]
        axs[0].plot(x(mk), np.full(len(mk), off * 0.9), "|", color=SWD_COLOR, ms=5)
    raster(axs[1], d, PY, t0, t1); axs[1].set_ylabel("PY"); axs[1].set_yticks([0, 499])
    raster(axs[2], d, TC, t0, t1); axs[2].set_ylabel("TC"); axs[2].set_yticks([])
    raster(axs[3], d, RE, t0, t1); axs[3].set_ylabel("RE"); axs[3].set_yticks([])
    for a in axs:
        for e0, e1 in (episodes or []):
            if e1 > t0 and e0 < t1: a.axvspan(x(max(e0, t0)), x(min(e1, t1)), color=SWD_COLOR, alpha=0.10, lw=0)
        a.spines["top"].set_visible(False); a.spines["right"].set_visible(False)
    for a in axs[:3]: a.tick_params(labelbottom=False)
    axs[3].set_xlabel(f"time from {t0 / 1000:g} s (s)"); axs[0].set_xlim(0, (t1 - t0) / 1000)
    if zoom:
        z0, z1 = zoom; az = fig.add_subplot(gs[4]); zm = (t >= z0) & (t < z1)
        for a in axs: a.axvspan(x(z0), x(z1), ymin=0, ymax=1, fill=False, ec="0.4", lw=0.6)
        az2 = az.twinx(); raster(az2, d, PY, z0, z1, tref=z0); az2.set_yticks([]); az2.set_ylim(az2.get_ylim())
        for s_ in az2.collections: s_.set_alpha(0.25)
        az.plot((t[zm] - z0) / 1000, Z[zm, mid], color=KIND_COL[kind], lw=1.0, zorder=3)
        az.plot((t[zm] - z0) / 1000, Z2[zm, mid], color=KIND_COL[other], lw=0.8, zorder=3)
        if marks is not None:
            mk = np.asarray(marks); mk = mk[(mk >= z0) & (mk < z1)]
            az.plot((mk - z0) / 1000, np.full(len(mk), Z[zm, mid].max() * 1.05), "v", color=SWD_COLOR, ms=3)
        az.set_xlim(0, (z1 - z0) / 1000); az.set_zorder(az2.get_zorder() + 1); az.patch.set_visible(False)
        az.set_ylabel("close-up\nEEG (z)"); az.set_xlabel(f"time from {z0 / 1000:g} s (s)")
        az.spines["top"].set_visible(False)
    if title: axs[0].set_title(title, loc="left", pad=10)
    if path: fig.savefig(path, dpi=300, bbox_inches="tight")
    return fig
