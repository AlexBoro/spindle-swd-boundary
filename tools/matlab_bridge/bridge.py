"""Submit MATLAB jobs to the Windows-side bridge and collect results.

MATLAB is installed on the host but unreachable from this sandbox: there is no
Windows interop here (empty binfmt_misc, no /init or /run/WSL, WSL_INTEROP
unset), and no host-path grant can supply it. The bridge works around that
without widening any permission -- `tools/matlab_bridge/run_bridge.m` runs on
the Windows side and watches a folder this sandbox can already write to.

Usage::

    from tools.matlab_bridge.bridge import is_alive, submit
    assert is_alive(), "start run_bridge.m in MATLAB first"
    r = submit("x = 1 + 1; save(fullfile(JOB_OUT_DIR,'r.mat'), 'x');")
    r["status"]       # 'ok' | 'error'
    r["console"]      # captured MATLAB output
    r["outputs"]      # {filename: absolute path}
"""
import json
import os
import time
import uuid

# Bridge folder: $MATLAB_BRIDGE_ROOT, else a matlab_bridge/ folder next to this repo,
# else ~/dev/matlab_bridge.
_REPO_PARENT = os.path.dirname(os.path.dirname(os.path.dirname(os.path.dirname(os.path.abspath(__file__)))))
_SIBLING = os.path.join(_REPO_PARENT, "matlab_bridge")
DEFAULT_ROOT = _SIBLING if os.path.isdir(_SIBLING) else os.path.expanduser("~/dev/matlab_bridge")
HEARTBEAT_MAX_AGE_S = 30


def _root(root=None):
    return os.path.abspath(root or os.environ.get("MATLAB_BRIDGE_ROOT", DEFAULT_ROOT))


def is_alive(root=None, max_age_s=HEARTBEAT_MAX_AGE_S):
    """True if the watcher wrote its heartbeat within `max_age_s`.

    Check before submitting: otherwise a job sits in the queue until someone
    notices, and the caller blocks for the full timeout for no reason.
    """
    hb = os.path.join(_root(root), "bridge_alive.txt")
    if not os.path.exists(hb):
        return False
    return (time.time() - os.path.getmtime(hb)) <= max_age_s


def _reject_local_functions(source):
    """Job scripts must not define local functions.

    `run()` on a script containing local functions is not reliable when invoked
    from inside a function, which is how the watcher executes jobs. Failing here
    with a clear message beats an opaque MATLAB parse error on the far side.
    """
    for i, line in enumerate(source.splitlines(), 1):
        if line.lstrip().startswith("function "):
            raise ValueError(
                "job source defines a local function at line %d; the watcher runs "
                "scripts via run() inside a function, where local functions are "
                "unreliable. Inline the logic, or use an anonymous function." % i)


def submit(source, name=None, root=None, wait=True, timeout=600, poll=2.0):
    """Write a job for the bridge and (by default) block until it completes.

    `source` is MATLAB script text. It may write files to the folder named by
    the variable ``JOB_OUT_DIR``, which the watcher defines; anything saved
    there comes back in the result's ``outputs``.

    Returns a dict with status, error, console, outputs, elapsed_s and the
    MATLAB version that ran it. With ``wait=False`` returns the job id only.
    """
    _reject_local_functions(source)
    r = _root(root)
    in_dir, out_dir = os.path.join(r, "jobs", "in"), os.path.join(r, "jobs", "out")
    os.makedirs(in_dir, exist_ok=True)

    job_id = "job_%s_%s" % (time.strftime("%Y%m%d_%H%M%S"),
                            name or uuid.uuid4().hex[:6])
    tmp = os.path.join(in_dir, job_id + ".m.tmp")
    with open(tmp, "w", newline="\r\n") as fh:      # CRLF: MATLAB on Windows
        fh.write(source if source.endswith("\n") else source + "\n")
    os.replace(tmp, os.path.join(in_dir, job_id + ".m"))   # atomic publish

    if not wait:
        return {"job": job_id, "status": "submitted"}
    return collect(job_id, root=r, timeout=timeout, poll=poll)


def collect(job_id, root=None, timeout=600, poll=2.0):
    """Block until `job_id` reports done, then read its result."""
    r = _root(root)
    out_dir = os.path.join(r, "jobs", "out")
    sentinel = os.path.join(out_dir, job_id + ".done")

    deadline = time.time() + timeout
    while not os.path.exists(sentinel):
        if time.time() > deadline:
            raise TimeoutError(
                "%s did not complete within %gs. Is run_bridge.m still running? "
                "(is_alive() = %s)" % (job_id, timeout, is_alive(r)))
        time.sleep(poll)

    job_out = os.path.join(out_dir, job_id)
    with open(os.path.join(job_out, "status.json")) as fh:
        st = json.load(fh)
    console_path = os.path.join(job_out, "console.log")
    st["console"] = open(console_path, errors="replace").read() if os.path.exists(console_path) else ""
    st["outputs"] = {f: os.path.join(job_out, f)
                     for f in os.listdir(job_out)
                     if f not in ("status.json", "console.log")}
    st["job_out_dir"] = job_out
    return st


def stop(root=None):
    """Ask the watcher to exit after its current poll."""
    open(os.path.join(_root(root), "STOP"), "w").close()
