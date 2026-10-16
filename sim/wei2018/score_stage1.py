"""Score Stage 1 test-only runs into a per-trial table.

usage: python score_stage1.py <dir containing stage1_*.npz (searched recursively)> <out.csv>

One row per test trial: protocol, weight set (init / train / <cond>_block), seed,
stimulus amplitude, trial index, recalled order, SM against ABCDE, number of
groups responding, and spike counts of group A and groups B-E in the 350 ms window.
"""
import glob, os, re, sys
import numpy as np
import pandas as pd
sys.path.insert(0, os.path.join(os.path.dirname(os.path.abspath(__file__)), "..", ".."))
from analysis import wei2018 as W

STARTS = [200, 205, 210, 215, 220]


def parse_tests(txt):
    out = []
    for l in txt.splitlines():
        f = l.split()
        if f and f[0] == "test":
            out.append((float(f[2]) + float(f[4]), float(f[5]) if len(f) > 5 else -1.0))
    return sorted(out)


def score_file(path):
    d = dict(np.load(path, allow_pickle=True))
    rid = os.path.basename(path)[:-4]
    m = re.match(r"(stage1_\w+?)_((?:init|train)_s(\d)|(\w+?)_s(\d)_block)(_[0-9a-f]{6})?$", rid)
    proto = m.group(1)
    wset = m.group(2)
    seed = int(m.group(3) or m.group(5))
    stage = wset.split("_s")[0] if m.group(3) else m.group(4)
    k = d["spk_type"] == 4
    st, sm = d["spk_t"][k], d["spk_m"][k].astype(int)
    rows = []
    tests = parse_tests(str(d["protocol_used"]))
    for i, (on, amp) in enumerate(tests):
        o = W.recall_order(st, sm, STARTS, on)
        w = (st >= on) & (st < on + 350)
        a = int(((sm >= 200) & (sm < 205) & w).sum())
        be = int(((sm >= 205) & (sm < 225) & w).sum())
        rows.append(dict(run_id=rid, protocol=proto, wset=stage, seed=seed, trial=i, onset=on,
                         amp=amp, iti=(on - tests[i - 1][0]) if i else np.nan, order=o,
                         sm=W.string_match(o, "ABCDE"), n_groups=len(o), A=a, BE=be))
    return rows


if __name__ == "__main__":
    files = sorted(glob.glob(os.path.join(sys.argv[1], "**", "stage1_*.npz"), recursive=True))
    seen, rows = set(), []
    for f in files:
        b = os.path.basename(f)
        if b in seen:
            continue
        seen.add(b)
        rows += score_file(f)
    df = pd.DataFrame(rows)
    df.to_csv(sys.argv[2], index=False)
    print(len(seen), "runs", len(df), "trials")
