# Exact speed-ups and checkpoint/fork for the Wei 2018 C++ model

*Branch `opt-exact`, 2026-10-26. Every change keeps the output **bitwise identical** to the original
code: spikes, LFP and the PY–PY weight and mini snapshots, checked with `rp/digest.py`-style SHA-256
fingerprints.*

## What changed

| Change | Where | Switch |
|---|---|---|
| **Shared presynaptic gates.** AMPA (TC→RE, CX→TC, CX→RE), GABA_A (RE→TC, RE→RE) and NMDA_D1 (CX→CX, CX→IN) gates depend only on the presynaptic spike train: there are no minis, no per-synapse randomness and no plasticity. Every synapse from one presynaptic cell therefore holds a bitwise-identical gate (probe: 1.65 M comparisons, 0 differing). One leader per (presynaptic cell, kind) is updated per RK substep, 1,200 leaders for 28,776 synapses. Substep 2 repeats substep 1's time with no new input, so the leader update is skipped there (idempotent). | `main.cpp` `build_shared_gates`, `runMP`; `currents.cpp` `*::gate`, `shared_*` | `-share_gates 0` restores the original per-synapse path |
| **Compact per-cell synapse plan.** Contiguous entries in the original `syns[]` order, so currents are accumulated in exactly the original order. Shared entries carry strength, reversal potential and pointers to the leader's gate, so the scattered `Syn` objects are never touched. The NMDA voltage factor is computed once per cell and call: same expression, same `vd`. | `CellSyn.cpp` `CellSyn::calc`, `build_plan` | built only when `homeo_boost == 0`, because the plan caches strengths |
| **Exact idle skip** for AMPA_D2, AMPA_D3 and GABA_A_D2. A call that would change no state is skipped: gate closed (`C == 0`, `R == 0`; `exptable()` returns exactly 0, so `R` cannot grow back without a release), no presynaptic spike, no post spike (AMPA_D3 STDP), and no spontaneous release due. The test uses the same expressions as `calc()`. In instrumented runs 54–78 % of synapse calls were in this state. | `currents.h` `idle()`; `CellSyn::calc` | `-idle_skip_off 1` |
| **Checkpoint/fork.** `-fork_at T` with `WEI_FORK_LIST=<file>` simulates `[0, T)` once, then `fork()`s one child per protocol. Each child inherits the complete in-memory state, copies the prefix outputs, reopens its output streams in append mode, switches protocol and parameters, and continues. A child's output equals an unforked run of its protocol. Protocols must agree before `T`; this is checked. | `fork.cpp`; driver `sim/wei2018/job_fork.py` | off unless `-fork_at` is given |

### A donor bug this surfaced

`REsyn::memory` cast **every** synapse onto RE cells to `GABA_A` and wrote `E_GABA`. For the
AMPA synapses (TC→RE, CX→RE) that write lands on the unused `AMPA::old_v`, so it was harmless. It
stopped being harmless as soon as the `Syn` layout changed: a 4-byte field shifted AMPA's members
and the write hit `AMPA::R`, which produced NaNs. The cast is now guarded by type, and the new base
fields are 8-byte so derived-class offsets are unchanged.

### OpenMP and fork()

libgomp worker threads do not survive `fork()`; a child that opens a multi-thread parallel region
hangs. The parent therefore calls `omp_pause_resource_all(omp_pause_hard)` (OpenMP 5.0) before
forking, which works with GCC 13. If that symbol is missing (older libgomp), children fall back to
one thread.

## Validation so far (local, 6 cores, g++ 13)

| Check | Result |
|---|---|
| `devcheck` (6 s: awake tests, training with STDP, N3, N2, awake test; `-plasticity_start 0`) | identical to the original code at every stage. Wall time 871 s original → 479 s (shared gates) → 362 s (+plan) → 251 s (+idle skip): **3.5×** |
| Same at 2 threads vs 6 threads | identical |
| `devcheck_w` (test-only from saved weights, `-rec_area 1 -tc_ampa_route 1`) | identical, including `rec_area` |
| Fork at 3 s into `devcheck` + `devcheck_b` (N2/N3 order swapped) | child `devcheck` = original run; child `devcheck_b` = unforked run of `devcheck_b` |
| Thread efficiency | at 2 threads one run uses 1.5× fewer core-seconds than at 6 threads, so pack runs (or fork children) at 1–2 threads each |

### Full-length validation on Runpod (2026-10-27, `sweeps/wei2018_speedups/`)

The Pod was Compute-Optimized, 8 vCPU (4 AMD EPYC 9655P cores × 2 hyperthreads), with g++ 9.4.
Fig 3 seed 0 was simulated once to 212 s on 8 threads, then forked into awake, N2, N3 and N2+N3,
each continuing on 2 threads to 562 s. Each child's complete output (spikes, LFP, weight and mini
snapshots) was compared with the original Modal run (g++ 12.2, unoptimised code) at 212 s and at
562 s: **all 8 comparisons identical**.

| Measure on this Pod | Value |
|---|---|
| Original vs optimised code, fig3_n2 first 10 s, 8 threads | 369.9 s vs 314.5 s: **only 1.18×**, against 3.5× on the local PC |
| Shared prefix 0–212 s, 8 threads | 6,821 s (32.2 s per model-s) |
| Four forked children, 2 threads each, 212–562 s | 87–98 s per model-s per child (≈ 24 Pod-s per model-s in total) |
| Whole job | ≈ 11.7 h ≈ $2.85, i.e. ≈ $0.71 per Fig 3 condition |

The optimisations gain far less on this server CPU than on the local PC, which runs the original
code about 4× slower. The local PC is probably memory-bound, and the big caches of the server
processor already hide most of the memory traffic the changes remove. On Runpod the saving comes
mostly from checkpoint/fork (1,612 instead of 2,248 model-seconds for Fig 3) and from packing runs at
2 threads each.

## Using it

```
python job_fork.py src.tar.gz <seed> <threads> 212000 <child_threads> fig3_awake fig3_n2 fig3_n3 fig3_n2n3
python job_fork.py src.tar.gz 0 8 212000 2 fig3_n2:stdp_factor_n2=1 fig3_n2n3:stdp_factor_n2=1
```

Each child is reduced to `out/<run_id>.npz` under the same `run_id` that `job_run.py` gives the
unforked run. Parameter overrides that only matter after the fork go on the child; anything that
affects the prefix goes after `--`, and then applies to the parent and every child.
