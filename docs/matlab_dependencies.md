# MATLAB dependencies of the SWD detector

## `filter.mat` — resolved, and it is a dt trap

`detectEEGspikesSWDs.m:76-86` designs the 8 Hz pre-filter **only if `filter.mat`
is absent**; the deposit ships it, so the shipped path always loads cached
coefficients. Read (MATLAB v7.3 / HDF5, written 2020-11-22), it contains:

- top-level `b`, `a` — seven taps each, i.e. the **order-6 lowpass**. They match
  a fresh `buttord(8/Nyq, 12/Nyq, 0.5, 10)` + `butter(n, Wn, 'low')` design at
  **dt = 0.25 ms** to 4.6e-09 in the denominator. So at the deposit's default dt
  the cached and computed paths are the same filter, and the port's computed
  `prefilter()` reproduces the shipped behaviour exactly.
- top-level `d` — a `designfilt` bandpass object. **The detector never
  references `d`**; `load` simply dumps it into the function workspace. Its spec
  is worth recording anyway because it is the *paper's* filter and not the
  code's: `fspecs.bpmin`, Fs 4000, passband 2.7512–6.7512 Hz, stopband
  0.7512–8.7512 Hz, Apass 0.5, Astop 65 dB, 17 second-order Butterworth
  sections — ±2 Hz passband and ±4 Hz stopband about a centre of 4.7512 Hz,
  exactly the paper's description. The running code instead designs its bandpass
  fresh every call from `bandWidth = maxPowerFrequency + [-0.75 -0.5 0 0.5 0.75]`
  with `stopbandAttenuation = 16`. **The paper-vs-code filter discrepancy is
  therefore real and `filter.mat` does not resolve it** — the file preserves the
  paper's filter as a variable nothing reads.

**The trap.** `Wn` is normalised, so the cached lowpass is pinned to Fs = 4000 Hz
with nothing in the file or at the call site recording that. At dt = 0.1 ms —
which the run protocol contemplates for figure-quality runs — the same
coefficients give a cutoff of **25 Hz instead of 8 Hz**. That is not a rounding
difference: the 8 Hz pre-filter is what removes the ~9 Hz spindle/wake rhythm
before the oscillation-frequency estimate, and the wake-vs-SWD discrimination in
`sweeps/gkl_tcfo/` rests on it. Any run at a dt other than 0.25 ms must delete or
bypass `filter.mat`. The port computes the design from `dt` on every call and so
does not inherit this.

