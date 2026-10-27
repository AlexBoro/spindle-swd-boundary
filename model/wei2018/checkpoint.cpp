#include "checkpoint.h"
#include "CellSyn.h"
#include "network.h"
#include "protocol.h"
#include <cstdio>
#include <cstdlib>
#include <cstring>
#include <cstdint>
#include <cmath>
#include <vector>
#include <type_traits>

double ckpt_save_at = -1;
int ckpt_exit_after_save = 0;
std::string ckpt_save_path = "", ckpt_load_path = "";

extern CellSyn **cells;
extern int num_cells;
extern Homeostasis homeo;

static const char MAGIC[8] = {'W', 'E', 'I', 'C', 'K', 'P', 'T', '1'};

// Only BaseCell / Syn carry a vtable, so each object has exactly one vptr, at offset 0.
static_assert(!std::is_polymorphic<IT_RE>::value && !std::is_polymorphic<INaK>::value &&
              !std::is_polymorphic<ICa>::value && !std::is_polymorphic<IT_TC>::value &&
              !std::is_polymorphic<Ih_TC>::value && !std::is_polymorphic<IA_TC>::value &&
              !std::is_polymorphic<CX_DEND>::value && !std::is_polymorphic<CX_SOMA>::value,
              "intrinsic-current classes must not be polymorphic");

struct Ckpt {
  FILE *f; bool save;
  long n_param_kept[ENUM_Syn_Types][3];   // [syn type][strength, mini_s, mini_fre]
  Ckpt(FILE *f_, bool s) : f(f_), save(s) { memset(n_param_kept, 0, sizeof(n_param_kept)); }
  void raw(void *p, size_t n) {
    if (save) { if (fwrite(p, 1, n, f) != n) die("write failed"); }
    else if (fread(p, 1, n, f) != n) die("read failed (truncated checkpoint?)");
  }
  template <class T> void io(T &x) { raw(&x, sizeof(T)); }
  template <class T> void check(T x, const char *what) {   // identity field: must match
    T y = x; io(y);
    if (!save && memcmp(&x, &y, sizeof(T)) != 0) { fprintf(stderr, "checkpoint mismatch: %s\n", what); exit(3); }
  }
  static void die(const char *m) { fprintf(stderr, "checkpoint: %s\n", m); exit(3); }

  // object with a single vptr at offset 0 and no other pointers: copy all bytes but the vptr
  void object_bytes(void *obj, size_t n) {
    if (save) { raw(obj, n); return; }
    std::vector<unsigned char> buf(n); raw(buf.data(), n);
    memcpy((unsigned char *)obj + sizeof(void *), buf.data() + sizeof(void *), n - sizeof(void *));
  }

  static size_t syn_size(int type) {
    switch (type) {
      case E_GABA_A: return sizeof(GABA_A);  case E_GABA_B: return sizeof(GB);
      case E_AMPA: return sizeof(AMPA);      case E_AMPA_D2: return sizeof(AMPA_D2);
      case E_AMPA_D3: return sizeof(AMPA_D3); case E_NMDA_D1: return sizeof(NMDA_D1);
      case E_GABA_A_D2: return sizeof(GABA_A_D2);
    }
    fprintf(stderr, "checkpoint: synapse type %d not supported\n", type); exit(3);
  }
  static drand48_data **rand_slot(Syn *s) {
    switch (s->type) {
      case E_AMPA_D2: return &((AMPA_D2 *)s)->rand_buffer;
      case E_AMPA_D3: return &((AMPA_D3 *)s)->rand_buffer;
      case E_GABA_A_D2: return &((GABA_A_D2 *)s)->rand_buffer;
    }
    return NULL;
  }

  void synapse(Syn *s) {
    check((int)s->type, "synapse type"); check((int)s->from_type, "synapse from_type");
    check((int)s->to_type, "synapse to_type"); check(s->from_cell, "synapse from_cell");
    if (s->giant) die("giant synapses not supported");
    size_t n = syn_size(s->type);
    drand48_data **rs = rand_slot(s);
    if (save) { raw(s, n); if (rs) raw(*rs, sizeof(drand48_data)); return; }
    // keep what must survive the byte copy: vptr, pointers, parameters
    void *vptr; memcpy(&vptr, (void *)s, sizeof(void *));
    drand48_data *rb = rs ? *rs : NULL;
    double par[3] = {s->strength, s->mini_s, s->mini_fre};
    std::vector<unsigned char> buf(n); raw(buf.data(), n);
    memcpy((void *)s, buf.data(), n);
    memcpy((void *)s, &vptr, sizeof(void *));
    s->giant = NULL;
    if (rs) { *rs = rb; raw(rb, sizeof(drand48_data)); }
    double *cur[3] = {&s->strength, &s->mini_s, &s->mini_fre};
    for (int k = 0; k < 3; k++) {
      if (k == 1 && s->type == E_AMPA_D3) continue;          // plastic: restored
      if (memcmp(cur[k], &par[k], sizeof(double)) != 0) n_param_kept[s->type][k]++;
      *cur[k] = par[k];
    }
  }

