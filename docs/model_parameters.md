# Model parameters: published values cross-validated against the vendored code

Every value here was checked **both** ways — read from the cns.14206 supplementary
tables and from `model/thalamocortical2/`, and compared. Where they disagree, that
is recorded rather than reconciled.

Source: Dervinis & Crunelli 2023, *Sleep waves in a large-scale corticothalamic
model…*, CNS Neurosci Ther, doi:10.1111/cns.14206, supplementary appendix
(`docs/sources/cns14206-sup-0001-supinfo.pdf`). Tables S1–S13 plus Appendices A–D
(full current equations).

## How the K⁺ leak is actually implemented

Table S9 ("Leak K+ conductance of all cells in corticothalamic network model")
carries the footnote *"expressed in mS/cm² in cortical cells, in µS in thalamic
cells"*. That mixed unit reflects two different mechanisms:

- **Thalamic cells** use `gbase_c`, a RANGE variable of `glu3.mod`, declared there
  as `gbase_c = 0.001 (uS) : baseline K+ leak conductance` and entering the current
  balance at line 196 as `iKLeak = (gbase_c - g_c)*(v - Erev_c)`. The mechanism
  bundles AMPA (`_a`), NMDA (`_b`) and a metabotropic component (`_c`) that
  *subtracts* from the K⁺ leak — which is why the leak lives on an object named
  `GLUfullsyn`. **This is the variable to change for any thalamic leak manipulation.**
- **Cortical cells** use `kleak.mod` (`g` in siemens/cm², default `0.025E-4`),
  described in its own header as "used in cortical neurons; reduced under
  cholinergic activation".

Anyone treating `gbase_c` as a purely glutamatergic parameter, or searching for a
variable named `gkl`, will not find the thalamic leak.

## Verified baselines for the candidate sweep axes

| Axis | Variable | File | Baseline | Cross-check |
|---|---|---|---|---|
| Cortical phasic GABA-A | `GABAsyn.gbar_a` | `Cx3cell.hoc` | **0.068 µS** | Table S11 (Cortex GABA_A ḡ = 0.068) — match |
| Cortical AMPA | `GLUsyn.gbar_a` | `Cx3cell.hoc` | **0.001945 µS** | Table S10 (Cortex AMPA ḡ = 0.001945) — match |
| TC_HO T-type Ca²⁺ | `gcabar_it`, HO branch | `TCcell.hoc` | **2×0.0021** | Table S3 (TC_FO 2.1, TC_HO 4.2; ratio exactly 2.0) — match |
| NRT T-type Ca²⁺ | `gcabar_its` | `NRTcell.hoc` | **2×0.00069 = 0.00138** | Table S4 (NRT ḡ_T = 1.4) — match |
| TC_FO leak K⁺ | `GLUfullsyn.gbase_c`, FO branch | `TCcell.hoc` | state-dependent, below | Table S9 TC_FO row — match, 4 of 4 states |
| TC_HO leak K⁺ | `GLUfullsyn.gbase_c`, HO branch | `TCcell.hoc` | state-dependent, below | Table S9 TC_HO row — 3 of 4 match, see discrepancy |
| TC_FO tonic (extrasynaptic) GABA-A | `GABAfullsyn.gbar_c` | `TCcell.hoc` | **0**, with `0.00065` in a trailing comment | no table entry |

Other receptor conductances also agree exactly: TC AMPA 0.034 (S10), NRT AMPA 0.04
(S10), NRT GABA-A 0.8 (S11), TC GABA-B 0.61 (S12).

## State-dependent thalamic leak (`GLUfullsyn.gbase_c`, µS)

| Cell | wake | slow | delta | spindles | SWDs |
|---|---|---|---|---|---|
| TC_FO | 0.001325 | 0.0015 | 0.0019 | 0.0008 | 0.001395 |
| TC_HO | 0.0045 | 0.0022 | 0.00305 | 0.0021 | 0.0045 |

