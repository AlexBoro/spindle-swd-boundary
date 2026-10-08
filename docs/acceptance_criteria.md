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
| C4.8 | SWDs **invariably start in neocortical territories**; Tables S1/S2 sharpen this to **leading structure = L4** in every case (see C4.16) | [B] | TODO |
| C4.9 | Blocking `g_CAN` in NRT markedly **prolongs** SWD duration | [B] | TODO |
| C4.10 | Physiological rhythms are only **minimally affected** by the conductance changes that produce SWDs | [B] | TODO |

## 4b. SWD phenotype targets (Tables S1/S2, cns.14204 supplementary)

Obtained from the supplementary appendix. These are **outcome** statistics, and
they index everything by "pathology level 1/2/3" without ever defining a level in
conductance units — see Known gaps. Ranges below are over all **15** pathology
columns: 6 in Table S1 (tonic inhibition of TC_FO, two routes × three levels) and
9 in Table S2 (five other routes).

| ID | Criterion | Status |
|---|---|---|
| C4.11 | Intra-SWD frequency falls in **4.60–5.45 Hz** across all 15 pathology columns. The four routes the text calls "~4 Hz" measure **4.60–5.09 Hz**; increased I_T in NRT is the fastest at **5.45 Hz** | TODO |
| C4.12 | Mean SWD duration **8.76–21.96 s**; longest is increased I_T in TC_HO level 2 (21.96 ± 0.77 s) | TODO |
| C4.13 | Mean interictal period **19.81–48.39 s** | TODO |
| C4.14 | Time spent in SWDs **16.34–47.15 %**; highest is increased I_T in TC_HO level 2 (47.15 %) | TODO |
| C4.15 | SWD incidence **1.01–1.85 min⁻¹** | TODO |
| C4.16 | **Leading structure is L4 in all 15 pathology columns**, without exception | TODO |
| C4.17 | Poly-spikes present in all 15 pathology columns | TODO |
| C4.18 | Mean spike-to-wave amplitude **3.02–8.45 µV**; mean PSI **0.52–0.82** | TODO |
| C4.19 | TC_FO cells fire **tonically and essentially never burst** during SWDs: bursting fraction is exactly 0 % in **13 of 15** columns, the only exceptions being 0.0034 % (I_KL level 3) and 0.02 % (increased I_T in NRT); tonic-spiking fraction 5.43–88.16 % | TODO |
| C4.20 | Phase of the first TC_HO action potential in the first second of an SWD is near zero or negative (−0.45 to +0.40 rad) while cortical layers are 1.04–2.76 rad — i.e. TC_HO leads | TODO |

C4.19 is worth flagging beyond its role as a criterion: TC_FO relay cells are
*tonically firing*, not T-type bursting, throughout these SWDs. That cuts against
the classical burst-centred account of absence seizures and bears directly on how
this project should interpret the T-current axes.

Note on C5.1: Tables S1/S2 report **global** PSI, AP cross-correlation and AP–EEG
correlation. The route-discrimination claim in the main text concerns **pairwise**
L5PY–NRT and L4PY–TC_HO synchrony (Figure 4C4), which is a different measure.
C5.1 must still be checked against the figure, not these columns.

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
| C6.1 | Python port of `detectEEGspikesSWDs.m` agrees with the MATLAB original on identical traces. Reference generated by `analysis/matlab_reference/make_reference.m` on a machine with MATLAB + Signal Processing Toolbox; 8 deterministic cases (`rng(42,'twister')`) covering baseline detection, the 3 s minimum, both SD thresholds, both `edgeOverlap` settings, `dt = 0.25 ms`, and the ~7 Hz regime | repo | AWAITING REFERENCE |
| C6.2 | Phase extraction uses a Butterworth bandpass with **passband ±2 Hz and stopband ±4 Hz** around the SWD frequency (~4 or ~7 Hz) | [B] | TODO |
| C6.3 | Detection uses **two** thresholds on **negative** deflections — 1 SD and 1.96 SD relative to a Gaussian-fitted baseline; `minSWD = 3 s`; lone spikes ≥3 s apart and groupings <1.5 s are eliminated | repo (`detectEEGspikesSWDs.m` docstring) | TODO |

