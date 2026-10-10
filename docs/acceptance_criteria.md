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
| C2.1 | Spindles occur in the **7–14 Hz** band | [B] | **PASS** — 9.06 ± 0.26 Hz across **11 post-warm-up cycles** of the 300 s run (range 8.79–9.28); EEG gives 8.91 Hz on the 60 s run. Comfortably inside 7–14 Hz |
| C2.2 | Spindle waves appear **regularly** in the EEG with the classical waxing–waning waveform | [A] | **PARTIAL, n=11** — waxing–waning envelope present (peak 9.23 µV) and epochs recur regularly (gap 16.7 ± 1.7 s). But the gaps are *flat-zero* EEG, not low-amplitude background, and **they do not fill in over 300 s** — so this is an all-or-none alternation, not NREM-like continuous activity |
| C2.3 | **Onset sequence: NRT_FO first**, followed within a few ms by TC_HO and NRT_HO, then TC_FO and cortical neurons | [A] | **FAIL as a strict order; PASS in weakened form** — over 11 cycles the exact predicted order occurs in **1 of 11**. First to fire: NRT_FO 5, NRT_HO 4, TC_HO 2, TC_FO 0. What *does* hold: an **NRT population leads in 9 of 11** and **TC_FO never leads**. The n=2 result that matched the prediction exactly was chance |
| C2.4 | The spindle **builds in thalamus before** being reflected into cortex | [A] | **PARTIAL, n=11** — NRT consistently leads, and TC_FO is never first, so thalamus does initiate. But the four thalamic populations' onsets span a median of 156 ms against a 110 ms spindle cycle, so "within a few ms" does not hold |
| C2.5 | First firing of a spindle cycle may alternatively originate in **TC_HO** | [A] | TODO |
| C2.6 | Spindle sequences are **grouped by slow-oscillation up-states** | [A] | TODO |

## 3. Vigilance-state transition

| ID | Criterion | Source | Status |
|---|---|---|---|
| C3.1 | Progressively increasing membrane hyperpolarisation moves the network desynchronised → spindles → slow (<1 Hz) → delta | [A] | **STATES PASS, PROGRESSION UNTESTED** — each named state produces its named rhythm when measured *within active epochs*: wake 7.93 Hz continuous with the lowest EEG amplitude (sd 1.83 vs 4.5–5.2), spindles 8.89 Hz, slow **0.61 Hz** (<1 Hz as required), delta 2.81 Hz, SWDs 4.76 Hz. But the deposit implements each state as its own parameter set — 13 `strcmp` branch sites across `TCcell`/`NRTcell`/`Cx3cell` setting `gbase_c`, `gbar_c`, `g_pas`, `cac_iarg`, `shift_iarg` and an AHP term together — not as positions on a hyperpolarisation axis. The *progression* claim therefore cannot be tested by running the shipped states and requires a deliberate sweep of a single conductance |

## 4. Spike-and-wave discharge

