"""Spike-and-wave discharge detection.

Port target: `detectEEGspikesSWDs.m` (776 lines) from the vendored model tree.
NOT YET IMPLEMENTED -- this module fixes the interface and the validation
contract so the port is well defined. Criterion C6.1 in
docs/acceptance_criteria.md is not satisfied until `validate_against_matlab`
passes.

Algorithm, quoted from the MATLAB source's own docstring (the authoritative
statement; the paper gives only the filter settings):

    "SWD detection algorithm works first by detecting the filtered EEG signal
    baseline. Negative spikes exceeding 1 and 1.96 standard deviation of the EEG
    signal relative to the baseline and spaced by at least 1 cycle distance from
    each other are then marked. Lone spikes separated by at least 3 seconds are
    eliminated. Groupings of spikes smaller than 1.5 seconds are also eliminated.
    The next step is to find individual large (> 1.96 SD relative to baseline)
    spike clusters that have durations of at least 3 seconds. Smaller clusters
    are eliminated. The remaining clusters are marked as individual SWDs. Spikes
    identified in earlier stages are then associated with SWDs. Phase of SWCs is
    also estimated, as well as SWC number. The same procedure is repeated for
    SWDs that include only spikes exceeding 1.96 standard deviations."

Points the port must get right, and which an earlier draft of this module had
wrong:

* **Spikes are NEGATIVE deflections.** Detection is on downward excursions.
* **There are TWO thresholds, not one** -- 1 SD and 1.96 SD. The 1.96 SD set
  defines the "large" variant returned alongside every primary output; the 1 SD
  set participates in the initial marking.
* **Minimum SWD duration is 3 s** (`minSWD = 3` in the source).
* Three distinct elimination rules apply, in order: spikes closer than one cycle
  are merged; lone spikes separated by >= 3 s are dropped; spike groupings
  shorter than 1.5 s are dropped; then clusters shorter than `minSWD` are dropped.
* The baseline is obtained by fitting a Gaussian to the voltage histogram, not by
  taking the mean.
* The bandpass is built as ``fmax + [-0.75 -0.5 0 0.5 0.75]`` passed as a COLUMN
  to ``designFilterBP(Fpass, 16, 0.5, 16, 1000/dt)`` -- i.e. passband +/-0.5 Hz,
  stopband +/-0.75 Hz, ripple 0.5, attenuation 16. **The paper's '+/-2 Hz
  passband, +/-4 Hz stopband' does not match the code.** Follow the code.
* ``fmax`` comes from ``oscFreq(EEGfilt, dt, 'SWDs_human')`` -- hardcoded to the
  3-6 Hz band, so a genuine ~7 Hz rodent SWD is mis-measured and then missed
  entirely. Reproduce this faithfully, but do not use it for the ~7 Hz route.
* Thresholds are ``baseline - k*SD_CONST`` for k = 1, 1.96 (norminv .975) and
  2.576 (norminv .995), where ``baseline`` is ``b1`` of a ``gauss1`` fit to a
  histogram of the filtered signal binned at 0.0001 over
  ``[floor(min), ceil(max)]``. ``c1`` of that fit is NOT used.
* **``SD_CONST`` is hardcoded in the source**, not computed:
  ``sdEEGfilt = 1.28074765136489`` (line 127), with ``std(EEGfiltBP)`` commented
  out on the line above. The detector is therefore NOT scale-invariant. Port it
  faithfully for C6.1, but expose ``adaptive_sd=True`` to restore the computed
  value, because the sweep needs it -- see docs/matlab_dependencies.md section 3.
* `edgeOverlap=False` is the MATLAB default, but every caller inside the authors'
  own analysis scripts passes `True`. Support both; default to False to match the
  function, and state the choice explicitly at each call site.

Only four Signal Processing Toolbox functions are used -- `butter`, `filtfilt`,
`filter`, `findpeaks` -- each with a direct `scipy.signal` equivalent. Note that
`scipy.signal.find_peaks` differs from MATLAB `findpeaks` in plateau handling, so
plateau cases must be checked against the reference rather than assumed.
"""
from dataclasses import dataclass, field
from typing import Optional

