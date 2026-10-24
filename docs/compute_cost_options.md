# Cheaper ways to run the Wei 2018 / Bazhenov-lineage C++ simulations

*Written 2026-10-24 while the Stage 2 jobs were running. All prices are third-party summaries of Modal's pricing page; check the live page before relying on them.*

## Where the money goes now
- **What a run costs.** A 562 s Fig 3 run at `cpu=4` takes about 264 core-s per model-s, i.e. about **41 core-h** and about 10.3 h wall.
- **The pricing tier.** Every job submitted through the Claude Science Modal integration runs as a **Modal Sandbox**; job records carry `sb-…` IDs.
  - The Sandbox tier is about **$0.142 per physical core-hour** plus $0.024 per GiB-hour.
  - Standard (preemptible) Modal Functions are about **$0.047 per core-hour** plus $0.008 per GiB-hour.
  - So we pay roughly **3x the Function rate**.

| Where it runs | Cost per 562 s run | Notes |
|---|---|---|
| Modal Sandbox (current) | ≈ $6.1 (41 core-h × $0.142 + 10 GiB-h × $0.024) | Works today; 10-container cap |
| Modal Function | ≈ $2.0 | Needs `input-plane.us-east.modal.com` allowlisted, a deployed app, and checkpointing or retries because Functions are preemptible |
| Neuroscience Gateway (NSG → SDSC Expanse) | $0 within the allowance | Starting limit is 20,000 core-h per user per year, about 480 such runs; more on request. Account vetting, batch-queue waits, 48 h job limit |
| ACCESS "Explore" allocation | $0 | For US academic / non-profit researchers; short proposal |
| Local machine (6 logical cores) | $0 | Multithreaded scaling is poor here (about 575 core-s per model-s at 6 threads), so about 15 h per run using the whole machine |

For scale, the project has used on the order of 2,000–2,500 Modal core-hours so far, counting the runs lost to the spend limit and to the offline harvest. That is about 10 % of one year's NSG allowance.

## Changes to the code and protocols (these apply on any platform)
Profile of 300 ms of N2 on one thread (gprof):
- The per-cell synapse loop (`CellSyn::calc`) takes 30 %.
- Synapse updates take about 45 %: thalamic `AMPA` 14 %, `NMDA_D1` 9 %, plastic `AMPA_D3` 9 %, `AMPA_D2` 7 %, GABA 6 %.
- Intrinsic currents take about 20 %.
- Every synapse is re-evaluated at each of the four RK4 substeps. The 18,090 non-plastic cortex→thalamus AMPA synapses account for 1.18 of about 2.3 billion synapse calls.

| Change | Expected saving | Exact? | Effort |
|---|---|---|---|
| **A. Checkpoint and fork.** Save the full network state at a shared time point (e.g. sleep onset, 212 s) and start every condition from it | Fig 3 design −28 % (4 × 562 → 212 + 4 × 350 model-s); a rerun of one sleep condition −38 %; SWD parameter sweeps from a trained state need to simulate only the perturbation window, often 5–20x less per point | Yes, bit-identical. No `rand()` calls after initialisation; per-synapse `drand48_r` buffers are plain structs | About ½–1 day plus an identity test |
| **B. Update synaptic gating once per time step**, not at every RK substep. The driving force still uses the substep voltage | About 1.5–2x overall, since synapse code is about 75 % of run time | No. The O(dt) change in R within a 0.02 ms step is physiologically negligible, but it must be validated against the gate statistics (rates, spindle and SO metrics, Fig 3 weight change) | About ½ day plus validation runs |
| **C. Merge non-plastic cortex→thalamus AMPA synapses** onto each target cell | Perhaps a further 1.2–1.3x | Approximate, because the receptor kinetics saturate | Lower priority |
| **D. Shorter screens.** Test-only readouts from saved weights (already in use); 100 s instead of 300 s sleep blocks for parameter screens | Several-fold per screen | Protocol change, not a model change | Done / trivial |
| **E. Keep `cpu=4` per run** (264 core-s/model-s, against 285 at 8 threads and 344 at 16). Pack two runs into one `cpu=8` container when the 10-container cap binds | Already applied | Yes | Done |

Combining the Function tier (≈3x), checkpoint/fork (≈1.4x on Fig-3-type designs) and B (≈1.7x) gives roughly **7x less spend per experiment**. Moving to NSG instead makes it free within the yearly allowance.

## Recommendation
1. **Before the SWD phase, implement A (checkpoint/fork).** That phase is a parameter sweep from one trained, slept network state, which is where A pays off most. It needs no new accounts.
2. **Implement B behind a switch, then validate it.** Run one Fig 3 condition and the N2/N3 gates with B on and off, and adopt B only if every gate metric agrees within seed-to-seed variability.
3. **Platform: choose one.**
   - (a) Register for NSG (free; nsgportal.org; vetting takes a few days). I would drive it through its REST API (NSG-R), which needs your NSG username, password and application key stored as credentials, and `nsgr.sdsc.edu` allowlisted.
   - (b) Allowlist Modal's Function endpoint so I can test the cheaper tier, with checkpointing from A making preemption harmless.
4. Keep using the current Modal Sandbox path for anything urgent; it is the most reliable option we have.