## Known gaps

1. **RESOLVED IN PART — Tables S1/S2 obtained** (cns.14204 supplementary
   appendix). They supply the SWD frequency / duration / interictal statistics,
   now recorded as criteria C4.11–C4.20.

2. **LARGELY RESOLVED — baselines obtained** from the cns.14206 supplementary
   (Tables S1–S13) and cross-validated against the vendored code; see
   `docs/model_parameters.md`. Three axes are now fully anchored (cortical GABA-A
   −10 %/−25 % of 0.068; TC_FO leak with the authors' own SWD threshold of
   0.0013792 against a 0.001325 wake baseline; TC_HO leak 0.0045 → 0.0028 for the
   ~7 Hz route). **Still open:** pathology levels for extrasynaptic g_eGABAa,
   cortical AMPA, NRT I_T and **TC_HO I_T** — the last being this project's
   nominated primary axis.

   Superseded text: the conductance values themselves. Tables S1/S2
   index every column by "pathology level 1/2/3" and nowhere state what a level
   *is* in conductance units. Only two mappings are recoverable, by inference from
   the main text: reduced cortical g_GABAa levels 1 and 2 are the quoted −10 % and
   −25 %, and the TC_FO I_KL route is introduced at +5 %. Unknown: I_KL levels 2
   and 3; extrasynaptic g_eGABAa levels 1–3; cortical AMPA levels 1–2; I_T in NRT
   level 1; **I_T in TC_HO levels 1–2** — the last being the axis this project
   nominates as primary. Without these the published SWD points cannot be located
   in parameter space, so the Phase 3 boundary calibration has no anchor.

3. **RESOLVED — Table S8 obtained.** It was in the *sleep-waves* companion
   supplement (cns.14206), as expected.

   Superseded text: Table S8 is in the other paper's supplement. It was cited in the
   *sleep-waves* companion (cns.14206), not the SWD paper, so it was never going
   to be in this file. Request the cns.14206 supplementary appendix.

4. **Evidence that the model parameters live in the cns.14206 supplement:** the
   Figure S1 legend in *this* appendix says the synaptic connection strengths are
   given "in Supplementary Table 1" — but Table S1 here is SWD outcome statistics,
   not connection strengths. That cross-reference resolves to the companion
   paper's supplementary tables, which is where the model specification (and
   Table S8's g_KL values) should be found.
5. **No published spindle density or duration figures** — see §2. Figure S2 of
   this appendix does display simulated slow, delta and spindle waves, but its
   legend carries no quantities, so it does not close the gap. Do not invent a
   tolerance; use the sequence criteria and report measured spindle statistics as
   new characterisation rather than as a reproduction test.
6. **Numeric tolerances are unset** for the conductance-indexed criteria pending (2). Until then each criterion is
   judged on the qualitative claim as stated.

## Model facts established while instrumenting (not criteria)

Recorded here because they bear on the axis design and were not obvious from the
papers:

1. **TC_HO carries twice the baseline T-type Ca²⁺ conductance of TC_FO.** In
   `TCcell.hoc`, `gcabar_it` is assigned per thalamic order inside
   `if (!strcmp(section, "FO"))` / `else if (... "HO")` branches: `0.0021` for
   FO and `2*0.0021` for HO. Any override of this conductance must say which
   order it means — the runner refuses an ambiguous override rather than
   silently patching the first match.
2. **Several right-hand sides are expressions, not literals.** Overrides are
   therefore expressed relative to baseline (`"1.05*0.0021"`) rather than as
   absolute numbers, so a fold-change stays a fold-change if upstream baselines
   are ever revised.

## Axis independence audit (blocks Phase 3)

[B] implements increased tonic GABA-A inhibition of TC_FO as a **+5% increase in
`g_KL`** of those neurons — so "tonic GABA-A on TC_FO" and "TC_FO leak
conductance" are *partly the same manipulation*. Before Phase 3, audit the
candidate axes for genuine independence. Prefer the direct `g_eGABAa` route
(C4.3) over the indirect `g_KL` proxy when the tonic-GABA-A axis is used as the
hyperpolarising counterpart to the cortical-AMPA axis in the opposing-direction
control.
