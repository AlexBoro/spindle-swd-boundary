"""Compare a restored run against the reference run over t >= t0 (bit for bit).
usage: python compare.py <ref_dir> <test_dir> <t0_ms>"""
import sys, os, numpy as np
ref, tst, t0 = sys.argv[1], sys.argv[2], float(sys.argv[3])
ok = True
def lines(p, lo):
    out = []
    for l in open(p):
        f = l.split()
        if f and float(f[0]) >= lo: out.append(l.rstrip("\n"))
    return sorted(out)
a, b = lines(os.path.join(ref, "spike_time"), t0), lines(os.path.join(tst, "spike_time"), t0)
same = a == b; ok &= same
print(f"spike_time: ref {len(a)} test {len(b)} identical={same}")
if not same:
    k = next((i for i, (x, y) in enumerate(zip(a, b)) if x != y), min(len(a), len(b)))
    print("  first difference:", a[k:k+1], b[k:k+1])
for fn, w in [("lfp.f32", 5), ("weights_g.f32", None), ("weights_mini.f32", None)]:
    pa, pb = os.path.join(ref, fn), os.path.join(tst, fn)
    if not os.path.exists(pa): continue
    if w is None:
        w = sum(1 for _ in open(os.path.join(ref, "weights_index.txt"))) - 1 + 1
    A = np.fromfile(pa, np.float32).reshape(-1, w); B = np.fromfile(pb, np.float32).reshape(-1, w)
    ta = {float(x): i for i, x in enumerate(A[:, 0])}
    common = [(ta[float(x)], j) for j, x in enumerate(B[:, 0]) if float(x) in ta and float(x) >= t0]
    ia, ib = np.array([c[0] for c in common]), np.array([c[1] for c in common])
    same = len(common) > 0 and np.array_equal(A[ia].view(np.uint32), B[ib].view(np.uint32)); ok &= same
    print(f"{fn}: rows ref>=t0 {int((A[:,0]>=t0).sum())} test {len(B)} common {len(common)} identical={same}")
print("ALL_IDENTICAL" if ok else "DIFFERENCES_FOUND")
