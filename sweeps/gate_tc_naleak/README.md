# Sweep 5 — the gate test: a spindle state with the wake Na leak

> **A note on the name.** `GLUfullsyn.gbase_c` is the thalamic **K⁺ leak**,
> not a glutamatergic conductance. `glu3.mod:84` declares it as "baseline K+
> leak conductance" (µS) with `Erev_c = -95 mV` (E_K), and line 196 drives
> `NONSPECIFIC_CURRENT iKLeak = (gbase_c - g_c)*(v - Erev_c)`. It sits on a
> `GLUfullsyn` object only because that mechanism bundles AMPA (`_a`), NMDA
> (`_b`) and a metabotropic component (`_c`) whose conductance `g_c`
> *subtracts* from the leak.

Sweeps 2 and 3 showed the spindle state reaches spike-wave on neither the
thalamic leak axis nor the cortical GABA-A axis, and nominated TC `g_naleak` as
the gate. `TCcell.hoc:169` gives it a nonzero value **only** for `wake_*` and
`SWDs_*`; every sleep state falls to the `else` at 0. The authors' own tables
report TC_FO firing tonically and essentially never bursting during SWDs, and a
depolarising Na leak is what takes relay cells out of burst mode.

So: add `spindles_long` to that condition — relay cells get the wake Na leak
(FO 0.000052, HO 0.00003) on an otherwise unchanged sleep background — and sweep
the thalamic K⁺ leak across it. Ten points, 90 s, single seed, first 30 s
discarded.

## Result: the gate is real, and it is inseparable from the spindling

| `gbase_c` (µS) | network | spikes | cortical E (Hz) | TC_FO burst | EEG peak (Hz) | spindle power | SWDs |
|---|---|---|---|---|---|---|---|
| 0.00080 | alive | 1,257,322 | 14.48 | **0.0** | 8.54 | **0.16** | 0 |
| 0.00100 | alive | 988,153 | 11.63 | **0.0** | 19.78 | 0.14 | 0 |
| 0.00120 | alive | 483,982 | 4.31 | **0.0** | 19.53 | 0.17 | 0 |
| 0.00130 | **dead** | 2,953 | 0.00 | — | — | — | 0 |
| 0.00136 | **dead** | 2,801 | 0.00 | — | — | — | 0 |
| 0.00140 – 0.00210 | **dead** | 2,248–2,417 | 0.00 | — | — | — | 0 |

For comparison the unmodified spindle baseline gives cortical E 4.5 Hz, TC_FO
burst fraction 0.19, EEG peak 9.28 Hz and spindle-band power 3.34.

**The mechanism identification is confirmed.** Restoring the Na leak drives the
TC_FO burst fraction to exactly 0 at every point, from 0.19 unmodified. This is
the parameter that controls relay bursting, as hypothesised.

**But it does not open a route to spike-wave.** It does two other things
instead.

*Below 0.0013 it abolishes spindling.* Spindle-band power collapses from 3.34 to
0.14–0.17, a factor of 21, and the EEG's dominant rhythm leaves the spindle band
for ~20 Hz at the two upper surviving points. Cortical rate rises to 14.5 Hz at
the baseline leak — partway from sleep (4.5) toward wake (30.9) — and no SWDs
appear anywhere.

*At and above 0.0013 the network dies outright.* Not a decline: every spike in
those seven runs occurs in the **first 80 ms**, and the EEG is flat at 0.0004 µV
sd for the remaining 89.9 s. The runs are otherwise normal (exit 0, NEURON's
`Execution time` line present, full memory use, ~55 min wall). The transition
from alive to dead is abrupt, between 0.0012 and 0.0013.

That collapse is mechanistically coherent. The Na leak depolarises relay cells
out of the T-current window, removing the rebound bursts that restart activity
after each infra-slow silent gap; and the *sleep* cortical configuration —
higher `g_pas`, `reduce = -0.000025` — cannot self-sustain without that thalamic
drive. In the wake state the cortex is configured differently (lower `g_pas`)
and does sustain tonic firing, which is why the same Na leak is fine there. The
thalamic and cortical halves of each vigilance state are co-dependent; moving
one without the other gives a network that either stops spindling or stops.

## What this settles, and what it does not

This is the third of the three readings left open in
`sweeps/gkl_tcfo_spindles/README.md`: the spindle-supporting and
spike-wave-supporting configurations are separated by a **coordinated** change
of several parameters, not by a distance along any one of them. In this model
there appears to be no operating point that both spindles and sits a measurable
distance from the spike-wave boundary — which is what H1b as originally framed
requires.

**One large caveat, and it is the reason the next sweep exists.** The deposit
implements vigilance states as five hand-tuned parameter sets, not as positions
on a neuromodulatory axis — a point already recorded against criterion C3.1.
`g_naleak` steps from 0 to 0.000052 with nothing in between because the model
defines nothing in between, and this sweep jumped the whole step at once. A real
sleep-to-wake transition moves cholinergic and noradrenergic tone continuously.
So the result so far may be a fact about the model's *discretisation* rather
than about thalamocortical dynamics. `sweeps/naleak_continuum/` supplies the
intermediate values and asks whether any of them supports spindling and spike-
wave susceptibility at the same time.

## Reproducing

```
python sim/job_sweep.py 90000 spindles_long tc_fo_gkl 0.0014 tc_naleak_wake
```
The fifth argument is a comma-separated modifier list. `tc_naleak_wake` adds the
swept state to the `TCcell.hoc:169` condition; the patch asserts that condition
matches exactly once and preserves parenthesis balance.
