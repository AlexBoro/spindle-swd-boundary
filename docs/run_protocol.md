# Run protocol

What a trustworthy run of this model requires, and why. Everything here was
established against the deposit as vendored, on NEURON 7.8.2.

## What the 20 s run actually showed

**Correction.** An earlier version of this document diagnosed the 20 s run as a
cold-start transient in which the network died. The first half of that is right
and the second is wrong. A 60 s run (`14e4782842b132e0`, `saveData = 20`, 5237.5 s
wall) shows the network **does not die — it cycles**:

| | epoch 1 | gap | epoch 2 | gap | epoch 3 |
|---|---|---|---|---|---|
| time | 0.0–5.6 s | 21.4 s | 27.0–33.6 s | 19.5 s | 53.1–60.0 s |
| peak cortical rate | 87.1 Hz | — | 36.5 Hz | — | 34.6 Hz |
| peak NRT_FO rate | 110 Hz | — | 76 Hz | — | 81 Hz |
| spindle-band peak (Welch) | 8.30 Hz | — | 8.79 Hz | — | 8.79 Hz |

Activity arrives in epochs of 6–7 s separated by ~20 s of complete network
silence, with an autocorrelation period of **27.93 s (0.0358 Hz)**. The 20 s
window happened to contain exactly one epoch plus one gap, which is why it looked
terminal. Duty cycle is 31.8%.

Two things follow. First, **the warm-up is one full cycle, not a few seconds**:
epoch 1 is visibly the cold start (peak rates 2.4–2.5× those of later epochs, a
broad spectrum peaking at 5.4 Hz rather than in the spindle band), while epochs 2
and 3 agree closely on rate and to 0.01 Hz on frequency. Discard the first ~28 s.
Epoch 3 is right-censored at `tstop`, so its duration is a lower bound and the
case for stationarity rests on one complete post-transient cycle.

Second, **the active epochs look spindle-like and the gaps do not look like
sleep.** Within epochs 2 and 3 the cortical population rate peaks at 8.79 Hz,
inside criterion C2.1's 7–14 Hz window. But ~20 s of *complete* silence — zero
spikes across all 900 cells — is not NREM: infra-slow modulation of spindle
occurrence in real sleep rides on continuous background activity. Whether longer
runs fill the gaps in is an open Gate 0 question, and it is the reason the
authors' 1200 s default matters.

### The mechanism, which still holds

The thalamic account below was derived from the 20 s run and survives: it is what
drives the cycle, rather than what killed the network.

| window | NRT_FO rate | TC_FO rate | cortex (L5) rate |
|---|---|---|---|
| 0–2 s | 25.5 Hz | 7.8 Hz | 18.0 Hz |
| 4–6 s | 18.4 Hz | 6.0 Hz | 6.2 Hz |
| 8–20 s | 0.0 Hz | 0.0 Hz | 0.0 Hz |

Eight spikes were emitted across all 900 cells between 8.5 s and 20 s.

The mechanism is thalamic and is visible in the code. `TCcell.hoc` gives both
relay populations the `iarg` mechanism — I_h gated by intracellular Ca²⁺ — with
`k2_iarg = 0.000150` and `k4_iarg = 0.00007`, binding and unbinding rates whose
reciprocals are roughly 7 s and 14 s. From a cold start at `v_init = -65` the
network bursts vigorously, T-type Ca²⁺ entry loads the Ca²⁺ binding site, I_h
rises, and the thalamus depolarises: TC_FO from −68 mV to −46 mV over six
seconds, TC_HO to −55 mV, both NRT populations to −50 mV. At those potentials
T-current cannot de-inactivate and Na⁺ channels are largely inactivated, so the
thalamus stops firing. Cortex, deprived of thalamic drive, settles at −73 to
−77 mV with no synaptic input at all (|iGlu| < 3e-15 after 12 s).

