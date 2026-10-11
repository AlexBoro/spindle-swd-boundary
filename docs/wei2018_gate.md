# Wei 2018 reproduction: physiology gate (Phase 1)

Three 60 s state-only runs (awake, N2, N3), STDP off, seed 0, 16 threads on Modal,
first 10 s discarded. Run as specified (v0), then two diagnostic variants.
Analysis: `analysis/wei2018.py` (choices A4-A6). N2 events are thalamic RE
population episodes (>5 spikes per 50 ms bin, merged across gaps < 300 ms or
< 100 ms, kept if >= 300 ms). Every row uses ONE method across all three columns. Runs: Modal jobs listed in
`sweeps/wei2018_gate/runs.csv`.

| measure | paper | v0 (as specified) | **v1: PY-PY mini 0.0002** | v1 + AMPA-from-TC 0.5 |
|---|---|---|---|---|
| awake PY rate (Hz) | ~0.6 (S4B) | 1.84 | **0.70** | 0.70 |
| awake pattern | desynchronised | desynchronised | desynchronised | desynchronised |
| N2 thalamic events / min, 300 ms merge (100 ms merge) | ~5 (S5B) | 8.4 (16.8) | **4.8 (8.4)** | 4.8 (7.2) |
| N2 event duration, median s [IQR], 300 ms merge | 0.5-3 | 4.25 [1.95-7.3] | **5.05 [4.71-5.32]** | 5.07 [4.49-5.78] |
| N2 event duration, median s [IQR], 100 ms merge | 0.5-3 | 2.35 [1.49-3.3] | **3.6 [1.27-3.8]** | 4.15 [2.43-4.22] |
| N2 LFP spectral peak, 3-20 Hz (Hz) | 7-14 | 6.35 | **6.47** | 6.10 |
| N2 per-event RE-rate frequency, median [IQR], 100 ms merge (Hz) | 7-14 | 7.03 [6.25-7.62] | **6.25 [6.25-7.02]** | 6.25 [6.25-6.25] |
| N3 slow oscillation (Hz) | ~0.7 (S6B) | 0.80 | **0.74** | 0.70 |
| N3 Up / Down (ms) | Up and Down states | 615 / 650 | **620 / 845** | 790 / 645 |
| N3 pattern | traveling waves | traveling waves | traveling waves | traveling waves |
| peak xcorr, d = 60 cells: N2 / N3 | ~0.35 / ~0.8 | 0.36 / 0.44 | **0.34 / 0.45** | -- |

Verdict for v1 (adopted):
- PASS: awake rate and desynchrony; N2 event density; N3 SO frequency and traveling
  Up/Down states; spindles more local than slow waves (N2 correlation falls to
  the paper's ~0.35).
- MISS: N2 events are longer than the paper's 0.5-3 s and LONGER than in v0 under
  the same detector (median 5.05 s vs 4.25 s with a 300 ms merge; 3.6 s vs 2.35 s
  with a 100 ms merge). Lowering the PY-PY minis makes events rarer (density
  now matches) but each one longer.
- MISS, small: N2 oscillation frequency is 6.1-6.5 Hz by LFP spectral peak and
  6.25 Hz median per event, just below the 7-14 Hz band (v0 was marginally
  faster: 6.35 Hz LFP peak, 7.03 Hz per-event median).
- MISS, measure-dependent: the N3 long-distance correlation (0.45 at 60 cells) is
  below the paper's ~0.8 asymptote. The paper's normalisation of the
  cross-correlation is not specified; the qualitative ordering N3 > N2 holds at
  every distance.

AMPA-from-TC 0.5 (the donor value, interpretation I1) changes little, so the
paper's 0.6/0.72/1.2 are kept.
