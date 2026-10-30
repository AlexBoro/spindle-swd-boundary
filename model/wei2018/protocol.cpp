// protocol.cpp -- see protocol.h
#include <stdio.h>
#include <stdlib.h>
#include <math.h>
#include <fstream>
#include <sstream>
#include "protocol.h"

Protocol protocol;

double stim_period = 1000.0;   // ms between trials        (donor: period=1000)
double stim_spacing = 15.0;    // ms between group onsets  (donor: 0,15,30,45,60)
double stim_pulse = 10.0;      // ms pulse per group       (donor: stime<10 etc.)
int sim_seed = 0;              // 0 reproduces the donor's fixed seeds

double stdp_factor_now = 0.0;
double stdp_cD_train = 0.001;  // donor: cD = 0.001 inside training windows
double stdp_cD = 0.002;        // donor: cD = 0.002 elsewhere
double stdp_cP = 0.002;        // donor: cP = 0.002
int in_train_now = 0;

static void die(const std::string &msg, int line) {
  fprintf(stderr, "protocol error (line %d): %s\n", line, msg.c_str());
  exit(2);
}

void Protocol::load(const char *path) {
  std::ifstream in(path);
  if (!in) { fprintf(stderr, "cannot open protocol file %s\n", path); exit(2); }
  std::string line; int ln = 0;
  while (std::getline(in, line)) {
    ln++;
    size_t h = line.find('#'); if (h != std::string::npos) line = line.substr(0, h);
    std::stringstream ss(line); std::string kw;
    if (!(ss >> kw)) continue;
    if (kw == "state") {
      StateBlock b; std::string s;
      if (!(ss >> b.t0 >> b.t1 >> s)) die("state <t0> <t1> <awake|n2|n3>", ln);
      if (s == "awake") b.state = ST_AWAKE; else if (s == "n2") b.state = ST_N2;
      else if (s == "n3") b.state = ST_N3; else die("unknown state " + s, ln);
      states.push_back(b);
    } else if (kw == "seq") {
      SeqDef q; int st;
      if (!(ss >> q.id >> q.size)) die("seq <id> <size> <starts...>", ln);
      while (ss >> st) q.starts.push_back(st);
      if (q.starts.empty()) die("seq needs at least one group start", ln);
      seqs.push_back(q);
    } else if (kw == "train" || kw == "test") {
      StimWin w; w.is_test = (kw == "test");
      if (!(ss >> w.seq >> w.t0 >> w.t1 >> w.phase)) die(kw + " <id> <t0> <t1> <phase> [amp]", ln);
      if (!(ss >> w.amp)) w.amp = -1.0;   // -1: use input_strength
      wins.push_back(w);
    } else if (kw == "weights") {
      if (!(ss >> weights_path)) die("weights <file>", ln);
      if (weights_path[0] != '/') {
        std::string p(path); size_t sl = p.rfind('/');
        if (sl != std::string::npos) weights_path = p.substr(0, sl + 1) + weights_path;
      }
    } else die("unknown directive " + kw, ln);
  }
  // validation: state blocks contiguous from 0
  if (states.empty()) die("no state blocks", 0);
  if (states[0].t0 != 0) die("first state block must start at 0", 0);
  for (size_t i = 1; i < states.size(); i++)
    if (states[i].t0 != states[i-1].t1) die("state blocks must be contiguous", 0);
  for (size_t i = 0; i < wins.size(); i++)
    if (!find_seq(wins[i].seq)) die("stimulus window refers to undefined seq", 0);
}

void Protocol::dump(FILE *f) const {
  const char *nm[3] = {"awake", "n2", "n3"};
  for (size_t i = 0; i < states.size(); i++)
    fprintf(f, "state %.3f %.3f %s\n", states[i].t0, states[i].t1, nm[states[i].state]);
  for (size_t i = 0; i < seqs.size(); i++) {
    fprintf(f, "seq %d %d", seqs[i].id, seqs[i].size);
    for (size_t j = 0; j < seqs[i].starts.size(); j++) fprintf(f, " %d", seqs[i].starts[j]);
    fprintf(f, "\n");
  }
  for (size_t i = 0; i < wins.size(); i++)
    fprintf(f, "%s %d %.3f %.3f %.3f %.4f\n", wins[i].is_test ? "test" : "train",
            wins[i].seq, wins[i].t0, wins[i].t1, wins[i].phase, wins[i].amp);
  if (!weights_path.empty()) fprintf(f, "weights %s\n", weights_path.c_str());
}

const SeqDef *Protocol::find_seq(int id) const {
  for (size_t i = 0; i < seqs.size(); i++) if (seqs[i].id == id) return &seqs[i];
  return NULL;
}

int Protocol::state_at(double t) const {
  for (size_t i = 0; i < states.size(); i++)
    if (t >= states[i].t0 && t < states[i].t1) return states[i].state;
  return states.back().state;  // past the last block: hold the final state
}

int Protocol::in_test(double t) const {
  for (size_t i = 0; i < wins.size(); i++)
    if (wins[i].is_test && t >= wins[i].t0 && t < wins[i].t1) return 1;
  return 0;
}

