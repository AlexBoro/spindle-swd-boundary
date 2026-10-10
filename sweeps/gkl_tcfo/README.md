# Sweep 1 — TC_FO tonic K+ conductance, wake → SWD

The project's first parameter sweep. Ten points along `GLUfullsyn.gbase_c` in
the first-order TC branch of `TCcell.hoc`, 90 s of model time each, `state =
wake_long`, single seed, run on Modal (image `im-MjGYjvPyiWkNx8nW9DPCBa`,
2 cores, 16 GiB). Each job ran ~1.4 h wall and peaked at 26.8 GB RSS. The
first 30 s of every record is discarded as warm-up, leaving 60 s of analysis
window; `summary.csv` is computed over that window.

It was run to answer three questions at once.

## 1. Which baseline did the authors use?

The deposit ships `state = "awake_long"`, which matches no `strcmp` branch, and
the README names it for all five SWD routes. The chains have no `else` clause,
so under `awake_long` every state-dependent conductance silently keeps its
`.mod` default — for this parameter, 0.001 µS instead of 0.001325.

`TCcell.hoc:546` sets the SWD value to 0.001395 with the comment `> 0.0013792`.
That comment is the authors' own statement of where the transition lies.
Sweeping from the `wake_long` baseline, SWDs first appear at **0.001360**, and
the EEG's dominant rhythm drops from 8.06 Hz to 4.88 Hz between 0.001345 and
0.001360. The measured transition is 1.4 % below the authors' stated threshold, and sits
2.6 % above the wake baseline it was swept from. Reaching it from the
`awake_long` default of 0.001 µS would instead require a 36 % rise, which no
reading of "> 0.0013792" supports. **`awake_long` is a typo for `wake_long`**;
the question no longer needs the authors to answer it.

## 2. Where is the boundary, and is it sharp?

Two independent measures agree, and neither is a tuning of the other:

| `gbase_c` (µS) | EEG peak (Hz) | SWDs | duty (%) | mean duration (s) |
|---|---|---|---|---|
| 0.001280 | 9.40 | 0 | 0 | — |
| 0.001325 | 9.28 | 0 | 0 | — |
| 0.001345 | 8.06 | 0 | 0 | — |
| 0.001360 | 4.88 | 1 | 13.7 | 8.25 |
| 0.001372 | 5.00 | 1 | 24.9 | 14.92 |
| 0.001380 | 4.88 | 1 | 24.8 | 14.89 |
| 0.001388 | 4.88 | 1 | 23.1 | 13.85 |
| 0.001395 | 4.76 | 1 | 19.4 | 11.63 |
| 0.001410 | 4.76 | 2 | 24.3 | 7.29 |
| 0.001440 | 4.64 | 2 | 46.1 | 13.82 |

The frequency step is abrupt — 8.06 Hz to 4.88 Hz with nothing in between — at
a step size of 1.5e-5 µS, 1.1 % of the parameter value. Duty cycle, by
contrast, is graded above the boundary and reaches the published range
(16.34–47.15 %) immediately. Intra-SWD frequency across the seven supra-
threshold points is 4.64–5.00 Hz, inside the published 4.60–5.45 Hz.

The subthreshold points are not uniformly quiet: 0.001345 produces four large
spikes with no SWD. A graded precursor below the boundary is useful — it means
the boundary coordinate does not have to be built out of a binary outcome
alone.

Resolution limit: with one seed per point this is a deterministic bisection of
the transition, not an estimate of P(SWD). The planned boundary coordinate
(sigmoid over replicate seeds) still has to be built; this sweep bounds where to
centre it.

## 3. Does the harness work?

Yes. `sim/job_sweep.py` patches one conductance with a uniqueness assertion,
runs, builds the EEG in-container and returns ~8 MB instead of ~7 GB.

## What the sweep also settled about the model

**The authors' SWD route is a one-parameter continuation from wake.** Every
`wake_long`/`SWDs_long` branch pair in `TCcell.hoc`, `NRTcell.hoc` and
`Cx3cell.hoc` is byte-identical — `g_naleak`, `shift_iarg`, `cac_iarg`, the NRT
AHP conductances, the NRT and TC_HO `gbase_c`, the cortical `g_pas` and
`reduce`. The only difference anywhere is TC_FO `gbase_c`: 0.001325 vs
0.001395, a 5.3 % rise. So this sweep is not an approximation of their route;
it is their route, sampled.

**The swept parameter moves alone over this range.** `TCcell.hoc:558` derives
the tonic conductance from the swept one, `gbar_c = min(0.0017,
(gbase_c/0.0012)*0.0017)`. That saturates for any `gbase_c` ≥ 0.0012, so across
0.001280–0.001440 `gbar_c` is pinned at 0.0017 and does not co-vary. Below
0.0012 it would, and a sweep that crosses 0.0012 is a two-parameter sweep
wearing one name.

**The hardcoded `sdEEGfilt` is load-bearing, not a leftover.**
`detectEEGspikesSWDs.m:127` hardcodes the threshold scale at 1.28074765136489
with `std(EEGfiltBP)` commented out on the line above. Re-deriving it from the
data makes the detector scale-invariant — and a scale-invariant detector cannot
see this transition at all: it reports 1–2 "SWDs" at *every* point including
the wake baseline, because the only thing separating wake from SWD in the
band-passed signal is amplitude. Both columns are in `summary.csv`
(`sd_mode = fixed | adaptive`). The fixed constant is the published behaviour
and the one that works. This retires the planned question to the authors about
whether the hardcode was deliberate: whatever the intent, removing it breaks
detection.

## Reproducing

```
python sim/job_sweep.py 90000 wake_long 0.001360
```
returns `sweep_point.npz` (EEG + spike times) and `meta.json`. `summary.csv`
carries the Modal job id for every point.
