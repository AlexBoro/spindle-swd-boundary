"""In-job step between the sleep run and the fresh-state test (Stage 2, D1).
usage: python stage2_post.py <cond> <seed> <tag>
1) checks that the new run is bit-identical to the original Fig 3 run (same cond/seed, Volume /vol/fig3)
   before sleep onset (212 s): spikes with t < 212000 and every weight snapshot with t <= 212000
2) writes stage1_weights/<cond><tag>_s<seed>_block.txt from the weights at t = 512 s
"""
import glob, json, os, sys
import numpy as np
cond, seed, tag = sys.argv[1], int(sys.argv[2]), sys.argv[3]
new = sorted(glob.glob(f"out/fig3_{cond}_s{seed}_*.npz")); assert len(new) == 1, new
d = np.load(new[0]); o = np.load(f"/vol/fig3/fig3_{cond}_s{seed}/fig3_{cond}_s{seed}.npz")
T0 = 212000.0
def spk(x):
    k = x["spk_t"] < T0
    return np.c_[x["spk_t"][k], x["spk_type"][k], x["spk_m"][k]]
sp_same = np.array_equal(spk(d), spk(o))
kn, ko = d["w_g_t"] <= T0, o["w_g_t"] <= T0
w_same = np.array_equal(d["w_g"][kn], o["w_g"][ko]) and np.array_equal(d["w_mini"][kn], o["w_mini"][ko])
i = int(np.argmin(np.abs(d["w_g_t"] - 512000))); assert abs(d["w_g_t"][i] - 512000) < 1
os.makedirs("stage1_weights", exist_ok=True)
fn = f"stage1_weights/{cond}{tag}_s{seed}_block.txt"
with open(fn, "w") as f:
    for p, q, g, m in zip(d["w_pre"], d["w_post"], d["w_g"][i], d["w_mini"][i]):
        f.write(f"{p} {q} {float(g):.9g} {float(m):.9g}\n")
rep = dict(run=os.path.basename(new[0]), prefix_spikes_identical=bool(sp_same), prefix_weights_identical=bool(w_same),
           n_prefix_spikes=int(len(spk(d))), weights_file=fn)
print("PREFIX_CHECK", json.dumps(rep), flush=True)
pdir = os.environ.get("WEI_PERSIST_DIR")
if pdir:
    json.dump(rep, open(os.path.join(pdir, f"prefix_check_{cond}{tag}_s{seed}.json"), "w"))
