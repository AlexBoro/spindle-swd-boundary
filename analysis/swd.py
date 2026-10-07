"""Spike-and-wave discharge detection.

Port target: `detectEEGspikesSWDs.m` (776 lines) from the vendored model tree.
NOT YET IMPLEMENTED -- this module fixes the interface and the validation
contract so the port is well defined. Criterion C6.1 in
docs/acceptance_criteria.md is not satisfied until `validate_against_matlab`
passes.

Specification taken from the MATLAB source and from Dervinis & Crunelli 2023
(doi:10.1111/cns.14204):

* Input is an EEG vector plus the sampling interval `dt` in ms. The model's EEG
  proxy is the summed synaptic current (`saveData = 30/40` modes).
* Spikes are detected on the EEG; a spike is classed "large" when it exceeds
  **1.96 SD** relative to the EEG baseline. The MATLAB returns both the full and
  large-spike-demarcated variants of every downstream quantity.
* SWDs are demarcated by spikes; waves are the troughs within SWD boundaries.
* Spike-wave-complex (SWC) phase is obtained by Hilbert transform of the EEG
  bandpass-filtered with a Butterworth filter whose **passband is centred +/-2 Hz
  and stopband +/-4 Hz** around the SWD oscillation frequency (~4 Hz human-like
  or ~7 Hz rodent-like), passband ripple and stopband attenuation as in the paper.
* Interictal periods are the complement of SWDs.
* `edgeOverlap=False` (the MATLAB default) unmarks SWDs and interictal periods
  that overlap the start or end of the record.
"""
from dataclasses import dataclass, field
from typing import Optional

import numpy as np

LARGE_SPIKE_SD = 1.96
PASSBAND_HZ = 2.0
STOPBAND_HZ = 4.0


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


def validate_against_matlab(eeg, dt_ms, matlab_output_path, tol_samples=1):
    """Acceptance contract for criterion C6.1.

    Compares this port against saved MATLAB output on an identical trace. The
    port passes when, for the same input:

    * every spike index matches within ``tol_samples``;
    * SWD and interictal boundary counts match exactly;
    * each SWD boundary matches within ``tol_samples``;
    * ``max_power_frequency`` matches to within 0.05 Hz.

    Returns a dict of per-check booleans plus the discrepancies, so a partial
    pass is visible rather than collapsing to a single False.
    """
    raise NotImplementedError