import numpy as np

LARGE_SPIKE_SD = 1.96
BAND_OFFSETS_HZ = (-0.75, -0.5, 0.0, 0.5, 0.75)   # from the source, not the paper
SD_CONST = 1.28074765136489        # hardcoded in detectEEGspikesSWDs.m line 127
HIST_BIN_WIDTH = 0.0001            # histcounts edge spacing
MIN_SWD_S = 3.0
BANDS_HZ = {"spindles": (6.0, 16.0), "SWDs_human": (3.0, 6.0),
            "SWDs_rodent": (6.0, 9.0), "delta": (1.0, 5.0), "slow": (0.0, 1.0)}
PASSBAND_RIPPLE = 0.5
STOPBAND_ATTENUATION = 16


@dataclass
class SWDResult:
    """Detection output. Mirrors the MATLAB return values that we actually use.

    Attributes
    ----------
    spike_times, spike_idx
        All detected EEG spikes.
    large_spike_times, large_spike_idx
        Spikes exceeding LARGE_SPIKE_SD relative to baseline.
    swd_bounds
        (n_swd, 2) array of (start, end) sample indices.
    interictal_bounds
        (n_interictal, 2) array of (start, end) sample indices.
    wave_times
        Wave (trough) times within SWD boundaries.
    swc_phase
        Per-sample SWC phase; NaN outside spike-wave complexes.
    max_power_frequency
        Frequency of maximum spectral power, used to pick the filter centre.
    """
    spike_times: np.ndarray
    spike_idx: np.ndarray
    large_spike_times: np.ndarray
    large_spike_idx: np.ndarray
    swd_bounds: np.ndarray
    interictal_bounds: np.ndarray
    wave_times: np.ndarray
    swc_phase: np.ndarray
    max_power_frequency: float
    meta: dict = field(default_factory=dict)


def detect_swds(eeg, dt_ms, edge_overlap=False, large_only=False):
    """Detect SWDs and their constituent spikes in an EEG trace.

    Parameters
    ----------
    eeg : array_like
        EEG vector. For the model, the summed-synaptic-current proxy.
    dt_ms : float
        Sampling interval in ms.
    edge_overlap : bool
        If False (default, matching the MATLAB), SWDs and interictal periods
        overlapping the record boundaries are unmarked.
    large_only : bool
        Demarcate SWDs using only spikes above LARGE_SPIKE_SD.

    Returns
    -------
    SWDResult
    """
    raise NotImplementedError(
        "Port of detectEEGspikesSWDs.m pending -- see module docstring for the "
        "specification and validate_against_matlab for the acceptance contract."
    )


def swd_frequency(result, dt_ms):
    """Mean within-SWD spike-wave frequency in Hz, per detected SWD.

    Used for criteria C4.1 (~4 Hz human-like) and C4.7 (~7-8 Hz rodent-like).
    """
    raise NotImplementedError


def evoked_swd_probability(results, n_trials=None):
    """P(SWD | standardised perturbation) across repeated trials at one
    parameter point.

    This is the graded boundary coordinate the design depends on -- see the
    project README (H1b/H1c). A spontaneous-onset binary is explicitly NOT the
    measure.
    """
    raise NotImplementedError


def validate_against_matlab(matlab_output_path="swd_reference.mat", tol_samples=1):
    """Acceptance contract for criterion C6.1.

    Compares this port against `swd_reference.mat`, produced by running
    `analysis/matlab_reference/make_reference.m` in MATLAB (see that folder's
    README). The reference carries eight deterministic traces -- generated with
    `rng(42,'twister')` so this module can regenerate them identically -- each
    pinning a documented behaviour: baseline detection, the 3 s minimum, the two
    SD thresholds, both `edgeOverlap` settings, `dt = 0.25 ms`, and the ~7 Hz
    rodent-like regime. The
    port passes when, for the same input:

    * every spike index matches within ``tol_samples``;
    * SWD and interictal boundary counts match exactly;
    * each SWD boundary matches within ``tol_samples``;
    * ``max_power_frequency`` matches to within 0.05 Hz.

    Returns a dict of per-check booleans plus the discrepancies, so a partial
    pass is visible rather than collapsing to a single False.
    """
    raise NotImplementedError


