"""Measures for the Wei et al. 2018 reproduction (PLoS Comput Biol 14: e1006322).

Every function cites the Methods paragraph it implements. Where Methods leave a
choice open, the choice is stated in the docstring and listed in
docs/wei2018_interpretations.md (items A1-A6).

Input is the reduced run file written by sim/wei2018/job_run.py:
  spk_t (ms), spk_type (cell-type enum: 0 RE, 2 TC, 4 CX=PY, 7 IN), spk_m (index),
  lfp (t, mean V PY, IN, TC, RE at 1 ms), w_pre/w_post, w_g_t/w_g (PY-PY AMPA
  weights over time), w_mini_t/w_mini, protocol_used (text).
"""
from __future__ import annotations

import numpy as np
from scipy import signal

PY, IN, TC, RE = 4, 7, 2, 0
N_PY = 500
SEQ1 = [200, 205, 210, 215, 220]   # A..E, activation order
SEQ2 = [296, 291, 286, 281, 276]   # E2..A2, activation order
GROUP = 5


# ----------------------------------------------------------------------------- io
def load(path):
    d = dict(np.load(path, allow_pickle=False))
    d["protocol"] = parse_protocol(str(d["protocol_used"]))
    return d


def parse_protocol(text):
    p = {"states": [], "seqs": {}, "wins": []}
    for ln in text.splitlines():
        f = ln.split()
        if not f:
            continue
        if f[0] == "state":
            p["states"].append((float(f[1]), float(f[2]), f[3]))
        elif f[0] == "seq":
            p["seqs"][int(f[1])] = (int(f[2]), [int(x) for x in f[3:]])
        elif f[0] in ("train", "test"):
            p["wins"].append((f[0], int(f[1]), float(f[2]), float(f[3]), float(f[4])))
    return p


def spikes_of(d, ctype=PY):
    k = d["spk_type"] == ctype
    return d["spk_t"][k], d["spk_m"][k].astype(int)


# ------------------------------------------------------------------- string match
def string_match(s1, ideal):
    """Methods, Sequence learning analysis: SM = 2N - sum_i |L(S1, S2[i]) - i|,
    normalised by M = 2*len(ideal). S2 = ideal restricted to elements present in S1.

    >>> string_match("ACDB", "ABCDE")
    0.4
    >>> string_match("ABCDE", "ABCDE")
    1.0
    """
    s1 = list(s1)
    s2 = [c for c in ideal if c in s1]
    n = len(s1)
    if n == 0:
        return 0.0
    sm = 2 * n - sum(abs((s1.index(c) + 1) - (i + 1)) for i, c in enumerate(s2))
    return round(sm / (2 * len(ideal)), 10)


def gauss_window(n=50, alpha=2.5):
    """MATLAB gausswin(n): exp(-0.5*(alpha*k/((n-1)/2))^2), k = -(n-1)/2..(n-1)/2."""
    k = np.arange(n) - (n - 1) / 2
    return np.exp(-0.5 * (alpha * k / ((n - 1) / 2)) ** 2)


def recall_order(st, sm, starts, onset, window=350.0, size=GROUP, kernel_ms=50):
    """Methods, Sequence learning analysis, steps 1-3: spikes of each group in
    [onset, onset+350 ms), mean instantaneous rate of the 5 neurons at 1 ms,
    smoothed with a 50 ms Gaussian window (choice A1: MATLAB gausswin(50),
    alpha 2.5, sigma ~9.8 ms), groups ordered by the time of their smoothed peak.
    Groups with no spike in the window are absent from the recalled sequence."""
    labels = "ABCDEFGHIJ"[: len(starts)]
    nb = int(window)
    w = gauss_window(kernel_ms)
    w = w / w.sum()
    sel = (st >= onset) & (st < onset + window)
    t, m = st[sel], sm[sel]
    peaks = []
    for g, s0 in enumerate(starts):
        k = (m >= s0) & (m < s0 + size)
        if not k.any():
            continue
        r = np.bincount(((t[k] - onset).astype(int)).clip(0, nb - 1), minlength=nb) / size
        rs = np.convolve(r, w, mode="same")
        peaks.append((int(np.argmax(rs)), g))
    peaks.sort()
    return "".join(labels[g] for _, g in peaks)


def test_trials(d, seq_id):
    """Onsets of every test trial for sequence seq_id, grouped by test session."""
    out = []
    for kind, sid, t0, t1, ph in d["protocol"]["wins"]:
        if kind == "test" and sid == seq_id:
            out.append(np.arange(t0 + ph, t1, 1000.0))
    return out


def recall_performance(d, seq_id=1, th=0.8):
    """Per test session: list of SM values, performance = fraction SM >= 0.8."""
    size, starts = d["protocol"]["seqs"][seq_id]
    st, sm = spikes_of(d)
    ideal = "ABCDEFGHIJ"[: len(starts)]
    res = []
    for onsets in test_trials(d, seq_id):
        sms = np.array([string_match(recall_order(st, sm, starts, o, size=size), ideal) for o in onsets])
        res.append({"t0": float(onsets[0]), "sm": sms, "perf": float(np.mean(sms >= th)), "mean_sm": float(sms.mean())})
    return res