**Correction (supersedes this file's original claim).** This document previously
stated that `detectEEGspikesSWDs.m` depends on three helper functions "absent
from both Zenodo deposits", and the project fetched them from
`github.com/dervinism/commonlib` on that basis. **That was wrong.** All three are
in the deposit, in `model/thalamocortical2/dependencies/` — they arrived with the
unmodified vendoring commit `7fa47ca`, and the deposit carries GPL-3.0, so they
are licensed for use and redistribution.

The real problem is narrower: `dependencies/` is **not on the MATLAB path** when
`detectEEGspikesSWDs` is called from the deposit root, so the function fails with
an undefined-function error partway through. `addpath('dependencies')` fixes it.
That is a packaging wrinkle worth reporting to the authors, not a missing-file
problem, and it required no fetching from elsewhere.

What this invalidates: `tools/matlab_bridge/fetch_commonlib.sh` is unnecessary
and the "do not vendor commonlib" licence analysis is moot. Two of the four
questions drafted for the authors were dropped as a result.

How the error happened, since it is the instructive part: the functions were
found to be undefined *at runtime*, and a GitHub search located them in
`commonlib` — a repository by the same author. Having found a plausible source,
the deposit itself was never re-searched. A `find . -name designFilterBP.m`
inside the vendored tree would have taken one second and prevented all of it.

## Dependency chain

| Function | Where it lives | Status |
|---|---|---|
| `oscFreq` | deposit root | present |
| `spectra` | deposit root | present (called *by* `oscFreq`, not directly) |
| `ciplot` | deposit root | present (plotting only; `showFigs` is false) |
| `thPks`, `eliminatePks`, `eliminatePks2` | local functions inside `detectEEGspikesSWDs.m` | present |
| `designFilterBP` | `dependencies/designFilterBP.m` | present — needs `addpath` |
| `hilbertTransform` | `dependencies/hilbertTransform.m` | present — needs `addpath` |
| `recentrePhase` | `dependencies/recentrePhase.m` | present — needs `addpath` |
| `fit(..., 'gauss1')` | Curve Fitting Toolbox | external; installed (25.2, R2025b) |

The Curve Fitting Toolbox is the only genuine external requirement, and it is not
listed in the deposit's stated prerequisites.

The three `dependencies/` functions are small and self-contained:

- `designFilterBP(Fpass, Astop1, Apass, Astop2, Fs)` — a thin wrapper over
  `designfilt('bandpassiir', ..., 'DesignMethod','butter')`. `Fpass` is a
  5-element column (stopband1, passband1, —, passband2, stopband2).
- `hilbertTransform(data)` — returns `[h, phase, envelope]` from MATLAB's
  `hilbert`, with `phase = angle(h)` and `envelope = abs(h)`.
- `recentrePhase(phaseData, phaseCentre)` — wraps phase into
  `[phaseCentre-pi, phaseCentre+pi]`.

`detectEEGspikesSWDs` calls `hilbertTransform(-EEGfiltBP)` — note the **sign
flip**, consistent with spikes being negative deflections — then
`recentrePhase(phaseTemp, 0)`.


## Curve Fitting Toolbox

`detectEEGspikesSWDs.m` line 137 fits the voltage histogram to find the EEG
baseline:

```matlab
f = fit(centres.', voltageValues.', 'gauss1');
```

This needs the Curve Fitting Toolbox. **Resolved** — it is installed (version
25.2, R2025b) and `which('fit')` now resolves to
`...\toolbox\curvefit\curvefit\fit.m`. The reference in
`analysis/matlab_reference/swd_reference.mat` was generated with it.

It had been licensed but *not installed*: `license('test','Curve_Fitting_Toolbox')`
returned 1 while `ver` omitted it and the `cfit` class was absent, so `which('fit')`
resolved only to the unrelated `@gmdistribution/fit` method. Recorded because the
licensed-but-absent combination is confusing to diagnose, and anyone setting up a
fresh machine will meet it again — install from **Home → Add-Ons → Get Add-Ons →
Curve Fitting Toolbox**.

Substituting a hand-rolled Gaussian fit would defeat the purpose of criterion
C6.1, which exists precisely to compare against the authors' actual behaviour.

## Band definitions (from `oscFreq.m`)

Useful for the port, and not stated in either paper:

| `type` | band |
|---|---|
| `spindles` | 6–16 Hz |
| `SWDs_human` | 3–6 Hz |
| `SWDs_rodent` | 6–9 Hz |
| `delta` | 1–5 Hz |
| `slow` | 0–1 Hz |

`detectEEGspikesSWDs` calls `oscFreq(EEGfilt, dt, 'SWDs_human')` internally at
line 91 to pick the filter centre, so the ~4 Hz band is assumed before the
rodent-like ~7 Hz case is considered. The port must reproduce that, and it is
worth checking what it implies for the 7 Hz route in criterion C4.7.

## Discrepancies between the papers and the code

Found by running the detector, not by reading it. In both cases the **code** is
what produced the published results, so the code wins.

### 1. Filter settings

The SWD paper describes the bandpass as *"passband and stopband frequencies
centered at ±2 Hz and ±4 Hz around the SWD oscillation frequency"*. The source
(`detectEEGspikesSWDs.m` lines 107–110) does something quite different:

```matlab
passbandRipple = 0.5;
stopbandAttenuation = 16;
bandWidth = maxPowerFrequency + [-0.75 -0.5 0 0.5 0.75];
dBP = designFilterBP(bandWidth', stopbandAttenuation, passbandRipple, stopbandAttenuation, 1000/dt);
```

Passband ±0.5 Hz and stopband ±0.75 Hz — four to five times narrower than
described. Criterion C6.2 has been corrected. `Fpass` must be passed as a
**column**; `designFilterBP` indexes `Fpass(1,1)`, `(2,1)`, `(4,1)`, `(5,1)`.

### 2. The detector cannot measure rodent-frequency SWDs

Line 91 hardcodes the human band:

```matlab
[maxPowerFrequency, ...] = oscFreq(EEGfilt, dt, 'SWDs_human');   % 3-6 Hz
cycle = (1000/maxPowerFrequency)*1.1;
```

`cycle` sets the minimum spike spacing, so for a genuine ~7 Hz SWD it is ~19 %
too long. Demonstrated on a synthetic 7.004 Hz trace:

| call | result |
|---|---|
| `oscFreq(EEG, 1.0, 'SWDs_rodent')` | **7.004 Hz** (correct) |
| `oscFreq(EEG, 1.0, 'SWDs_human')` | 5.920 Hz (clamped at the 6 Hz band edge) |
| `detectEEGspikesSWDs(EEG, 1.0, false)` | **0 spikes, 0 SWDs** |

The authors' own `coherenceAnalyses.m` also sets `type = 'SWDs_human'` (line 63).
Consistently, every intra-SWD frequency in supplementary Tables S1/S2 lies in
4.60–5.45 Hz — inside the human band — and the ~7 Hz rodent route is reported
only in a figure, not the tables.

**Consequence for criterion C4.7:** the ~7 Hz route cannot be assessed with this
detector as deposited. Either pass `'SWDs_rodent'`, or measure the frequency
outside the detector. This must be resolved before C4.7 is judged.

## Threshold definitions (from the source)

```
sdEEGfilt  = std(EEGfiltBP)
[baseline] = b1 of fit(centres', counts', 'gauss1') on a 1000-bin histogram
1.00 SD    : baseline - sdEEGfilt
1.96 SD    : baseline - norminv(0.975)*sdEEGfilt
2.576 SD   : baseline - norminv(0.995)*sdEEGfilt
```

Spikes are `findpeaks` on `abs(EEGfiltBP)` after zeroing everything at or above
the threshold, with `MinPeakDistance = ceil(cycle/2/dt)`. The `c1` of the
Gaussian fit is computed but **not** used for the thresholds.


### 3. The spike thresholds use a hardcoded standard deviation

`detectEEGspikesSWDs.m` lines 125–127:

```matlab
sdEEG = std(EEG);
%sdEEGfilt = std(EEGfiltBP);
sdEEGfilt = 1.28074765136489;
```

The data-derived line is **commented out**. `sdEEGfilt` is assigned exactly once,
to that constant, and `sdEEG` is computed but never used anywhere in the file.
All three detection thresholds are therefore **fixed absolute offsets** from the
fitted baseline, not multiples of the signal's own variability:

| nominal | actual threshold |
|---|---|
| 1 SD | baseline − 1.280748 |
| 1.96 SD | baseline − 2.510219 |
| 2.576 SD | baseline − 3.298987 |

The function's own docstring still describes them as "exceeding 1 and 1.96
standard deviation of the EEG signal", so the documented behaviour and the
implemented behaviour differ.

**The detector is not scale-invariant.** The constant is presumably tuned to the
amplitude of the authors' own EEG proxy. Applied to a signal of different
amplitude — a different EEG estimator, different units, or simply a network whose
output has grown — the thresholds mean something else entirely.

An earlier version of this note claimed the constant also explained why the
reference produced no "large" spikes. **That was wrong.** The debug dumps show
the 1.96 SD threshold *is* crossed: `three_swds` yields `pksLocs95` = 42, and
elimination leaves all 42 (`pksLocsGrp95` = 42). The final `eegSpikesLarge*`
outputs are nonetheless empty.

**Resolved — and it is not a thresholding, elimination or clustering problem.
`pksLocsLarge` is never populated.**

Line 453 builds the ordinary spike mask from the low-pass spike set, then line 455
masks out interictal periods for both the ordinary and the large sets:

```matlab
pksLocs = false(1,numel(EEGfilt));
pksLocs(pksLocsLP) = true;          % <- ordinary spikes get filled in here
pksLocs(logical(interictal)) = false;
pksLocsLarge(logical(interictal)) = false;   % <- but pksLocsLarge was never filled
```

`pksLocsLarge` has no creating assignment anywhere before line 455 (the only plain
assignment to it is line 461, `pksLocsLarge = find(pksLocsLarge)`, which runs
after). MATLAB therefore auto-creates it at line 455 as an all-`false` logical
array, and lines 459–461 then read an empty set out of it. The counterpart of
line 453 — something like `pksLocsLarge(pksLocsGrp95) = true;` — is absent.

Consequence: the five spike-level outputs `eegSpikesLarge`, `eegSpikesLargeSWD`,
`eegSpikesLargeT`, `eegSpikesLargeLocs` and `eegSpikesLargeLocsSWD` are empty for
**every** input, regardless of amplitude. Confirmed against the authors' own
MATLAB across all eight reference cases: `eegSpikesLarge` comes back full-length
with exactly zero entries set, including `edge_overlap_false`/`true` which carry
66 large spikes and `three_swds` which carries 42.

**Scope.** `SWDsLarge` and `interictalLarge` are built from `pksLocsGrp95`
directly at lines 375–448 and are unaffected — they are correctly populated. So
SWD-level "large" results are sound; only the spike-level outputs are empty. Any
of our analysis that wants large-spike positions should use `pksLocsGrp95`.

This supersedes the earlier note here, which inferred that the arrays were
"emptied somewhere in the downstream clustering" and named `kmeans` and the
`minSWD` filter as candidates. The framing was wrong: they are not emptied, they
are never filled.

#### Why this matters for the project, not just for the port

Phase 3 measures evoked-SWD susceptibility across conductance sweeps, and the
boundary coordinate `d` derived from it underpins H1b and H1c. But EEG amplitude
is itself a function of the swept parameter: supplementary Tables S1/S2 report
mean spike-to-wave amplitudes from **3.02 to 8.45 µV**, a factor of 2.8, across
the published pathology routes. With a fixed threshold, detection sensitivity
therefore varies systematically with the very parameter being swept. A boundary
measured this way would partly reflect amplitude drift rather than a change in
dynamical regime.

Planned handling, to be carried into the Phase 3 design:

1. **Port it faithfully**, constant included, so criterion C6.1 compares like with
   like against the authors' behaviour.
2. **Add a scale-adaptive variant** that restores the commented-out
   `std(EEGfiltBP)`, as a switch rather than a replacement.
3. **Run the boundary calibration both ways and report the difference.** If `p*`
   is materially different between them, the fixed-threshold boundary cannot be
   used for H1b/H1c; if it is not, that is a robustness result worth stating.

This is also worth raising with the authors — it may be a debugging line left in,
in which case the published SWD statistics were produced with it.