The silence is the trough of the cycle, not an endpoint. NRT repolarises
throughout it — from −50.4 mV at 6–8 s to −60.7 mV at 18–20 s, a linear fit over
8–20 s giving **0.887 mV/s** (r = −0.9994) — which is the slow `k4` unbinding limb
recovering the T-current from inactivation. In the 60 s run NRT reaches −67 mV by
26 s and the next epoch starts at 27 s, so the cycle period is set by how long
that unbinding takes.

The authors never see the silence as pathology: the deposit ships
`tstop = 1200e3`, forty-odd cycles, so the gaps are just structure in a long
recording.

**Consequence for Gate 0.** No measurement from the first cycle counts. The
10.468 Hz spectral peak, the firing rates, and the three "spindle events"
reported from the 20 s run are withdrawn — that window held one cold-start epoch
and one gap. Every run must discard a full warm-up cycle (~28 s at these
settings) and that length must be re-measured whenever a conductance moves, since
the cycle period is itself a function of the thalamic parameters this project
sweeps.

## Settings that are not free parameters

| variable | value | note |
|---|---|---|
| `modelType` | 20 | thalamocortical network; also the deposit default |
| `runMode` | 0 | single run without a clamp; deposit default |
| `dt` | 0.25 | deposit default. The comment says 0.25 for testing, 0.1 for figures |
| `v_init` | −65 | deposit default; there is no equilibration step (see below) |
| `pProc` | 1 | left at the deposit default and run serially (`nhost = 1`) |

`initialise.hoc` defines an `init()` with four equilibration paths — a 2 s
pre-run at `dt = 1`, a run-to-3010.65-ms-and-save, and a load-saved-states
branch — selected by a variable `initState`. **That file is never loaded by any
other file in the deposit, and `initState`, `saveStates` and `loadStates` are
defined nowhere.** It is dead code. There is no equilibration; every run starts
cold, which is what makes the transient above unavoidable.

## Two defects in the deposit

**The shipped default state is not a valid state.** `init.hoc` sets
`state = "awake_long"`, but every `strcmp` chain in `TCcell.hoc`, `NRTcell.hoc`
and `Cx3cell.hoc` tests for `"wake_long"`. The default therefore matches no
branch and the model as downloaded applies no state-specific conductances at
all. Any run must set `state` explicitly.

