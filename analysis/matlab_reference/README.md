# MATLAB reference output for the SWD detector port

The Python port in `analysis/swd.py` must agree with the authors' original
`detectEEGspikesSWDs.m` (criterion C6.1). MATLAB is not reachable from the
analysis sandbox, so the reference is generated on a machine that has it.

## To run

1. Copy this whole folder somewhere convenient.
2. Open MATLAB, `cd` into it.
3. `>> make_reference`
4. Return the `swd_reference.mat` it writes alongside.

Requires the Signal Processing Toolbox (`butter`, `filtfilt`, `findpeaks`).
Nothing is plotted — `detectEEGspikesSWDs.m` sets `showFigs = false` internally.
Takes well under a minute.

## What it does

Builds eight deterministic traces (`rng(42,'twister')`), each exercising a
documented behaviour of the detector, and saves every one of the function's 23
outputs for each. The cases are chosen to pin the elimination rules rather than
just to look realistic:

| Case | What it tests |
|---|---|
| `three_swds` | three episodes well above the 3 s minimum — baseline correctness |
| `noise_only` | no SWDs should be found |
| `short_episodes` | 2 / 1.5 / 1.8 s episodes — all below `minSWD`, must be eliminated |
| `edge_overlap_false` | episodes touching both record edges, unmarked |
| `edge_overlap_true` | the same trace with `edgeOverlap = true` |
| `mixed_amplitude` | episode amplitudes straddling the 1 SD and 1.96 SD thresholds |
| `fine_dt` | `dt = 0.25 ms`, the model's integration step |
| `seven_hz` | rodent-like ~7 Hz intra-SWD frequency |

MATLAB version and creation time are recorded in `reference_meta` so the
reference is traceable.

## Files

`detectEEGspikesSWDs.m`, `oscFreq.m` and `ciplot.m` are copied unmodified from
`model/thalamocortical2/` so the harness is self-contained. Do not edit them.

## Licence of copied files

The MATLAB helpers copied unmodified from `model/thalamocortical2` (Dervinis & Crunelli) in this folder are GPL-3.0, as in the original deposit (see `model/thalamocortical2/LICENSE`). Everything else here is MIT (repository `LICENSE`).
