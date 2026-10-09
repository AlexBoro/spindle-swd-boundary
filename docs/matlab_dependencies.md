# MATLAB dependencies of the SWD detector

**The deposited detector cannot be run as deposited.** (All dependencies are now satisfied locally — this section records what was missing and how it was resolved.) `detectEEGspikesSWDs.m`
depends on four helper functions that are not in either Zenodo deposit, plus a
MATLAB toolbox. This was found by running it, not by reading it — the call sites
are scattered and three of the four are reached only partway through the
function.

## Dependency chain

| Function | Where it lives | Status |
|---|---|---|
| `oscFreq` | the deposit | present |
| `spectra` | the deposit | present (called *by* `oscFreq`, not directly) |
| `ciplot` | the deposit | present (plotting only; `showFigs` is false) |
| `thPks`, `eliminatePks`, `eliminatePks2` | local functions inside `detectEEGspikesSWDs.m` | present |
| **`designFilterBP`** | `github.com/dervinism/commonlib` | **absent from the deposit** |
| **`hilbertTransform`** | `github.com/dervinism/commonlib` | **absent from the deposit** |
| **`recentrePhase`** | `github.com/dervinism/commonlib` | **absent from the deposit** |
| `fit(..., 'gauss1')` | Curve Fitting Toolbox | resolved — installed (25.2, R2025b) |

The three `commonlib` functions are small and self-contained, with no further
dependencies beyond MATLAB and Signal Processing:

- `designFilterBP(Fpass, Astop1, Apass, Astop2, Fs)` — a thin wrapper over
  `designfilt('bandpassiir', ..., 'DesignMethod','butter')`. Confirms the paper's
  filter description and shows `Fpass` is a 5-element vector
  (stopband1, passband1, —, passband2, stopband2).
- `hilbertTransform(data)` — returns `[h, phase, envelope]` from MATLAB's
  `hilbert`, with `phase = angle(h)` and `envelope = abs(h)`.
- `recentrePhase(phaseData, phaseCentre)` — wraps phase into
  `[phaseCentre-pi, phaseCentre+pi]`.

`detectEEGspikesSWDs` calls `hilbertTransform(-EEGfiltBP)` — note the **sign
flip**, consistent with spikes being negative deflections — then
`recentrePhase(phaseTemp, 0)`.

## Licence: do not vendor commonlib

`dervinism/commonlib` **has no licence file**, so it is all-rights-reserved by
default and we have no explicit permission to redistribute it. The three files
are therefore **not committed here**. Fetch them instead:

```bash
tools/matlab_bridge/fetch_commonlib.sh
```

which clones at the pinned commit `deb441aad510113458c604363e6465e628825f14` and copies only the three
required files into `tools/matlab_bridge/lib/` (git-ignored). Worth asking the
authors to add a licence — it would make their analysis pipeline properly
redistributable.

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
output has grown — the thresholds mean something else entirely. This also
explains why no synthetic trace in the reference produced "large" spikes: their
amplitudes were scaled to the noise SD rather than to the authors' absolute
units.

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
