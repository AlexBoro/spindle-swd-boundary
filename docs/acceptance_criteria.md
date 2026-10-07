# Gate 0 acceptance criteria

**Committed before any reproduction runs.** Gate 0 passes only when every
criterion below is marked PASS or explicitly waived with a recorded reason.
Sources are the two papers; every value here is quoted from their published text,
not inferred.

- **[A]** = Dervinis & Crunelli 2023, *Sleep waves in a large-scale corticothalamic
  model...*, CNS Neurosci Ther, doi:10.1111/cns.14206
- **[B]** = Dervinis & Crunelli 2023, *Spike-and-wave discharges of absence seizures
  in a sleep waves-constrained corticothalamic model*, CNS Neurosci Ther
  30:e14204, doi:10.1111/cns.14204

## 1. Isolated cortical network — slow and delta oscillation

| ID | Criterion | Source | Status |
|---|---|---|---|
| C1.1 | All neurons in all cortical layers oscillate at **0.44 Hz** at the elevated `g_KL` of Table S8 | [A] | TODO |
| C1.2 | At lower `g_KL` the oscillation reaches the **delta** band (~1 Hz) | [A] | TODO |
| C1.3 | Up-state duration **~250 ms**, down-state duration **~840 ms** | [A] | TODO |
| C1.4 | Initiation order **L5 → L6 → L2/3 → L4** (firing appears in L5 first) | [A] | TODO |
| C1.5 | Reducing AMPA EPSPs or `I_Na(P)` abolishes up-states | [A] | TODO |

## 2. Full corticothalamic network — sleep spindles

The papers characterise spindles **qualitatively** — there is no published
density or duration tolerance to test against. The onset-sequence signature below
is used instead, and is a stronger test: it is a specific claim about which
population fires first.

| ID | Criterion | Source | Status |
|---|---|---|---|
| C2.1 | Spindles occur in the **7–14 Hz** band | [B] | TODO |
| C2.2 | Spindle waves appear **regularly** in the EEG with the classical waxing–waning waveform | [A] | TODO |
| C2.3 | **Onset sequence: NRT_FO first**, followed within a few ms by TC_HO and NRT_HO, then TC_FO and cortical neurons | [A] | TODO |
| C2.4 | The spindle **builds in thalamus before** being reflected into cortex | [A] | TODO |
| C2.5 | First firing of a spindle cycle may alternatively originate in **TC_HO** | [A] | TODO |
| C2.6 | Spindle sequences are **grouped by slow-oscillation up-states** | [A] | TODO |

## 3. Vigilance-state transition

| ID | Criterion | Source | Status |
|---|---|---|---|
| C3.1 | Progressively increasing membrane hyperpolarisation moves the network desynchronised → spindles → slow (<1 Hz) → delta | [A] | TODO |

## 4. Spike-and-wave discharge

| ID | Criterion | Source | Status |
|---|---|---|---|
| C4.1 | **+5% `g_KL` in TC_FO** produces spontaneous SWDs at **~4 Hz** | [B] | TODO |
| C4.2 | Further `g_KL` increase leaves SWD frequency and duration unchanged, but decreases then prolongs the **interictal period** | [B] | TODO |
| C4.3 | Increasing **`g_eGABAa`** (extrasynaptic GABA-A) of TC_FO directly also produces SWDs | [B] | TODO |
| C4.4 | Decreasing cortical **`g_GABAa` by 10% and 25%** produces SWDs of progressively larger amplitude and longer interictal periods | [B] | TODO |
| C4.5 | Increasing **cortical AMPA** function produces ~4 Hz SWDs | [B] | TODO |
| C4.6 | Increasing **T-type Ca²⁺ in TC_HO** produces ~4 Hz SWDs | [B] | TODO |
| C4.7 | **Decreasing `g_KL` in TC_HO** produces **~7–8 Hz** SWDs while spindles remain at 7–14 Hz | [B] | TODO |
| C4.8 | SWDs **invariably start in neocortical territories** | [B] | TODO |
| C4.9 | Blocking `g_CAN` in NRT markedly **prolongs** SWD duration | [B] | TODO |
| C4.10 | Physiological rhythms are only **minimally affected** by the conductance changes that produce SWDs | [B] | TODO |

## 5. Route discrimination

These distinguish the conductance axes mechanistically and matter for H1c — the
axes must be genuinely independent paths, not one attractor reached several ways.

| ID | Criterion | Source | Status |
|---|---|---|---|
| C5.1 | The decreased-cortical-`g_GABAa` route shows **stronger L5PY–NRT and L4PY–TC_HO synchrony** than the thalamic tonic GABA-A route | [B] | TODO |
| C5.2 | SWDs show a characteristic **interictal-to-ictal decrease in synchrony** | [B] | TODO |

## 6. SWD detector validation

| ID | Criterion | Source | Status |
|---|---|---|---|
| C6.1 | Python port of `detectEEGspikesSWDs.m` agrees with the MATLAB original on identical traces (spike times, SWD boundaries, interictal periods) | repo | TODO |
| C6.2 | Phase extraction uses a Butterworth bandpass with **passband ±2 Hz and stopband ±4 Hz** around the SWD frequency (~4 or ~7 Hz) | [B] | TODO |
| C6.3 | "Large" spikes are those exceeding **1.96 SD** relative to the EEG baseline | repo (`detectEEGspikesSWDs.m`) | TODO |

## Known gaps

1. **Supplementary Tables S1, S2 and S8 are not in the PMC full text.** They hold
   the exact conductance values and the SWD frequency / duration / interictal
   statistics. Obtain them from the Wiley supplementary material or from the
   authors before finalising tolerances on C1.1, C4.1–C4.4.
2. **No published spindle density or duration figures** — see §2. Do not invent a
   tolerance; use the sequence criteria and report measured spindle statistics as
   new characterisation rather than as a reproduction test.
3. **Numeric tolerances are unset** pending (1). Until then each criterion is
   judged on the qualitative claim as stated.

## Axis independence audit (blocks Phase 3)

[B] implements increased tonic GABA-A inhibition of TC_FO as a **+5% increase in
`g_KL`** of those neurons — so "tonic GABA-A on TC_FO" and "TC_FO leak
conductance" are *partly the same manipulation*. Before Phase 3, audit the
candidate axes for genuine independence. Prefer the direct `g_eGABAa` route
(C4.3) over the indirect `g_KL` proxy when the tonic-GABA-A axis is used as the
hyperpolarising counterpart to the cortical-AMPA axis in the opposing-direction
control.
