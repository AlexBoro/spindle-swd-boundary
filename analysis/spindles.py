"""Spindle measures for Gate 0 criteria C2.1-C2.6.

Works from reduced per-cell spike times rather than traces, so it runs on the
small .npz a run leaves behind rather than the gigabytes it writes.
"""
import numpy as np
from scipy.signal import butter, sosfiltfilt, welch

SPINDLE_BAND_HZ = (7.0, 14.0)
OSC_BAND_HZ = (6.0, 16.0)          # oscFreq's 'spindles' band
RATE_BIN_S = 0.001
EPOCH_SMOOTH_S = 1.0
EPOCH_RATE_THRESHOLD_HZ = 0.5
EPOCH_MIN_S = 1.0
ONSET_SMOOTH_MS = 25
ONSET_FRACTION = 0.10

#: Order C2.3 predicts: NRT_FO first, then TC_HO/NRT_HO, then TC_FO and cortex.
PREDICTED_ORDER = ("NRT_FO", "NRT_HO", "TC_HO", "TC_FO")


def population_rates(spike_times_ms, pops, tstop_s, bin_s=RATE_BIN_S):
    """Per-population mean firing rate in Hz, binned at ``bin_s``."""
    edges = np.arange(0, tstop_s + bin_s, bin_s)
    out = {}
    for p in sorted(set(np.asarray(pops).tolist())):
        idx = np.flatnonzero(np.asarray(pops) == p)
        allsp = np.concatenate([np.asarray(spike_times_ms[i]) for i in idx]) / 1000.0
        h, _ = np.histogram(allsp, bins=edges)
        out[p] = h / len(idx) / bin_s
    return out


def active_epochs(rates, cortical=("L23_E", "L4_E", "L5_E", "L6_E"), bin_s=RATE_BIN_S):
    """Index spans where the network is firing, from the mean cortical rate.

    The model alternates between spindle epochs and complete silence on an
    infra-slow cycle, so 'the data' is these spans rather than the whole record.
    """
    cx = np.mean([rates[p] for p in cortical if p in rates], axis=0)
    w = int(EPOCH_SMOOTH_S / bin_s)
    sm = np.convolve(cx, np.ones(w) / w, mode="same")
    act = sm > EPOCH_RATE_THRESHOLD_HZ
    d = np.diff(act.astype(int))
    starts = np.flatnonzero(d == 1) + 1
    ends = np.flatnonzero(d == -1) + 1
    if act[0]:
        starts = np.r_[0, starts]
    if act[-1]:
        ends = np.r_[ends, act.size - 1]
    return [(a, b) for a, b in zip(starts, ends) if (b - a) * bin_s > EPOCH_MIN_S]


def spindle_frequency(rates, epochs, population="L5_E", bin_s=RATE_BIN_S):
    """Welch peak within the spindle band, per epoch. Criterion C2.1."""
    out = []
    for a, b in epochs:
        w = rates[population][a:b]
        f, p = welch(w - w.mean(), fs=1 / bin_s, nperseg=min(2048, w.size),
                     noverlap=min(1024, w.size // 2))
        m = (f >= SPINDLE_BAND_HZ[0]) & (f <= SPINDLE_BAND_HZ[1])
        out.append(float(f[m][np.argmax(p[m])]))
    return out


def onset_latencies(rates, epochs, populations, bin_s=RATE_BIN_S):
    """Per-epoch onset latency (ms from epoch start) for each population.

    Onset is when a population's smoothed rate first reaches ONSET_FRACTION of
    its own within-epoch peak, which is scale-free across populations firing at
    very different rates.

    Do NOT substitute mean firing PHASE for this. Phase is circular: on a
    ~114 ms spindle cycle a 12 ms lead and a 101 ms lag are the same number,
    so a phase ordering cannot establish which population starts a spindle.
    That mistake inverted the thalamic ordering when first tried here.
    """
    w = max(int(ONSET_SMOOTH_MS * 1e-3 / bin_s), 1)
    out = {p: [] for p in populations}
    for a, b in epochs:
        for p in populations:
            r = np.convolve(rates[p][a:b], np.ones(w) / w, mode="same")
            if r.max() <= 0:
                out[p].append(np.nan)
                continue
            i = np.flatnonzero(r >= ONSET_FRACTION * r.max())
            out[p].append(i[0] * bin_s * 1000 if i.size else np.nan)
    return out


def score_onset_order(latencies, predicted=PREDICTED_ORDER):
    """Compare the observed thalamic onset order against C2.3's prediction.

    Returns the observed order, whether it matches, and the per-epoch spread --
    which is the number that decides whether the comparison means anything.
    """
    means = {p: float(np.nanmean(v)) for p, v in latencies.items() if p in predicted}
    observed = tuple(sorted(means, key=means.get))
    spread = {p: float(np.nanmax(v) - np.nanmin(v))
              for p, v in latencies.items() if p in predicted}
    return {
        "observed_order": observed,
        "predicted_order": tuple(predicted),
        "matches": observed == tuple(predicted),
        "mean_latency_ms": means,
        "per_epoch_spread_ms": spread,
        "n_epochs": len(next(iter(latencies.values()))),
    }