# ----------------------------------------------------------------------- replay
def replay_events(d, seq_id, t0, t1, jitter=50.0):
    """Methods, Sequence replay measurement during sleep, steps (i)-(v), applied to
    the 25-cell area of sequence seq_id in [t0, t1).

    For each spike of the lowest-index neuron of the area, chain to the nearest
    spike of the next neuron; a candidate further than 50 ms from the current
    reference is rejected and the reference is kept (step iii). Group times are
    the mean of accepted spike times in each group of 5 (step iv; choice A2:
    rejected neurons are excluded from the mean, a group with none is absent).
    Returns a list of recalled orders, labelled in ACTIVATION order of the
    sequence (so 'ABCDE' is the correct order for both Seq1 and Seq2)."""
    size, starts = d["protocol"]["seqs"][seq_id]
    lo, hi = min(starts), max(starts) + size
    st, sm = spikes_of(d)
    k = (st >= t0 - jitter) & (st < t1 + jitter) & (sm >= lo) & (sm < hi)
    st, sm = st[k], sm[k]
    per = [np.sort(st[sm == n]) for n in range(lo, hi)]
    labels = "ABCDEFGHIJ"[: len(starts)]
    grp_of = {}
    for g, s0 in enumerate(starts):
        for n in range(s0, s0 + size):
            grp_of[n] = g
    orders = []
    for t_lead in per[0]:
        if not (t0 <= t_lead < t1):
            continue
        ref = t_lead
        acc = {lo: t_lead}
        for i in range(1, hi - lo):
            s = per[i]
            if len(s) == 0:
                continue
            j = np.searchsorted(s, ref)
            cand = [s[x] for x in (j - 1, j) if 0 <= x < len(s)]
            c = min(cand, key=lambda v: abs(v - ref))
            if abs(c - ref) <= jitter:
                acc[lo + i] = c
                ref = c
        gt = {}
        for n, tt in acc.items():
            gt.setdefault(grp_of[n], []).append(tt)
        order = sorted((np.mean(v), g) for g, v in gt.items())
        orders.append("".join(labels[g] for _, g in order))
    return orders


def replay_summary(d, seq_id, t0, t1, th=0.8):
    orders = replay_events(d, seq_id, t0, t1)
    n = len(starts := d["protocol"]["seqs"][seq_id][1])
    ideal = "ABCDEFGHIJ"[:n]
    fwd = np.array([string_match(o, ideal) for o in orders])
    rev = np.array([string_match(o, ideal[::-1]) for o in orders])
    return {"n_events": len(orders),
            "n_correct": int((fwd >= th).sum()), "n_reversed": int((rev >= th).sum()),
            "n_correct_exact": int((fwd == 1).sum()), "n_reversed_exact": int((rev == 1).sum()),
            "frac_correct": float((fwd >= th).mean()) if len(orders) else 0.0,
            "frac_correct_exact": float((fwd == 1).mean()) if len(orders) else 0.0}


# ---------------------------------------------------------------------- weights
def box_synapses(d, seq_id):
    """Fig 3A grey box: synapses from pre to post where both lie in the sequence
    area and pre precedes post in the trained order (pre = post - k for Seq1,
    post + k for Seq2; k = 1..5, the PY-PY radius). Choice A3."""
    size, starts = d["protocol"]["seqs"][seq_id]
    lo, hi = min(starts), max(starts) + size
    ascending = starts[-1] > starts[0]
    pre, post = d["w_pre"], d["w_post"]
    inarea = (pre >= lo) & (pre < hi) & (post >= lo) & (post < hi)
    fwd = (pre < post) if ascending else (pre > post)
    return np.where(inarea & fwd)[0], np.where(inarea & ~fwd & (pre != post))[0]


def weight_change(d, seq_id):
    """Mean % change of g_AMPA relative to each synapse's initial (t = 0) value."""
    f, r = box_synapses(d, seq_id)
    g = d["w_g"].astype(float)
    g0 = g[0]
    rel = (g / g0[None, :] - 1.0) * 100.0
    return d["w_g_t"], rel[:, f].mean(1), rel[:, r].mean(1)


# --------------------------------------------------------------- physiology
def state_windows(d, state):
    return [(a, b) for a, b, s in d["protocol"]["states"] if s == state]


def rate(d, ctype, t0, t1, n_cells):
    st, _ = spikes_of(d, ctype)
    return ((st >= t0) & (st < t1)).sum() / n_cells / ((t1 - t0) / 1000.0)


def lfp_trace(d, col=1):
    """col 1 = mean PY soma voltage, the cortical LFP proxy (choice A4)."""
    return d["lfp"][:, 0], d["lfp"][:, col].astype(float)


def bandpass(x, lo, hi, fs=1000.0, order=4):
    sos = signal.butter(order, [lo, hi], btype="band", fs=fs, output="sos")
    return signal.sosfiltfilt(sos, x)


