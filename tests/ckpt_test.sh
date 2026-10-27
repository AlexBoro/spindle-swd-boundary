#!/bin/sh
# Checkpoint regression test (model/wei2018/checkpoint.h), about 10 min on 6 cores.
# 1) reference run 0-3.5 s that also writes a checkpoint at 2 s (training stimulus + STDP active,
#    awake->N2 switch at 2.5 s); 2) restore at 2 s with a different thread count and run to 3.5 s;
# 3) spikes, LFP and weights over t >= 2 s must be bit-identical.
set -e
M=$(cd "$(dirname "$0")/../model/wei2018" && pwd); W=${1:-/tmp/ckpt_test}; mkdir -p "$W/ref" "$W/rst"
(cd "$M" && make -s mindcurrent && g++ -O2 generate_network.cpp -o generate_network && ./generate_network > connection_info2 2>/dev/null)
C="-sim_seed 3 -plasticity_start 500 -stdp_factor_n2 1 -stdp_factor_n3 0.75 -tmax 3500"
"$M/mindcurrent" "$M/wei2018_params.txt" "$W/ref/" "$M/connection_info2" "$M/protocols/ckpt_test.txt" $C -num_mp_threads 6 -ckpt_save_at 2000 -ckpt_save_path "$W/ref/ck2000.bin" > "$W/ref.log" 2>&1
"$M/mindcurrent" "$M/wei2018_params.txt" "$W/rst/" "$M/connection_info2" "$M/protocols/ckpt_test.txt" $C -num_mp_threads 3 -ckpt_load_path "$W/ref/ck2000.bin" > "$W/rst.log" 2>&1
python3 "$(dirname "$0")/ckpt_compare.py" "$W/ref" "$W/rst" 2000