double Protocol::stim(int m, double x) const {
  extern double input_strength;
  double I = 0.0;
  for (size_t i = 0; i < wins.size(); i++) {
    const StimWin &w = wins[i];
    if (x < w.t0 || x >= w.t1) continue;
    double rel = x - w.t0 - w.phase;
    if (rel < 0) continue;
    double st = fmod(rel, stim_period);
    const SeqDef *q = find_seq(w.seq);
    int ng = w.is_test ? 1 : (int)q->starts.size();
    for (int g = 0; g < ng; g++) {
      double on = g * stim_spacing;
      if (st >= on && st < on + stim_pulse && m >= q->starts[g] && m < q->starts[g] + q->size)
        I += (w.amp >= 0 ? w.amp : input_strength);
    }
  }
  return I;
}

// ---------------- vigilance-state table ----------------
#define N_ NAN
double gkl_cx_awake = 0.19*0.7, gkl_cx_n2 = N_, gkl_cx_n3 = 0.19*2.0;
double gkl_tc_awake = 0.8*0.5,  gkl_tc_n2 = N_, gkl_tc_n3 = 0.8*2.0;
double gkl_re_awake = 0.9,      gkl_re_n2 = N_, gkl_re_n3 = 0.9*((2-2.0/2)-0.5);
double gh_tc_awake = -8.0*3,    gh_tc_n2 = N_,  gh_tc_n3 = -1.0;
double ampa_cx_awake = 0.19*0.7, ampa_cx_n2 = N_, ampa_cx_n3 = 0.19*2.0*1.28;
double ampa_th_awake = 0.5,     ampa_th_n2 = N_, ampa_th_n3 = 0.5;
double gaba_cx_awake = 0.22,    gaba_cx_n2 = N_, gaba_cx_n3 = 0.22*2.0;
double gaba_th_awake = 0.6,     gaba_th_n2 = N_, gaba_th_n3 = 0.6*2.0;
double stdp_factor_n2 = N_, stdp_factor_n3 = 0.75;   // donor: factor 0.75 in sleep
double plasticity_start = 12000;
int share_gates = 1;
int idle_skip_off = 0;   // 1 = disable the exact idle skip of AMPA_D2/AMPA_D3/GABA_A_D2 (diagnostics)
double weight_dt = 1000;
double lfp_dt = 1;
int weight_jitter = 1;
int tc_ampa_route = 0;
int rec_area = 0;
int rec_eeg = 0;                  // 1 = write eeg.f32 (PY dipole / synaptic currents by block, 1 ms)

extern double fac_gkl, fac_gkl_TC, fac_gkl_RE, fac_gh_TC, fac_AMPA_D2, fac_AMPA_TC,
  fac_GABA_D2, fac_GABA_TC, fac_gkca_cx, fac_gkm_cx, fac_gkv_cx;

void apply_state(int st) {
  const double *row[8][3] = {
    {&gkl_cx_awake, &gkl_cx_n2, &gkl_cx_n3}, {&gkl_tc_awake, &gkl_tc_n2, &gkl_tc_n3},
    {&gkl_re_awake, &gkl_re_n2, &gkl_re_n3}, {&gh_tc_awake, &gh_tc_n2, &gh_tc_n3},
    {&ampa_cx_awake, &ampa_cx_n2, &ampa_cx_n3}, {&ampa_th_awake, &ampa_th_n2, &ampa_th_n3},
    {&gaba_cx_awake, &gaba_cx_n2, &gaba_cx_n3}, {&gaba_th_awake, &gaba_th_n2, &gaba_th_n3}};
  fac_gkl = *row[0][st]; fac_gkl_TC = *row[1][st]; fac_gkl_RE = *row[2][st];
  fac_gh_TC = *row[3][st]; fac_AMPA_D2 = *row[4][st]; fac_AMPA_TC = *row[5][st];
  fac_GABA_D2 = *row[6][st]; fac_GABA_TC = *row[7][st];
  fac_gkca_cx = 1.0; fac_gkm_cx = 1.0; fac_gkv_cx = 1.0;   // donor: 1.0 in all states
}

void check_state_table() {
  const double *row[8][3] = {
    {&gkl_cx_awake, &gkl_cx_n2, &gkl_cx_n3}, {&gkl_tc_awake, &gkl_tc_n2, &gkl_tc_n3},
    {&gkl_re_awake, &gkl_re_n2, &gkl_re_n3}, {&gh_tc_awake, &gh_tc_n2, &gh_tc_n3},
    {&ampa_cx_awake, &ampa_cx_n2, &ampa_cx_n3}, {&ampa_th_awake, &ampa_th_n2, &ampa_th_n3},
    {&gaba_cx_awake, &gaba_cx_n2, &gaba_cx_n3}, {&gaba_th_awake, &gaba_th_n2, &gaba_th_n3}};
  int used[3] = {0, 0, 0};
  for (size_t i = 0; i < protocol.states.size(); i++) used[protocol.states[i].state] = 1;
  for (int s = 0; s < 3; s++) {
    if (!used[s]) continue;
    for (int r = 0; r < 8; r++)
      if (isnan(*row[r][s])) { fprintf(stderr, "state table: row %d state %d is NaN but used\n", r, s); exit(2); }
  }
  if (used[ST_N2] && isnan(stdp_factor_n2)) { fprintf(stderr, "stdp_factor_n2 unset but N2 used\n"); exit(2); }
}
