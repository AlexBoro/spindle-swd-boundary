# Wei et al. 2018 reimplementation: Stage 0 diagnostics (analysis only)

This stage used the 20 existing Fig 3 runs: 4 conditions × seeds 0–4, 562 s each, at commit f48134b. No new simulations were run.
The question is which parts of the Fig 3 mismatch come from the readout, which from the model's state, and which from the consolidation magnitude.
Figure: `sweeps/wei2018_stage0/wei2018_stage0_diagnostics.png`. Tables are in the same folder.

## Summary

| Mismatch (from docs/wei2018_reproduction.md) | Stage 0 verdict |
|---|---|
| Awake recall rises 18.4 → 26.4 % (p=0.02) with no weight change; the paper reports n.s. | **Readout artefact.** The gain sits mostly in the first ~15 trials after a 300 s stimulus-free pause, when evoked responses are larger. Weights and minis do not drift (forward Δw +0.46 points, minis 0). Under an exact-ABCDE readout the awake gain is 0.0 points. |
| Recall magnitudes are small (N3 40 % vs paper ~65 %), and N2 / N2+N3 are not above awake | **Partly readout.** Success is set mainly by how many evoked spikes reach groups B–E: 2.5 % → 44 % across quartiles. On average only 3.6–3.8 of the 5 groups respond in a trial. Stricter readouts raise ρ(recall, Δw) from 0.54 to 0.77–0.85. But N2 never exceeds awake under any of the 8 readouts, and N2+N3 does so only marginally (+2.9 to +4.6 points; p=0.03 in one variant). So a **consolidation-magnitude shortfall in N2 remains possible** and is not settled by this analysis. |
| Weight change after the block (N3 54.7, N2+N3 43.5, N2 29.4, awake 25.2 %) vs paper ~65/53/35/27 % | Not testable without new runs. The ordering matches. Candidate cause: interpretation I2, which halves STDP in N2 as well as N3. |
| N3 spatial correlation 0.45 at 60 cells vs paper ~0.8 | **Method, mostly.** With the MATLAB `xcorr(...,'coeff')` convention (no mean subtraction) and lags spanning the whole Up state, N3 levels off at 0.71 (0.76 at 60 cells). The gate method (demeaned, ±100 ms) gives 0.27. N2 levels off at 0.50 vs the paper's ~0.35, so N2 events are somewhat more global than in the paper. |
| Spindle frequency 6.1–6.5 Hz vs 7–14 Hz | **Small real miss, about 0.5–1 Hz.** Model N2 events have a median within-event cycle frequency of 6.48 Hz (IQR 6.30–6.92; 152 events). The paper's own Fig 2B N2 trace, digitised against its 1 s scale bar, runs at about 6.9–7.6 Hz and lasts about 5 s. Its text says 7–14 Hz and 0.5–3 s. Krishnan et al. 2016 describe the model's spindles as 7–15 Hz. Every population (PY, IN, TC, RE) has its spectral peak at 6.35 Hz, so this is not cycle-skipping. |
| N2 event duration longer than 0.5–3 s | **Detector-dependent; not a miss.** Medians are 1.08 s (median/MAD threshold, 300 ms merge), 3.6 s and 5.05 s (gate detectors). The paper's own Fig 2B event is about 5 s. |

## Step-by-step results

1. **Stationarity.** Whole-network spontaneous PY rate, excluding 0–600 ms after each stimulus, is 1.2 Hz during warm-up. After that it is stable at about 0.6–0.73 Hz, drifting down about 15 % (test 1 0.67 → test 3 0.56 Hz). In the trained area the spontaneous rate is strongly suppressed during training (0.014 Hz) and during tests (0.33–0.39 vs 0.55–0.63 Hz in the block).
2. **Fatigue / transient.** Group A spikes per trial are stable at 5.1–5.6. Downstream B–E spikes per trial: 6.0 before, 7.6 after training, 8.6 after the block, and 14.4 in the first 5 trials after the block. In the awake condition, after-block success is 32/36/48 % in the first trial bins and then about 20 %, the same level as after training. Thalamus is silent during awake tests. All short-term-depression recovery constants are 700 ms. Background rate only weakly predicts success (25 → 18 % across quartiles).
3. **Drift.** Over the awake block, forward weights change +0.46 points and minis do not change. During N3, synapses entering the trained area from outside depress by −17.6 %.
4. **Readout sensitivity** (`stage0_readout_sensitivity.csv`). In the table, "train gain" is the recall gain from training and "awake gain" is the recall gain over the awake block. The last three columns are same-seed recall gains over awake, in points.

