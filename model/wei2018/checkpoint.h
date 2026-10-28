// Bit-identical checkpoint / fork of the full simulation state (Stage 3).
//
// -ckpt_save_at T -ckpt_save_path P   write the state at the top of the first step with t >= T
// -ckpt_exit_after_save 1             stop the run right after writing it
// -ckpt_load_path P                   start from a saved state instead of t = 0
//
// A loaded run continues exactly as the saving run would have, provided the binary, network,
// seed and every parameter are the same: tests/ckpt in the repo checks this bit for bit.
// Branching ("fork") works by changing parameters between save and load:
//  * vigilance-state table entries, STDP factors and anything else read from a global each step
//    take the new value immediately;
//  * synapse 'strength', 'mini_s' and 'mini_fre' are PARAMETERS: the load keeps the freshly
//    built value (so network.cfg overrides apply) and reports how many differ from the file.
//    Exception: AMPA_D3 'mini_s' is plastic and is restored. Synapses cache strength*E in g1
//    at each release, so a changed strength takes effect at that synapse's next release;
//  * the header records share_gates and the shared-gate leader/member counts (1,200 / 28,776 for the
//    production network) and refuses a mismatch, because followers do not carry live gate state;
//  * shared-gate leaders (opt-exact) live inside Syn objects and are restored with them; the
//    lead pointers and the per-cell synapse plans (which cache only parameters) are those of the
//    fresh build, so the plan picks up overridden strengths automatically;
//  * cell-intrinsic constants (G_h, G_kl, ...) are restored from the file, so they cannot be
//    branched this way; perturb them through the state table instead.
#ifndef _CHECKPOINT_H_
#define _CHECKPOINT_H_
#include <string>
extern double ckpt_save_at;
extern int ckpt_exit_after_save;
extern std::string ckpt_save_path, ckpt_load_path;
void ckpt_save(const std::string &path, double t, int ii, int print_count);
void ckpt_load(const std::string &path, double &t, int &ii, int &print_count);
#endif
