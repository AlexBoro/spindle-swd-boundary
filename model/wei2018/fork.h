// fork.h -- exact in-process checkpoint/fork (see fork.cpp)
#ifndef WEI_FORK_H
#define WEI_FORK_H
#include <stdio.h>
#include <string>
FILE *out_fopen(const std::string &path, const char *mode);   // fopen + register as a run output
void fork_if_due(double t, double &tmax);                    // call at the top of every time step
extern double fork_at;      // ms; < 0 = never fork
extern int fork_threads;    // OpenMP threads per child (0 = keep num_mp_threads)
#endif
