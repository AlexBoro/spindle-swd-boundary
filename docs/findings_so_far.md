# Where the project stands

Seven sweeps, 75 simulations, 180 core-hours on Modal (89.8 h wall, mean 4310 s per run on 2 cores). Every point is 90 s of
model time at dt = 0.25 ms with the first 30 s discarded, one seed per point.

## The two things that worked

**The boundary is real and reproducible on the wake background.** Raising the
TC_FO tonic K⁺ leak from `wake_long` produces SWDs at 0.001360, within 1.4 % of
the authors' own code comment `> 0.0013792`, with the EEG's dominant rhythm
stepping abruptly 8.06 → 4.88 Hz at the same point. Cutting cortical GABA-A from
the same baseline gives a second boundary at −15 %. Intra-SWD frequency across
both is 4.49–5.57 Hz against a published 4.60–5.45.

**The design's built-in control is now measured rather than assumed.** The two
axes reach spike-wave with cortical excitatory firing moving in *opposite*
directions — 30.87 → 28.70 Hz on the thalamic route, 30.87 → 43.68 Hz on the
cortical one. Wake sits in a window bracketed by 30.12–30.46 Hz below and
32.14–32.78 Hz above and leaves it either way into SWDs. That is exactly the
structure that would make a matched δ along both kinds of axis an argument
overall network gain cannot explain.

## The thing that did not

**Nothing on the spindle background reaches spike-wave.** 43 distinct
(Na⁺ leak, K⁺ leak) points on `spindles_long`, four sweeps, two conductance axes
plus a cortical one, and zero SWDs. The viable region is an L along the two
axes — the Na⁺ = 0 row spindles all the way to a K⁺ leak of 0.0025, 3.1×
baseline and well past where wake seizes — with a dead interior.

Two confirmations that this is not a detection artefact:

- *Spectral.* The dominant rhythm never leaves 7.9–9.4 Hz on any spindle-
  background run. The abrupt step to a slower rhythm that marks the wake route
  simply does not happen.
- *Cellular.* Cortical excitatory rate stays at 2.6–5.9 Hz across all 20 points
  of sweeps 2 and 3, against 28.3–31.7 Hz in the regime where SWDs occur —
  a factor of five, no overlap, and no reliance on the EEG or any band.

## What this does to the hypothesis

**H1b, as originally framed, has no operating point in this model to measure
from.** The normalised distance d = (p\* − p)/σ presupposes a baseline from
which the boundary is reachable. From the spindle state it is not reachable
along any axis tried, and the intervening region is quiescent rather than
intermediate.

**H1a and H1c are not affected in the same way.** Both boundaries that exist are
on the wake background, both are locatable, and consolidation along those axes
is still a measurable thing — it just would not be *spindle*-timed consolidation
unless the plasticity module runs in a state that spindles.

**The project's negative result may be the more interesting one.** "Spindle-
supporting and seizure-supporting thalamic configurations are mutually exclusive
in a model constrained against sleep physiology" bears directly on Kostopoulos's
proposal that absence seizures are transformed sleep spindles. In this model the
transformation is not continuous; there is a quiescent gap.

## The caveat that bounds all of it

The deposit implements vigilance states as **five hand-tuned parameter sets**,
not positions on a neuromodulatory axis — the same limitation already recorded
against criterion C3.1. The quiescent gap sits exactly where no state was tuned.
Sweep 6 supplied the intermediate Na⁺ leak values the model does not define and
found the network dies across part of that range, which is consistent with
"nothing was fitted there" as much as with "thalamus cannot be there".

So the honest statement is: **in this model**, no regime both spindles and sits
a measurable distance from spike-wave. Distinguishing that from a fact about
thalamus needs a model built with a continuous neuromodulatory axis, which is
different work from what this repository does.

## Open decisions

1. **Reframe H1b** around the wake background, accepting that the consolidation
   studied is not spindle-timed; or
2. **Change host model** to one with a continuous arousal axis, and re-test; or
3. **Report the negative** as the primary result and build the plasticity graft
   to measure consolidation along the two wake boundaries that do exist.

These are not mutually exclusive — (3) is a prerequisite for (1) and produces a
publishable result on its own.

## Not yet done

- σ for the normalised distance: both boundaries are located as p\*, but the
  slope needs replicate seeds, which no sweep so far has run.
- Gate 0 criteria C1.x (isolated cortex), C2.5, C2.6, C5.1 and most of C4.x.
- Criterion C4.7 remains blocked on method — see `acceptance_criteria.md`; the
  rodent band is non-specific where spindles live.
- Pathology-level conductance multipliers for four axes, which is the only
  remaining ask in the email to the authors.
