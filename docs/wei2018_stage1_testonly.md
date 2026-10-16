# Wei et al. 2018 reimplementation: Stage 1, test-only runs from saved weights

## Question
Stage 0 left one question open. Are the small sleep effects on recall in N2 and N2+N3 a readout problem, or does consolidation actually fall short?
Stage 1 separates the two. The network is restarted fresh, the saved PY-PY weights are loaded, and recall is tested with plasticity off. Every weight set is therefore tested from the same state, with no session history.

## Method (commit 9df9f02)
- **Weights directive.** A new protocol directive, `weights <file>`, overwrites every PY-PY AMPA_D3 weight and mini amplitude after the initial weights are set.
  - The jitter draws are still consumed first, so every RNG stream is unchanged.
  - Each pre/post pair is checked against the network.
  - Verified: the loaded weights equal the source snapshot exactly and stay frozen to the end of the run.
  - Verified: loading the t = 0 weights reproduces the original run's spikes for the first ~100 ms. After that the runs diverge chaotically, because the loaded snapshot is float32 rather than double.
- **Per-window amplitude.** Test and train windows take an optional 5th field giving that window's stimulus amplitude.
- **Weight sets (30).** For each seed 0–4: the t = 0 weights (`init`), the end-of-training weights (`train`, t = 162 s), and the end-of-block weights (t = 512 s) of each of the 4 Fig 3 conditions. `init` and `train` were checked to be identical across conditions for each seed.
- **Run setup.** Each run uses the seed of its weight set: 12 s awake warm-up, then awake test trials only. `-plasticity_start 999999999` keeps STDP off throughout.
- **`stage1_curve`** (30 runs, 132 s each). 120 trials at the paper's 1 s ITI. Amplitudes 1.2 (the paper's value), 1.5, 1.9 and 2.4, 30 trials each, in one fixed shuffled order shared by all runs.
- **`stage1_spaced`** (20 runs, 102 s each). 30 trials at 1.2 with a 3 s ITI, for the `train`, `awake`, `n2` and `n3` weight sets.
- **Compute.** Modal, cpu = 4 / 1 GB, 5 runs per job, results persisted to Volume `wei2018-runs:/stage1`. Job wall times were 8.8–13.9 h. One job hit its deadline during its fifth run (spaced awake_s4); that run was resubmitted and completed. Total about 450 core-h.
- **Paired statistics.** By seed, n = 5. Two tests are reported: a paired t-test on per-seed means (conservative), and a trial-level McNemar test on trials matched by seed and trial index (liberal, because trials are not independent).

## Results

### 1. Fresh-state recall from saved weights (SM ≥ 0.8; mean of 5 seeds; `stage1_curve_table.csv`)

| weight set | Δw forward (%) | amp 1.2 | 1.5 | 1.9 | 2.4 | all amps | exact ABCDE, all amps |
|---|---|---|---|---|---|---|---|
| init | 0 | 11.3 | 12.7 | 10.0 | 13.3 | 11.8 | 2.0 |
| train | 24.7 | 16.7 | 26.7 | 20.7 | 38.0 | 25.5 | 6.2 |
| awake block | 25.2 | 24.0 | 18.7 | 18.0 | 47.3 | 27.0 | 6.2 |
| N2 block | 29.4 | 24.7 | 20.7 | 26.7 | 47.3 | 29.8 | 7.7 |
| N2+N3 block | 43.5 | 32.0 | 32.7 | 34.0 | 62.7 | 40.3 | 18.3 |
| N3 block | 54.7 | 44.0 | 41.3 | 52.7 | 64.0 | 50.5 | 29.7 |

Paired contrasts, all amplitudes pooled (`stage1_contrasts.csv`):

| contrast | SM ≥ 0.8 | exact ABCDE | paper (approx.) |
|---|---|---|---|
| train − init | +13.7 (seed-t p .005) | +4.2 (p <.001) | +8.8 |
| awake − train | +1.5 (p .63) | 0.0 (p 1.0) | ~+4, n.s. |
| N2 − awake | +2.8 (p .04; McNemar .29) | +1.5 (p .31) | ~+8 |
| N2+N3 − awake | +13.3 (p .017) | +12.2 (p .042) | ~+26 |
| N3 − awake | +23.5 (p .008) | +23.5 (p .026) | ~+38 |