# ---------------------------------------------------------------------------
# Implementation. Validated layer by layer against MATLAB R2025b via
# analysis/matlab_reference/intermediates/ -- see INTERMEDIATES.md.
# ---------------------------------------------------------------------------

def matlab_buttord_bandpass(Wp, Ws, Rp, Rs):
    """MATLAB's ``buttord`` for the bandpass case (normalised, Nyquist = 1).

    ``scipy.signal.buttord`` is NOT a drop-in substitute: it picks the natural
    frequency to meet the PASSBAND exactly, MATLAB to meet the STOPBAND. The
    orders agree, but the cutoffs differ (3.939431 vs 3.937008 Hz on the
    reference case), which shifts the filtered signal by ~5e-3 and flips spikes
    sitting near a threshold. Reproduces MATLAB's Wn to 0.00e+00.

    Returns (n, Wn) with Wn normalised to Nyquist, as MATLAB does.
    """
    import numpy as _np
    Wp = _np.asarray(Wp, float); Ws = _np.asarray(Ws, float)
    WP = _np.tan(_np.pi * Wp / 2.0)
    WS = _np.tan(_np.pi * Ws / 2.0)
    WA = (WS ** 2 - WP[0] * WP[1]) / (WS * (WP[0] - WP[1]))
    WA = float(_np.min(_np.abs(WA)))
    n = int(_np.ceil(_np.log10((10 ** (0.1 * Rs) - 1) / (10 ** (0.1 * Rp) - 1))
                     / (2 * _np.log10(WA))))
    W0 = WA / ((10 ** (0.1 * Rs) - 1) ** (1.0 / (2 * n)))
    BW = WP[1] - WP[0]
    prod = WP[0] * WP[1]
    c = W0 * BW
    disc = _np.sqrt(c * c + 4 * prod)
    lo, hi = (-c + disc) / 2.0, (c + disc) / 2.0
    return n, (2 / _np.pi) * _np.arctan(_np.array([lo, hi]))


def bandpass(eeg, dt_ms, fmax_hz):
    """Reproduce ``designFilterBP`` + ``filtfilt`` on the EEG.

    Band edges are ``fmax + BAND_OFFSETS_HZ`` (the source's values, not the
    paper's). Agrees with MATLAB to ~3.5e-04 in the interior; see `bandpass`
    caveat in INTERMEDIATES.md for record-edge behaviour.
    """
    from scipy import signal as _sg
    import numpy as _np
    bw = fmax_hz + _np.asarray(BAND_OFFSETS_HZ, float)
    nyq = (1000.0 / dt_ms) / 2.0
    n, Wn = matlab_buttord_bandpass(_np.array([bw[1], bw[3]]) / nyq,
                                    _np.array([bw[0], bw[4]]) / nyq,
                                    PASSBAND_RIPPLE, STOPBAND_ATTENUATION)
    sos = _sg.butter(n, Wn * nyq, btype="bandpass", output="sos", fs=1000.0 / dt_ms)
    return _sg.sosfiltfilt(_np.ascontiguousarray(sos), _np.asarray(eeg, float).ravel())


def th_pks(eeg_bp, threshold, cycle_ms, dt_ms):
    """Port of the local ``thPks``: negative-going peaks past `threshold`.

    Everything at or above the threshold is zeroed, the remainder rectified,
    and peaks taken with ``MinPeakDistance = ceil(cycle/2/dt)``. Returns
    0-based indices (MATLAB's are 1-based).
    """
    from scipy import signal as _sg
    import numpy as _np
    z = _np.asarray(eeg_bp, float).copy()
    z[z >= threshold] = 0.0
    locs, _ = _sg.find_peaks(_np.abs(z), distance=int(_np.ceil(cycle_ms / 2.0 / dt_ms)))
    return locs