def spectrum(x, fs=1000.0):
    f, p = signal.welch(x - x.mean(), fs=fs, nperseg=min(len(x), 8192))
    return f, p


def detect_spindles(t, x, fs=1000.0, k=2.0, kmin=1.0, dmin=0.5, dmax=3.0):
    """Spindles on the PY LFP proxy (choice A5): 7-14 Hz band, Hilbert envelope,
    events where the envelope exceeds mean + k*SD, extended to mean + kmin*SD,
    kept if 0.5-3 s long (the paper's own description of N2 spindles)."""
    y = bandpass(x, 7, 14, fs)
    env = np.abs(signal.hilbert(y))
    hi_th, lo_th = env.mean() + k * env.std(), env.mean() + kmin * env.std()
    above = env > lo_th
    ev = []
    i, n = 0, len(env)
    while i < n:
        if above[i]:
            j = i
            while j < n and above[j]:
                j += 1
            if env[i:j].max() > hi_th:
                dur = (j - i) / fs
                if dmin <= dur <= dmax:
                    seg = y[i:j]
                    zc = np.sum(np.diff(np.sign(seg)) > 0)
                    ev.append((t[i], t[j - 1], dur, zc / dur))
            i = j
        else:
            i += 1
    return ev


def detect_up_states(d, t0, t1, bin_ms=10.0, frac=0.2, min_ms=50.0):
    """Up states from the PY population rate (choice A6): 10 ms bins, smoothed
    over 50 ms, Up where rate exceeds frac*max; Up/Down durations and SO
    frequency = Up states per second."""
    st, _ = spikes_of(d)
    st = st[(st >= t0) & (st < t1)]
    edges = np.arange(t0, t1 + bin_ms, bin_ms)
    r = np.histogram(st, edges)[0] / N_PY / (bin_ms / 1000.0)
    r = np.convolve(r, np.ones(5) / 5, mode="same")
    up = r > frac * r.max() if r.max() > 0 else np.zeros_like(r, bool)
    dif = np.diff(up.astype(int))
    on = np.where(dif == 1)[0] + 1
    off = np.where(dif == -1)[0] + 1
    if len(off) and len(on) and off[0] < on[0]:
        off = off[1:]
    m = min(len(on), len(off))
    on, off = on[:m], off[:m]
    keep = (off - on) * bin_ms >= min_ms
    on, off = on[keep], off[keep]
    ups = (off - on) * bin_ms
    downs = (on[1:] - off[:-1]) * bin_ms
    return {"n_up": len(on), "so_freq_hz": len(on) / ((t1 - t0) / 1000.0),
            "up_ms": float(np.median(ups)) if len(ups) else np.nan,
            "down_ms": float(np.median(downs)) if len(downs) else np.nan,
            "on_ms": edges[on], "off_ms": edges[off]}


def spatial_correlation(d, windows, max_d=40, sigma=5.0, maxlag=100):
    """Fig 4A: spike trains convolved with a Gaussian (sigma 5 ms), within each
    event window the peak normalised cross-correlation (|lag| <= 100 ms) of every
    PY pair at distance dist, averaged over pairs and events."""
    st, sm = spikes_of(d)
    out = np.zeros(max_d + 1)
    cnt = np.zeros(max_d + 1)
    ker = np.exp(-0.5 * (np.arange(-25, 26) / sigma) ** 2)
    for a, b in windows:
        nb = int(b - a)
        if nb < 2 * maxlag:
            continue
        X = np.zeros((N_PY, nb))
        k = (st >= a) & (st < b)
        np.add.at(X, (sm[k], (st[k] - a).astype(int).clip(0, nb - 1)), 1.0)
        X = np.apply_along_axis(lambda v: np.convolve(v, ker, mode="same"), 1, X)
        X = X - X.mean(1, keepdims=True)
        nrm = np.sqrt((X ** 2).sum(1))
        good = nrm > 0
        F = np.fft.rfft(X, n=2 * nb, axis=1)
        for dist in range(1, max_d + 1):
            i = np.arange(0, N_PY - dist)
            j = i + dist
            ok = good[i] & good[j]
            if not ok.any():
                continue
            cc = np.fft.irfft(F[i[ok]] * np.conj(F[j[ok]]), n=2 * nb, axis=1)
            cc = np.concatenate([cc[:, -maxlag:], cc[:, : maxlag + 1]], axis=1)
            peak = cc.max(1) / (nrm[i[ok]] * nrm[j[ok]])
            out[dist] += peak.sum()
            cnt[dist] += ok.sum()
    with np.errstate(invalid="ignore"):
        return np.arange(max_d + 1), out / cnt


if __name__ == "__main__":
    import doctest
    doctest.testmod(verbose=False)
    assert string_match("ACDB", "ABCDE") == 0.4
    assert string_match("ABCDE", "ABCDE") == 1.0
    assert string_match("EDCBA", "ABCDE") == string_match("ABCDE", "EDCBA")
    print("wei2018 analysis self-tests passed")
