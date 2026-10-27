"""Validate a restored run against an uninterrupted one on the production network.
usage: python ckpt_check_vs_run.py <restored.npz> <reference.npz> <t0_ms> <t1_ms> [out.json]
Spikes (t, type, cell) in [t0, t1) and LFP rows in (t0, t1] must be identical."""
import json, sys
import numpy as np
a, b = np.load(sys.argv[1]), np.load(sys.argv[2]); t0, t1 = float(sys.argv[3]), float(sys.argv[4])
def spk(d):
    k = (d["spk_t"] >= t0) & (d["spk_t"] < t1)
    return np.c_[d["spk_t"][k], d["spk_type"][k], d["spk_m"][k]]
sa, sb = spk(a), spk(b)
la = a["lfp"][(a["lfp"][:, 0] > t0) & (a["lfp"][:, 0] <= t1)]; lb = b["lfp"][(b["lfp"][:, 0] > t0) & (b["lfp"][:, 0] <= t1)]
rep = dict(restored=sys.argv[1], reference=sys.argv[2], t0=t0, t1=t1, n_spikes_restored=int(len(sa)), n_spikes_reference=int(len(sb)),
           spikes_identical=bool(np.array_equal(sa, sb)), lfp_rows=int(len(la)),
           lfp_identical=bool(len(la) == len(lb) and np.array_equal(la.view(np.uint32), lb.view(np.uint32))))
print("CKPT_CHECK", json.dumps(rep), flush=True)
if len(sys.argv) > 5: json.dump(rep, open(sys.argv[5], "w"), indent=1)
