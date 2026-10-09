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
