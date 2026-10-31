# Stage 3, tier 1: single-axis SWD screen of the Wei 2018 network

**Status (2026-10-31):** complete, 108 of 108 branches (3 seeds × 2 states × 18 points).
**Result:** no spike-and-wave discharge anywhere. Under the human-absence frequency band (2–5.5 Hz) there are 0 episodes. Under the rodent band (7–11 Hz) there are 26 episodes, all in N2 with RE→TC inhibition ≥ ×1.5. In a reconstructed EEG these are trains of sharp surface-negative transients with no slow wave, i.e. hypersynchronous spindle-band discharges, not SWDs.

## Design

- Model: ckpt-opt branch (checkpoint/fork build of opt-exact). Reference configuration: stdp_factor_n2 1.0, stdp_factor_n3 0.75 (Stage 2, option 2).
- Each seed (0, 1, 2) writes a full-state checkpoint at 212 s, at the end of training, of the Fig 3 protocol.
- **Validation gate.** Each seed's checkpoint is restored into all four Fig 3 conditions and run to 282 s. The output must match the original Modal runs at 212 and 282 s, comparing spike, LFP and weight digests. All three seeds returned `ALL_IDENTICAL`.
- **Branches.** 70 s runs (212–282 s) from the checkpoint with plasticity off. The SWD screen covers 222–282 s, after a 10 s settle. Axes:
  - **A**, RE→TC GABA-A and GABA-B together: ×0.25, 0.5, 0.75, 1.5, 2, 3, 4.
  - **B**, TC Ih activation shift (gh_tc for the state): +Δ for Δ ∈ {−2, −1, +1, +2, +4, +6} mV. + means less Ih.
  - **C**, cortical GABA-A (IN→PY): ×0.8, 0.6, 0.4, 0.2.
  - Plus an unperturbed baseline. Each axis is run in N2 and in awake.
- **Compute.** Three Runpod 8-vCPU pods, one seed each, 4 branches in parallel at 2 threads. Seed 0's last 3 branches were completed later from its saved checkpoint, using the EEG-capable build. That build is bit-identical to the tier-1 build (see EEG section).

## SWD screen (analysis/swd_wei.py, commit 01d06dd)

The screen works on the PY population spike train in 2 s windows (0.25 s step). A window passes when all four criteria hold:

1. The dominant frequency f₀ (0.5–20 Hz) lies in the band.
2. At least 35 % of power is within ±0.5 Hz of f₀.
3. The median fraction of PY cells firing per population burst is at least 30 %.
4. The inter-burst-interval CV is at most 0.25.

Episodes are merged passing windows lasting at least 3 s. Two bands are reported side by side: **human** 2–5.5 Hz (the legacy `swd` column) and **rodent** 7–11 Hz (GAERS / WAG-Rij). Because the rodent band overlaps the spindle band, rodent hits must be checked against the N2 baseline and by eye.

## Results (swd_tier1_dualband_all.csv)

- **Human band:** 0 episodes in all 108 branches.
- **Rodent band:** 26 episodes, all in N2 axis A:

  | RE→TC (N2) | episodes, seeds 0/1/2 | median f₀ | participation |
  |---|---|---|---|
  | ≤ ×1 | 0/0/0 | – | – |
  | ×1.5 | 1/0/2 | 7.5 Hz | 0.50 |
  | ×2 | 2/4/1 | 8.5 Hz | 0.55 |
  | ×3 | 3/3/1 | 9.5 Hz | 0.56 |
  | ×4 | 3/3/3 | 10 Hz | 0.66 |

  0 of 699 N2-baseline windows pass the rodent band.
- **Awake:** TC and RE fire no spikes, with fixed potentials (TC −57.5 mV, RE −77.4 mV, SD 0.016 mV). Axes A and B are therefore identical to awake baseline in every seed. Only axis C changes cortical activity (PY 0.70 → 1.24 Hz at ×0.2), with no episodes. Whether a silent awake thalamus is faithful to Wei et al. is unverified.
- **N2, axis B:** PY rate rises monotonically with less Ih, from 0.04 Hz at −2 mV to 4.5 Hz at +6 mV. Less Ih gives near-continuous 6–6.5 Hz spindling. No episodes.
- **N2, axis C:** rate rises modestly (1.9 → 2.7 Hz). Near-miss windows move to 0.5–1 Hz. No episodes.

## EEG reconstruction (commits 157dd2c, 7e79ee9)

The model now has an optional `-rec_eeg 1` recorder. Every 1 ms, for 25 blocks of 20 PY cells, it writes the summed dendro-somatic axial current (the current dipole of the two-compartment cells), the total synaptic current and the IN→PY GABA-A current. `analysis/eeg_wei.py` turns these into three EEG estimates at 5 virtual electrodes along the chain:

- **current dipole:** primary;
- **Destexhe Coulomb sum** of synaptic currents;
- **Martínez-Cañada et al. 2021 ERWS1** proxy.

Each is 40 Hz low-passed.

- **Non-invasive.**
  - On a 6 s development run, spikes, LFP and weights are bit-identical across the old build, the new build, and the new build with recording on.
  - At production length, five seed-0 N2 branches re-run with EEG on reproduce the tier-1 branches exactly (every spike, the mean-voltage trace).
- **Calibration:** awake is flat, N2 shows waxing-waning spindle transients, N3 shows large slow waves. Destexhe and ERWS1 agree (r ≈ 1.0). The dipole is similar, with sharper transients.
- **Polarity is a convention.** Dendritic inward current is plotted as surface-negative, so population bursts and Up states are negative.
- **Morphology:**
  - In every N2 condition, including RE→TC ×4, discharges are trains of sharp negative transients, about 30–50 ms wide.
  - The peak-triggered mean shows no positive slow wave 100–300 ms after the peak.
  - ×4 differs from baseline in regularity and size (a ~100 ms periodic train across the chain), not in shape.

## Interpretation and consequences for tier 2

1. On these three single axes, the network moves from spindles toward faster, more synchronous spindle-band discharges. It does not move toward 3 Hz spike-and-wave.
2. **The Wei network has no cortical GABA-B.** Its only cortical inhibition is IN→PY GABA-A (network.cfg). In Destexhe's thalamocortical SWD models, the slow "wave" and the ~3 Hz pacing come from GABA-B-mediated K⁺ currents in cortical cells. The absence of a wave in our EEG is therefore expected, and tier 2 cannot find a classic SWD on these axes without adding the missing receptor.
3. **Tier 2 proposals:**
   - **Positive control:** add IN→PY GABA-B, Destexhe-style, so that the detector and EEG can be validated on a model that does produce SWDs.
   - **Combined axes:** for example, cortical GABA-A loss together with stronger thalamic inhibition.
   - **The awake thalamus question.**
4. The EEG-based SWD detector (port of analysis/swd.py) should require a morphology criterion, a negative spike followed by a positive slow wave, in addition to frequency.

## Artifacts

| Content | Location |
|---|---|
| tier-1 table (108 rows) | swd_tier1_dualband_all.csv |
| tier-1 figure | tier1_axes.png |
| EEG figures | eeg_calibration_s0.png, eeg_inspect_reTCx4_s0.png, eeg_morphology_s0.png |
| checkpoints | ck212_s{0,1,2}.bin |
| per-branch reduced data | tier1_branches_s0.tar.gz, tier1_branches_s1s2.tar.gz, s0_combined_results.tar.gz |

Figures, the table and plot_tier1.py are also in `sweeps/wei2018_stage3_tier1/`; checkpoints and per-branch data are in the project store only.