| Variant | train gain | awake gain | N3 | N2+N3 | N2 | ρ(recall, Δw) |
|---|---|---|---|---|---|---|
| V0 as published (SM ≥ 0.8, σ≈10 ms, 350 ms) | 3.2 | 8.0 | +13.6 (p .01) | −0.4 | −3.2 | 0.54 |
| V1 σ≈5 ms | 3.6 | 9.2 | +12.8 | −2.0 | −3.6 | 0.51 |
| V2 σ≈20 ms | 5.6 | 8.0 | +12.4 | −2.4 | −3.2 | 0.46 |
| V3 150 ms window | 1.2 | 0.8 | +4.4 | +3.6 | −0.4 | 0.51 |
| V4 all 5 groups present | 1.2 | 2.0 | +10.8 (p .03) | +2.0 | −1.6 | 0.78 |
| V5 exact ABCDE | 2.8 | 0.0 | +13.6 (p .02) | +4.4 | +0.4 | 0.85 |
| V6 trials 15–49 only | 3.4 | 3.4 | +18.9 (p <.01) | +4.6 | −2.3 | 0.64 |
| V7 V4 + trials 15–49 | 1.7 | −2.3 | +16.0 | +2.9 (p .03) | −0.6 | 0.77 |

   Paper targets: training gain +8.8, awake about +1 (n.s.), N3 about +40, N2+N3 about +25, N2 about +6.
   Exact-ABCDE absolute recall (%) before / after training / after the block: awake 2.0 / 4.8 / 4.8; N2 2.0 / 4.8 / 5.2; N2+N3 2.0 / 4.8 / 9.2; N3 2.0 / 4.8 / 18.4.
   The paper says that with a threshold of 1.0 the baseline is "almost zero"; ours is 2.0 %.
   Under this strict readout the ordering is N3 > N2+N3 > N2 ≈ awake. That matches the paper, except that N2 shows no benefit.
5. **Spatial correlation** (`stage0_xcorr.csv`). Data: first 40 Up-state events ≥ 300 ms in each of `fig3_n3_s0` and `fig3_n2_s0` (sleep block), each padded by ±100 ms. Spike trains were convolved with a Gaussian (σ = 5 ms), and the peak of the normalised cross-correlation was averaged over all cell pairs at each distance. The N3 level ranges from 0.27 to 0.71 depending only on mean subtraction and lag range. The MATLAB 'coeff' convention is the one the paper most likely used: Methods say "cross-correlation", and the code lineage is MATLAB. Under that convention N3 is about 0.1 below the paper and N2 about 0.15 above it.
6. **Spindles** (`stage0_n2_spectral.csv`, `stage0_n2_events.csv`). Data: 215–510 s of each `fig3_n2` run, PY mean-voltage LFP. The Welch peak is 6.35 Hz in all 5 seeds, with a harmonic at about 12.7 Hz. Power at 4–7 Hz is 2.8 times power at 7–14 Hz. Events per minute are 6.2 with the median/MAD detector; the paper reports about 5. The text-specified detector (7–14 Hz envelope, mean + 2 SD, 0.5–3 s) finds only 0.4 events/min here, because most power sits below 7 Hz.

## Implications for Stage 1 / 2

- The readout explains the awake artefact and much of the compressed dynamic range. Most of it traces to weak, incomplete propagation of the evoked response: on average only 3.6–3.8 of 5 groups respond.
  A Stage 1 load-weights test can separate readout from consolidation. Freeze the end-of-block weights of each run, then rerun tests only. Steps: sweep input_strength, space trials more widely, and plot the readout curve against the weights.
- N2 shows no benefit under any readout. That is the one result that would need a model change if Stage 1 confirms it. The candidates, in order:
  1. I2: N2 at full STDP, i.e. stdp_factor_n2 = 1.
  2. N2 spindle density and frequency. The model runs 0.5–1 Hz slow and its events are more global.
- The N3 correlation needs no model change. Use the MATLAB 'coeff' convention from now on.
