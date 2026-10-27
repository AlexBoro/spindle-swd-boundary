"""Write the Stage 3 tier-1 branch list (one spec per state) for job_branch.py.

Axes (each varied alone from the reference configuration, N2 1.0 / N3 0.75 STDP, plasticity off):
  A  RE->TC inhibition: network.cfg strengths of RE->TC GABA_A and GABA_B scaled together (cfg units are mS:
     paper 0.00006 and 0.0000025). Both directions, because the earlier 'weaker' gate run was invalid.
  B  TC Ih activation shift gh_tc_<state>: base + delta (positive delta = curve to hyperpolarised = less Ih).
  C  cortical GABA-A: gaba_cx_<state> scaled (fac_GABA_D2 multiplies evoked and mini IN->PY IPSCs).
"""
import json, sys
BASE = {"gh_tc": {"n2": -2.0, "awake": -24.0}, "gaba_cx": {"n2": 0.264, "awake": 0.22}}
A = [0.25, 0.5, 0.75, 1.5, 2.0, 3.0, 4.0]
B = [-2.0, -1.0, 1.0, 2.0, 4.0, 6.0]
C = [0.8, 0.6, 0.4, 0.2]
def spec(state):
    p = f"swd_{state}_70s"; out = [dict(name=f"{state}_base", protocol=p)]
    for s in A:
        out.append(dict(name=f"{state}_A_reTC_x{s:g}", protocol=p,
                        cfg=[f"RE:TC:GABA_A:strength={0.00006 * s:.10f}", f"RE:TC:GABA_B:strength={0.0000025 * s:.12f}"]))
    for dl in B:
        out.append(dict(name=f"{state}_B_gh{dl:+g}", protocol=p, args=[f"-gh_tc_{state}", f"{BASE['gh_tc'][state] + dl:g}"]))
    for s in C:
        out.append(dict(name=f"{state}_C_gabacx_x{s:g}", protocol=p, args=[f"-gaba_cx_{state}", f"{BASE['gaba_cx'][state] * s:.6g}"]))
    return out
if __name__ == "__main__":
    for st in ["n2", "awake"]:
        json.dump(spec(st), open(f"swd_tier1_{st}.json", "w"), indent=1)
        print(st, len(spec(st)), "branches")
