# Wei et al. 2018 reimplementation: comparison with the public Bazhenov-lineage code

## Purpose
This report checks the three public codebases the user named for parameter or implementation differences that could explain the remaining mismatches. The donor code is included as a fourth point of comparison. The mismatches are:
- consolidation during sleep is smaller than in the paper, most of all in N2;
- recall drops at the paper's 1 s inter-trial interval (ITI);
- spindles run at about 6.5 Hz, against roughly 7 Hz in the paper's own figure.

| Code | What it is | State checked |
|---|---|---|
| bazhlab-ucsd/sleep-stage-transition | Krishnan et al. 2016 C++ code. This is the paper Wei 2018 cites for its sleep stages. | f672f12, 2023-09-20; no licence file, so reference only |
| christian-g-fink/bazhenov-sleep-model | NEURON port of the Krishnan 2016 code | ac25f99, 2024-07-15; GPL-2 |
| ModelDBRepository/28189 | Bazhenov et al. 2002 C code, the ancestor of the lineage | f2d2d2b |
| bazhlab-ucsd/TCmodel-sequenceLearningSleepCode-eLife2020 | Gonzalez et al. 2020, our donor | 62fb644 |

No public code for Wei 2018 itself exists.

## 1. What is identical (rules out implementation bugs in the shared machinery)
- **Intrinsic currents.** Every channel class in the donor and in Krishnan is identical, kinetics and default conductances alike: IT_TC, IT_RE, Ih_TC with Ca²⁺ up-regulation, INaK, IA_TC, IHVA, IKCa, IKm, INa/INap and IKv.
  - The thalamic channel classes are also identical to Bazhenov 2002.
  - The per-cell overrides in CellSyn.h are the same in donor and Krishnan, and match Wei Table 1. Examples: TC gT 2.5, gh 0.016, gK 12, gKL 0.024; RE gT 2.2, EL −77, gKL 0.012; PY gKm 0.02, gKCa 0.05, gNap 2.5/15; IN without gNap, with gNa 2500.
  - The one exception is cortical leak (interpretation I5, already recorded). Both codes use G_l = 0.011 + U(0.003–0.006) for PY and 0.009 + U(…) for IN, whereas Table 1 says 0.009.
- **Synapse kinetics and short-term depression.** AMPA/AMPA_D2/AMPA_D3 use α 1.1 and β 0.19; GABA_A_D2 uses 0.53 and 0.18; RE→TC GABA_A uses 10.5 and 0.166. Depression uses Use = 0.07 and Tr = 700 ms in AMPA_D2, AMPA_D3 and GABA_A_D2. The mini rate law matches the paper's formula. All of these are the same in donor and Krishnan.
  - Only the mini gating after a presynaptic spike differs: 50 ms in the donor, 100 ms (AMPA_D2) or 70 ms (GABA_A_D2) in Krishnan.
- **Connectivity.** I generated the Wei 2018 network with both generators. The edge sets are identical except for 196 boundary edges: Krishnan's generator gives some PY cells a 3rd IN input or a 7th TC input.
  - Per-synapse normalisation gives the same values for interior cells, though the method differs: the donor divides by the maximum count over cells, Krishnan by each cell's own count.
  - In-degrees under the Wei radii: PY←PY 10, PY←IN 2, PY←TC 6, IN←PY 15, IN←TC 7, TC←RE 17, RE←TC 17, RE←RE 10, TC←PY 105, RE←PY 85.
- **Stimulus timing.** The donor trains with group onsets 15 ms apart (10 ms pulse + 5 ms gap), and so does our protocol. Measured on Wei Fig 2C (training panel against the 100 ms bar), A→E spans about 58 ms, which confirms the 15 ms reading. The paper's "5 ms delay" is the gap between pulses.

So none of the public code points to a hidden implementation difference in cells, synapses or wiring. What differs between the codes is parameters: network.cfg strengths, the neuromodulator factors, and STDP scheduling.

## 2. Differences that bear on the remaining mismatches, ranked

### D1. STDP amplitude in N2 (interpretation I2): the most likely cause of the N2 shortfall
- The paper's Methods say: "We reduced the STDP amplitude A+ and A− to 0.001 during slow-wave sleep".
- The paper's own Introduction defines N3 as slow-wave sleep: "N3 sleep (also referred as slow wave sleep)".
- We applied the halving to N2 as well (I2), which is not the literal reading.
- The Discussion says the amplitude was adjusted "based on the level of the ACh during different sleep and wake stages". That leaves room for an intermediate N2 value. A linear interpolation on cortical AChgkl (0.133 / 0.228 / 0.38) gives ≈ 0.81.
- **Expected effect, from our numbers.** N2 sleep added +4.7 points of forward weight over the end-of-training value in 300 s, at factor 0.5. At factor 1 that becomes about +9.4, so N2-only Δw ≈ 34 % against the paper's ~35 %. N2+N3 gains about +2.3 points, to ≈ 46 % against the paper's ~53 %.
- The code lineage gives no guidance: Krishnan has no plastic synapse used in sleep, and the donor has no N2. The donor uses factor 0.75 in its N3.

### D2. STDP amplitude in N3 (only if the N3 gap persists)
- Our N3 Δw is 54.7 % against the paper's ~65 %.
- The paper's text gives 0.001, i.e. factor 0.5, which is what we use. The donor, written by the same lab two years later with the same AMPA_D3 STDP code, uses 0.75.
- This is the next lever if D1 does not also lift N2+N3 and N3. I would not change it first, because it contradicts the paper's explicit number.