def spectra(data, dt_ms):
    """Port of ``spectra.m``. Returns ``(f, powerDBcons)`` -- outputs 1 and 7,
    the two that ``oscFreq`` consumes. Exact to 0.00e+00 against MATLAB."""
    import numpy as _np
    data = _np.asarray(data, float).ravel()
    Fs = 1000.0 / dt_ms
    L = data.size
    n = 1 << (L - 1).bit_length()                 # MATLAB 2^nextpow2(L)
    f = Fs * _np.arange(n // 2 + 1) / n
    Y = (_np.fft.fft(data, n) / Fs)[: n // 2 + 1]
    P1 = _np.abs(Y) ** 2
    P1[1:-1] *= 2                                  # powerCons
    with _np.errstate(divide="ignore"):
        return f, 10 * _np.log10(P1)


def osc_freq(eeg, dt_ms, kind):
    """Port of ``oscFreq.m`` -> ``(oscillationFrequency, maxPower)``.

    ``kind`` is one of BANDS_HZ. Note the detector calls this internally with
    'SWDs_human' regardless of the actual rhythm -- see docs/matlab_dependencies.md.
    """
    import numpy as _np
    eeg = _np.asarray(eeg, float).ravel()
    f, pdb = spectra(eeg - _np.mean(eeg), dt_ms)
    lo, hi = BANDS_HZ[kind]
    m = (f >= lo) & (f <= hi)
    sub, foi = pdb[m], f[m]
    i = int(_np.argmax(sub))
    return foi[i], sub[i]


def eliminate_pks(t_pks, pks, pks_locs, distance):
    """Port of the local ``eliminatePks`` in ``detectEEGspikesSWDs.m``.

    Drops peaks that are further than ``distance`` from BOTH neighbours -- the
    detector's way of keeping only spikes that occur in runs. ``t_pks`` is in
    seconds and ``distance`` is ``1.5 * cycle / 1000``, also seconds.

    The MATLAB original indexes ``tPks(peak+1)`` on the first iteration without
    guarding the length, so a single-peak input raises there. That case is
    treated here as "nothing to compare against, keep it", which is the only
    sane reading; it cannot be validated against the reference because no
    reference case produces exactly one peak.
    """
    import numpy as _np
    t = _np.asarray(t_pks, float).ravel()
    n = t.size
    if n <= 1:
        return (_np.asarray(t_pks).ravel(), _np.asarray(pks).ravel(),
                _np.asarray(pks_locs).ravel())
    gap_prev = _np.empty(n); gap_next = _np.empty(n)
    gap_prev[1:] = t[1:] - t[:-1]; gap_prev[0] = _np.inf
    gap_next[:-1] = t[1:] - t[:-1]; gap_next[-1] = _np.inf
    # First and last peaks are judged on their one real neighbour only.
    keep = ~(((gap_prev > distance) | ~_np.isfinite(gap_prev))
             & ((gap_next > distance) | ~_np.isfinite(gap_next)))
    keep[0] = not (gap_next[0] > distance)
    keep[-1] = not (gap_prev[-1] > distance)
    return (t[keep], _np.asarray(pks).ravel()[keep],
            _np.asarray(pks_locs).ravel()[keep])


def _merge_adjacent(t_grp, min_swd):
    """Initial cluster labelling.

    MATLAB calls ``kmeans(tPksGrp2', k)`` with ``k = numel(tPksGrp2)`` -- one
    centroid per spike -- so with distinct spike times every point lands in its
    own cluster and the call is a no-op. Only the grouping matters downstream
    (labels are compared for equality, never used as values), so a trivial
    1..n labelling is equivalent and avoids reproducing MATLAB's kmeans.
    """
    import numpy as _np
    t = _np.asarray(t_grp, float).ravel()
    ids = _np.arange(1, t.size + 1)
    for i in range(t.size - 1):
        if t[i + 1] - t[i] <= min_swd / 2.0:
            ids[i + 1] = ids[i]
    return ids


def cluster_spikes(t_grp2, locs_grp2, t_grp95, cycle_ms, dt_ms, min_swd=MIN_SWD_S):
    """Port of the clustering and cluster-rejection stage.

    Returns ``(cluster_ids_reordered, keep_mask)`` over the input spikes.
    ``tPksGrp99`` is ``tPksGrp95`` in the deposited code (line 174), so the
    second rejection test reuses the 1.96 SD set.
    """
    import numpy as _np
    t2 = _np.asarray(t_grp2, float).ravel()
    t95 = _np.asarray(t_grp95, float).ravel()
    ids = _merge_adjacent(t2, min_swd)

    remove = _np.zeros(t2.size, bool)
    run_needed = (min_swd * 0.25) / (cycle_ms / 1000.0)
    for cl in _np.unique(ids):
        sel = ids == cl
        span = t2[sel]
        # Test 1: the 1.96 SD spikes inside this cluster must span >= minSWD.
        inside = t95[(t95 >= span[0]) & (t95 <= span[-1])]
        if inside.size == 0 or inside[-1] - inside[0] + dt_ms / 1000.0 < min_swd:
            remove[sel] = True
            continue
        # Test 2: same set, >= minSWD/2, plus a run of spikes closer than one cycle.
        if inside[-1] - inside[0] + dt_ms / 1000.0 < min_swd / 2.0:
            remove[sel] = True
            continue
        count = 1
        count_max = 1
        hit = False
        for i in range(inside.size - 1):
            if inside[i + 1] - inside[i] < cycle_ms / 1000.0:
                count += 1
            else:
                count_max = max(count_max, count)
                count = 1
            if count >= run_needed or count_max >= run_needed:
                hit = True
                break
        if not hit:
            remove[sel] = True

    keep = ~remove
    kept = ids[keep]
    reordered = _np.zeros(kept.size, int)
    seen = []
    for v in kept:                                  # unique(..., 'stable')
        if v not in seen:
            seen.append(v)
    for rank, v in enumerate(seen, start=1):
        reordered[kept == v] = rank
    return reordered, keep


def find_waves(eeg_filt, cycle_ms, dt_ms):
    """Port of ``findpeaks(EEGfilt, 'MinPeakDistance', ceil(cycle/2/dt))``.

    Returns 0-based indices of the positive peaks (the 'waves').
    """
    import numpy as _np
    from scipy.signal import find_peaks
    d = int(_np.ceil(cycle_ms / 2.0 / dt_ms))
    locs, _ = find_peaks(_np.asarray(eeg_filt, float).ravel(), distance=max(d, 1))
    return locs


def mark_swds(n_samples, locs_grp2_0b, cluster_ids, wave_locs_0b):
    """Port of the SWD demarcation loop. Returns a label vector, 0 = not in SWD.

    Each cluster is extended outward to the nearest wave peak on either side,
    or to the record boundary when there is none.
    """
    import numpy as _np
    swds = _np.zeros(n_samples, int)
    locs = _np.asarray(locs_grp2_0b, int).ravel()
    for cl in _np.unique(cluster_ids):
        sel = locs[cluster_ids == cl]
        left = wave_locs_0b[wave_locs_0b < sel[0]]
        start = 0 if left.size == 0 else int(left.max())
        right = wave_locs_0b[wave_locs_0b > sel[-1]]
        end = n_samples - 1 if right.size == 0 else int(right.min())
        swds[start:end + 1] = cl
    return swds


def mark_interictal(swds):
    """Port of the interictal-period loop.

    Labels each gap before SWD ``cl`` with ``cl``, and the tail after the last
    SWD with ``cl+1``. Note the MATLAB original leaks ``clOI`` out of the loop
    to compute the tail, so with no clusters at all it would raise; the caller
    there has already returned early in that case.
    """
    import numpy as _np
    swds = _np.asarray(swds, int).ravel()
    inter = _np.zeros(swds.size, int)
    clusters = _np.unique(swds[swds > 0])
    if clusters.size == 0:
        return inter
    last = None
    for cl in clusters:
        idx = _np.flatnonzero(swds == cl)
        start = 0 if cl == clusters[0] else _np.flatnonzero(swds == cl - 1)[-1] + 1
        end = idx[0] - 1
        if end >= start:
            inter[start:end + 1] = cl
        last = idx
    tail = last[-1] + 1
    if tail < swds.size:
        inter[tail:] = clusters[-1] + 1
    return inter


def apply_edge_overlap(swds, interictal_vec):
    """Port of the ``edgeOverlap`` block.

    Zeroes any SWD or interictal period that touches the start or end of the
    record, since a truncated episode has no measurable duration. Returns new
    arrays. The authors' own callers pass ``edgeOverlap = true``.
    """
    import numpy as _np
    out = []
    for v in (swds, interictal_vec):
        a = _np.asarray(v, int).ravel().copy()
        if a.size and a[0]:
            a[: _np.flatnonzero(a == a[0])[-1] + 1] = 0
        if a.size and a[-1]:
            a[_np.flatnonzero(a == a[-1])[0]:] = 0
        out.append(a)
    return tuple(out)


def hilbert_phase(data, centre=0.0):
    """Port of ``hilbertTransform`` followed by ``recentrePhase``.

    Returns the instantaneous phase of ``data`` wrapped into
    ``[centre-pi, centre+pi]``. The detector calls this on the NEGATED
    band-passed signal, consistent with spikes being negative deflections.
    """
    import numpy as _np
    from scipy.signal import hilbert as _hilbert
    # hilbertTransform.m does `h = hilbert(data'); h = h';` and in MATLAB `'`
    # on a COMPLEX array is the conjugate transpose, so the helper returns the
    # conjugate of the analytic signal and its phase is sign-flipped relative to
    # the usual convention. Reproduced here deliberately: the reference matches
    # -angle(hilbert(x)) to 1.3e-15, and matching their output is the point.
    ph = -_np.angle(_hilbert(_np.asarray(data, float).ravel()))
    # recentrePhase only moves values STRICTLY outside the limits, so a value
    # sitting exactly on +pi stays put. A modulo would wrap it to -pi and
    # disagree with MATLAB by 2*pi at those samples.
    upper, lower = centre + _np.pi, centre - _np.pi
    hi = ph > upper
    if hi.any():
        ph[hi] -= 2 * _np.pi * _np.ceil((ph[hi] - upper) / (2 * _np.pi))
    lo = ph < lower
    if lo.any():
        ph[lo] += 2 * _np.pi * _np.ceil((lower - ph[lo]) / (2 * _np.pi))
    return ph


def mark_swcs(n_samples, locs_grp_0b, wave_locs_0b, phase_vec):
    """Port of the SWC demarcation loop -> ``(swcs, phase)``.

    Each spike-and-wave complex runs from the wave peak before its spike to the
    one after. Both arrays are NaN outside any complex. The MATLAB original
    extends only the LAST complex to include its right-hand wave peak
    (``endSWC = min(rightWaveLocs)`` rather than ``- 1``), so complexes abut
    without overlapping except at the final one.
    """
    import numpy as _np
    swcs = _np.full(n_samples, _np.nan)
    ph = _np.full(n_samples, _np.nan)
    locs = _np.asarray(locs_grp_0b, int).ravel()
    wl = _np.asarray(wave_locs_0b, int).ravel()
    for i, loc in enumerate(locs):
        left = wl[wl < loc]
        right = wl[wl > loc]
        if left.size == 0 or right.size == 0:
            continue                       # MATLAB max([]) / min([]) give []
        start = int(left.max())
        end = int(right.min()) if i == locs.size - 1 else int(right.min()) - 1
        swcs[start:end + 1] = i + 1
        ph[start:end + 1] = phase_vec[start:end + 1]
    return swcs, ph


def gauss1_baseline(eeg_filt_bp, bin_width=HIST_BIN_WIDTH):
    """Port of the baseline estimate -> ``(baseline, sd_baseline, a1)``.

    MATLAB fits ``gauss1`` -- ``a1*exp(-((x-b1)/c1)^2)`` -- to a histogram of the
    band-passed signal and takes ``b1`` as the baseline. Note ``c1`` is NOT a
    standard deviation: gauss1 has no 1/2 in the exponent, so ``c1 = sqrt(2)*sigma``.
    The detector assigns it to ``sdBaseline`` but never uses it for a threshold,
    so the discrepancy does not propagate -- thresholds come from ``sdEEGfilt``.
    """
    import numpy as _np
    from scipy.optimize import curve_fit
    x = _np.asarray(eeg_filt_bp, float).ravel()
    edges = _np.arange(_np.floor(x.min()), _np.ceil(x.max()) + bin_width, bin_width)
    counts, edges = _np.histogram(x, bins=edges)
    centres = edges[:-1] + (edges[1] - edges[0]) / 2.0

    def g1(t, a1, b1, c1):
        return a1 * _np.exp(-(((t - b1) / c1) ** 2))

    p0 = [counts.max(), centres[int(_np.argmax(counts))], _np.std(x) * _np.sqrt(2)]
    popt, _ = curve_fit(g1, centres, counts.astype(float), p0=p0, maxfev=20000)
    a1, b1, c1 = popt
    return float(b1), float(abs(c1)), float(a1)


def detect_swds(eeg, dt_ms, edge_overlap=True, adaptive_sd=False,
                osc_type="SWDs_human"):
    """Full detector: EEG in, SWD/interictal/spike structure out.

    ``adaptive_sd`` restores ``std(EEGfiltBP)`` in place of the hardcoded
    ``sdEEGfilt`` constant (detectEEGspikesSWDs.m line 127). The deposited code
    uses the constant, so the default reproduces published behaviour; the switch
    exists because the constant makes detection non-scale-invariant, which is a
    confound for any sweep that changes EEG amplitude.

    ``osc_type`` is hardcoded to 'SWDs_human' in the original, which cannot see
    the ~7 Hz rodent route -- pass 'SWDs_rodent' for that.
    """
    import numpy as _np
    from scipy.stats import norm as _norm

    eeg = _np.asarray(eeg, float).ravel()
    fmax, _ = osc_freq(eeg, dt_ms, osc_type)
    cycle_ms = (1000.0 / fmax) * 1.1
    bp = bandpass(eeg, dt_ms, fmax)
    sd = float(_np.std(bp, ddof=1)) if adaptive_sd else SD_CONST
    baseline, sd_baseline, _a1 = gauss1_baseline(bp)

    ks = (1.0, float(_norm.ppf(0.975)), float(_norm.ppf(0.995)))
    thresholds = [baseline - k * sd for k in ks]
    locs = [th_pks(bp, t, cycle_ms, dt_ms) for t in thresholds]
    t_pks = [l * dt_ms / 1000.0 for l in locs]

    distance_s = 1.5 * cycle_ms / 1000.0
    grp = [eliminate_pks(tp, bp[l], l, distance_s) for tp, l in zip(t_pks, locs)]
    t_grp, _p_grp, l_grp = grp[0]
    t_grp95, _p95, l_grp95 = grp[1]

    if t_grp.size == 0 or t_grp95.size == 0:
        zero = _np.zeros(eeg.size, int)
        return {"fmax_hz": fmax, "cycle_ms": cycle_ms, "baseline": baseline,
                "sd_used": sd, "swds": zero, "interictal": zero,
                "n_swds": 0, "spike_locs": _np.array([], int),
                "large_spike_locs": _np.array([], int)}

    ids, keep = cluster_spikes(t_grp, l_grp, t_grp95, cycle_ms, dt_ms)
    wave_locs = find_waves(eeg, cycle_ms, dt_ms)
    swds = mark_swds(eeg.size, l_grp[keep].astype(int), ids, wave_locs)
    inter = mark_interictal(swds)
    if edge_overlap:
        swds, inter = apply_edge_overlap(swds, inter)
    return {"fmax_hz": fmax, "cycle_ms": cycle_ms, "baseline": baseline,
            "sd_baseline": sd_baseline, "sd_used": sd,
            "swds": swds, "interictal": inter,
            "n_swds": int(_np.unique(swds[swds > 0]).size),
            "spike_locs": l_grp[keep].astype(int),
            "large_spike_locs": l_grp95.astype(int)}
