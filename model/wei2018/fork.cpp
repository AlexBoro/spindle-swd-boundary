// fork.cpp -- exact checkpoint/fork for runs that share a prefix.
//
// With -fork_at T and WEI_FORK_LIST=<file>, the run simulates [0, T) once and then, at the top of
// the first step with t >= T, fork()s one child process per line of <file>:
//     <name> <raw_dir> <log_path> <protocol_file> [-param value ...]
// Each child inherits the complete in-memory state (cells, synapses, per-synapse RNG buffers,
// globals), so its trajectory is bitwise identical to an unforked run of <protocol_file> with the
// same parameters -- provided the protocols agree before T, which is checked here.  The child copies
// the prefix outputs into <raw_dir>, reopens every output stream there in append mode, switches
// protocol and parameters, and continues.  The parent waits for all children and exits.
#include "fork.h"
#include "protocol.h"
int cmdline_parameters(int argc, char *argv[]);   // params.h (defined in io.cpp)
#include <stdlib.h>
#include <string.h>
#include <unistd.h>
#include <dirent.h>
#include <sys/stat.h>
#include <sys/wait.h>
#include <vector>
#include <fstream>
#include <sstream>

double fork_at = -1;
int fork_threads = 0;
extern int num_mp_threads;
extern std::string output_location;

struct OutFile { FILE *fp; std::string name; std::string mode; };
static std::vector<OutFile> out_files;
static int forked = 0;
static double fork_t = 0;   // actual time of the first step with t >= fork_at

FILE *out_fopen(const std::string &path, const char *mode){
  FILE *fp = fopen(path.c_str(), mode);
  std::string name = path.substr(path.rfind('/') + 1);
  if(fp){ OutFile o = {fp, name, mode}; out_files.push_back(o); }
  return fp;
}

// OpenMP worker threads do not survive fork(); release them first (OpenMP 5.0) when the runtime
// supports it, otherwise children must run single-threaded.
extern "C" int wei_omp_pause_all(int) __asm__("omp_pause_resource_all") __attribute__((weak));

static void fail(const char *msg){ fprintf(stderr, "fork: %s\n", msg); fflush(stderr); _exit(3); }

static bool same_prefix(const Protocol &a, const Protocol &b, double T){
  std::vector<StateBlock> sa, sb; std::vector<StimWin> wa, wb;
  for(size_t i=0;i<a.states.size();i++) if(a.states[i].t0 < T) sa.push_back(a.states[i]);
  for(size_t i=0;i<b.states.size();i++) if(b.states[i].t0 < T) sb.push_back(b.states[i]);
  if(sa.size() != sb.size()) return false;
  for(size_t i=0;i<sa.size();i++){
    double ea = sa[i].t1 < T ? sa[i].t1 : T, eb = sb[i].t1 < T ? sb[i].t1 : T;
    if(sa[i].t0 != sb[i].t0 || ea != eb || sa[i].state != sb[i].state) return false;
  }
  for(size_t i=0;i<a.wins.size();i++) if(a.wins[i].t0 < T) wa.push_back(a.wins[i]);
  for(size_t i=0;i<b.wins.size();i++) if(b.wins[i].t0 < T) wb.push_back(b.wins[i]);
  if(wa.size() != wb.size()) return false;
  for(size_t i=0;i<wa.size();i++){
    double ea = wa[i].t1 < T ? wa[i].t1 : T, eb = wb[i].t1 < T ? wb[i].t1 : T;
    if(wa[i].seq != wb[i].seq || wa[i].t0 != wb[i].t0 || ea != eb || wa[i].phase != wb[i].phase ||
       wa[i].is_test != wb[i].is_test || wa[i].amp != wb[i].amp) return false;
    // a window that runs past T must also agree after T up to its end (same trial schedule)
    if(wa[i].t1 != wb[i].t1 && (wa[i].t1 > T || wb[i].t1 > T)) return false;
  }
  if(a.seqs.size() != b.seqs.size()) return false;
  for(size_t i=0;i<a.seqs.size();i++)
    if(a.seqs[i].id != b.seqs[i].id || a.seqs[i].size != b.seqs[i].size || a.seqs[i].starts != b.seqs[i].starts) return false;
  if(a.weights_path != b.weights_path) return false;
  return true;
}

