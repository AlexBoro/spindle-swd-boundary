# Sweep 2 — the same conductance, from the spindle baseline

> **A note on the name.** `GLUfullsyn.gbase_c` is the thalamic **K⁺ leak**,
> not a glutamatergic conductance. `glu3.mod:84` declares it as "baseline K+
> leak conductance" (µS) with `Erev_c = -95 mV` (E_K), and line 196 drives
> `NONSPECIFIC_CURRENT iKLeak = (gbase_c - g_c)*(v - Erev_c)`. It sits on a
> `GLUfullsyn` object only because that mechanism bundles AMPA (`_a`), NMDA
> (`_b`) and a metabotropic component (`_c`) whose conductance `g_c`
> *subtracts* from the leak.

Identical protocol to `sweeps/gkl_tcfo/` (90 s, Modal, single seed, first 30 s
discarded) with one change: `state = spindles_long` instead of `wake_long`, and
the TC_FO `GLUfullsyn.gbase_c` swept over a much wider range — from the spindle
baseline of 0.0008 up to 0.0025, which is 3.1× baseline and 1.8× the value at
which the wake route produced SWDs.

This is the sweep the project's hypothesis actually needs. H1b says the
consolidation optimum lies a small normalised distance from the spike-wave
transition. Spindles are the regime in which spindle-timed plasticity happens,
so the distance that matters is measured *from the spindle state*, not from
wake.

## Result: the spindle state does not reach spike-wave on this axis

**Zero SWDs at all ten points.** The same detector, with the same fixed
threshold, found SWDs at seven of ten points on the wake sweep.

Read that as **no 3–6 Hz spike-wave**, not as no spike-wave: the deposited
detector hardcodes `oscFreq(..., 'SWDs_human')`. Re-running this sweep in the
6–9 Hz rodent band returns 1–3 "SWDs" at *every* point including the untouched
baseline — it flags the spindle epochs themselves — and two candidate
discriminators (harmonic ratio, absolute band power) fail to separate spindles
from known SWDs. `sweeps/gabaa_cx_spindles/README.md` gives the numbers. The
detector-independent part of the result is the spectrum: the dominant rhythm
never leaves 8.4–9.3 Hz, so the abrupt step to a slower rhythm that marked the
wake route does not happen here.

| `gbase_c` (µS) | EEG peak (Hz) | SWDs | spindles/min | spindle freq (Hz) | band power | epoch duty (%) |
|---|---|---|---|---|---|---|
| 0.0008 *(baseline)* | 9.28 | 0 | 6.0 | 9.65 | 3.34 | 28.5 |
| 0.0010 | 9.03 | 0 | 7.0 | 8.86 | 3.63 | 28.2 |
| 0.0012 | 8.79 | 0 | 8.0 | 8.94 | 1.43 | 27.2 |
| 0.0013 | 8.67 | 0 | 6.0 | 9.00 | 1.89 | 25.1 |
| 0.0014 | 9.03 | 0 | 9.0 | 8.90 | 2.36 | 27.7 |
| 0.0015 | 8.91 | 0 | 6.0 | 8.83 | 2.87 | 42.0 |
| 0.0016 | 8.91 | 0 | 5.0 | 9.06 | 2.57 | 33.7 |
| 0.0018 | 8.42 | 0 | 7.0 | 8.33 | 2.54 | 54.6 |
| 0.0021 | 9.03 | 0 | 7.0 | 8.47 | 2.03 | 36.2 |
| 0.0025 | 8.67 | 0 | 4.0 | 8.55 | 1.34 | 20.0 |

The EEG's dominant rhythm stays at 8.4–9.3 Hz throughout — it never performs
the abrupt 8→5 Hz step that marked the transition on the wake route. Spindling
persists across the whole range (4–9 events per minute at 8.3–9.7 Hz).

**The axis is not inert.** The infra-slow epoch duty cycle doubles from 28 % at
baseline to 54.6 % at 0.0018 and then falls to 20 % at 0.0025, and overall EEG
amplitude declines monotonically from 3.96 to 2.76 µV. The parameter moves the
network; it just moves it somewhere other than spike-wave. (With two to six
epochs per point and one seed, the duty-cycle non-monotonicity is suggestive,
not established. The SWD absence is not fragile in the same way: ten points,
zero detections, same detector that fired on seven of ten wake points.)

