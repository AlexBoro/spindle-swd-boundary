"""Run the thalamocortical model and REDUCE in-container.

The raw output is 32 MB per model-second across 900 files -- 9.6 GB for a 300 s
run -- which cannot be harvested. Everything the Gate 0 analysis needs (spike
times, population rates, coarse Vm) compresses to under a megabyte, so the
reduction happens here and only the small file travels.
"""
import glob, json, os, re, resource, subprocess, sys, time

import numpy as np

MODEL = "thalamocortical2"
TSTOP_MS = int(sys.argv[1])
STATE = sys.argv[2] if len(sys.argv) > 2 else "spindles_long"
DT_MS = 0.25
SPIKE_THRESHOLD_MV = 0.0
RATE_BIN_S = 0.001
VM_WINDOW_S = 2.0

os.chdir(MODEL)
t0 = time.time()
subprocess.run(["nrnivmodl", "."], check=True, capture_output=True, text=True)
compile_s = time.time() - t0

init = open("init.hoc").read()
init = init.replace('state = "awake_long"', 'state = "%s"' % STATE, 1)
init = init.replace("tstop = 1200e3", "tstop = %d" % TSTOP_MS, 1)
init = init.replace("saveData = 50", "saveData = 20", 1)
open("init.hoc", "w").write(init)

t0 = time.time()
p = subprocess.run([os.path.abspath("x86_64/special"), "-nogui", "init.hoc"],
                   capture_output=True, text=True)
wall = time.time() - t0
peak_mb = resource.getrusage(resource.RUSAGE_CHILDREN).ru_maxrss / 1024.0
completed = "Execution time" in p.stdout

files = sorted(glob.glob("*.dat"))
pat = re.compile(r'z\d+_(Cx\d|TC|NRT)data_(\d)_(\d{4})_([A-Z]+)\.dat$')
pops, spikes, vm_coarse, names = [], [], [], []
tstop_s = TSTOP_MS / 1000.0
nwin = int(tstop_s / VM_WINDOW_S)
fs = 1000.0 / DT_MS

for f in files:
    m = pat.match(os.path.basename(f))
    if not m:
        continue
    kind, field, idx, suffix = m.group(1), m.group(2), int(m.group(3)), m.group(4)
    if kind == "TC":
        pop = "TC_FO" if field == "1" else "TC_HO"
    elif kind == "NRT":
        pop = "NRT_FO" if field == "1" else "NRT_HO"
    else:
        layer = {"2": "23"}.get(field, field)
        pop = "L%s_%s" % (layer, "FS" if suffix == "FS" else "E")
    with open(f) as fh:
        fh.readline()
        vm = np.fromstring(fh.readline(), sep="\t")
    above = vm > SPIKE_THRESHOLD_MV
    spikes.append((np.flatnonzero(above[1:] & ~above[:-1]) + 1) * DT_MS)
    vm_coarse.append(np.array([np.clip(vm[int(i*VM_WINDOW_S*fs):int((i+1)*VM_WINDOW_S*fs)],
                                       -100, -20).mean() for i in range(nwin)]))
    pops.append(pop)
    names.append(os.path.basename(f))

os.makedirs("../out", exist_ok=True)
np.savez_compressed(
    "../out/reduced.npz",
    spike_times_ms=np.array(spikes, dtype=object),
    pop=np.array(pops), cell_file=np.array(names),
    vm_mean=np.array(vm_coarse), vm_window_s=VM_WINDOW_S,
    dt_ms=DT_MS, tstop_s=tstop_s, state=STATE, allow_pickle=True)

meta = {
    "tstop_ms": TSTOP_MS, "state": STATE,
    "compile_s": round(compile_s, 1), "wall_s": round(wall, 1),
    "core_s_per_model_s": round(wall / tstop_s, 1),
    "peak_rss_mb": round(peak_mb, 1),
    "n_dat": len(files), "n_cells_reduced": len(pops),
    "total_spikes": int(sum(len(s) for s in spikes)),
    "exit_code": p.returncode, "completed": completed,
    "stdout_tail": p.stdout[-300:], "stderr_tail": p.stderr[-300:],
}
json.dump(meta, open("../out/meta.json", "w"), indent=2)
print(json.dumps(meta, indent=2))
if not completed:
    sys.exit(1)
