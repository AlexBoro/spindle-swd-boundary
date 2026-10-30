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
