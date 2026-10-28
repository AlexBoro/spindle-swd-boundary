"""ckpt_compare_refs.py <refs.json> <prefix.npz> <restored.npz>... : stitch prefix + restored runs and
compare their fingerprints with the original Modal runs at every t_cut available for that run."""
import json, os, re, sys
import numpy as np
from digest_lib import digest, stitch
refs = json.load(open(sys.argv[1])); pre = np.load(sys.argv[2]); ok = True
pd = digest(pre, 212000)
for f in sys.argv[3:]:
    m = re.match(r"(fig3_[a-z0-9]+_s\d)_", os.path.basename(f)); run = m.group(1)
    st = stitch(pre, np.load(f), 212000.0)
    t_end = float(np.load(f)["lfp"][-1, 0])
    for r in [x for x in refs if x["run"] == run and x["t_cut"] <= t_end + 1]:
        d = digest(st, r["t_cut"]); keys = ["n_spk", "spk", "n_lfp", "lfp", "w_g", "w_mini"]
        same = all(d[k] == r[k] for k in keys); ok &= same
        print(f"{run} t_cut={r['t_cut']}: {'IDENTICAL' if same else 'DIFFERENT'}  " + " ".join(f"{k}={d[k]}" + ("" if d[k] == r[k] else f"(ref {r[k]})") for k in keys), flush=True)
print("ALL_IDENTICAL" if ok else "DIFFERENCES_FOUND")
