"""Run fingerprints, same method as the compute-cost session's digest.py (artifact 2d3b6b8b):
sha256[:16] of spikes sorted by (t, type, cell) with t < t_cut, LFP rows with t < t_cut - 1, and
weight/mini snapshots with t <= t_cut - 1000."""
import hashlib
import numpy as np
def h(*a):
    return hashlib.sha256(b"".join(np.ascontiguousarray(x).tobytes() for x in a)).hexdigest()[:16]
def digest(d, tc):
    m = d["spk_t"] < tc
    o = np.lexsort((d["spk_m"][m], d["spk_type"][m], d["spk_t"][m]))
    lf = d["lfp"]; lm = lf[:, 0] < tc - 1
    wm = d["w_g_t"] <= tc - 1000
    return {"n_spk": int(m.sum()), "spk": h(d["spk_t"][m][o], d["spk_type"][m][o], d["spk_m"][m][o]),
            "n_lfp": int(lm.sum()), "lfp": h(lf[lm]), "n_w": int(wm.sum()), "w_g": h(d["w_g"][wm]), "w_mini": h(d["w_mini"][wm])}
def stitch(prefix, restored, t_cut):
    """Prefix run (saved its checkpoint at ~t_cut and stopped) + run restored from that checkpoint ->
    the arrays an uninterrupted run would have produced. t_cut is the nominal save time in ms."""
    p, r = prefix, restored
    out = {}
    kp, kr = p["spk_t"] < t_cut, r["spk_t"] >= t_cut - 0.001
    for k in ("spk_t", "spk_type", "spk_m"): out[k] = np.concatenate([p[k][kp], r[k][kr]])
    out["lfp"] = np.concatenate([p["lfp"][p["lfp"][:, 0] <= t_cut], r["lfp"][r["lfp"][:, 0] > t_cut]])
    wp, wr = p["w_g_t"] <= t_cut, r["w_g_t"] > t_cut          # drops the restored run's initial snapshot
    out["w_g_t"] = np.concatenate([p["w_g_t"][wp], r["w_g_t"][wr]])
    out["w_g"] = np.concatenate([p["w_g"][wp], r["w_g"][wr]]); out["w_mini"] = np.concatenate([p["w_mini"][wp], r["w_mini"][wr]])
    return out