**The thalamus-only configuration does not run.** `modelType = 4` ("thalamus
(minimal sleep spindle)") aborts at `thalamus.hoc:90` with
`init not enough arguments` — `TCcell`'s constructor signature and this caller
have diverged. `modelType = 5` is untested. The full network (`modelType = 20`)
is unaffected.

## NEURON's exit code means nothing

NEURON returns **0 after a hoc error**. The broken thalamus configuration above
aborts during `createCells()`, writes no output, and exits 0.

In a parameter sweep this failure mode is silent and total: a conductance point
that kills the model returns success with no traces, and the point either
disappears from the sweep or is recorded as a zero. Either way the measured
boundary moves and nothing announces it.

`sim/runner.py:check_run()` therefore gates each run on four independent
signals — a nonzero exit, any of twelve hoc error signatures in stderr, the
absence of NEURON's own `Execution time` line from stdout, and the absence of
`.dat` files when `saveData` requested them — plus a tripwire for a wall time
below the model time, which no legitimate run of this model can achieve. The
run record carries `ok` and `failures`, and the runner exits 1 when any fire.

## Cost

Serial, one run per core, measured on the local machine (6 cores, 16 GB):

| run | model time | `saveData` | wall | core-s per model-s |
|---|---|---|---|---|
| smoke | 2 s | 0 (no traces) | 125.4 s | 62.7 |
| `68eb4d34f3a325a8` | 20 s | 50 (Vm + currents) | 1742.3 s | 87.1 |
| `14e4782842b132e0` | 60 s | 20 (Vm only) | 5237.5 s | 87.3 |

**Use 87 core-seconds per model-second.** An earlier version of this table
inferred a "39% I/O premium" from the gap between the 2 s and 20 s runs and
attributed it to `saveData`. The 60 s run refutes that: dropping from
`saveData = 50` to `saveData = 20` — from three recorded rows per cortical cell
to one — changed the rate by 0.2%, from 87.1 to 87.3. The cost is CPU-bound, and
the 62.7 figure from the 2 s smoke run is not representative of anything longer.

Peak RSS 315 MB per run. Output is 75 MB per model-second at `saveData = 50`
(1.62 GB for 20 s) and 32 MB per model-second at `saveData = 20` (1.92 GB for
60 s) — so trace volume, not run time, is what `saveData` controls.

A sweep budget must include the discarded warm-up cycle in the per-point cost. At
~28 s of warm-up plus a usable window, no point costs less than about 1.4
core-hours even before the analysis window is chosen.

## Memory: the number, and what it cost to learn

NEURON sizes its recording Vectors from `tstop/dt` at run start. Measured
directly with `getrusage(RUSAGE_CHILDREN)` around the NEURON child, 20 s of
model time at `saveData = 20` peaks at **1910 MB** — **~95 MB per model-second**,
linear in `tstop`:

| model time | peak RSS | fits in 15.3 GB free? |
|---|---|---|
| 20 s | 1.9 GB | yes |
| 60 s | 5.6 GB | yes — this is why the 60 s run succeeded |
| 150 s | 14.0 GB | marginal |
| 300 s | 28.0 GB | no |

Two runs were lost before this was measured. A 150 s and a 300 s run were
launched concurrently on the 16 GB machine, together demanding ~42 GB; the 150 s
was OOM-killed at 92% of its length (exit 137, `Killed`, no output, 3.3 hours
spent). NEURON writes its `.dat` files only at the end, so a killed run yields
nothing at all — not a partial trace.

Worse, the failure was misdiagnosed at the time. Watching `available_gb` sit
flat at 0.40 GB for two minutes was read as "allocation already succeeded, no
growth to run out on". The flatness was the symptom, not the reassurance: the
system was pinned at its floor. **Monitoring free memory tells you nothing
useful once it is already near zero** — the figure that was needed is peak RSS
of a completed run, and that takes one short run to obtain.

**Rule.** Before choosing a run length, multiply model-seconds by 95 MB and
compare against worker memory, with headroom. Never infer capacity from free
memory during a run.

## Remote compute is faster and removes the ceiling

The same 20 s run on Modal (`cpu=2`, image `im-MjGYjvPyiWkNx8nW9DPCBa`,
Python 3.8 + NEURON 7.8.2) takes **45.3 core-seconds per model-second** against
**87.1** locally — about 1.9x faster per core — and memory is a `provider_params`
field rather than a wall. Local cost estimates are therefore pessimistic for
this provider, and the practical limit on run length is a number you request,
not a property of the machine.

Jobs must reduce in-container. Raw output is ~32 MB per model-second across 900
files (9.6 GB for 300 s), far past what the harvest can carry; `sim/job_run.py`
extracts spike times and coarse per-cell Vm and returns a ~1 MB `.npz`. This is
the in-worker reduction the sweep design always required, now implemented.

## Open question: do the gaps fill in?

Settled by the 60 s run: the warm-up is one cycle, ~28 s. Still open is whether
the ~20 s of complete network silence between spindle epochs persists over the
authors' 1200 s, or whether background activity develops and the infra-slow
rhythm becomes a modulation of spindle *density* rather than an all-or-none
alternation. The second would match sleep physiology; the first would not, and
would make "spindle density" criteria meaningless at these settings.

This matters beyond Gate 0. The cycle period is a thalamic time constant, so any
conductance this project sweeps can move it — and a boundary coordinate measured
over a fixed window would then be comparing different fractions of a cycle at
different parameter points. The warm-up and analysis windows must be defined
relative to the measured cycle, not in absolute seconds.
