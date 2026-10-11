"""Generate the Wei 2018 protocol files in model/wei2018/protocols/.

Timeline read from Wei 2018 Fig 2D / 3B / 5i / 7F (paper time t; file time = t + W):
  test 0-50 s, training 50-150 s, test 150-200 s, sleep 200-500 s, test 500-550 s.
  Fig 7: N2 200-700 s, N3 700-1000 s, test 1000-1050 s ('500s N2 sleep preceding N3').
W = 12 s warm-up (awake, no stimulus, STDP frozen: plasticity_start = 12000 ms),
matching the donor's 12 s initialisation period.

Sequences (Methods, Training and test; Results, two-sequence section):
  Seq1 'ABCDE'       groups A(#200-204) B(#205-209) C(#210-214) D(#215-219) E(#220-224)
  Seq2 'E2D2C2B2A2'  groups E2(#296-300) D2(#291-295) C2(#286-290) B2(#281-285) A2(#276-280)
                     activated in that order (E2 first), test stimulates E2.
Two-sequence trials: Seq1 at phase 0 ms, Seq2 at phase 500 ms of each 1 s period
(interpretation I4 -- the paper shows both training bars starting together but
does not state the within-trial offset).
"""
import os, sys
W = 12000
S1 = "seq 1 5 200 205 210 215 220"
S2 = "seq 2 5 296 291 286 281 276"
out = sys.argv[1] if len(sys.argv) > 1 else "model/wei2018/protocols"
os.makedirs(out, exist_ok=True)

def ms(t_s):  # paper seconds -> file ms
    return W + int(round(t_s * 1000))

def write(name, states, seqs, wins, tmax_s, note):
    lines = [f"# {note}", f"# tmax = {ms(tmax_s)} ms (paper t = {tmax_s} s + {W/1000:.0f} s warm-up)"]
    lines.append(f"state 0 {W} awake")
    for a, b, st in states:
        lines.append(f"state {ms(a)} {ms(b)} {st}")
    lines += seqs
    for kind, sid, a, b, ph in wins:
        lines.append(f"{kind} {sid} {ms(a)} {ms(b)} {ph}")
    open(os.path.join(out, name + ".txt"), "w").write("\n".join(lines) + "\n")
    print(name, ms(tmax_s))

def tests(seq_ids, a, b):
    return [("test", s, a, b, 0 if s == 1 else 500) for s in seq_ids]

# --- Fig 2/3: single sequence, four sleep conditions ---
sleep = {"n2n3": [(200, 350, "n2"), (350, 500, "n3")],
         "awake": [(200, 500, "awake")],
         "n2": [(200, 500, "n2")],
         "n3": [(200, 500, "n3")]}
for cond, blk in sleep.items():
    states = [(0, 200, "awake")] + blk + [(500, 550, "awake")]
    wins = tests([1], 0, 50) + [("train", 1, 50, 150, 0)] + tests([1], 150, 200) + tests([1], 500, 550)
    write(f"fig3_{cond}", states, [S1], wins, 550, f"Wei 2018 Fig 2/3, single sequence, sleep = {cond}")

# --- Fig 5: strong Seq1 (100 s) + weak Seq2 (40 s), N3 only; and Seq2 alone ---
st5 = [(0, 200, "awake"), (200, 500, "n3"), (500, 550, "awake")]
w5 = tests([1, 2], 0, 50) + [("train", 1, 50, 150, 0), ("train", 2, 50, 90, 500)] \
     + tests([1, 2], 150, 200) + tests([1, 2], 500, 550)
write("fig5_two_n3", st5, [S1, S2], w5, 550, "Wei 2018 Fig 5: Seq1 100 s + Seq2 40 s, N3 300 s")
w5b = tests([2], 0, 50) + [("train", 2, 50, 90, 500)] + tests([2], 150, 200) + tests([2], 500, 550)
write("fig5_seq2alone_n3", st5, [S2], w5b, 550, "Wei 2018 Fig 5i black line: Seq2 alone 40 s, N3 300 s")

# --- Fig 7: same training, N2 500 s then N3 300 s ---
st7 = [(0, 200, "awake"), (200, 700, "n2"), (700, 1000, "n3"), (1000, 1050, "awake")]
w7 = tests([1, 2], 0, 50) + [("train", 1, 50, 150, 0), ("train", 2, 50, 90, 500)] \
     + tests([1, 2], 150, 200) + tests([1, 2], 1000, 1050)
write("fig7_two_n2n3", st7, [S1, S2], w7, 1050, "Wei 2018 Fig 7: Seq1 100 s + Seq2 40 s, N2 500 s + N3 300 s")

# --- physiology gate: state only, no stimulus ---
for st in ["awake", "n2", "n3"]:
    open(os.path.join(out, f"state_{st}.txt"), "w").write(
        f"# physiology gate: {st} only, no stimulus (run with -plasticity_start 1e12)\nstate 0 1000000000 {st}\nseq 1 5 200 205 210 215 220\n")
    print(f"state_{st}")
