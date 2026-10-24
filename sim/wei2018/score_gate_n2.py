"""Score N2 spindle-sensitivity gate runs (Stage 2, D3/D4).

usage: python score_gate_n2.py <out.csv> <label=npz> [<label=npz> ...]

Per run, over t = 12-102 s of a state_n2 run (PY mean-voltage LFP, 1 ms):
  Welch peak 4-16 Hz; events from a 4-14 Hz Hilbert envelope (savgol-smoothed,
  threshold median + 2 x 1.4826 MAD, gaps < 300 ms merged, >= 500 ms kept):
  events/min, median duration, median within-event cycle frequency (peaks of the
  2-20 Hz band); PY participation (fraction of PY cells spiking in an event);
  rates of PY/TC/RE/IN overall; peak cross-correlation at 60 cells and its
  asymptote (mean over 150-300 cells) with MATLAB xcorr 'coeff' (no demeaning,
  lags up to half the event), 5 ms Gaussian, on the first 30 events.
These are the Stage 0 methods (docs/wei2018_stage0_diagnostics.md).
"""
import os, sys
import numpy as np, pandas as pd
from scipy import signal as ss
sys.path.insert(0, os.path.join(os.path.dirname(os.path.abspath(__file__)), "..", ".."))
from analysis import wei2018 as W

T0, T1 = 12000, 102000


def events(x):
    y = W.bandpass(x, 4, 14, 1000)
    env = ss.savgol_filter(np.abs(ss.hilbert(y)), 201, 2)
    th = np.median(env) + 2 * 1.4826 * np.median(np.abs(env - np.median(env)))
    on = np.diff(np.r_[0, (env > th).astype(int), 0])
    ev = []
    for s0, e0 in zip(np.flatnonzero(on == 1), np.flatnonzero(on == -1)):
        if ev and s0 - ev[-1][1] < 300: ev[-1][1] = e0
        else: ev.append([s0, e0])
    return [e for e in ev if e[1] - e[0] >= 500]


def xcorr_profile(st, sm, wins, dists=(1, 5, 10, 20, 40, 60, 100, 150, 200, 300), sigma=5.0):
    ker = np.exp(-0.5 * (np.arange(-25, 26) / sigma) ** 2)
    acc = {k: [0.0, 0] for k in dists}
    for a, b in wins:
        a, b = int(a), int(b); nb = b - a
        X = np.zeros((500, nb)); k = (st >= a) & (st < b)
        np.add.at(X, (sm[k], (st[k] - a).astype(int).clip(0, nb - 1)), 1.0)
        X = np.apply_along_axis(lambda v: np.convolve(v, ker, mode="same"), 1, X)
        nrm = np.sqrt((X ** 2).sum(1)); good = nrm > 0
        F = np.fft.rfft(X, n=2 * nb, axis=1); ml = nb // 2
        for dist in dists:
            i = np.arange(0, 500 - dist); j = i + dist; ok = good[i] & good[j]
            if not ok.any(): continue
            cc = np.fft.irfft(F[i[ok]] * np.conj(F[j[ok]]), n=2 * nb, axis=1)
            cc = np.concatenate([cc[:, -ml:], cc[:, :ml + 1]], axis=1)
            acc[dist][0] += (cc.max(1) / (nrm[i[ok]] * nrm[j[ok]])).sum(); acc[dist][1] += ok.sum()
    return {k: v[0] / v[1] for k, v in acc.items() if v[1]}


def score(label, path):
    d = dict(np.load(path, allow_pickle=True))
    t, xx = W.lfp_trace(d); k = (t >= T0) & (t < T1); x = xx[k]
    f, P = ss.welch(x - x.mean(), fs=1000, nperseg=4096); m = (f >= 4) & (f <= 16)
    r = dict(run=label, lfp_peak_Hz=f[m][P[m].argmax()], P4_7_over_P7_14=P[(f >= 4) & (f < 7)].sum() / P[(f >= 7) & (f < 14)].sum())
    ev = events(x); b2 = W.bandpass(x, 2, 20, 1000)
    cyc, dur = [], []
    for s0, e0 in ev:
        seg = b2[s0:e0]; pk, _ = ss.find_peaks(seg, prominence=0.5 * seg.std(), distance=50)
        dur.append((e0 - s0) / 1000)
        if len(pk) > 2: cyc.append((len(pk) - 1) / ((pk[-1] - pk[0]) / 1000))
    r.update(events_per_min=len(ev) / ((T1 - T0) / 60000), dur_med_s=np.median(dur) if dur else np.nan,
             cycle_Hz_med=np.median(cyc) if cyc else np.nan, cycle_Hz_iqr=(np.percentile(cyc, 75) - np.percentile(cyc, 25)) if cyc else np.nan)
    tk = (d["spk_t"] >= T0) & (d["spk_t"] < T1)
    for nm, ty, n in [("PY", 4, 500), ("IN", 7, 100), ("TC", 2, 100), ("RE", 0, 100)]:
        r[f"rate_{nm}_Hz"] = ((d["spk_type"] == ty) & tk).sum() / n / ((T1 - T0) / 1000)
    py = d["spk_type"] == 4; st, sm = d["spk_t"][py], d["spk_m"][py].astype(int)
    part = [len(np.unique(sm[(st >= T0 + s0) & (st < T0 + e0)])) / 500 for s0, e0 in ev]
    r["PY_participation_med"] = np.median(part) if part else np.nan
    wins = [(T0 + s0 - 100, T0 + e0 + 100) for s0, e0 in ev][:30]
    if wins:
        xc = xcorr_profile(st, sm, wins)
        r["xcorr_60"] = xc.get(60, np.nan); r["xcorr_asym"] = np.mean([xc[k] for k in (150, 200, 300) if k in xc])
    r["n_events"] = len(ev)
    return r


if __name__ == "__main__":
    rows = [score(*a.split("=", 1)) for a in sys.argv[2:]]
    pd.DataFrame(rows).to_csv(sys.argv[1], index=False)
    print(pd.DataFrame(rows).round(3).to_string(index=False))