## Why: the two baselines differ in more than this one conductance

The wake route was a one-parameter continuation because `wake_long` and
`SWDs_long` are byte-identical apart from TC_FO `gbase_c`. `spindles_long` is
not. A variable-level diff of every state-dependent assignment gives:

| | spindles_long | wake_long |
|---|---|---|
| TC `g_naleak` (FO / HO) | **0 / 0** | **0.000052 / 0.00003** |
| TC `GLUfullsyn.gbase_c` (FO / HO) | 0.0008 / 0.0021 | 0.001325 / 0.0045 |
| NRT `GLUfullsyn.gbase_c` | 0.0004 | 0.0002 |
| NRT `gkbar1_iahp` | 0.0003 | 0.01 × 0.0003 |
| NRT `gkbar2_iahp` | 0.01 × 0.00006 | 0.00006 |
| cortical `reduce` | −0.000025 | +0.00002 |
| cortical `g_pas` | 0.0000293 | 0.0000293 − reduce/2 |

(NRT `g_naleak` is 0 in both — only `slow_*` sets it nonzero, at 0.000004 — so
it is not one of the differences despite appearing in a state-grouped test.)

The first row is the likely gate. `TCcell.hoc:169` gives the thalamic Na leak a
nonzero value **only** for `wake_*` and `SWDs_*`; every sleep state falls to the
`else` clause at 0. Without it, relay cells sit hyperpolarised. Dervinis &
Crunelli's own Tables S1/S2 report that TC_FO cells fire **tonically and
essentially never burst** during SWDs (0 % bursting in 13 of 15 pathology
columns), and tonic relay firing is exactly what the Na leak enables. On that
reading, raising the K⁺ leak from the spindle configuration cannot produce
spike-wave because the cells it would have to recruit are not in a tonic-capable
regime at all. **This is a hypothesis consistent with the sweep, not something
the sweep tested** — isolating it needs a run with `g_naleak` restored and
everything else left at spindle values.

## What this means for the project

It does **not** refute H1b, but it rules out one way of making H1b measurable.
"Normalised distance from the spindle operating point to the spike-wave
boundary" is undefined along this axis, because the boundary is not reachable
along it: the two regimes are separated by a change of configuration, not by a
distance.

Three readings remain open, and they are distinguishable by experiment:

1. **The axis is wrong, not the question.** A *cortical* parameter is
   state-independent in this model — `GABAsyn.gbar_a` and `GLUsyn.gbar_a` are
   each assigned exactly once, outside every `strcmp` chain — so a cortical
   route to SWD should operate from any vigilance state. The authors' own route
   C4.4 (cortical GABA-A at −10 % and −25 %) is the natural test, and it is
   running next.
2. **The gate is specific and removable.** If TC `g_naleak` is what separates
   them, then a spindle state with the wake Na leak restored should have a
   boundary, and the distance to it becomes measurable.
3. **The regimes are genuinely disjoint in this model.** If no single-parameter
   axis connects spindles to spike-wave, then H1b has to be reformulated in
   terms of a boundary in a plane rather than a distance along a line — or the
   model cannot address it.

Nothing here is decided by this sweep alone. What the sweep does establish is
that the obvious axis — the one the authors themselves use to reach SWD — does
not do the job from the regime the hypothesis lives in, and that the project
cannot assume otherwise.

## Reproducing

```
python sim/job_sweep.py 90000 spindles_long tc_fo_gkl 0.0014
```
`summary.csv` carries the Modal job id for every point.

One caveat on the low end of the range. The derived tonic conductance is set
twice in `TCcell.hoc`, with **different denominators per thalamic order**:
`gbar_c = min(0.0017, (gbase_c/0.0012)*0.0017)` for FO at line 554, and
`/0.000775` for HO at line 581. Both sit *outside* the `strcmp(state)` arms —
after the chain, applied to whatever the chain left in `gbase_c` — so a diff
that only reads branch bodies sees the HO form and misses the FO one. This
sweep moves the **FO** parameter, so `/0.0012` is the relevant formula: it
saturates at `gbase_c` ≥ 0.0012, meaning the two lowest points (0.0008 and
0.0010) move the tonic conductance as well as the leak, while the eight points
from 0.0012 up are single-parameter. The wake sweep in `sweeps/gkl_tcfo/` lies
entirely above 0.0012 and is single-parameter throughout.
