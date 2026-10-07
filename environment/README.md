# Build environment

The vendored mechanism files require **NEURON 7.8.2**. 13 of the 65 `.mod` files
(`ampa`, `nmda`, `gaba`, `gaba2`, `gabaa`, `gabab`, `glu`, `glu2`, `glu3`,
`mGluR1a`, `minis`, `minis2`, `SynExp5NMDA`) use the pre-8.2 `VERBATIM`
random-number interface (`nrn_random_pick`, `nrn_random_arg`) and fail on NEURON
8.2+ with:

    error: cannot convert '_nrn_mechanism_cache_range*' to 'nrnran123_State*'

This is a version mismatch, not a broken deposit. Two routes, both taken:

1. **Pin 7.8.2** (this directory) — verified to compile and run. Requires
   Python <= 3.8. Use for the Gate 0 baseline.
2. **Port the 13 files** to the modern `RANDOM`/`nrnran123` interface — tracked
   separately. All 13 use the identical idiom, so the port is mechanical. Verify
   the two builds give statistically indistinguishable spindle and SWD statistics
   before switching.

Note: the model uses gap junctions between NRT neurons (`HalfGap.mod`), which
force a fixed time step and complicate CoreNEURON. Treat any CoreNEURON speedup
as a bonus, not a dependency.

## Local conda

    conda create -n neuron7 python=3.8 numpy gcc_linux-64 gxx_linux-64 make bison flex ncurses
    conda activate neuron7
    pip install neuron==7.8.2

## Compile

From `model/thalamocortical2/` (the `.mod`/`.hoc` files are flat):

    nrnivmodl .        # -> x86_64/special

`nrnivmodl` emits many benign `Warning: nrnran123_dblpick undefined. (declared
within VERBATIM?)` lines even on a successful build. Only `Error` and
`make: ***` lines matter.

## Run

    ./x86_64/special -nogui init.hoc

`init.hoc` sets `pProc = 1` and creates a `ParallelContext`, which works on a
single rank — MPI is not required.

## Measured cost

Full network, `modelType = 20`, `state = "spindles_long"`, `dt = 0.25`, serial:

| Quantity | Value |
|---|---|
| Wall time | 62.7 core-seconds per second of model time |
| Peak RSS | 315 MB |
| Output at `saveData = 50` | 900 `.dat` files, 75 MB per model-second |

Re-measure in the production container before sizing a sweep.
