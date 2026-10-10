**To:** Martynas Dervinis; Vincenzo Crunelli
**Subject:** Three questions about the thalamocortical2 code (Zenodo 7724443)

Dear Dr Dervinis and Professor Crunelli,

I am building on your corticothalamic model (CNS Neurosci Ther 2023, e14204 and
e14206) for a project on whether the parameter regime that best supports
spindle-timed cortical plasticity sits close to the transition to spike-and-wave
discharges. Your model is the only one I know of that is constrained against
sleep physiology *and* has characterised routes to SWDs, which is exactly what
the question needs.

I have the code running (NEURON 7.8.2 — the 13 mechanisms using the older
`nrn_random_pick` idiom don't compile on 8.2+, in case anyone else asks) and I am
reproducing your baseline before changing anything. Four items below: three are
things in the code I cannot resolve by reading it, and the fourth is something I
think I have found, reported in case it is useful to you. They are independent,
and each should be a one- or two-line answer — if only one is easy, **the first
is by far the most important to me**.

---

### 1. `awake_long` vs `wake_long` — which state did the SWD simulations use?

Your README says, for each of the five SWD routes:

> set the `state` variable inside the `init.hoc` file to `'awake_long'`

But `"awake_long"` appears only in `init.hoc`. The `strcmp` chains in
`TCcell.hoc`, `NRTcell.hoc` and `Cx3cell.hoc` test for `"wake_long"`, and they
have no `else` clause. So with `state = "awake_long"` none of the branches fires
and the conductances keep their `.mod` file defaults rather than any state value.

For the thalamic K+ leak this is a large difference:

| | `awake_long` (falls through to `glu3.mod` default) | `wake_long` branch |
|---|---|---|
| TC_FO `GLUfullsyn.gbase_c` | 0.001 µS | 0.001325 µS |
| TC_HO `GLUfullsyn.gbase_c` | 0.001 µS | 0.0045 µS |

**The question:** were the published SWD results obtained with the fall-through
defaults, or did you mean `wake_long`? I need to know which baseline your SWD
figures sit on before I can perturb away from it.

### 2. What conductance values do "pathology level 1/2/3" correspond to?

Tables S1 and S2 of the SWD paper report SWD statistics in 15 columns, each
headed "pathology level 1", "2" or "3", across the routes (I_KL in TC_FO,
extrasynaptic GABA-A in TC_FO, cortical GABA-A, cortical AMPA, I_T in NRT, I_T in
TC_HO). The tables give the outcomes but not the conductance values behind them.

From the main text I can recover two: cortical GABA-A reduced by 10% and 25%, and
the TC_FO I_KL route introduced at +5%. The rest I cannot — in particular **I_T in
higher-order TC cells**, which is the axis my project depends on most.

**The question:** what multipliers or absolute values do levels 1/2/3 correspond
to, for each route? Without them I cannot place your published SWD points in
parameter space, which means I cannot check that my sweep passes through them.

I appreciate this is the heaviest of the three asks. Anything at all would help,
and I do not need it tidied up: a run script, a parameter file, a spreadsheet,
or even a note of the ranges you remember sweeping would be enough. If it is
simply gone, telling me so is also useful — I would then recover the values by
finding what reproduces the Table S1/S2 statistics, and I would rather know that
is what I am doing.

### 3. Is the hardcoded `sdEEGfilt` in `detectEEGspikesSWDs.m` intended?

Lines 125–127 read:

```matlab
sdEEG = std(EEG);
%sdEEGfilt = std(EEGfiltBP);
sdEEGfilt = 1.28074765136489;
```

The data-derived line is commented out and replaced by a constant, so the three
detection thresholds are fixed absolute offsets below the fitted baseline rather
than multiples of the signal's own standard deviation. (`sdEEG` on line 125 is
then never used.)

**The question:** is that deliberate — a calibration against your own EEG
estimator that should be kept — or a debugging line that was left in?