### D3. Routing of the "AMPA from TC" factor (interpretation I1)
- The paper's text says AChAMPA modulates "cortical PY-PY, TC-PY, and TC-IN connections", with one factor "from PY" (0.133/0.1938/0.4332) and one "from TC" (0.6/0.72/1.2).
- Read literally, TC→PY and TC→IN take the TC factor.
- In the donor and in Krishnan, TC→PY and TC→IN are AMPA_D2 synapses scaled by the PY factor (fac_AMPA_D2). The second factor (fac_AMPA_TC) scales the thalamic AMPA synapses: TC→RE, PY→TC, PY→RE.
- We followed the code (I1). The earlier check, 0.5 vs 0.72 on the thalamic synapses, showed little effect. The literal reading was never tested.
- Under the literal reading, TC→PY in N2 would be 0.14 × 0.72 = 0.10 µS instead of 0.027 µS, i.e. 3.7× stronger thalamocortical drive. The factor is 4.5× in awake and 2.8× in N3.
- That would raise cortical participation in spindles, and with it N2 replay, and would also alter the corticothalamic loop. It is a large change, so treat it as a test, not a fix.

### D4. Thalamic loop strength in N2 vs Krishnan 2016 (spindle frequency)
Effective N2 conductances (strength × state factor) relative to Krishnan's code, which the Krishnan paper reports as giving 7–15 Hz spindles (`effective_conductance_comparison.csv`):

| Synapse | Ours N2 (µS) | Krishnan N2 (µS) | Ratio |
|---|---|---|---|
| RE→TC GABA_A | 0.0432 | 0.0316 | 1.37 |
| RE→TC GABA_B | 0.0018 | 0.0013 | 1.42 |
| RE→RE GABA_A | 0.0720 | 0.0633 | 1.14 |
| TC→RE AMPA | 0.0432 | 0.0250 | 1.73 |
| TC→PY | 0.0271 | 0.0496 | 0.55 |
| TC→IN | 0.0233 | 0.0496 | 0.47 |
| PY→RE | 0.0576 | 0.0750 | 0.77 |
| PY→TC | 0.0288 | 0.0250 | 1.15 |
| PY→PY | 0.0465 | 0.0595 | 0.78 |

TC Ih shift in N2: ours −2 mV (paper), Krishnan −3 mV. The Fink port uses −4 mV and its comments say this was "found to give better spindles in N2". K-leak factors for PY, TC and RE in N2 are the same in all three codes.

- Our thalamic loop has about 1.4× stronger RE→TC inhibition and 1.7× stronger TC→RE excitation than Krishnan's, and only about half the thalamocortical drive.
- Stronger and longer RE→TC IPSPs lengthen the spindle cycle, so this is the most plausible source of the 6.5 Hz frequency and of the more global N2 events.
- Every one of these values is the Wei paper's own number. The donor network.cfg equals Wei's synaptic list, and the factors are Wei's. So this is not an error in our code. The paper's own Fig 2B spindle also digitises at ~6.9–7.6 Hz.
- **GABA_B scaling.** Both codes multiply GABA_B by the thalamic GABA factor, but the paper says the factor modulates GABA_A only. Unscaled GABA_B would make N2 GABA_B 1.39× stronger still, which slows spindles further. So this item does not explain the miss.

### D5. Recall depression at 1 s ITI: no code difference found
- Every code shares the same depression (Use 0.07, Tr 700 ms) and the same mini law, so whatever lowers recall at a 1 s ITI should exist in Wei's model too.
- An estimate from the depression equation for a cell that fires about one spike per trial: synaptic efficacy is about 2 % lower at 1 s ITI than at 3 s. For a 5-spike burst it is about 9 % lower. In a chain of four threshold-limited links that can matter, but probably not by 20 points.
- No other mechanism in the code has a recovery time between 1 and 3 s in awake cortex. KCa, Km and Ca²⁺ all recover in tens to hundreds of ms. GABA_B is thalamic, and the thalamus is silent during awake tests.
- **Correction to the Stage 1 write-up.** The decline across the 120 trials of a run need not be caused by the trials. The network starts from a synchronous initial state: our warm-up PY rate is 1.2 Hz, falling to 0.6–0.7 Hz with a slow drift, and the Fink README says to discard the first ~10 s. Part of the within-run decline is therefore probably relaxation from initial conditions.
- The 1 s vs 3 s ITI effect itself compares runs over the same time span, so it is real. Its mechanism would need a recording run.
- I would no longer call it a model discrepancy. The paper only ever tested at 1 s, so it is unknown whether the paper's network shows the same sensitivity.

## 3. Recommended order of tests
1. **D1: N2 at full STDP** (`stdp_factor_n2 = 1`; optionally also 0.81). Run the N2 and N2+N3 conditions, 5 seeds, then fresh-state test-only runs from the end-of-block weights. Predicted N2-only Δw ≈ 34 %. Cost at cpu = 4: 10 runs × ~9.6 h, plus Stage-1-style tests.
2. **D2: N3 factor 0.75**, only if N3 or N2+N3 Δw still fall short after D1.
3. **D3 / D4: short N2 gate runs (60–120 s)**, scored on spindle frequency, density, duration and cortical participation:
   - TC→PY and TC→IN scaled by the TC factor (literal I1);
   - Ih shift −3 / −4 mV;
   - RE→TC GABA_A and GABA_B reduced to Krishnan's effective values.

   These are scans for sensitivity, not candidates for the reproduction itself, because they move away from the paper's stated values. They do map directly onto the thalamic levers for the later SWD phase.
4. **D5: one short recording run** comparing 1 s vs 3 s ITI to identify the recovery process.
