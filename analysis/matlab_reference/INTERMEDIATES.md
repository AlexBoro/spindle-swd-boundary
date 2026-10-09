# Detector intermediates (layer-by-layer port validation)

`detectEEGspikesSWDs_dbg.m` is generated from the authors' `detectEEGspikesSWDs.m`
by renaming the function and inserting one block that dumps internal state to the
path in the global `DBG_SAVE_PATH`, immediately after the spike-elimination step.
**No algorithmic line is altered.** Regenerate it rather than editing by hand.

Running it over the eight reference traces produces `dbg_<case>.mat` (~21 MB
total, git-ignored; distributed as an artifact). Each holds the filtered signals,
the exact `designfilt` SOS coefficients and order, the histogram and `gauss1` fit
parameters, all three thresholds, and the spike sets before and after
elimination — enough to check every layer of the port independently instead of
comparing only the final output.

The dumps must be generated from the *same RNG stream* as `make_reference.m`.
Note that `edge_overlap_true` reuses `edge_overlap_false`'s trace **without
drawing from the generator**; regenerating it instead desynchronises every later
case. Verified by comparing `dbg.EEG` against the reference `EEG` for all eight.

## Port status

| Layer | Status |
|---|---|
| `spectra` → `oscFreq` | **exact**, 0.00e+00 on all 8 cases |
| Butterworth order selection | matches (8 sections, order 16) |
| Filter coefficients | **not reproduced** — see below |
| Filtering with MATLAB's own SOS | interior agrees to 3.8e-04 |
| `thPks` spike detection | **exact** location match at all three thresholds, given a matching filtered signal |

### The open problem: `designfilt` cutoff selection

With MATLAB's extracted SOS, the port reproduces every spike location exactly
(76 at 1 SD, 42 at 1.96 SD, 5 at 2.576 SD for `three_swds`). With a filter
designed here via `scipy.signal.buttord` + `butter`, the interior error rises
from 3.8e-04 to 5.4e-03 and spikes near threshold flip.

Both designs agree on order (16) and on the −3 dB band (3.9500–5.0750 Hz), but
differ by ~0.03 dB in the passband and ~0.33 dB in the stopband — `designfilt`
and `buttord` choose slightly different natural frequencies. Designing from the
−3 dB points or the passband edges directly is worse, not better, and no
symmetric rescaling of the band closes it.

This must be resolved before the port can stand alone, since the sweep cannot
call MATLAB per run. Next step: ask MATLAB for `[n, Wn] = buttord(...)` directly
and compare with scipy's, which will show whether the difference is in the order
estimate, the cutoff formula, or the bilinear prewarping.

The transfer-function route is a dead end: at order 16 the direct form is badly
conditioned and `filtfilt(b, a, ...)` returns NaN. Use SOS.

## Resolved: `designfilt` cutoff selection

`scipy.signal.buttord` is not a drop-in substitute for MATLAB's. Both return
order 8 (bandpass order 16), but they choose the natural frequency differently:
**MATLAB picks `Wn` to meet the stopband exactly, scipy to meet the passband.**

| | lower cutoff (Hz) | upper cutoff (Hz) |
|---|---|---|
| MATLAB `buttord` | 3.937007693 | 5.083065030 |
| scipy `buttord` | 3.939431 | 5.079938 |

A 0.0024 Hz difference, but it shifts the filtered signal by ~5e-3 and flips
spikes sitting near a threshold. `analysis/swd.py:matlab_buttord_bandpass`
reproduces MATLAB's `Wn` to **0.00e+00**, after which the interior error drops
from 5.4e-03 to 3.5e-04 and spike detection becomes exact.

Note that comparing SOS matrices element-wise is meaningless here: MATLAB's own
`butter(n, Wn)` and `designfilt` differ by 2.0 in that comparison while
describing the same filter, because the gain is distributed across sections
differently. Compare frequency responses or filtered output instead.

## Remaining gap: `filtfilt` boundary handling

With the cutoffs fixed, the port reproduces MATLAB's spike locations **exactly in
6 of the 8 cases**, at all three thresholds. The two failures are
`edge_overlap_false` and `edge_overlap_true` — by construction the cases with SWD
episodes touching the record boundaries (0–6 s and 54–60 s of a 60 s record).

MATLAB's `filtfilt` and `scipy.signal.sosfiltfilt` extend the signal differently
at the ends. A scan over `padtype` ∈ {odd, even, constant} × `padlen` ∈ [0, 400]
does not close it: interior error stays at 6.45e-02 against ~1e-3 for the
non-edge cases. The discrepancy is confined to the boundaries — the interior is
unaffected.

Practical significance is probably limited, since `edgeOverlap` exists precisely
to mark SWDs overlapping the record ends and the authors' own callers pass
`true`. But it must be settled before C6.1 can be declared met. Options, in order
of preference: replicate MATLAB's `filtfilt` initial-condition scheme directly;
or restrict the criterion to interior spikes and state the exclusion explicitly.
