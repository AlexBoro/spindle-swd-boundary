"""Cellular-level regime measures, independent of the EEG and of any band.

The deposited SWD detector hardcodes a 3-6 Hz search band, and widening it does
not help: in the 6-9 Hz rodent band it flags the unperturbed spindle baseline,
because spindle epochs share that band and have the shape it looks for (see
sweeps/gabaa_cx_spindles/README.md). These measures sidestep the question by
working from spike trains instead of the EEG.

What they do and do not separate, measured on labelled windows from
sweeps/gkl_tcfo (which contains known SWDs) and the two spindle-baseline sweeps:

  cortical excitatory rate   SWD 29.2-31.0 Hz | wake, no SWD 28.3-31.7 Hz
                             | spindle epoch 2.6-5.9 Hz
  TC_FO burst fraction       SWD 0.0% | wake, no SWD 0.0%
                             | spindle epoch 0.0-21.3%

Read those two rows differently.

The **cortical excitatory rate** separates wake-like from sleep-like completely:
every one of the 20 spindle-baseline points lies at 2.6-5.9 Hz and every one of
the 17 wake-baseline windows at 28.3-31.7 Hz, a gap of a factor of five with no
overlap. This is the load-bearing measure.

The **TC_FO burst fraction is one-sided and must not be read as a separation.**
Nonzero bursting implies sleep-like, but zero bursting does not imply wake-like:
3 of the 20 spindle-baseline points sit at exactly 0.0%, the same value as every
SWD and wake window. (All three are on the TC_FO leak axis; those three still
have cortical rates of 2.6-3.9 Hz, so the rate criterion still places them
correctly.) Quote the range as 0.0-21.3%, never as "18-21%".

Neither measure separates SWD from wake. Do not use them as an SWD detector.
Their use is the converse: to show that a perturbation did or did not move the
network into the regime in which SWDs are possible at all. The TC_FO burst
fraction reproduces a published signature -- Dervinis & Crunelli's Tables S1/S2
report 0% TC_FO bursting in 13 of 15 pathology columns.
"""
import numpy as np

CORTICAL_E = ("L23_E", "L4_E", "L5_E", "L6_E")
BURST_ISI_MS = 5.0          # intra-burst interval
BURST_QUIET_MS = 100.0      # silence required before a burst onset


def population_rates_in(spike_times_ms, pops, windows_s, populations=None):
    """Mean per-cell firing rate of each population inside the given windows.

    ``windows_s`` is a list of (start, end) pairs in seconds; rates are summed
    over all windows and divided by their total duration, so discontinuous
    windows (e.g. all SWD episodes in a record) are handled correctly.
    """
    pops = np.asarray(pops)
    names = list(populations) if populations is not None else sorted(set(pops.tolist()))
    total = float(sum(b - a for a, b in windows_s))
    if total <= 0:
        raise ValueError("windows_s has zero total duration")
    out = {}
    for p in names:
        idx = np.flatnonzero(pops == p)
        if idx.size == 0:
            out[p] = np.nan
            continue
        n = 0
        for k in idx:
            s = np.asarray(spike_times_ms[k], float) / 1000.0
            for a, b in windows_s:
                n += int(((s >= a) & (s < b)).sum())
        out[p] = n / idx.size / total
    return out


def cortical_e_rate(spike_times_ms, pops, windows_s, populations=CORTICAL_E):
    """Mean excitatory firing rate across cortical layers."""
    r = population_rates_in(spike_times_ms, pops, windows_s, populations)
    return float(np.mean([r[p] for p in populations]))


def burst_fraction(spike_times_ms, pops, windows_s, population="TC_FO",
                   isi_ms=BURST_ISI_MS, quiet_ms=BURST_QUIET_MS):
    """Fraction of a population's spikes that belong to low-threshold bursts.

    A burst starts where an interval below ``isi_ms`` is preceded by at least
    ``quiet_ms`` of silence -- the de-inactivation requirement that makes this a
    T-current burst rather than a fast doublet -- and continues while intervals
    stay below ``isi_ms``.
    """
    pops = np.asarray(pops)
    idx = np.flatnonzero(pops == population)
    n_burst = n_total = 0
    for k in idx:
        s = np.asarray(spike_times_ms[k], float)
        if windows_s:
            s = np.concatenate([s[(s >= a * 1000) & (s < b * 1000)]
                                for a, b in windows_s]) if len(windows_s) else s
        if s.size < 2:
            continue
        s = np.sort(s)
        isi = np.diff(s)
        n_total += s.size
        prev = np.r_[quiet_ms + 1.0, isi[:-1]]
        onsets = np.flatnonzero((isi < isi_ms) & (prev > quiet_ms))
        for o in onsets:
            j = o + 1
            while j < isi.size and isi[j] < isi_ms:
                j += 1
            n_burst += (j - o + 1)
    return n_burst / max(n_total, 1)
