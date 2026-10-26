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

Pending: a full-length check against the original Modal Fig 3 runs on Runpod (`rp/validate.sh`).
It forks at 212 s into awake, N2, N3 and N2+N3, and compares each child's complete 562 s output
with the Modal run's fingerprint.

## Using it

```
python job_fork.py src.tar.gz <seed> <threads> 212000 <child_threads> fig3_awake fig3_n2 fig3_n3 fig3_n2n3
python job_fork.py src.tar.gz 0 8 212000 2 fig3_n2:stdp_factor_n2=1 fig3_n2n3:stdp_factor_n2=1
```

Each child is reduced to `out/<run_id>.npz` under the same `run_id` that `job_run.py` gives the
unforked run. Parameter overrides that only matter after the fork go on the child; anything that
affects the prefix goes after `--`, and then applies to the parent and every child.
