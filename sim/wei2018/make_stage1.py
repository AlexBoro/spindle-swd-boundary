"""Stage 1 test-only protocols for the Wei 2018 reproduction (load saved weights, no plasticity).

Each run: same network and RNG seed as the run the weights came from, 12 s awake
warm-up, then awake test trials only (group A stimulated; STDP frozen everywhere
because test windows freeze it and plasticity_start is set past tmax).

stage1_curve   120 trials at 1 s ITI; input amplitude per trial from {1.2, 1.5, 1.9, 2.4}
               (30 each) in one fixed pseudo-random order shared by every run, so
               conditions are paired trial-by-trial.  -> readout curve vs amplitude.
stage1_spaced  30 trials at 1.2 with a 3 s ITI (stimulus at the start of each 3 s slot).
               -> does the 1 s ITI depress recall (fatigue)?

Both protocols load 'weights.txt' from the protocol directory; job_run.py copies the
requested weight set there (argument %<file>).
"""
import os
import numpy as np

HERE = os.path.dirname(os.path.abspath(__file__))
PDIR = os.path.join(HERE, "..", "..", "model", "wei2018", "protocols")
AMPS = [1.2, 1.5, 1.9, 2.4]
N_PER = 30
SEQ1 = "seq 1 5 200 205 210 215 220"
WARM = 12000


def curve_order():
    a = np.repeat(AMPS, N_PER)
    return np.random.default_rng(2018).permutation(a)


def write():
    amps = curve_order()
    tmax = WARM + 1000 * len(amps)
    L = [f"# Stage 1 readout curve: test-only from loaded weights, tmax = {tmax} ms",
         f"state 0 {tmax} awake", SEQ1, "weights weights.txt"]
    L += [f"test 1 {WARM + 1000 * k} {WARM + 1000 * (k + 1)} 0 {a:.2f}" for k, a in enumerate(amps)]
    open(os.path.join(PDIR, "stage1_curve.txt"), "w").write("\n".join(L) + "\n")
    n, iti = 30, 3000
    tmax = WARM + iti * n
    L = [f"# Stage 1 trial spacing: 3 s ITI, amp 1.2, test-only from loaded weights, tmax = {tmax} ms",
         f"state 0 {tmax} awake", SEQ1, "weights weights.txt"]
    L += [f"test 1 {WARM + iti * k} {WARM + iti * k + 1000} 0 1.20" for k in range(n)]
    open(os.path.join(PDIR, "stage1_spaced.txt"), "w").write("\n".join(L) + "\n")


if __name__ == "__main__":
    write()
    print(open(os.path.join(PDIR, "stage1_curve.txt")).read()[:400])
