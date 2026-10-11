# Provenance of model/wei2018/

Wei Y, Krishnan GP, Komarov M, Bazhenov M (2018) Differential roles of sleep
spindles and sleep slow oscillations in memory consolidation. PLoS Comput Biol
14(7): e1006322. doi:10.1371/journal.pcbi.1006322

**No code was released with the 2018 paper.** This directory starts from the
closest public descendant from the same laboratory:

- Repository: https://github.com/bazhlab-ucsd/TCmodel-sequenceLearningSleepCode-eLife2020
- Commit: `62fb64411d9798b9ae32f5e465c1831a97622694`
- Licence: GPL-2.0 (`LICENSE`, unmodified)
- Paper: Gonzalez OC, Sokolov Y, Krishnan GP, Delanois JE, Bazhenov M (2020)
  Can sleep protect memories from catastrophic forgetting? eLife 9:e51005.

Why this donor: it is the same C++ simulator lineage the 2018 paper used
(4th-order Runge-Kutta, dt = 0.02 ms, g++), with the same 500 PY / 100 IN /
100 TC / 100 RE one-dimensional network, the same intrinsic currents, and the
STDP synapse (AMPA_D3, which modifies both gAMPA and the miniature EPSP
amplitude with f = 0.01) that Wei 2018 Methods describe. Its network.cfg already
matches every synaptic strength and radius in Wei 2018 Methods except the
plastic PY-PY AMPA connection.

The first commit touching this directory is the donor **byte for byte**.
Unlike model/thalamocortical2/ (patched at run time), C++ has to be edited and
recompiled, so every departure is its own commit here and

    git log --oneline -- model/wei2018/

is the complete list of deviations from the donor. Each commit message cites the
Wei 2018 Methods sentence (or figure) that motivates it. Points where the paper
is ambiguous are recorded in docs/wei2018_interpretations.md.

The Krishnan et al. 2016 sleep-stage code (bazhlab-ucsd/sleep-stage-transition)
was consulted for the N2 parameterisation scheme only; it carries no licence
file and is not vendored.
