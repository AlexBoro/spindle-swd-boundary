# Run protocol

What a trustworthy run of this model requires, and why. Everything here was
established against the deposit as vendored, on NEURON 7.8.2.

## The cold-start transient

**A short run of this model does not measure its steady state.** The first real
run — 20 s, `spindles_long`, `saveData = 50`, seed 0, run id `68eb4d34f3a325a8` —
produced a network that was dead by 8.5 s:

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

This is a transient, not a failure. NRT is already repolarising when the
recording ends — from −50.4 mV at 6–8 s to −60.7 mV at 18–20 s. A linear fit to
the 2 s window means over 8–20 s gives **0.887 mV/s** (r = −0.9994), which is the
slow `k4` unbinding limb doing its work. Extrapolating that rate linearly, NRT
would reach −70 mV at about 29 s; the true approach is presumably exponential and
so slower than that, which makes 29 s a lower bound rather than an estimate. The
60 s diagnostic below is what actually settles it.

The authors never encounter this: the deposit ships `tstop = 1200e3`, so their
analysis window is sixty times longer than the transient and begins long after
it has resolved.

**Consequence for Gate 0.** No measurement from the first 20 s of a cold start
counts. The 10.468 Hz spectral peak, the firing rates, and the three "spindle
events" found in that run all describe the transient and have been withdrawn.
A warm-up period must be discarded from every run, and its length must be
measured rather than assumed — see the open question below.

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

| configuration | core-seconds per model-second |
|---|---|
| `saveData = 0` (no traces) | 62.7 |
| `saveData = 50` (Vm + AMPA/NMDA + GABAa/GABAb) | 87.1 |

Peak RSS 315 MB per run. `saveData = 50` writes 75 MB per model-second across
900 files; the 20 s baseline produced 1.62 GB. The I/O premium is about 39%.

Any sweep budget must use the `saveData = 50` figure for runs that need an EEG,
and must include the discarded warm-up in the per-point cost.

## Open question: how long is the warm-up?

Being measured now: a 60 s `spindles_long` run at `saveData = 20` (Vm only),
config `sim/configs/diag_spindles_60s.json`. The question it answers is whether
the thalamus repolarises and the network resumes firing on the `k4` limb, and if
so when. Until that number exists, no production run length can be chosen and
no Gate 0 criterion can be scored.
