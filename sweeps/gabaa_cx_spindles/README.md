# Sweep 3 — cortical GABA-A, from the spindle baseline

The follow-up that `sweeps/gkl_tcfo_spindles/` nominated. If the thalamic leak
axis cannot reach spike-wave from the spindle state because the two baselines
differ in their *thalamic* configuration, a **cortical** parameter should not
care: `GABAsyn.gbar_a` is assigned exactly once in `Cx3cell.hoc` (line 695),
outside every `strcmp(state)` chain, so it takes the same value in every
vigilance state. And decreasing it is one of Dervinis & Crunelli's own five
routes to SWD, published at −10 % and −25 %.

Ten points from 0.068 (baseline) down to 0.027 (−60 %), well past both
published levels. Same protocol throughout: `state = spindles_long`, 90 s,
single seed, first 30 s discarded.

## Result: no spike-wave on this axis either

| `gbar_a` (µS) | change | EEG peak (Hz) | SWDs (3–6 Hz) | spindles/min | cortical PY rate (Hz) |
|---|---|---|---|---|---|
| 0.0680 | — | 9.28 | 0 | 6.0 | 1.68 |
| 0.0646 | −5 % | 8.91 | 0 | 6.0 | 1.74 |
| 0.0612 | **−10 %** | 9.16 | 0 | 10.0 | 1.92 |
| 0.0578 | −15 % | 9.40 | 0 | 6.0 | 1.86 |
| 0.0544 | −20 % | 9.03 | 0 | 7.0 | 1.63 |
| 0.0510 | **−25 %** | 8.79 | 0 | 9.0 | 1.65 |
| 0.0476 | −30 % | 9.40 | 0 | 8.0 | 1.81 |
| 0.0408 | −40 % | 9.16 | 0 | 6.0 | 2.03 |
| 0.0340 | −50 % | 8.67 | 0 | 11.0 | 1.58 |
| 0.0270 | −60 % | 9.28 | 0 | 8.0 | 2.13 |

The two published levels are in the table and neither produces anything. The
EEG's dominant rhythm stays at 8.7–9.4 Hz across the whole range; spindling
persists at 6–11 per minute.

**The patch bit, but weakly.** Every point reports `baseline_replaced = 0.068`
and the requested value, and cortical pyramidal firing rises from 1.68 to
2.13 Hz (+27 %) across a 60 % cut in phasic inhibition — roughly monotone,
small. That is itself informative: in the spindle state the network spends
~65 % of its time silent between infra-slow epochs, and cortical activity is
gated by thalamic drive that is simply absent in the gaps. Disinhibiting cortex
does little when there is nothing to disinhibit. It is consistent with the
thalamic-gate reading, though it does not establish it.

**This does not score criterion C4.4.** That criterion is a claim about the
authors' own baseline, and the deposit's SWD protocol starts from `wake_long`
(see `sweeps/gkl_tcfo/`). Running the same axis from `wake_long` is the correct
test of C4.4 and is underway.

## The band problem — what "0 SWDs" does and does not mean

The counts above are the deposited detector as the authors configure it, which
hardcodes `oscFreq(..., 'SWDs_human')` and therefore searches **3–6 Hz**. Zero
means no 3–6 Hz spike-wave. It does not mean no spike-wave.

Re-running both spindle-baseline sweeps with `osc_type='SWDs_rodent'` (6–9 Hz)
returns **1–3 "SWDs" at every point of both sweeps, including the untouched
baselines**. That is not evidence of seizures; it is the detector flagging the
spindle epochs themselves. The detector has no criterion separating "a bounded
run of large, regularly spaced deflections with quiet periods between" from a
spindle epoch other than the frequency band it is told to use — and in this
model the infra-slow epoch structure gives spindles exactly that shape.

Two candidate discriminators were tested on data that contains known SWDs (the
wake sweep) and known spindles, and **neither separates the classes**:

- *Harmonic content.* Spike-wave should be harmonically rich where a spindle is
  near-sinusoidal. Measured P(2f₀)/P(f₀): SWD points 0.108–0.329, spindle
  points 0.055–0.093, but wake points with no SWDs 0.086–0.200 — overlapping
  the SWD range.
- *Absolute band power.* P(f₀) separates cleanly **within** the wake series
  (SWD 1.69–8.48 vs no-SWD 0.45–0.72) but not across states: spindle epochs
  give 2.36–3.56, squarely inside the SWD range.

So the honest statement for both spindle-baseline sweeps is: **no transition to
a slower rhythm occurs** — the abrupt 8.06 → 4.88 Hz step that marked the wake
route never happens, which is a direct spectral observation independent of any
detector — and **no 3–6 Hz spike-wave appears**. Whether a same-band (~9 Hz)
spike-wave appears is *undecidable with the deposited detector*, and settling it
needs a morphology criterion the deposit does not provide and that the two
obvious candidates do not supply.

This also sharpens criterion C4.7. The problem is worse than "the human band
cannot see a 7 Hz SWD": switching to the rodent band makes the detector
non-specific in exactly the regime where spindles live, because spindles occupy
that band.

## Reproducing

```
python sim/job_sweep.py 90000 spindles_long cx_gabaa 0.051
```
`summary.csv` carries the Modal job id for every point.