- **The awake artefact disappears.** The awake-block weights recall no better than the end-of-training weights: +1.5 points, and 0.0 under exact ABCDE. The +8-point awake gain in the original Fig 3 runs therefore came from the state of the network in the post-block session, not from the weights.
- **The paper's full ordering now reproduces:** N3 > N2+N3 > N2 ≥ awake ≈ train > init. N3 and N2+N3 are significant. N2 is only marginal.
- **Recall now tracks the weights tightly.** Across the 30 runs, Spearman ρ(recall, forward Δw) = 0.93, against 0.77 for the original test sessions. For exact ABCDE ρ = 0.88; for B–E spikes ρ = 0.92.
- **Raising the amplitude does not make the readout more sensitive.** Recall is flat or non-monotonic from 1.2 to 1.9, then jumps at 2.4 for every weight set. At 2.4 the N3 − awake gap (+16.7) is no larger than at 1.2 (+20.0).

### 2. Trial spacing: a 1 s ITI suppresses recall (`stage1_spacing.csv`, `stage1_spacing_contrasts.csv`)

| weight set | ITI 1 s: SM ≥ 0.8 | ITI 3 s: SM ≥ 0.8 | ITI 1 s: exact | ITI 3 s: exact | ITI 1 s: B–E spikes | ITI 3 s: B–E spikes |
|---|---|---|---|---|---|---|
| train | 16.7 | 34.0 | 3.3 | 12.7 | 6.7 | 11.3 |
| awake block | 24.0 | 40.0 | 3.3 | 12.0 | 6.5 | 11.5 |
| N2 block | 24.7 | 44.7 | 5.3 | 16.0 | 7.9 | 12.9 |
| N3 block | 44.0 | 70.7 | 26.0 | 48.7 | 10.5 | 16.0 |

- Spacing trials 3 s apart raises recall by +20.0 points (p < 1e-4, 20 paired runs) and roughly doubles the evoked B–E response (+5.0 spikes).
- At 3 s the N3 level, 70.7 %, is close to the paper's ~65 %. N3 − awake is +30.7 (p .004). N2 − awake is +4.7 (n.s.) and awake − train is +6.0 (n.s.).
- The paper tests at 1 s, so this is a **model discrepancy**: the reimplementation recovers from each trial more slowly than the paper's network. Two further signs point the same way.
  - In the fresh curve runs, recall falls steadily across the 120 trials (N3: 59 % in trials 0–19 → ~40–48 % by trial 100). The B–E response falls from 10.4 to 8.1 spikes.
  - The paper's Fig 2D shows no such within-session decline.
- The decline builds up over tens of seconds. That is too slow to come from PY-PY short-term depression alone (τ = 700 ms), so a slow intrinsic or synaptic process is the more likely candidate. Identifying it is a Stage 2 task.

### 3. Fresh-state vs original sessions (amp 1.2; `stage1_fresh_vs_original.csv`)
Fresh testing at 1.2 gives init 11.3, train 16.7, awake 24.0, N2 24.7, N2+N3 32.0, N3 44.0. The original sessions gave 15.2, 18.4, 26.4, 23.2, 26.0 and 40.0.
N2+N3 gains the most from removing session history. The awake level at 1.2 alone is still numerically high (+7.3 over train, p .13), but the pooled and exact measures show no awake effect.

## Interpretation
1. **Readout, part 1: session-state history.** This fully explains the awake artefact, and part of why N2+N3 was not above awake in Fig 3.
2. **Readout, part 2: inter-trial fatigue at 1 s.** It compresses all recall levels by about 20 points. This is a model-level deviation from the paper, not an analysis artefact.
3. **Consolidation magnitude.** Recall is now almost a monotone function of the forward weight change, so whatever gap to the paper remains is set by Δw.
   Our sleep weight gains over awake are N3 +29.5, N2+N3 +18.3 and N2 +4.2 points. The paper's are about +38, +26 and +8.
   The N2 deficit is proportionally the largest, at about half of the paper's. Interpretation I2 (STDP halved in N2) and the spindle-frequency offset (6.5 vs ~7 Hz) remain the candidates.

## Suggested Stage 2
- **(a) N2 at full STDP.** 5 seeds × the N2 condition only, with `stdp_factor_n2 = 1`; then test-only runs from the resulting weights. This tests I2 directly. Cost: 5 × ~9.6 h at cpu = 4.
- **(b) Fatigue mechanism.** Short (~30 s) runs with state-variable recording. Compare 1 s and 3 s ITI, check which slow current or synaptic resource in the trained area builds up across trials, and check the corresponding Methods values in the paper.
- **(c) Optional.** Re-score all conditions with a fresh-state, 3 s ITI readout as a sensitivity analysis. This should be reported alongside the paper-faithful 1 s readout, never instead of it.
