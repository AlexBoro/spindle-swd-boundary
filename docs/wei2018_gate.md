# Wei 2018 reproduction: physiology gate (Phase 1)

Three 60 s state-only runs (awake, N2, N3), STDP off, seed 0, 16 threads on Modal,
first 10 s discarded. Run as specified (v0), then two diagnostic variants.
Analysis: `analysis/wei2018.py` (choices A4-A6). Runs: Modal jobs listed in
`sweeps/wei2018_gate/runs.csv`.

| measure | paper | v0 (as specified) | **v1: PY-PY mini 0.0002** | v1 + AMPA-from-TC 0.5 |
|---|---|---|---|---|
| awake PY rate (Hz) | ~0.6 (S4B) | 1.84 | **0.70** | 0.70 |
| awake pattern | desynchronised | desynchronised | desynchronised | desynchronised |
| N2 thalamic events / min | ~5 (S5B) | 8.4 (merged epochs, near-continuous) | **4.8** (300 ms merge) / 8.4 (100 ms merge, incl. fragments) | 4.8 |
| N2 event duration (s) | 0.5-3 | ~4.3, epochs | **median 3.6, IQR 1.3-3.8** | ~5 |
| N2 intra-event frequency (Hz) | 7-14 | 6.35 | **6.25 (IQR 6.25-7.0)** | 6.10 |
| N3 slow oscillation (Hz) | ~0.7 (S6B) | 0.80 | **0.74** | 0.70 |
| N3 Up / Down (ms) | Up and Down states | 615 / 650 | **620 / 845** | 790 / 645 |
| N3 pattern | traveling waves | traveling waves | traveling waves | traveling waves |
| peak xcorr, d = 60 cells: N2 / N3 | ~0.35 / ~0.8 | 0.36 / 0.44 | **0.34 / 0.45** | -- |

Verdict for v1 (adopted):
- PASS: awake rate and desynchrony; N2 event density; N3 SO frequency and traveling
  Up/Down states; spindles more local than slow waves (N2 correlation falls to
  the paper's ~0.35).
- MISS, small: N2 intra-event frequency 6.3-7.0 Hz sits at or just below the
  7-14 Hz band, and events run slightly long (median 3.6 s).
- MISS, measure-dependent: the N3 long-distance correlation (0.45 at 60 cells) is
  below the paper's ~0.8 asymptote. The paper's normalisation of the
  cross-correlation is not specified; the qualitative ordering N3 > N2 holds at
  every distance.

AMPA-from-TC 0.5 (the donor value, interpretation I1) changes little, so the
paper's 0.6/0.72/1.2 are kept.
