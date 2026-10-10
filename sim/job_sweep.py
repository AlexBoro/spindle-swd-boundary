"""One sweep point: set one conductance, run, reduce, return.

Two axes so far, selected by the ``axis`` argument:

``tc_fo_gkl``   GLUfullsyn.gbase_c in the FO branch of TCcell.hoc. This one
                needs an anchor rather than a bare value match: gbase_c is
                assigned once per state in the FO branch and again in the HO
                branch, and wake_short carries the same value as wake_long, so
                matching on the number alone is ambiguous. The anchor pins both
                the state and the FO baseline value, which also makes the patch
                fail loudly if upstream ever changes that baseline.

``cx_gabaa``    GABAsyn.gbar_a in Cx3cell.hoc, and ``cx_ampa`` GLUsyn.gbar_a.
                Both are assigned exactly once and are state-independent, so a
                cortical sweep runs identically from any vigilance state.

Every patch asserts it replaced exactly one line.

Usage: job_sweep.py <tstop_ms> <state> <axis> <value>
"""
import glob, json, os, re, resource, subprocess, sys, time

import numpy as np
from scipy import signal

MODEL = "thalamocortical2"
TSTOP_MS = int(sys.argv[1])
STATE = sys.argv[2]
AXIS = sys.argv[3]
VALUE = float(sys.argv[4])
DT_MS = 0.25
SPIKE_THRESHOLD_MV = 0.0
LAYER_DEPTH_UM = {"2": 351.8, "4": 693.4, "5": 1089.4, "6": 1597.2}
GABA_DEPTH_OFFSET_UM, CELL_SPACING_UM, COLUMN_CENTRE = 500.0, 20.0, 49.5
CONDUCTIVITY = 230.0 / (4.0 * np.pi)
CONV_FACT = 1e-3 * 1e1 * 1e3

os.chdir(MODEL)

# --- patch the swept conductance -------------------------------------------
FO_BASELINE = {"wake_long": "0.001325", "spindles_long": "0.0008",
               "slow_long": "0.0015", "delta_long": "0.0019",
               "SWDs_long": "0.001395"}

if AXIS == "tc_fo_gkl":
    target_file = "TCcell.hoc"
    base = FO_BASELINE[STATE]
    anchor = re.compile(
        r'(strcmp\(state,"' + re.escape(STATE)
        + r'"\)\)\s*\{\s*\n\s*GLUfullsyn\.gbase_c\s*=\s*)(' + re.escape(base) + r')')
elif AXIS in ("cx_gabaa", "cx_ampa"):
    target_file = "Cx3cell.hoc"
    var, base = (("GABAsyn.gbar_a", "0.068") if AXIS == "cx_gabaa"
                 else ("GLUsyn.gbar_a", "0.001945"))
    anchor = re.compile(r'(' + re.escape(var) + r'\s*=\s*)(' + re.escape(base) + r')')
else:
    raise SystemExit("unknown axis %r" % AXIS)

src = open(target_file).read()
hits = anchor.findall(src)
assert len(hits) == 1, ("axis %s: expected exactly one assignment of baseline %s, found %d"
                        % (AXIS, base, len(hits)))
old_val = hits[0][1]
src = anchor.sub(lambda m: m.group(1) + repr(VALUE), src, count=1)
open(target_file, "w").write(src)

init = open("init.hoc").read()
init = init.replace('state = "awake_long"', 'state = "%s"' % STATE, 1)
init = init.replace("tstop = 1200e3", "tstop = %d" % TSTOP_MS, 1)
open("init.hoc", "w").write(init)

t0 = time.time()
subprocess.run(["nrnivmodl", "."], check=True, capture_output=True, text=True)
compile_s = time.time() - t0

t0 = time.time()
p = subprocess.run([os.path.abspath("x86_64/special"), "-nogui", "init.hoc"],
                   capture_output=True, text=True)
wall = time.time() - t0
peak_mb = resource.getrusage(resource.RUSAGE_CHILDREN).ru_maxrss / 1024.0

pat = re.compile(r'z\d+_(Cx\d|TC|NRT)data_(\d)_(\d{4})_([A-Z]+)\.dat$')
files = sorted(f for f in glob.glob("*.dat") if pat.match(os.path.basename(f)))
first = {}
for f in files:
    if "Cx3data" in f:
        lay, idx = os.path.basename(f)[12], int(os.path.basename(f)[14:18])
        first[lay] = min(first.get(lay, idx), idx)

eeg, pops, spikes = None, [], []
for f in files:
    m = pat.match(os.path.basename(f))
    kind, field, idx, suffix = m.group(1), m.group(2), int(m.group(3)), m.group(4)
    with open(f) as fh:
        nrows = int(fh.readline().split()[0])
        vm = np.fromstring(fh.readline(), sep="\t")
        rows = [np.fromstring(fh.readline(), sep="\t") for _ in range(nrows - 1)]
    if kind == "TC":
        pop = "TC_FO" if field == "1" else "TC_HO"
    elif kind == "NRT":
        pop = "NRT_FO" if field == "1" else "NRT_HO"
    else:
        pop = "L%s_%s" % ({"2": "23"}.get(field, field), "FS" if suffix == "FS" else "E")
    above = vm > SPIKE_THRESHOLD_MV
    spikes.append((np.flatnonzero(above[1:] & ~above[:-1]) + 1) * DT_MS)
    pops.append(pop)
    if kind.startswith("Cx") and len(rows) >= 2:
        if eeg is None:
            eeg = np.zeros_like(rows[0])
        lay = os.path.basename(f)[12]
        h, pos = LAYER_DEPTH_UM[lay], abs(idx - first[lay] - COLUMN_CENTRE) * CELL_SPACING_UM
        eeg += CONV_FACT * CONDUCTIVITY * rows[0] / np.sqrt(h**2 + pos**2)
        eeg += CONV_FACT * CONDUCTIVITY * rows[1] / np.sqrt((h + GABA_DEPTH_OFFSET_UM)**2 + pos**2)

nyq = (1000.0 / DT_MS) / 2.0
n_, wn = signal.buttord(40.0 / nyq, 60.0 / nyq, 0.5, 10)
eeg_lp = signal.sosfiltfilt(np.ascontiguousarray(signal.butter(n_, wn, btype="low", output="sos")), eeg)

os.makedirs("../out", exist_ok=True)
np.savez_compressed("../out/sweep_point.npz",
                    eeg_lp=eeg_lp, spike_times_ms=np.array(spikes, dtype=object),
                    pop=np.array(pops), dt_ms=DT_MS, tstop_s=TSTOP_MS/1000.0,
                    state=STATE, axis=AXIS, value=VALUE, allow_pickle=True)
json.dump({"axis": AXIS, "value": VALUE, "baseline_replaced": old_val, "state": STATE,
           "tstop_ms": TSTOP_MS, "wall_s": round(wall, 1),
           "core_s_per_model_s": round(wall/(TSTOP_MS/1000.0), 1),
           "peak_rss_mb": round(peak_mb, 1), "total_spikes": int(sum(len(s) for s in spikes)),
           "eeg_lp_std": float(np.std(eeg_lp, ddof=1)),
           "completed": "Execution time" in p.stdout, "exit_code": p.returncode,
           "stdout_tail": p.stdout[-200:]},
          open("../out/meta.json", "w"), indent=2)
print(json.dumps(json.load(open("../out/meta.json")), indent=2))
if "Execution time" not in p.stdout:
    sys.exit(1)