It matters to me because the detector is then not scale-invariant, and
spike-to-wave amplitude varies about 2.8-fold across the routes in Table S1/S2.
If I sweep a conductance that changes EEG amplitude, detection sensitivity drifts
with it, which would bias exactly the boundary measurement I am trying to make. I
plan to run my analysis both with your constant and with `std(EEGfiltBP)`
restored, and compare — but I would like to know which one reproduces your
published numbers.

*Much smaller, same file:* line 91 calls
`oscFreq(EEGfilt, dt, 'SWDs_human')` with the band hardcoded to 3–6 Hz, so the
~7 Hz route from the reduced TC_HO leak returns no spikes when I run it. Did you
pass `'SWDs_rodent'` for that figure, or measure the frequency another way?

### 4. I think a line may be missing around line 455 — have I misread it?

This one is me reporting rather than asking, in case it is useful. The five
`eegSpikesLarge*` outputs come back empty for every input I give the function,
including traces with plenty of large spikes.

Lines 452–455 are:

```matlab
pksLocs = false(1,numel(EEGfilt));
pksLocs(pksLocsLP) = true;
pksLocs(logical(interictal)) = false;
pksLocsLarge(logical(interictal)) = false;
```

`pksLocs` is created and filled on the first two lines. `pksLocsLarge` has no
creating assignment anywhere earlier — the next one is line 461,
`pksLocsLarge = find(pksLocsLarge)` — so line 455 auto-creates it as an all-false
logical array, and lines 459–461 read nothing out of it. The counterpart of line
453, something like `pksLocsLarge(pksLocsGrp95) = true;`, does not seem to be
there.

I checked this on eight test traces: `eegSpikesLarge` returns full-length with
zero entries set, even where `pksLocsGrp95` holds 42 or 66 spikes.

As far as I can tell this does **not** touch anything published: `SWDsLarge` and
`interictalLarge` are built from `pksLocsGrp95` directly at lines 375–448 and are
populated correctly, so SWD-level results are unaffected. It is only the
spike-level outputs. But since I am reimplementing the function I wanted to check
whether I am misreading it, or whether those outputs were simply never used.

One more of the same kind, in `dependencies/hilbertTransform.m`:

```matlab
h = hilbert(data');
h = h';
```

For a row-vector input the second line is a **conjugate** transpose, so the
function returns the conjugate of the analytic signal and the phase it reports
is sign-flipped relative to the usual convention. (`.'` would avoid it.) I only
noticed because my port disagreed with your output by exactly a sign until I
reproduced it — the reference matches `-angle(hilbert(x))` to 1e-15, so my
implementation now does the same deliberately. I would expect this to cancel in
any comparison where both signals go through the same function, which I think
covers the phase results in the paper, but it would change the sign of an
absolute lead/lag.

---

Two notes in case they are useful to you. First, `detectEEGspikesSWDs.m` calls
`designFilterBP`, `hilbertTransform` and `recentrePhase`, which live in
`dependencies/` but are not on the path when the function is called from the
deposit root — it fails with an undefined-function error until `addpath` is run,
which cost me a little time and may be worth a line in the README. Second, the
function needs `fit(..., 'gauss1')` from the Curve Fitting Toolbox, which is not
mentioned in the requirements.

I am happy to share anything that comes out of this. I have a partial Python port
of `detectEEGspikesSWDs.m`, validated layer by layer against your MATLAB on eight
synthetic test traces: `spectra`/`oscFreq`, the Butterworth design and the
elimination step agree exactly on all eight, and spike detection agrees exactly on
six — the two exceptions are traces with episodes overlapping the start or end of
the record, where MATLAB's `filtfilt` and scipy's `sosfiltfilt` pad the signal
differently and a few near-threshold spikes flip. The clustering and phase stages
are not ported yet. I also have a reproducible build recipe for the model on
NEURON 7.8.2. Both are yours if they are of any use.

With thanks for depositing the code so completely — being able to read the actual
conductance assignments has made this project possible.

With best wishes,

[name]
[affiliation]