static void copy_file(const std::string &src, const std::string &dst){
  FILE *in = fopen(src.c_str(), "rb"); if(!in) return;
  FILE *out = fopen(dst.c_str(), "wb"); if(!out) fail(("cannot write " + dst).c_str());
  char buf[1 << 16]; size_t n;
  while((n = fread(buf, 1, sizeof buf, in)) > 0) if(fwrite(buf, 1, n, out) != n) fail("short write");
  fclose(in); fclose(out);
}

static void become_child(const std::vector<std::string> &w, double &tmax){
  const std::string &name = w[0], raw = w[1] + "/", logp = w[2], proto = w[3];
  if(!freopen(logp.c_str(), "w", stdout)) fail("cannot open child log");
  std::string errp = logp.substr(0, logp.rfind('/') + 1) + "sim_stderr.log";
  if(!freopen(errp.c_str(), "w", stderr)) fail("cannot open child stderr");
  Protocol p2; p2.load(proto.c_str());
  if(!same_prefix(protocol, p2, fork_at)) fail(("protocol " + proto + " differs from the parent before fork_at").c_str());
  protocol = p2;
  // prefix outputs: copy everything written so far, then reopen the live streams in append mode
  mkdir(w[1].c_str(), 0755);
  DIR *d = opendir(output_location.c_str()); if(!d) fail("cannot list parent output dir");
  struct dirent *e;
  while((e = readdir(d))){
    std::string f = e->d_name; if(f == "." || f == "..") continue;
    struct stat st; if(stat((output_location + f).c_str(), &st) || !S_ISREG(st.st_mode)) continue;
    copy_file(output_location + f, raw + f);
  }
  closedir(d);
  for(size_t i=0;i<out_files.size();i++){
    std::string m = out_files[i].mode; m[0] = 'a';
    if(!freopen((raw + out_files[i].name).c_str(), m.c_str(), out_files[i].fp)) fail(("cannot reopen " + out_files[i].name).c_str());
  }
  FILE *fp = fopen((raw + "protocol_used.txt").c_str(), "w"); protocol.dump(fp); fclose(fp);
  output_location = raw;
  // parameter overrides for the child (registered params only, e.g. -stdp_factor_n2 1, -tmax)
  std::vector<char*> av; av.push_back((char*)"child");
  for(size_t i=4;i<w.size();i++) av.push_back((char*)w[i].c_str());
  if(av.size() > 1 && !cmdline_parameters((int)av.size(), &av[0])) fail("bad parameter override");
  if(fork_threads > 0) num_mp_threads = fork_threads;
  if(!wei_omp_pause_all) num_mp_threads = 1;
  printf("FORKED child %s at t=%.6f ms from parent pid %d: protocol %s, threads %d, tmax %.0f\n",
         name.c_str(), fork_t, (int)getppid(), proto.c_str(), num_mp_threads, tmax);
  fflush(stdout);
}

void fork_if_due(double t, double &tmax){
  if(forked || fork_at < 0 || t < fork_at) return;
  forked = 1; fork_t = t;
  const char *list = getenv("WEI_FORK_LIST"); if(!list) fail("fork_at set but WEI_FORK_LIST is not");
  std::ifstream in(list); if(!in) fail("cannot read WEI_FORK_LIST");
  std::vector<std::vector<std::string> > kids; std::string line;
  while(std::getline(in, line)){
    std::stringstream ss(line); std::vector<std::string> w; std::string tok;
    while(ss >> tok) w.push_back(tok);
    if(w.size() >= 4 && w[0][0] != '#') kids.push_back(w);
  }
  if(kids.empty()) fail("WEI_FORK_LIST has no children");
  printf("fork at t=%.6f ms (requested %.3f): %zu children\n", t, fork_at, kids.size());
  fflush(NULL);
  if(wei_omp_pause_all) wei_omp_pause_all(2 /* omp_pause_hard */);
  std::vector<pid_t> pids;
  for(size_t k=0;k<kids.size();k++){
    pid_t p = fork();
    if(p < 0) fail("fork() failed");
    if(p == 0){ become_child(kids[k], tmax); return; }
    pids.push_back(p);
  }
  int bad = 0;
  for(size_t k=0;k<pids.size();k++){
    int st = 0; waitpid(pids[k], &st, 0);
    int ok = WIFEXITED(st) && WEXITSTATUS(st) == 0;
    printf("child %s pid %d %s (status %d)\n", kids[k][0].c_str(), (int)pids[k], ok ? "done" : "FAILED", st);
    bad += !ok;
  }
  printf("Computation time: parent done, %d child failures\n", bad);
  fflush(NULL);
  exit(bad ? 4 : 0);
}
