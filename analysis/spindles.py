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


# --- EEG spindle detection -------------------------------------------------
#
# The deposit has no spindle detector; the SWD paper's criteria are stated in
# terms of frequency (7-14 Hz) and the companion paper's spindle figures are
# qualitative. This is the conventional envelope-threshold detector (Moelle /
# Bazhenov lineage) applied to the model EEG, written so that SWD-contaminated
# stretches can be excluded by mask rather than by hand.
#
# Thresholds are expressed in SDs of the band-passed envelope computed over the
# retained (non-SWD, non-warm-up) samples only. That is deliberately NOT the
# deposit's convention for SWDs -- there a fixed absolute threshold is
# load-bearing (see sweeps/gkl_tcfo/README.md) because the question is whether
# amplitude crossed an absolute level. Here the question is whether a spindle
# is distinguishable from its own background, so a relative threshold is the
# right one and makes points with different overall EEG amplitude comparable.

SPINDLE_THRESHOLD_SD = 1.5         # envelope threshold for the spindle core
SPINDLE_EXTEND_SD = 1.0            # lower threshold the event is grown out to
SPINDLE_MIN_S = 0.4
SPINDLE_MAX_S = 3.0
SPINDLE_MERGE_S = 0.1
ENVELOPE_SMOOTH_S = 0.1


def _runs(mask):
    import numpy as np
    m = np.asarray(mask).astype(bool).astype(np.int8)
    d = np.diff(np.r_[0, m, 0])
    return list(zip(np.flatnonzero(d == 1), np.flatnonzero(d == -1)))


def spindle_envelope(eeg, dt_ms, band_hz=SPINDLE_BAND_HZ):
    """Band-pass the EEG into the spindle band and return the Hilbert envelope."""
    import numpy as np
    from scipy.signal import butter, sosfiltfilt, hilbert

    fs = 1000.0 / dt_ms
    sos = butter(4, [band_hz[0] / (fs / 2), band_hz[1] / (fs / 2)],
                 btype="band", output="sos")
    bp = sosfiltfilt(sos, np.asarray(eeg, float))
    env = np.abs(hilbert(bp))
    w = max(1, int(round(ENVELOPE_SMOOTH_S * fs)))
    k = np.ones(w) / w
    return bp, np.convolve(env, k, mode="same")


def detect_spindles(eeg, dt_ms, keep=None, band_hz=SPINDLE_BAND_HZ):
    """Envelope-threshold spindle detector.

    ``keep`` is a boolean mask of samples eligible for both the threshold
    statistics and for detection -- pass ``~swd_mask`` to measure spindling in
    the non-seizure part of a record. Events are seeded where the smoothed
    envelope exceeds ``SPINDLE_THRESHOLD_SD`` SDs above its mean and grown out
    to ``SPINDLE_EXTEND_SD``, then merged, then length-gated.

    Returns a dict with the event list (sample index pairs), per-event peak
    frequency, and summary statistics. ``density_per_min`` is per minute of
    *retained* time, so excluding SWDs does not inflate it.
    """
    import numpy as np

    fs = 1000.0 / dt_ms
    eeg = np.asarray(eeg, float)
    keep = np.ones(eeg.size, bool) if keep is None else np.asarray(keep, bool)
    bp, env = spindle_envelope(eeg, dt_ms, band_hz)

    mu, sd = env[keep].mean(), env[keep].std()
    hi = (env >= mu + SPINDLE_THRESHOLD_SD * sd) & keep
    lo = (env >= mu + SPINDLE_EXTEND_SD * sd) & keep

    # grow each core above the low threshold, within the retained mask
    events = []
    for a, b in _runs(hi):
        i, j = a, b
        while i > 0 and lo[i - 1]:
            i -= 1
        while j < env.size and lo[j]:
            j += 1
        events.append((i, j))

    merged = []
    gap = int(round(SPINDLE_MERGE_S * fs))
    for a, b in events:
        if merged and a - merged[-1][1] <= gap:
            merged[-1] = (merged[-1][0], max(b, merged[-1][1]))
        else:
            merged.append((a, b))

    lo_n, hi_n = int(SPINDLE_MIN_S * fs), int(SPINDLE_MAX_S * fs)
    kept = [(a, b) for a, b in merged if lo_n <= b - a <= hi_n]

    freqs = []
    for a, b in kept:
        seg = bp[a:b]
        if seg.size < 8:
            freqs.append(np.nan)
            continue
        sp = np.fft.rfft(seg * np.hanning(seg.size))
        f = np.fft.rfftfreq(seg.size, 1.0 / fs)
        m = (f >= band_hz[0]) & (f <= band_hz[1])
        freqs.append(float(f[m][np.argmax(np.abs(sp[m]))]))

    durs = np.array([(b - a) / fs for a, b in kept])
    kept_s = keep.sum() / fs
    return dict(
        events=kept, freqs=np.array(freqs), durations_s=durs,
        kept_s=kept_s,
        n=len(kept),
        density_per_min=60.0 * len(kept) / kept_s if kept_s else np.nan,
        mean_duration_s=float(durs.mean()) if durs.size else np.nan,
        mean_freq_hz=float(np.nanmean(freqs)) if len(freqs) else np.nan,
        envelope_sd=float(sd), envelope_mean=float(mu),
        band_power=float(np.mean(bp[keep] ** 2)) if keep.any() else np.nan,
    )
