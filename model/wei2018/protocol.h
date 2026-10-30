// protocol.h -- run-time experiment protocol for the Wei et al. 2018 reproduction.
//
// Replaces the donor's hard-coded test/training/sleep timeline (main.cpp globals
// test1_start ... stage3_end, and the if-chains in CellSyn::calc and
// AMPA_D3::calc_ampad3) with a text protocol file, so that every experiment in
// the paper is a different input file rather than a different binary.
//
// Protocol file grammar (times in ms, one directive per line, '#' comments):
//
//   state   <t0> <t1> awake|n2|n3       vigilance-state block (must tile [0,tmax))
//   seq     <id> <size> <start_1> ... <start_k>
//                                       sequence <id>: k groups of <size> PY cells,
//                                       group j = [start_j, start_j+size); groups
//                                       are listed in ACTIVATION order
//   train   <id> <t0> <t1> <phase>      train sequence <id>: in every period
//                                       (default 1000 ms) starting at t0+phase,
//                                       group j is driven during
//                                       [j*spacing, j*spacing+pulse)
//   test    <id> <t0> <t1> <phase>      as train, but only group 1 is driven, and
//                                       STDP is frozen for the whole window
//   train/test take an optional 5th field <amp>: stimulus current for that window
//                                       (default: the input_strength param)
//   weights <file>                      after the initial weights are set (and the
//                                       jitter draws consumed, so every RNG stream is
//                                       unchanged), overwrite every PY-PY AMPA_D3 weight
//                                       and mini amplitude from <file>, one line
//                                       'pre post g mini' per synapse in the order of
//                                       weights_index.txt.  Relative paths resolve
//                                       against the protocol file's directory.
//
// Timing knobs are params (stim_period, stim_spacing, stim_pulse, input_strength).
#ifndef WEI_PROTOCOL_H
#define WEI_PROTOCOL_H

#include <string>
#include <vector>

enum VigState { ST_AWAKE = 0, ST_N2 = 1, ST_N3 = 2 };

struct StateBlock { double t0, t1; int state; };
struct SeqDef { int id; int size; std::vector<int> starts; };
struct StimWin { int seq; double t0, t1, phase; int is_test; double amp; };

struct Protocol {
  std::vector<StateBlock> states;
  std::vector<SeqDef> seqs;
  std::vector<StimWin> wins;
  std::string weights_path;   // empty = keep the initial weights
  void load(const char *path);
  void dump(FILE *f) const;
  int state_at(double t) const;
  int in_test(double t) const;
  // stimulus current for PY cell m at (sub)step time x
  double stim(int m, double x) const;
  const SeqDef *find_seq(int id) const;
};

extern Protocol protocol;

// run-time knobs (set from params file)
extern double stim_period, stim_spacing, stim_pulse;
extern int sim_seed;

// value of the STDP amplitude multiplier for the current time step
// (0 during test windows and before plasticity_start; 1 awake; stdp_factor_n2 /
// stdp_factor_n3 during sleep).  Updated once per integration step in main().
extern double stdp_factor_now;
extern double stdp_cD_train;   // depression amplitude during training windows
extern double stdp_cD;         // depression amplitude otherwise
extern double stdp_cP;         // potentiation amplitude
extern int in_train_now;       // 1 inside any train window (for stdp_cD_train)


// ---- vigilance-state parameter table (Wei 2018 Methods, 'Neuromodulators and
// sleep stages').  Index by VigState.  Defaults in protocol.cpp reproduce the
// donor's awake and stage-3 values; the donor has no N2, so N2 defaults to NaN
// and a protocol that enters N2 without setting all N2 values aborts.
//   gkl_cx  -> fac_gkl      (AChgkl, PY/IN K-leak)
//   gkl_tc  -> fac_gkl_TC   (AChgkl, TC K-leak)
//   gkl_re  -> fac_gkl_RE   (AChgkl, RE K-leak)
//   gh_tc   -> fac_gh_TC    (HAgh, mV shift of Ih activation)
//   ampa_cx -> fac_AMPA_D2  (AChAMPA on AMPA_D2/AMPA_D3: PY-PY, PY-IN, TC-PY, TC-IN)
//   ampa_th -> fac_AMPA_TC  (AChAMPA on class AMPA: TC-RE, PY-TC, PY-RE)
//   gaba_cx -> fac_GABA_D2  (GABA on IN-PY)
//   gaba_th -> fac_GABA_TC  (GABA on RE-TC GABA_A/GABA_B and RE-RE)
extern double gkl_cx_awake, gkl_cx_n2, gkl_cx_n3;
extern double gkl_tc_awake, gkl_tc_n2, gkl_tc_n3;
extern double gkl_re_awake, gkl_re_n2, gkl_re_n3;
extern double gh_tc_awake, gh_tc_n2, gh_tc_n3;
extern double ampa_cx_awake, ampa_cx_n2, ampa_cx_n3;
extern double ampa_th_awake, ampa_th_n2, ampa_th_n3;
extern double gaba_cx_awake, gaba_cx_n2, gaba_cx_n3;
extern double gaba_th_awake, gaba_th_n2, gaba_th_n3;
extern double stdp_factor_n2, stdp_factor_n3;
extern double plasticity_start;
extern int idle_skip_off;
extern int share_gates;          // 1 = gate state of AMPA/GABA_A/NMDA_D1 computed once per presynaptic cell (exact)   // ms; STDP frozen before (donor: 12000)
extern double weight_dt;          // ms between PY-PY weight snapshots (0 = off)
extern double lfp_dt;             // ms between LFP samples (0 = off)
extern int tc_ampa_route;          // 1 = TC->PY/TC->IN scaled by the 'AMPA from TC' factor (I1 literal)
extern int rec_eeg;                // 1 = write eeg.f32 (EEG source currents, see main.cpp eeg_open)
extern int rec_area;               // 1 = write rec_area.f32 (trained-area depression/Ca/K state, 1 ms)
extern int weight_jitter;         // 1 = donor's Gaussian jitter of initial PY-PY weights

void apply_state(int st);         // set the global fac_* from the table
void check_state_table();         // abort if a used state has NaN entries

#endif
