# Runpod job: for each seed given, write the 212 s checkpoint with the ckpt-opt binary (8 threads), restore
# it into fig3_awake/n2/n3/n2n3 (2 threads each, to 282 s), and compare the stitched outputs with the
# original Modal runs at 212 s and 282 s. Checkpoints are copied to out/ for harvest.
# usage: bash ckpt_make_validate.sh "0 1 2" [stop|none]  (stop: Pod stops 15 min after the job; none: no stop; default: 8 h safety stop)
set -u
SEEDS=${1:-0}; STOP=${2:-}
command -v python3 >/dev/null && python3 -c "import numpy" 2>/dev/null || (apt-get update -qq && DEBIAN_FRONTEND=noninteractive apt-get install -y -qq python3-numpy >/dev/null 2>&1)
mkdir -p out; lscpu | grep -E "Model name" > out/hw.txt; nproc >> out/hw.txt
W=$PWD; rc=0
for S in $SEEDS; do
  mkdir -p pre_$S && (cd pre_$S && python3 $W/job_run.py $W/wei2018_src.tar.gz fig3_n2 $S 8 -ckpt_save_at 212000 -ckpt_save_path ck212.bin -ckpt_exit_after_save 1 > run.log 2>&1)
  CK=$(ls $W/pre_$S/out/*_ck212.bin 2>/dev/null | head -n 1)
  if [ -z "$CK" ]; then echo "seed $S: no checkpoint"; tail -n 20 pre_$S/run.log; rc=1; continue; fi
  cp "$CK" out/ck212_s$S.bin; cp pre_$S/out/*.json out/ 2>/dev/null
  for C in awake n2 n3 n2n3; do
    mkdir -p r_${S}_$C && (cd r_${S}_$C && python3 $W/job_run.py $W/wei2018_src.tar.gz fig3_$C $S 2 -tmax 282000 -ckpt_load_path $CK > run.log 2>&1) &
  done
  wait
  cp r_${S}_*/out/*.json out/ 2>/dev/null
  python3 ckpt_compare_refs.py modal_ref_digests_282.json pre_$S/out/fig3_n2_s${S}_*.npz r_${S}_*/out/fig3_*.npz | tee out/compare_s$S.txt
  grep -q ALL_IDENTICAL out/compare_s$S.txt || rc=1
  grep -h "wall_s" pre_$S/out/*.json r_${S}_*/out/*.json | head -n 0
done
python3 - <<'P' > out/timing.txt
import json, glob
for f in sorted(glob.glob("out/fig3_*.json")):
    m = json.load(open(f)); print(m["run_id"], round(m["wall_s"]), m.get("last_ms"), m.get("threads"))
P
cat out/timing.txt
K=$(tr '\0' '\n' </proc/1/environ | sed -n 's/^RUNPOD_API_KEY=//p'); ID=$(tr '\0' '\n' </proc/1/environ | sed -n 's/^RUNPOD_POD_ID=//p')
if [ -n "$ID" ] && [ "$STOP" != "none" ]; then
  if [ "$STOP" = "stop" ]; then DELAY=900; else DELAY=28800; fi    # 15 min leaves time for the harvest
  setsid nohup sh -c "sleep $DELAY; RUNPOD_API_KEY='$K' runpodctl stop pod $ID" > /tmp/safety_stop.log 2>&1 &
fi
exit $rc
