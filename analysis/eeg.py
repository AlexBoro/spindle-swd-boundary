"""Build the EEG proxy from a simulation's per-cell .dat output.

Reproduces the forward model in the authors' ``readDataThCx_EEG.m``: a
distance-weighted sum of synaptic currents over cortical cells only, followed by
a 40 Hz Butterworth low-pass.

Each ``saveData = 50`` file holds three rows -- Vm, iGlu (AMPA+NMDA) and iGABA
(GABA-A+GABA-B) -- after a ``"<nrows> <nsamples>"`` header. Filename layout is
``z50_Cx3data_<layer>_<index>_<celltype>.dat``; the layer character and the
4-digit index give the cell's depth and lateral offset.
"""
import glob
import os

import numpy as np

LAYER_DEPTH_UM = {"2": 351.8, "4": 693.4, "5": 1089.4, "6": 1597.2}
GABA_DEPTH_OFFSET_UM = 500.0
CELL_SPACING_UM = 20.0
COLUMN_CENTRE = 49.5                 # centre of 100 cells per layer
CONDUCTIVITY = 230.0 / (4.0 * np.pi)
CONV_FACT = 1e-3 * 1e1 * 1e3         # nA->uA, cm->mm, um^-1->mm^-1
LOWPASS_HZ = 40.0
LOWPASS_STOP_HZ = 60.0


def build_eeg(model_dir, dt_ms=0.25, lowpass=True):
    """Return ``(eeg_raw, eeg_lowpass)`` for one run's output directory.

    Only cortical (``Cx3data``) files contribute, matching the original.
    """
    from scipy import signal

    paths = sorted(p for p in glob.glob(os.path.join(model_dir, "*.dat"))
                   if "Cx3data" in os.path.basename(p))
    if not paths:
        raise FileNotFoundError("no Cx3data .dat files in %s" % model_dir)

    layer = {p: os.path.basename(p)[12] for p in paths}
    index = {p: int(os.path.basename(p)[14:18]) for p in paths}
    first = {}
    for p in paths:
        first.setdefault(layer[p], index[p])

    eeg = None
    for p in paths:
        with open(p) as fh:
            fh.readline()
            fh.readline()                                   # Vm, unused here
            i_glu = np.fromstring(fh.readline(), sep="\t")
            i_gaba = np.fromstring(fh.readline(), sep="\t")
        if eeg is None:
            eeg = np.zeros_like(i_glu)
        h = LAYER_DEPTH_UM[layer[p]]
        pos = abs(index[p] - first[layer[p]] - COLUMN_CENTRE) * CELL_SPACING_UM
        eeg += CONV_FACT * CONDUCTIVITY * i_glu / np.sqrt(h ** 2 + pos ** 2)
        eeg += CONV_FACT * CONDUCTIVITY * i_gaba / np.sqrt((h + GABA_DEPTH_OFFSET_UM) ** 2 + pos ** 2)

    if not lowpass:
        return eeg, None
    nyq = (1000.0 / dt_ms) / 2.0
    n, wn = signal.buttord(LOWPASS_HZ / nyq, LOWPASS_STOP_HZ / nyq, 0.5, 10)
    sos = signal.butter(n, wn, btype="low", output="sos")
    return eeg, signal.sosfiltfilt(np.ascontiguousarray(sos), eeg)
