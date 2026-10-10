# Sweep 6 — the Na leak as a continuum

`sweeps/gate_tc_naleak/` jumped the thalamic Na leak from 0 (every sleep state)
to 0.000052 (wake FO) in one step, because that is the only step the deposit
defines: vigilance states are five hand-tuned parameter sets, not positions on
an axis. Real sleep-to-wake transitions move neuromodulatory tone continuously.
This sweep supplies the intermediate values and asks whether any of them
supports spindling **and** spike-wave susceptibility at once — the operating
point H1b needs.

Ten values of `g_naleak` from 0 to the wake value, `state = spindles_long`,
everything else at spindle settings, K⁺ leak at its spindle baseline of 0.0008.
HO is scaled by the wake FO:HO ratio (0.00003/0.000052) so the two thalamic
orders keep their published relation.

**Control.** At `g_naleak = 0` the run gives **188,530 spikes**, identical to the
unmodified `spindles_long` baseline in `sweeps/gkl_tcfo_spindles/`. The new code
path reproduces the deposit exactly.

## Result: three regimes, none of them seizure-prone

| `g_naleak` | % of wake | network | cortical E (Hz) | TC_FO burst | spindle power | EEG peak (Hz) | SWDs |
|---|---|---|---|---|---|---|---|
| 0 | 0 | alive | 1.68 | 0.169 | **3.34** | 9.28 | 0 |
| 5e-6 | 9.6 | alive | 1.82 | 0.048 | **3.79** | 8.79 | 0 |
| 1e-5 | 19.2 | **dead** | 0.00 | — | — | — | 0 |
| 1.5e-5 | 28.8 | **dead** | 0.00 | — | — | — | 0 |
| 2e-5 | 38.5 | alive | 3.33 | 0.000 | 1.85 | 7.94 | 0 |
| 2.6e-5 | 50.0 | alive | 5.63 | 0.000 | 1.57 | 8.55 | 0 |
| 3.2e-5 | 61.5 | alive | 7.80 | 0.000 | 2.17 | 8.55 | 0 |
| 4e-5 | 76.9 | alive | 11.47 | 0.000 | **0.19** | 8.91 | 0 |
| 4.6e-5 | 88.5 | alive | 12.69 | 0.000 | 0.15 | 8.42 | 0 |
| 5.2e-5 | 100 | alive | 14.48 | 0.000 | 0.16 | 8.55 | 0 |

The axis is not a smooth ramp. It has three parts.

**0 to ~10 % — sleep-like.** Spindling intact (power 3.3–3.8), relay bursting
present, cortical rate below 2 Hz. A tenth of the wake Na leak already cuts the
TC_FO burst fraction from 0.169 to 0.048, so bursting is the first thing to go.

**~19 to ~29 % — a dead zone.** The network fires a brief volley and stops, as
in the full-leak gate test. This is the interesting part: it is not a monotone
decline but a *gap*. The reading consistent with both sweeps is that the leak is
by then large enough to suppress rebound bursting but still too small to sustain
tonic firing, so the network has neither of its two drive mechanisms. Stated as
a reading of the pattern, not something these runs tested.

**~38 to 100 % — wake-like and progressively less spindly.** The network
recovers, cortical rate climbs 3.3 → 14.5 Hz, and spindle-band power decays from
1.85 to 0.16, a tenfold collapse concentrated between 62 % and 77 %. Bursting is
zero throughout.

**No SWDs at any point**, and the EEG's dominant rhythm never leaves 7.9–9.3 Hz.

## What is still open

This sweep holds the K⁺ leak at its spindle baseline, so it asks "does
intermediate neuromodulatory tone *spontaneously* produce spike-wave?" and the
answer is no. It does not ask the question H1b actually needs, which is whether
an intermediate tone is *susceptible* — whether raising the K⁺ leak from there
produces SWDs the way it does from wake, rather than killing the network the way
it does at full Na leak.

`sweeps/naleak_gkl_slice/` runs that: **all three tones in the recovered branch
that retain spindle power above 1.5** — 2e-5 (1.845), 2.6e-5 (1.574) and 3.2e-5
(2.170) — crossed with five K⁺ leak values spanning the spindle baseline to past
the wake-route boundary.

(The slice was first dispatched with only 2.6e-5 and 3.2e-5, described as "the
two tones with the best surviving spindling". That was wrong: ranked by spindle
power the recovered branch runs 3.2e-5 > 2e-5 > 2.6e-5, so the pair chosen was
the 1st and 3rd, and 2e-5 is also the only recovered point with a detected
active epoch. 2e-5 was added as a third row rather than substituted, so the
slice now spans the criterion as stated instead of a subset of it.)

## Reproducing

```
python sim/job_sweep.py 90000 spindles_long tc_naleak 2.6e-5
```
The `tc_naleak` axis rewrites the `else { g_naleak = 0 }` arm of
`TCcell.hoc:175` into an FO/HO conditional carrying the swept value; the patch
asserts that block matches exactly once.
