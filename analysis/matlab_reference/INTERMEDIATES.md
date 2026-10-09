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
