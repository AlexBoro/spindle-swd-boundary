# Sweeps

One manifest per sweep. A manifest enumerates (config, seed) pairs; the registry
records one row per completed run, keyed on `run_id` =
`sha256(config, seed)[:16]`, together with the git SHA of the producing tree.

Sizing: 62.7 core-seconds per second of model time (measured, serial,
`dt = 0.25`; re-measure in the production container). Apply the per-run cost to
each run-class separately and sum — do not apply one duration to the whole
sweep. Raw output is 75 MB per model-second, so the reducer in `analysis/` must
run in-worker; target under 50 MB retained per run.

Nothing here runs before Gate 0 passes (`docs/acceptance_criteria.md`).
