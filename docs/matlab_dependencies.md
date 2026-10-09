# MATLAB dependencies of the SWD detector

**The deposited detector cannot be run as deposited.** `detectEEGspikesSWDs.m`
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
| **`fit(..., 'gauss1')`** | Curve Fitting Toolbox | **toolbox not installed** |

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

This needs the Curve Fitting Toolbox. On this machine it is **licensed but not
installed** — `license('test','Curve_Fitting_Toolbox')` returns 1, while `ver`
does not list it and the `cfit` class is absent, so `which('fit')` resolves only
to the unrelated `@gmdistribution/fit` method. Install it from MATLAB's Add-On
Explorer (**Home → Add-Ons → Get Add-Ons → Curve Fitting Toolbox**).

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
