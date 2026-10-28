import json, sys, os
sys.path.insert(0, os.getcwd())
import numpy as np
from digest_lib import digest
out = []
for s in (0, 1, 2):
    for c in ("awake", "n2", "n3", "n2n3"):
        d = np.load(f"/vol/fig3/fig3_{c}_s{s}/fig3_{c}_s{s}.npz")
        for tc in (212000, 282000, 562000):
            x = digest(d, tc); x.update(run=f"fig3_{c}_s{s}", t_cut=tc); out.append(x); print(x, flush=True)
os.makedirs("out", exist_ok=True); json.dump(out, open("out/modal_ref_digests_282.json", "w"), indent=1)
