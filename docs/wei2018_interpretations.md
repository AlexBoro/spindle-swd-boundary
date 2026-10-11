# Wei et al. 2018 reproduction: interpretations and departures

Wei Y, Krishnan GP, Komarov M, Bazhenov M (2018) PLoS Comput Biol 14(7): e1006322.
No code was released with the paper. `model/wei2018/` starts from the same
laboratory's eLife 2020 code (see `model/wei2018/PROVENANCE.md`), and
`git log --oneline -- model/wei2018/` lists every change made to it.

This file records every point where the paper does not settle what to
implement, the choice made, and how to switch to the alternative. Values were
taken from both the paper's Methods and the code (the project's dual-source
convention). Where they disagree, the disagreement is recorded here rather than
silently resolved.

## Settled directly by the paper (no interpretation needed)

| Item | Wei 2018 Methods | Implementation |
|---|---|---|
| Network | 100 TC, 100 RE, 500 PY, 100 IN, 1-D | donor `network.cfg` Types |
| Radii and strengths of all 13 projections | Network geometry; Synaptic currents | donor `network.cfg` rows already equal; PY-PY AMPA changed to R=5, 0.24 uS (commit "PY-PY AMPA connectivity") |
| awake/N2/N3 neuromodulator values (8 x 3) | Neuromodulators; Intrinsic currents; Synaptic currents | `wei2018_params.txt`, entered literally |
| STDP A+ = A- = 0.002, tau = 20 ms, halved to 0.001 in sleep, bounds [0, 200%], mini factor f = 0.01 | STDP | params `stdp_cP/cD/cD_train`, `stdp_factor_n2/n3`; donor `AMPA_D3` bounds and `mini_stdp_factor` |
| Stimulus: 5 groups x 5 adjacent cells, 10 ms each, 5 ms between groups, 1 trial/s; test = group A only | Training and test | protocol files; `stim_period/spacing/pulse` = 1000/15/10 ms |
| Integration: RK4, dt = 0.02 ms | Computational methods | donor `TAU 0.02` |
| Timeline | Fig 2D, 3B, 5i, 7F (read off axes) | `sim/wei2018/make_protocols.py` |

## Interpretations

**I1. Which synapses "AMPA from TC" modulates.** The paper says AChAMPA
modulates "cortical PY-PY, TC-PY, and TC-IN connections", gives a 'from PY'
series (0.133/0.1938/0.4332) and a 'from TC' series (0.6/0.72/1.2). The code
lineage (Krishnan 2016 and eLife 2020 alike) has two factors routed by
*synapse class*: `fac_AMPA_D2` on every AMPA_D2/AMPA_D3 synapse (PY-PY, PY-IN,
TC-PY, TC-IN), and `fac_AMPA_TC` on class `AMPA` (TC-RE, PY-TC, PY-RE).
*Choice:* the class routing used throughout the code lineage, with 'from PY' ->
`ampa_cx_*` and 'from TC' -> `ampa_th_*`. A literal reading of the sentence
(TC-PY scaled by 0.6 in wake) would raise awake thalamocortical drive 4.5-fold
over the donor and is unlikely to be what was run. The donor used
`fac_AMPA_TC` = 0.5 in every state; setting `ampa_th_* 0.5` restores it.
*Gate check:* awake must remain desynchronised at ~0.6 Hz PY rate.

**I2. "Slow-wave sleep" for the STDP halving.** The paper says "we reduced the
STDP amplitude ... to 0.001 during slow-wave sleep to account for reduction of
ACh". ACh is reduced in both N2 and N3 in this model, so the halving is applied
in both. *Switch:* `stdp_factor_n2 1.0` for N3-only halving.

**I3. Initial PY-PY weight jitter.** The donor jitters each initial AMPA_D3
weight with `getGaussian2(g/10)`, which in the code's internal units
(0.00024 / 165e-6 / 10 ≈ 0.145) gives a standard deviation of about 12% of the
weight. The paper does not mention jitter. *Choice:* keep it (code lineage),
drawn serially so that it is reproducible. *Switch:* `weight_jitter 0`.

**I4. Within-trial timing of two sequences.** Fig 5A and 7A show Seq1 (100 s)
and Seq2 (40 s) training bars starting together; the offset between them within
each 1 s trial is not stated. *Choice:* Seq1 at 0 ms, Seq2 at 500 ms (more than the
350 ms response window apart, so neither trial's response overlaps the other).
Two-sequence tests use the same offsets inside one 50 s test block.

**I5. Cortical leak conductance.** Table 1 lists G_L = 0.009 mS/cm2 for PY.
The code (identical in 2016 and 2020) sets PY G_L = 0.011 + U(1,2)*0.003, i.e.
uniformly in [0.014, 0.017], and IN G_L = 0.009 + U(1,2)*0.003. The IN base value
matches the table; the PY base does not. *Choice:* code. Every other Table 1
entry matches the code (gNa, gK, gT, gh, K-leak, E_L, areas, rho,
dendritic gNa/gNap/gHVA/gKCa/gKm, somatic gNa/gKv/gNap).

**I6. mEPSP amplitude.** The paper gives 0.2 mV for PY-PY, PY-IN and IN-PY minis;
the code specifies mini *conductances* (`Mini_s` 0.0003, 0.0002, 0.0002, scaled
by fan-in). *Choice:* donor values. *Gate check:* awake PY rate ~0.6 Hz
(S4B Fig). The paper raised it to 1.7 Hz by going from 0.2 to 0.3 mV, i.e. x1.5.

**I7. Warm-up and test windows.** The donor holds weights fixed for its first 12 s
and freezes STDP during test windows (factor 0). The paper mentions neither.
*Choice:* keep both: a 12 s awake warm-up before paper t = 0, and no plasticity
during tests, so that a test does not change what it measures.

**I8. Stimulus amplitude.** Not given in the paper. *Choice:* donor
`input_strength 1.2` (added to the dendritic current of each driven PY cell).

**I9. State transitions are abrupt** at block boundaries, as in the donor.

**I10. Thread count.** The donor notes that results depend on the OpenMP thread
count (minor floating-point ordering). Runs record `num_mp_threads`, and runs with
the same seed and thread count are bit-identical (checked: two 150 ms runs at 2
threads gave identical spike and LFP files).
