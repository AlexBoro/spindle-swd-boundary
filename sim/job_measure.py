"""Measure NEURON 7.8.2 cost inside the container: wall time and peak RSS.

Peak RSS of the child is what decides how many sweep points fit per worker, and
it is not visible from inside the NEURON process itself.
"""
import json, os, resource, subprocess, sys, time

MODEL = "thalamocortical2"
TSTOP_MS = int(sys.argv[1]) if len(sys.argv) > 1 else 20000

os.chdir(MODEL)
t0 = time.time()
subprocess.run(["nrnivmodl", "."], check=True, capture_output=True, text=True)
compile_s = time.time() - t0

init = open("init.hoc").read()
init = init.replace('state = "awake_long"', 'state = "spindles_long"')
for old, new in [("tstop = 1200e3", "tstop = %d" % TSTOP_MS),
                 ("saveData = 50", "saveData = 20")]:
    init = init.replace(old, new, 1)
open("init.hoc", "w").write(init)

t0 = time.time()
p = subprocess.run([os.path.abspath("x86_64/special"), "-nogui", "init.hoc"],
                   capture_output=True, text=True)
wall = time.time() - t0
peak_mb = resource.getrusage(resource.RUSAGE_CHILDREN).ru_maxrss / 1024.0

ndat = len([f for f in os.listdir(".") if f.endswith(".dat")])
out = {
    "tstop_ms": TSTOP_MS,
    "compile_s": round(compile_s, 1),
    "wall_s": round(wall, 1),
    "core_s_per_model_s": round(wall / (TSTOP_MS / 1000.0), 1),
    "peak_rss_mb": round(peak_mb, 1),
    "n_dat": ndat,
    "exit_code": p.returncode,
    "completed": "Execution time" in p.stdout,
    "stdout_tail": p.stdout[-400:],
    "stderr_tail": p.stderr[-400:],
    "nproc": os.cpu_count(),
}
os.makedirs("../out", exist_ok=True)
json.dump(out, open("../out/measure.json", "w"), indent=2)
print(json.dumps(out, indent=2))
