# Stage 3: SWD boundary sweeps — tooling, design and status (branch `ckpt-opt`)

*2026-10-27. Reference configuration: N2 STDP factor 1.0, N3 0.75 (Stage 2), paper thalamic values.*

## 1. On-disk checkpoint (done, verified locally)

`-ckpt_save_at T -ckpt_save_path P [-ckpt_exit_after_save 1]` writes the full state (~11 MB);
`-ckpt_load_path P` continues from it. Implemented on top of `opt-exact` (exact 3.5× speed-ups and
in-process fork, built in a parallel session), so both ways of branching are available.

| Check (local, 6 cores) | Result |
|---|---|
| Restore at 2 s (training stimulus + STDP active, awake→N2 at 2.5 s) with 3 instead of 6 threads, vs uninterrupted run | spikes, LFP, weights, minis bit-identical over 2–3.5 s |
| Same test on the original code (main, `c150b71`) | bit-identical |
| `ckpt-opt` reference run vs original code | bit-identical |
| Branch with RE→TC GABA_A and GABA_B ×0.5 (1,628 + 1,628 synapses) and a changed `gaba_cx_awake`, `ckpt-opt` vs original code | bit-identical, so the compact synapse plans pick up overridden strengths |
| Runs without checkpoint flags vs previous binary | byte-identical |
| **Production network (Modal, original code, seed 0):** save at 212 s, restore, run to 232 s, vs the stored uninterrupted D1 `fig3_n2_s0` run | all 41,112 spikes and 20,000 LFP rows in 212–232 s bit-identical |

Branching semantics: state-table parameters (`gh_tc_*`, `gaba_cx_*`, `gkl_*`, …) and STDP factors take
effect immediately; synapse `strength`, `mini_s` and `mini_fre` come from the fresh build, so
`network.cfg` overrides branch (counts are logged as `CKPT_PARAM_OVERRIDE`); cell-intrinsic
constants are restored and cannot be branched. Checkpoint files are specific to the binary.

## 2. Correction to Stage 2

The gate run labelled "RE→TC GABA at Krishnan level" (v3) is invalid: its overrides were given in µS
in a file that uses mS, so RE→TC inhibition was ~730× (GABA_A) and ~700× (GABA_B) *stronger*, and
several TC cells were NaN from 9 ms. Its "4 Hz thalamic rhythm" is withdrawn (`wei2018_stage2.md`).
Also, a *more negative* `gh_tc` means *more* Ih here (h∞ = 1/(1+exp((V+75+gh_tc)/5.5))); the −3/−4 mV
gate runs increased Ih. Reduced Ih, the direction usually linked to absence epilepsy, is `gh_tc` > −2.

## 3. SWD screen (`analysis/swd_wei.py`)

The network has no EEG, so the screen uses the PY population spike train in 2 s windows (0.25 s
step). A window is SWD-like when (i) the dominant frequency in 0.5–20 Hz lies in 2–5.5 Hz, (ii) ≥35 %
of 0.5–20 Hz power is within ±0.5 Hz of it, (iii) median ≥30 % of PY cells fire in each population
burst, and (iv) the CV of inter-burst intervals is ≤0.25. Episodes are merged windows lasting ≥3 s.

Negative controls, all **0 episodes**: N2 baseline; N2 with `gh_tc` −3 and −4 mV; N2 with literal TC
routing (cortex at 7 Hz, 74 % participation); the N3 block and the no-sleep awake block of Fig 3
seed 0. Two attempted positive controls from t = 0 (N2 with cortical GABA-A ×0.3; ×0.5 plus RE→TC
GABA_B ×4) produced no SWD either. **Sensitivity is therefore unvalidated**: the first candidates
from tier 1 will be inspected by eye (rasters, LFP, TC/RE timing) before thresholds are relied on.

## 4. Tier 1 design (`make_swd_tier1.py`, `job_branch.py`)

Branch from the 212 s checkpoint of each seed; 70 s of N2 or awake, no stimulus, plasticity off;
screen 222–282 s. One axis at a time:

| Axis | Levels | How |
|---|---|---|
| A. RE→TC inhibition (GABA_A and GABA_B together) | ×0.25, 0.5, 0.75, 1.5, 2, 3, 4 | `network.cfg` strengths (mS) |
| B. TC Ih activation shift | Δ = −2, −1, +1, +2, +4, +6 mV from the state value | `gh_tc_n2` / `gh_tc_awake` |
| C. Cortical GABA-A loss | ×0.8, 0.6, 0.4, 0.2 | `gaba_cx_n2` / `gaba_cx_awake` |

18 branches per state (with the baseline) × 2 states × 3 seeds = 108 runs of 70 s. With the
opt-exact binary this is about 7,600 model-seconds: roughly 30 pod-hours (~$8) on the 8-vCPU
Runpod pod, or ~$20 on Modal Sandboxes, plus ~$1 for the three 212 s checkpoints.

## 5. Status

- Waiting for the parallel session's full-length Runpod validation of `opt-exact` (the user chose to
  consolidate on it). Then: write the three 212 s checkpoints with `ckpt-opt`, validate one restore
  against the stored Modal `fig3_n2` run, and launch tier 1.
- Production-network validation of the checkpoint (original code, seed 0): passed (table above).
