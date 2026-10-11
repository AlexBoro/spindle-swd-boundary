# Sweep 7 — is an intermediate tone *susceptible*?

`sweeps/naleak_continuum/` showed that intermediate thalamic Na⁺ leak does not
*spontaneously* produce spike-wave. That is the weaker question. H1b needs the
stronger one: is an intermediate tone **susceptible** — does raising the K⁺ leak
from there produce SWDs the way it does from wake, rather than killing the
network the way it does at the full wake Na leak?

A 3 × 5 grid. Rows are the three tones in the continuum's recovered branch that
keep spindle-band power above 1.5: 2e-5 (38 % of wake), 2.6e-5 (50 %) and 3.2e-5
(62 %). Columns are five K⁺ leak values from 0.0010 to 0.0015, spanning the
spindle baseline up past 0.001360, the value at which the *wake* state produces
SWDs. All on `spindles_long`, 90 s, single seed.

## Result: 14 of 15 dead, 1 alive, no SWDs anywhere

| Na⁺ leak | 0.0010 | 0.0012 | 0.0013 | 0.00136 | 0.0015 |
|---|---|---|---|---|---|
| 2e-5 (38 %) | dead | dead | dead | dead | dead |
| 2.6e-5 (50 %) | dead | dead | dead | dead | dead |
| 3.2e-5 (62 %) | **alive**, no SWD | dead | dead | dead | dead |

The one survivor sits at 3.2e-5 / 0.0010: cortical rate 1.18 Hz, spindle-band
power 1.80, EEG peak 8.55 Hz, zero SWDs. Every dead run shows the same signature
as the gate test — ~1,700–2,400 spikes, all in the first tenth of a second, then
flat EEG.

Taken with the continuum sweep, which had all three of these tones alive at the
spindle baseline of 0.0008, the viable region at intermediate tone is a
knife-edge: alive at 0.0008, dead by 0.0010 for two tones of three and by 0.0012
for all three. **There is no corridor.** Raising the K⁺ leak from an
intermediate tone does not approach spike-wave; it stops the network.

## The state map

`state_map.csv` pools every run on the `spindles_long` background across sweeps
2, 5, 6 and 7 — 43 distinct (Na⁺ leak, K⁺ leak) points — and classifies each as
spindling, awake-like without spindles, or dead.

The viable set is an **L along the two axes**: the whole Na⁺ = 0 row, which
spindles all the way to a K⁺ leak of 0.0025 (3.1× baseline, and well past the
value at which wake seizes), and the K⁺ = 0.0008 column, which survives up the
Na⁺ axis except for the dead zone at 19–29 %. The interior is dead. **No point
in the 43 produces spike-wave.**

## What this closes

Of the three readings left open in `sweeps/gkl_tcfo_spindles/README.md`:

1. *The axis was wrong, not the question.* Closed by sweeps 3 and 7 — a cortical
   axis (GABA-A to −60 %) and a thalamic one both fail from the spindle
   background, while the same cortical axis from wake has a boundary at −15 %.
2. *The gate is specific and removable.* Closed by sweeps 5–7. `g_naleak` is
   genuinely the parameter controlling relay bursting, but restoring it — wholly
   or in part — abolishes spindling or stops the network, and never confers
   susceptibility.
3. *The regimes are disjoint in this model.* **This is what the evidence
   supports.** Spindle-supporting and spike-wave-supporting configurations are
   separated by a coordinated change across several parameters, with a region of
   quiescence between them rather than a continuum.

The consequence for the project is specific and worth stating plainly: **H1b, as
originally framed, has no operating point in this model to measure from.** There
is no parameter setting that both spindles and sits a finite normalised distance
from a spike-wave boundary.

What this does *not* establish is that no such regime exists in thalamus. The
deposit implements vigilance states as five hand-tuned parameter sets; the
quiescent gap between them is where no state was tuned, and a model built with a
continuous neuromodulatory axis might well bridge it. Distinguishing "the
thalamus does not work that way" from "this model was not built to answer this"
needs a model with that axis, which is a different piece of work.

## Reproducing

```
python sim/job_sweep.py 90000 spindles_long tc_fo_gkl 0.0013 naleak=2.6e-05
```
`summary.csv` carries the Modal job id for all 15 points; `state_map.csv` pools
the 43-point map.
