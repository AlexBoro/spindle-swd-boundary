"""Run the model at saveData=50 and return an EEG plus spike times.

saveData=50 records Vm, iGlu and iGABA per cortical cell, which is what the
authors' EEG forward model (readDataThCx_EEG.m) consumes. The forward model is
applied in-container so the ~2 GB of traces never need to travel.
"""
import glob, json, os, re, resource, subprocess, sys, time

import numpy as np
from scipy import signal

MODEL = "thalamocortical2"
TSTOP_MS = int(sys.argv[1])
STATE = sys.argv[2]
DT_MS = 0.25
SPIKE_THRESHOLD_MV = 0.0

LAYER_DEPTH_UM = {"2": 351.8, "4": 693.4, "5": 1089.4, "6": 1597.2}
GABA_DEPTH_OFFSET_UM = 500.0
CELL_SPACING_UM = 20.0
COLUMN_CENTRE = 49.5
CONDUCTIVITY = 230.0 / (4.0 * np.pi)
CONV_FACT = 1e-3 * 1e1 * 1e3
LOWPASS_HZ, LOWPASS_STOP_HZ = 40.0, 60.0

os.chdir(MODEL)
t0 = time.time()
subprocess.run(["nrnivmodl", "."], check=True, capture_output=True, text=True)
compile_s = time.time() - t0

init = open("init.hoc").read()
init = init.replace('state = "awake_long"', 'state = "%s"' % STATE, 1)
init = init.replace("tstop = 1200e3", "tstop = %d" % TSTOP_MS, 1)
open("init.hoc", "w").write(init)          # saveData is already 50 in the deposit

t0 = time.time()
p = subprocess.run([os.path.abspath("x86_64/special"), "-nogui", "init.hoc"],
                   capture_output=True, text=True)
wall = time.time() - t0
peak_mb = resource.getrusage(resource.RUSAGE_CHILDREN).ru_maxrss / 1024.0
completed = "Execution time" in p.stdout

pat = re.compile(r'z\d+_(Cx\d|TC|NRT)data_(\d)_(\d{4})_([A-Z]+)\.dat$')
files = sorted(f for f in glob.glob("*.dat") if pat.match(os.path.basename(f)))
cortical = [f for f in files if "Cx3data" in f]
first = {}
for f in cortical:
    lay = os.path.basename(f)[12]
    idx = int(os.path.basename(f)[14:18])
    first.setdefault(lay, idx)
    first[lay] = min(first[lay], idx)

eeg = None
pops, spikes, names = [], [], []
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
    pops.append(pop); names.append(os.path.basename(f))
    if kind.startswith("Cx") and len(rows) >= 2:
        i_glu, i_gaba = rows[0], rows[1]
        if eeg is None:
            eeg = np.zeros_like(i_glu)
        lay = os.path.basename(f)[12]
        h = LAYER_DEPTH_UM[lay]
        pos = abs(idx - first[lay] - COLUMN_CENTRE) * CELL_SPACING_UM
        eeg += CONV_FACT * CONDUCTIVITY * i_glu / np.sqrt(h**2 + pos**2)
        eeg += CONV_FACT * CONDUCTIVITY * i_gaba / np.sqrt((h + GABA_DEPTH_OFFSET_UM)**2 + pos**2)

nyq = (1000.0 / DT_MS) / 2.0
n, wn = signal.buttord(LOWPASS_HZ / nyq, LOWPASS_STOP_HZ / nyq, 0.5, 10)
sos = signal.butter(n, wn, btype="low", output="sos")
eeg_lp = signal.sosfiltfilt(np.ascontiguousarray(sos), eeg)

os.makedirs("../out", exist_ok=True)
np.savez_compressed("../out/reduced_eeg.npz",
                    eeg=eeg, eeg_lp=eeg_lp, spike_times_ms=np.array(spikes, dtype=object),
                    pop=np.array(pops), cell_file=np.array(names),
                    dt_ms=DT_MS, tstop_s=TSTOP_MS/1000.0, state=STATE, allow_pickle=True)
meta = {"tstop_ms": TSTOP_MS, "state": STATE, "compile_s": round(compile_s, 1),
        "wall_s": round(wall, 1), "core_s_per_model_s": round(wall/(TSTOP_MS/1000.0), 1),
        "peak_rss_mb": round(peak_mb, 1), "n_dat": len(files),
        "n_cortical": len(cortical), "eeg_samples": int(eeg.size),
        "eeg_lp_std": float(np.std(eeg_lp, ddof=1)),
        "total_spikes": int(sum(len(s) for s in spikes)),
        "exit_code": p.returncode, "completed": completed,
        "stdout_tail": p.stdout[-300:], "stderr_tail": p.stderr[-300:]}
json.dump(meta, open("../out/meta.json", "w"), indent=2)
print(json.dumps(meta, indent=2))
if not completed:
    sys.exit(1)
