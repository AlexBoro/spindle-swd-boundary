# One Runpod Pod, one seed: (1) write the 212 s checkpoint with the ckpt-opt binary and validate it by
# restoring all four Fig 3 conditions to 282 s against the original Modal runs; (2) only if every
# comparison is identical, run the 36 tier-1 branches (N2 + awake) for this seed, 4 at a time on
# 2 threads, and screen them for SWDs; (3) arm an 8 h safety stop. The agent stops the Pod right after
# it has harvested out/ (container disk is erased on stop, so never stop before the harvest).
# usage: bash stage3_pod_job.sh <seed>
set -u
S=$1; W=$PWD
python3 -c "import numpy, scipy, pandas" 2>/dev/null || (apt-get update -qq && DEBIAN_FRONTEND=noninteractive apt-get install -y -qq python3-numpy python3-scipy python3-pandas >/dev/null 2>&1)
python3 -c "import numpy, scipy, pandas; print('numpy', numpy.__version__, 'scipy', scipy.__version__, 'pandas', pandas.__version__)"
bash ckpt_make_validate.sh "$S" none; rc=$?
if [ $rc -eq 0 ] && grep -q ALL_IDENTICAL out/compare_s$S.txt; then
  python3 make_swd_tier1.py && python3 -c "import json; json.dump(json.load(open('swd_tier1_n2.json')) + json.load(open('swd_tier1_awake.json')), open('spec_s$S.json', 'w'), indent=1)"
  mkdir -p br && cd br && cp ../job_run.py ../job_branch.py ../swd_wei.py . && \
    python3 job_branch.py ../wei2018_src.tar.gz $W/out/ck212_s$S.bin $S 2 4 ../spec_s$S.json > ../out/branch_s$S.log 2>&1; rc=$?
  cd $W; cp br/out/swd_*_s$S.csv out/ 2>/dev/null
  mkdir -p out/branches; for d in br/*/out; do cp $d/*.npz $d/*.json out/branches/ 2>/dev/null; done
  tail -n 40 out/branch_s$S.log
else
  echo "checkpoint validation failed for seed $S: tier 1 not started"; rc=1
fi
K=$(tr '\0' '\n' </proc/1/environ | sed -n 's/^RUNPOD_API_KEY=//p'); ID=$(tr '\0' '\n' </proc/1/environ | sed -n 's/^RUNPOD_POD_ID=//p')
[ -n "$ID" ] && setsid nohup sh -c "sleep 28800; RUNPOD_API_KEY='$K' runpodctl stop pod $ID" > /tmp/stop.log 2>&1 &
exit $rc
