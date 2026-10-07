# spindle-swd-boundary

Does the thalamocortical parameter regime that best supports spindle-timed
cortical plasticity lie close to the boundary separating physiological spindling
from generalised spike-wave discharge?

**Scope.** Spindle-timed cortico-thalamo-cortical plasticity and local cortical
consolidation of a cortically trained sequence. This project does *not* model
hippocampal systems consolidation — neither the host nor the donor model contains
a hippocampus, and replay in this lineage is spontaneous cortical sequence
reactivation. A minimal hippocampal ripple-input stub is an optional later
extension on which no claim depends.

## Hypothesis

Three nested, separately falsifiable propositions:

- **H1a** Consolidation specificity is a non-monotone function of position along a
  conductance axis, with an interior maximum.
- **H1b** That maximum lies a small distance `delta` from the spike-wave
  transition, in normalised units of evoked-SWD susceptibility.
- **H1c** `delta` is approximately conserved across *independent* conductance
  axes, including axes that move cortical excitability in opposite directions.

H1c is the substantive claim. See `docs/` for the full design.

## Layout

| Path | Contents |
|---|---|
| `model/thalamocortical2/` | Host model, vendored unmodified at v1.0.0. **Never edit in place** — every deviation is a separate patch commit. |
| `environment/` | NEURON 7.8.2 build recipe and container |
| `docs/` | Gate 0 acceptance criteria, provenance notes |
| `sim/` | Config-driven runner — one JSON config + one seed per run |
| `analysis/` | Python reimplementation of the measures (SWD detection, spindles, EEG proxy, coherence) |
| `sweeps/` | Parameter manifests and the run registry |

## Status

Phase 0 (infrastructure and reproduction). Gate 0 is not yet passed: the baseline
has not been reproduced against `docs/acceptance_criteria.md`.

## Attribution

The vendored model is the work of Martynas Dervinis and Vincenzo Crunelli, from
`github.com/dervinism/thalamocortical2` (Zenodo `10.5281/zenodo.7724443`), under
its own licence — see `model/thalamocortical2/LICENSE`. Papers:

- Dervinis M, Crunelli V. *Sleep waves in a large-scale corticothalamic model...*
  CNS Neurosci Ther 2023. doi:10.1111/cns.14206
- Dervinis M, Crunelli V. *Spike-and-wave discharges of absence seizures in a
  sleep waves-constrained corticothalamic model.* CNS Neurosci Ther
  2023;30:e14204. doi:10.1111/cns.14204
