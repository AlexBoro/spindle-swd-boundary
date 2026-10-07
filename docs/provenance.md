# Provenance rules

1. `model/thalamocortical2/` is vendored **unmodified** at upstream v1.0.0 in a
   single commit. The next commits apply changes one concern at a time, so that
   `git log --oneline -- model/` is a readable list of every departure from the
   published model.
2. Never edit vendored files in a commit that also does something else.
3. Line numbers quoted in upstream documentation drift between versions. Patches
   and docs reference **variable names**, not line numbers.
4. Every simulation records the git SHA of the tree that produced it, alongside
   its config hash and seed, in the run registry.

## Upstream

| Item | Value |
|---|---|
| Source | `github.com/dervinism/thalamocortical2` |
| Archive | Zenodo `10.5281/zenodo.7724443` |
| Version | v1.0.0 (`dervinism-thalamocortical2-0cc8608`) |
| Composition | 38 `.hoc`, 65 `.mod`, 195 MATLAB `.m`, 125 SLURM scripts |

The companion deposit `10.5281/zenodo.7724411`
(`github.com/dervinism/thalamocortical1`) corresponds to the sleep-waves paper
only and is not vendored here; `thalamocortical2` supersedes it and ships the
analysis suite.