Table S9's "Depolarised" column corresponds to the `wake_*` states: TC_FO 0.00133
versus the code's 0.001325, TC_HO 0.0044 versus 0.0045.

## Author-recorded thresholds (from code comments, not the papers)

These are the most valuable find, because they are the authors' own boundary
estimates — which is precisely the quantity the Phase 3 susceptibility calibration
sets out to measure independently.

- **TC_FO leak route.** `TCcell.hoc` marks the SWD setting `0.001395` with the
  comment `> 0.0013792`. Against the wake baseline of 0.001325 that places the SWD
  **onset threshold at +4.09 %** and the shipped SWD value at **+5.28 %** — which
  is the paper's "increasing (by 5 %) the leak conductance". **Measured** (see
  `sweeps/gkl_tcfo/`): SWDs first appear at **0.001360**, +2.64 % of baseline and
  1.4 % below the authors' stated threshold. Independently, the EEG's dominant
  rhythm steps from 8.06 Hz to 4.88 Hz between 0.001345 and 0.001360. The
  comment is confirmed to ~1 %.
- **The swept parameter moves alone only above 0.0012.** `TCcell.hoc:558` sets
  `gbar_c = min(0.0017, (gbase_c/0.0012)*0.0017)`, which saturates for
  `gbase_c` ≥ 0.0012. Within the SWD route `gbar_c` is pinned at 0.0017 and does
  not co-vary; a sweep extended below 0.0012 silently becomes two-parameter.
- **TC_HO leak route.** The comment `//4Hz: 0.0046; 7Hz: 0.0028` gives both SWD
  frequency regimes directly. Criterion C4.7 (decreased TC_HO leak → ~7 Hz) is
  therefore 0.0045 → **0.0028**, a −38 % change.
- **Cortical GABA-A route.** Baseline 0.068 with the main text's −10 % and −25 %
  gives **0.0612** (level 1) and **0.051** (level 2), fully determining that axis.

## Open items

1. **TC_HO "Depolarised" leak disagrees by 2.2 %** — Table S9 gives 0.0044, the
   code gives 0.0045. Small, but it is the baseline for one of the axes, so the
   sweep should be anchored on the **code** value and the discrepancy noted.
2. ~~**The shipped code sets TC_HO leak identically (0.0045) for `wake_*` and
   `SWDs_*`.**~~ **Closed.** Not just TC_HO leak — *every* `wake_long` /
   `SWDs_long` branch pair in `TCcell.hoc`, `NRTcell.hoc` and `Cx3cell.hoc` is
   identical (`g_naleak`, `shift_iarg`, `cac_iarg`, NRT `gkbar1/2_iahp`, NRT and
   TC_HO `gbase_c`, cortical `g_pas` and `reduce`). The sole difference in the
   model is TC_FO `gbase_c`, 0.001325 → 0.001395. The authors' SWD state is a
   one-parameter continuation from wake, which is why sweeping that parameter
   recovers their threshold.
3. **Pathology levels 1/2/3 remain undefined for four axes** — extrasynaptic
   `g_eGABAa`, cortical AMPA, NRT I_T, and TC_HO I_T. Only the cortical GABA-A
   levels are fully pinned. The TC_HO I_T axis is this project's nominated primary
   axis, so this still blocks anchoring Phase 3 there.
4. **The cortical leak-K variable has not been located in the network path.**
   `g_kleak` is set only inside parameter-sweep loops in `Cx3procs.hoc` and is
   commented out in `Cx2cell.hoc`, so Table S8/S9's cortical rows are reached by
   some other route. Not on a project axis — the cortical leak is the
   vigilance-state control — but it must be found before the state-transition
   criterion C3.1 can be driven programmatically.

## Ambiguous variable names

`gcabar_its` is assigned five times in `NRTcell.hoc` (lines 62, 113, 157, 189 and
333); only line 333 is the network model. `gcabar_it` is assigned twice in
`TCcell.hoc`, once per thalamic order. The runner refuses an unqualified override
of either (see `sim/runner.py`), which is why these were caught rather than
silently mis-patched.