| ID | Criterion | Source | Status |
|---|---|---|---|
| C4.1 | **+5% `g_KL` in TC_FO** produces spontaneous SWDs at **~4 Hz** | [B] | TODO |
| C4.2 | Further `g_KL` increase leaves SWD frequency and duration unchanged, but decreases then prolongs the **interictal period** | [B] | TODO |
| C4.3 | Increasing **`g_eGABAa`** (extrasynaptic GABA-A) of TC_FO directly also produces SWDs | [B] | TODO |
| C4.4 | Decreasing cortical **`g_GABAa` by 10% and 25%** produces SWDs of progressively larger amplitude and longer interictal periods | [B] | TODO |
| C4.5 | Increasing **cortical AMPA** function produces ~4 Hz SWDs | [B] | TODO |
| C4.6 | Increasing **T-type Ca²⁺ in TC_HO** produces ~4 Hz SWDs | [B] | TODO |
| C4.7 | **Decreasing `g_KL` in TC_HO** produces **~7–8 Hz** SWDs while spindles remain at 7–14 Hz. ⚠ The deposited detector **cannot measure this**: it hardcodes `oscFreq(..., 'SWDs_human')` (3–6 Hz) at line 91, and the authors' `coherenceAnalyses.m` sets `type = 'SWDs_human'` too. Demonstrated on a synthetic 7.004 Hz trace: the human band returns 5.920 Hz and the detector then finds **zero** spikes. C4.7 needs `'SWDs_rodent'` passed, or the frequency measured outside the detector | [B] + repo | BLOCKED ON METHOD |
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
| C4.11 | Intra-SWD frequency falls in **4.60–5.45 Hz** across all 15 pathology columns. The four routes the text calls "~4 Hz" measure **4.60–5.09 Hz**; increased I_T in NRT is the fastest at **5.45 Hz** | **PROVISIONAL PASS** — 4.76 Hz on the deposit's own `SWDs_long` state (60 s, Modal). Within-event measure, meaningful at n=1 |
| C4.12 | Mean SWD duration **8.76–21.96 s**; longest is increased I_T in TC_HO level 2 (21.96 ± 0.77 s) | **PROVISIONAL, n=1** — 11.63 s, in range. A single discharge is not a mean |
| C4.13 | Mean interictal period **19.81–48.39 s** | TODO |
| C4.14 | Time spent in SWDs **16.34–47.15 %**; highest is increased I_T in TC_HO level 2 (47.15 %) | **WEAK, n=1** — 36.34 % over 32 s of usable record. Rests on one event; not a usable estimate |
| C4.15 | SWD incidence **1.01–1.85 min⁻¹** | **FAIL (weak), n=1** — 1.88 min⁻¹, just above range. One event in 32 s cannot estimate a rate; re-measure on a long run |
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
| C6.1 | Python port of `detectEEGspikesSWDs.m` agrees with the MATLAB original on identical traces. Reference generated by `analysis/matlab_reference/make_reference.m`; 8 deterministic cases (`rng(42,'twister')`) | repo | **PASS on decisions, BOUNDED on boundaries.** Per-layer, exact against MATLAB: `spectra`, `osc_freq`, `matlab_buttord_bandpass`/`_lowpass`, `prefilter` (~1e-8 rel), `eliminate_pks`, `cluster_spikes`, `find_waves`, `mark_swds`, `mark_interictal`, `apply_edge_overlap`, `mark_swcs`, `hilbert_phase` (1e-15), `gauss1_baseline` (~1e-8, removing the Curve Fitting Toolbox dependency). End-to-end: **SWD counts exact on 8/8**; SWD boundaries within **32 samples** on `three_swds`/`mixed_amplitude` and 116 samples (29 ms) on `fine_dt`; spike counts within 1 of MATLAB. **Known limit:** the two `edge_overlap` cases have one boundary off by 1099 samples (1.1 s), from the same `filtfilt` record-boundary extension difference that makes `th_pks` exact on only 6/8 — a padtype × padlen scan over [0,400] does not close it. The project discards a warm-up cycle and analyses long records, so record-edge episodes are excluded by protocol; the limitation is recorded rather than waived. The `eegSpikesLarge*` gap is **resolved** — the deposited MATLAB never fills `pksLocsLarge`, so those outputs are empty for every input; the port fills it deliberately and returns 54 large spikes on a real SWD EEG |
| C6.2 | Butterworth bandpass built as `fmax + [-0.75 -0.5 0 0.5 0.75]` with passbandRipple 0.5 and stopbandAttenuation 16 (`detectEEGspikesSWDs.m` lines 107-110). **The paper's stated ±2 Hz passband / ±4 Hz stopband does not match the code**; the code is what produced the published results | repo (supersedes [B]) | TODO |
| C6.3 | Detection uses **three** thresholds on **negative** deflections at nominal 1, 1.96 and 2.576 SD below a `gauss1`-fitted baseline — but ⚠ **`sdEEGfilt` is hardcoded to 1.28074765136489** (line 127; the data-derived line is commented out), so the thresholds are fixed absolute offsets of 1.280748 / 2.510219 / 3.298987 and the detector is **not scale-invariant**. `minSWD = 3 s`; lone spikes ≥3 s apart and groupings <1.5 s eliminated | repo (`detectEEGspikesSWDs.m`) | TODO |

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


## Threshold-scaling caveat (affects Phase 3, not just Gate 0)

The detector's spike thresholds are fixed absolute offsets (C6.3), while EEG
amplitude varies by a factor of ~2.8 across the published pathology routes
(Tables S1/S2, 3.02–8.45 µV). Detection sensitivity therefore drifts with the
swept parameter. Before the boundary coordinate `d` is used for H1b or H1c, the
calibration must be run with both the fixed and a scale-adaptive threshold and
the two compared. See `docs/matlab_dependencies.md` §3.

## Status conventions used above

- **PASS** — measured, within the published range, with enough events that the
  statistic is meaningful.
- **PROVISIONAL PASS** — measured and within range, but on too few events (n
  stated) for the number to be evidence. A within-event measure such as
  frequency can be provisional at n=1; a rate or a mean cannot.
- **PARTIAL** — the qualitative feature is present but something about it
  departs from the published description, stated inline.
- **WEAK / FAIL (weak)** — measured, but n is too small for the result to
  count either way. Recorded so it is not mistaken for an untested criterion.

Every provisional entry names the run it came from and the n it rests on. None
of them closes Gate 0.
