# MATLAB bridge

MATLAB runs on the Windows side; the analysis sandbox cannot reach it (no
Windows interop — `binfmt_misc` is empty, there is no `/init` or `/run/WSL`, and
`WSL_INTEROP` is unset). No host-path grant fixes that, because the missing
piece is interop rather than permission.

This bridge works around it **without widening any permission**: MATLAB watches a
folder the sandbox can already write to, runs whatever job appears, and writes
results back.

## Start it

1. Open MATLAB.
2. `cd` to this folder.
3. `>> run_bridge`

It prints the folders it is watching and then polls every 2 seconds
(`run_bridge('poll', 5)` to slow it down).

## Stop it

Press **Ctrl+C**, or create a file named `STOP` in this folder — the bridge
checks each poll, deletes it, and exits cleanly. From the sandbox side:
`bridge.stop()`.

## Please read before running

This executes code from `jobs/in/` with your user's privileges. It does not
widen what the sandbox can reach — that folder is already write-granted — but it
does turn *reading* that folder into *running code from* it. So:

- Start it when you are working on this project; stop it when you are done.
- Do not leave it running unattended or set it to launch at login.
- Every script it runs is archived in `jobs/done/` with a timestamp, and every
  job is logged to `logs/bridge.log`, so there is a full record of what executed.

## Layout

| Path | Contents |
|---|---|
| `jobs/in/` | incoming `job_*.m` (written atomically: `.m.tmp` then renamed) |
| `jobs/out/<job_id>/` | `status.json`, `console.log`, and anything the job saved |
| `jobs/out/<job_id>.done` | sentinel, written **last** so a partial result is never read |
| `jobs/done/` | archive of every executed script, timestamped |
| `logs/bridge.log` | append-only record of every job |
| `lib/` | `.m` files on the path for jobs — the model's detector lives here |
| `bridge_alive.txt` | heartbeat, rewritten each poll |

## Writing a job

A job is a MATLAB script. The watcher defines `JOB_OUT_DIR`; save anything you
want returned there.

```matlab
load(fullfile(JOB_OUT_DIR, '..', '..', '..', 'lib', 'trace.mat'));
[spikes, ~, ~, locs] = detectEEGspikesSWDs(EEG, 1.0, false);
save(fullfile(JOB_OUT_DIR, 'result.mat'), 'spikes', 'locs', '-v7');
```

**Job scripts must not define local functions.** The watcher runs them via
`run()` from inside a function, where local functions are unreliable. The Python
client refuses such jobs up front rather than letting them fail opaquely on the
far side.

## Known limitations

- **One job at a time**, in-process. Faster than a fresh `matlab -batch` per job
  (which costs 10–20 s of startup), at the cost of isolation — a job that
  corrupts global state affects later jobs. Restart the bridge if in doubt.
- **No runaway-job timeout.** MATLAB cannot interrupt itself from within the
  same process; a job stuck in an infinite loop needs Ctrl+C. The Python client
  has its own `timeout`, but that only stops *waiting* — it does not stop the job.
- **Figures are suppressed only if the job suppresses them.** Nothing here forces
  `-nodisplay`.

## Licence of copied files

The MATLAB helpers copied unmodified from `model/thalamocortical2` (Dervinis & Crunelli) in this folder are GPL-3.0, as in the original deposit (see `model/thalamocortical2/LICENSE`). Everything else here is MIT (repository `LICENSE`).
