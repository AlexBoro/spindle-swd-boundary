"""Spike-and-wave discharge (SWD) screen for the Wei 2018 network (Stage 3, tier 1).

The Dervinis detector (analysis/swd.py) works on an EEG with a fixed absolute threshold and a 3-6 Hz
band; this network has no EEG, only spikes and mean soma voltages. This screen therefore works on
the cortical population spike train and asks, window by window, whether the cortex shows the
signature of absence-type SWDs in thalamocortical models:

  * a dominant population rhythm at 2-5.5 Hz (spindles are 6-14 Hz, the N3 slow oscillation < 1.5 Hz);
  * that rhythm concentrated in a narrow band (regular cycles), not broadband;
  * hypersynchrony: a large fraction of PY cells fires in each cycle;
  * cycle-to-cycle regularity (low CV of inter-burst intervals).

Windows that pass all four are merged into episodes; episodes shorter than MIN_EP_S are dropped
(3 s, as in the Dervinis code's minSWD). All thresholds are module constants and every window's
features are returned, so the thresholds can be checked against the data rather than trusted.
"""
import numpy as np
from scipy import signal
from scipy.ndimage import gaussian_filter1d

PY, IN, TC, RE = 4, 7, 2, 0          # spk_type codes
N_PY = 500
BIN_MS = 5.0
WIN_S, STEP_S = 2.0, 0.25
F_LO, F_HI = 2.0, 5.5                 # SWD band
Q_MIN = 0.35                          # power in f0 +- 0.5 Hz / power 0.5-20 Hz
PART_MIN = 0.30                       # median fraction of PY cells firing per cycle
CV_MAX = 0.25                         # CV of inter-burst intervals within the window
MIN_EP_S = 3.0


def pop_rate(t_ms, t0, t1, bin_ms=BIN_MS):
    edges = np.arange(t0, t1 + bin_ms, bin_ms)
    r, _ = np.histogram(t_ms, edges)
    return edges[:-1], r.astype(float)


def bursts(t_ms, m, t0, t1, sigma_ms=8.0, k=2.0, refractory_ms=90.0):
    """Population bursts: peaks of the smoothed PY rate above mean + k*sd, at least refractory_ms apart.
    Returns peak times and the fraction of PY cells spiking within +-30 ms of each peak."""
    tb, r = pop_rate(t_ms, t0, t1)
    rs = gaussian_filter1d(r, sigma_ms / BIN_MS)
    thr = rs.mean() + k * rs.std()
    pk, _ = signal.find_peaks(rs, height=thr, distance=max(1, int(refractory_ms / BIN_MS)))
    tp = tb[pk] + BIN_MS / 2
    part = np.array([len(np.unique(m[(t_ms >= x - 30) & (t_ms < x + 30)])) / N_PY for x in tp])
    return tp, part


def window_features(t_ms, m, t0, t1):
    tb, r = pop_rate(t_ms, t0, t1)
    fs = 1000.0 / BIN_MS
    nw, ns = int(WIN_S * fs), int(STEP_S * fs)
    tp, part = bursts(t_ms, m, t0, t1)
    rows = []
    for a in range(0, len(r) - nw + 1, ns):
        x = r[a:a + nw] - r[a:a + nw].mean()
        f, P = signal.periodogram(x * signal.windows.hann(nw), fs=fs)
        band = (f >= 0.5) & (f <= 20)
        tot = P[band].sum()
        f0 = f[band][np.argmax(P[band])] if tot > 0 else np.nan      # dominant frequency, 0.5-20 Hz
        q = P[(f >= f0 - 0.5) & (f <= f0 + 0.5)].sum() / tot if tot > 0 else 0.0
        pspin = P[(f >= 6) & (f <= 14)].sum() / tot if tot > 0 else 0.0
        ws, we = tb[a], tb[a] + WIN_S * 1000
        kk = (tp >= ws) & (tp < we)
        ibi = np.diff(tp[kk])
        cv = ibi.std() / ibi.mean() if len(ibi) >= 3 else np.inf
        pm = float(np.median(part[kk])) if kk.any() else 0.0
        ok = (F_LO <= f0 <= F_HI) and q >= Q_MIN and pm >= PART_MIN and cv <= CV_MAX
        rows.append(dict(t0=ws, t1=we, f0=f0, q=q, spindle_frac=pspin, part=pm, cv=cv,
                         n_bursts=int(kk.sum()), rate=r[a:a + nw].sum() / N_PY / WIN_S, swd=ok))
    return rows


def episodes(rows, min_s=MIN_EP_S):
    eps, cur = [], None
    for w in rows:
        if w["swd"]:
            if cur and w["t0"] <= cur[1]: cur[1] = w["t1"]
            else:
                if cur: eps.append(cur)
                cur = [w["t0"], w["t1"]]
    if cur: eps.append(cur)
    return [(a, b) for a, b in eps if (b - a) / 1000 >= min_s]


def screen(d, t0, t1):
    """d: run npz (spk_t, spk_type, spk_m, lfp). Analyse [t0, t1) ms. Returns summary dict and window rows."""
    k = (d["spk_type"] == PY) & (d["spk_t"] >= t0) & (d["spk_t"] < t1)
    t, m = d["spk_t"][k], d["spk_m"][k]
    rows = window_features(t, m, t0, t1)
    eps = episodes(rows)
    in_ep = lambda w: any(a <= w["t0"] and w["t1"] <= b for a, b in eps)
    ew = [w for w in rows if in_ep(w)]
    dur = sum(b - a for a, b in eps) / 1000
    rate = lambda ty: ((d["spk_type"] == ty) & (d["spk_t"] >= t0) & (d["spk_t"] < t1)).sum() / ((t1 - t0) / 1000) / (N_PY if ty == PY else 100)
    out = dict(n_episodes=len(eps), swd_time_frac=dur / ((t1 - t0) / 1000), swd_s=dur,
               ep_f0=float(np.median([w["f0"] for w in ew])) if ew else np.nan,
               ep_part=float(np.median([w["part"] for w in ew])) if ew else np.nan,
               frac_windows_swd=float(np.mean([w["swd"] for w in rows])) if rows else 0.0,
               max_part=float(max([w["part"] for w in rows], default=0)),
               rate_PY=rate(PY), rate_IN=rate(IN), rate_TC=rate(TC), rate_RE=rate(RE),
               lfp_finite=bool(np.isfinite(d["lfp"][(d["lfp"][:, 0] >= t0) & (d["lfp"][:, 0] < t1), 1:]).all()))
    return out, rows, eps