  void cell(CellSyn *c) {
    check(c->type, "cell type"); check(c->m, "cell m"); check(c->n, "cell n");
    check(c->num_syns, "num_syns"); check(c->lhs_size, "lhs_size"); check(c->ismap, "ismap");
    if (!c->giant_syns.empty()) die("giant synapses not supported");
    raw(c->y, sizeof(double) * c->lhs_size); raw(c->f, sizeof(double) * c->lhs_size);
    raw(c->s, sizeof(double) * c->lhs_size); raw(c->yk, sizeof(double) * c->lhs_size);
    io(c->cur_time); io(c->xk); io(c->tau); io(c->current_step); io(c->AMPA_Rsum);
    io(c->flip); io(c->flip_for_maps); io(c->old_v); io(c->num_spikes);
    raw(c->rand_buffer, sizeof(drand48_data));
    size_t nb; void *b = c->base_cell;
    if (c->type == E_RE) { nb = sizeof(RE); if ((void *)static_cast<BaseCell *>((RE *)b) != b) die("RE layout"); }
    else if (c->type == E_TC) { nb = sizeof(TC); if ((void *)static_cast<BaseCell *>((TC *)b) != b) die("TC layout"); }
    else if (c->type == E_CX || c->type == E_IN) { nb = sizeof(CX); if ((void *)static_cast<BaseCell *>((CX *)b) != b) die("CX layout"); }
    else { die("cell type not supported"); return; }
    check(nb, "base cell size");
    object_bytes(b, nb);
    for (int k = 0; k < c->num_syns; k++) synapse(c->syns[k]);
  }

  void homeostasis() {
    check(homeo.num_regions, "homeo regions");
    raw(homeo.boost_syn, sizeof(int) * homeo.num_regions);
    raw(homeo.total_region, sizeof(int) * homeo.num_regions);
    raw(homeo.frequencies, sizeof(double) * homeo.num_regions);
  }

  void all(double &t, int &ii, int &print_count) {
    char m[8]; memcpy(m, MAGIC, 8); raw(m, 8);
    if (memcmp(m, MAGIC, 8) != 0) die("bad magic");
    check(num_cells, "num_cells"); check(sim_seed, "sim_seed");
    io(t); io(ii); io(print_count);
    homeostasis();
    for (int i = 0; i < num_cells; i++) cell(cells[i]);
    char e[8]; memcpy(e, "ENDCKPT!", 8); raw(e, 8);
    if (memcmp(e, "ENDCKPT!", 8) != 0) die("bad trailer");
  }
};

void ckpt_save(const std::string &path, double t, int ii, int print_count) {
  std::string tmp = path + ".tmp";
  FILE *f = fopen(tmp.c_str(), "wb");
  if (!f) { fprintf(stderr, "checkpoint: cannot write %s\n", tmp.c_str()); exit(3); }
  Ckpt c(f, true); c.all(t, ii, print_count);
  if (fclose(f) != 0 || rename(tmp.c_str(), path.c_str()) != 0) { fprintf(stderr, "checkpoint: write failed\n"); exit(3); }
  printf("CKPT_SAVED t=%.17g ii=%d path=%s\n", t, ii, path.c_str()); fflush(stdout);
}

void ckpt_load(const std::string &path, double &t, int &ii, int &print_count) {
  FILE *f = fopen(path.c_str(), "rb");
  if (!f) { fprintf(stderr, "checkpoint: cannot read %s\n", path.c_str()); exit(3); }
  Ckpt c(f, false); c.all(t, ii, print_count);
  if (fgetc(f) != EOF) { fprintf(stderr, "checkpoint: trailing bytes\n"); exit(3); }
  fclose(f);
  printf("CKPT_LOADED t=%.17g ii=%d path=%s\n", t, ii, path.c_str());
  static const char *pn[3] = {"strength", "mini_s", "mini_fre"};
  for (int s = 0; s < ENUM_Syn_Types; s++)
    for (int k = 0; k < 3; k++)
      if (c.n_param_kept[s][k]) printf("CKPT_PARAM_OVERRIDE syn_type=%d %s n=%ld\n", s, pn[k], c.n_param_kept[s][k]);
  fflush(stdout);
}
