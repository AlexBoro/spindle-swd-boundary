# Sweep 4 — cortical GABA-A, from the wake baseline

The same cortical axis as `sweeps/gabaa_cx_spindles/`, run from `wake_long`,
which is the baseline the deposit's SWD protocol actually uses
(`sweeps/gkl_tcfo/`). Two things ride on it: it is the correct test of
criterion C4.4, and it is the second independent axis H1c needs.

Ten points from 0.068 down to 0.034 (−50 %), 90 s each, single seed, first 30 s
discarded.

## Result: a boundary at −15 %

| `gbar_a` (µS) | change | EEG peak (Hz) | SWDs | duty (%) | cortical E rate (Hz) |
|---|---|---|---|---|---|
| 0.0680 | — | 9.28 | 0 | 0 | 30.87 |
| 0.0646 | −5 % | 7.94 | 0 | 0 | 31.45 |
| 0.0612 | **−10 %** | 7.57 | 0 | 0 | 32.14 |
| 0.0578 | **−15 %** | 6.96 | 1 | 13.7 | 32.78 |
| 0.0544 | −20 % | 4.64 | 3 | 32.6 | 33.81 |
| 0.0510 | **−25 %** | 5.49 | 4 | 42.1 | 34.87 |
| 0.0476 | −30 % | 5.49 | 2 | 91.3 | 36.28 |
| 0.0442 | −35 % | 4.64 | 3 | 54.0 | 37.76 |
| 0.0408 | −40 % | 5.13 | 1 | 97.5 | 39.63 |
| 0.0340 | −50 % | 4.52 | 1 | 67.0 | 43.68 |

Across the seven supra-threshold points, intra-SWD frequency is 4.49–5.57 Hz
against a published 4.60–5.45, and duty cycle runs 13.7–97.5 % against a
published 16.34–47.15 % — the deep points run far past anything in the authors'
tables, which is expected since −30 % and beyond are not pathology levels they
report.

The approach is **more gradual than on the thalamic axis**. There the EEG peak
stepped 8.06 → 4.88 Hz with nothing between; here it walks down 9.28 → 7.94 →
7.57 → 6.96 before dropping to 4.64. Intermediate frequencies exist on this
route.

## C4.4 half-reproduces

The criterion is that decreasing cortical `g_GABAa` by 10 % and 25 % produces
SWDs. **−25 % does** (4 discharges, 42 % duty). **−10 % does not** — zero
discharges, and the EEG still peaking at 7.57 Hz. The measured onset is −15 %.

The discrepancy is 5 percentage points of a 10 % perturbation and plausibly a
power problem rather than a disagreement: these are 60 s records with one seed,
and at a marginal setting a route producing of order one discharge per minute
can easily return nothing. Note the direction is opposite to the thalamic axis,
where the measured threshold came in 1.4 % *below* the authors' own figure. Both
discrepancies are small and in opposite directions, which is what sampling noise
looks like and not what a systematic bias looks like. Settling it needs
replicate seeds at −10 %, not a longer argument.

## Both axes reach spike-wave, from opposite directions

With two boundaries located from the same baseline, the axes can be compared:

| | baseline | boundary | change at onset |
|---|---|---|---|
| TC_FO tonic K⁺ leak ↑ | 0.001325 | 0.001360 | **+2.6 %** |
| cortical GABA-A ↓ | 0.068 | 0.0578 | **−15 %** |

In fractional-parameter terms the thalamic axis is about six times closer to its
boundary. That number is not yet a normalised distance — fractional change is
not commensurable across conductances, which is exactly why the design specifies
d = (p\* − p)/σ with σ from the slope of P(SWD) over replicate seeds. This sweep
locates p\* on a second axis; σ still needs the replicate protocol.

What the two axes *do* settle now is the premise behind the design's control.
They move cortical excitatory firing in **opposite directions** — raising the
thalamic leak lowers it from 30.87 to 28.70 Hz, cutting cortical inhibition
raises it from 30.87 to 43.68 Hz — and both reach spike-wave. So the wake state
sits inside a narrow window of cortical firing rate, bracketed by 30.12–30.46 Hz
below and 32.14–32.78 Hz above, and leaving that window in **either** direction
produces SWDs.

Two cautions on reading that. Cortical rate is a consequence of the swept
conductances, not a control parameter, and each axis changes other things
besides; a window in one emergent coordinate is not a proof that the coordinate
is what matters. And with one seed per point the window edges are brackets, not
estimates. But the premise the project's control rests on — that Dervinis &
Crunelli's routes push cortical excitability in opposite directions and both
arrive at spike-wave — is now measured rather than assumed, which is what makes
a matched δ along both kinds of axis an argument that overall network gain
cannot explain.

## Reproducing

```
python sim/job_sweep.py 90000 wake_long cx_gabaa 0.0578
```
`summary.csv` carries the Modal job id for every point.
`../gkl_tcfo/whole_record_cellular.csv` holds the matching whole-record
cellular measures for axis 1.
