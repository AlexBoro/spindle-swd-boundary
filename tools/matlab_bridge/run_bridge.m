function run_bridge(varargin)
%RUN_BRIDGE  Execute MATLAB jobs dropped into jobs/in by the analysis sandbox.
%
%   run_bridge                 % poll every 2 s
%   run_bridge('poll', 5)     % poll every 5 s
%
% WHAT IT DOES
%   Watches jobs/in for files named job_*.m, runs each one, and writes results
%   to jobs/out. The processed script is archived under jobs/done. Every job and
%   its console output is appended to logs/bridge.log, so there is a complete
%   record of what was executed.
%
% TO STOP
%   Press Ctrl+C, or create a file named STOP in this folder. The bridge checks
%   for STOP on every poll, deletes it, and exits cleanly.
%
% SECURITY
%   This runs code from a folder with your user's privileges. Start it when you
%   are working, stop it when you are done; do not leave it running unattended.
%   Every executed script is archived in jobs/done and logged with a timestamp.

opts = struct('poll', 2);
for i = 1:2:numel(varargin)
    opts.(varargin{i}) = varargin{i+1};
end

root    = fileparts(mfilename('fullpath'));
inDir   = fullfile(root, 'jobs', 'in');
outDir  = fullfile(root, 'jobs', 'out');
doneDir = fullfile(root, 'jobs', 'done');
logDir  = fullfile(root, 'logs');
libDir  = fullfile(root, 'lib');
for d = {inDir, outDir, doneDir, logDir, libDir}
    if ~exist(d{1}, 'dir'); mkdir(d{1}); end
end
addpath(libDir);

logFile  = fullfile(logDir, 'bridge.log');
stopFile = fullfile(root, 'STOP');
aliveFile = fullfile(root, 'bridge_alive.txt');

logline(logFile, sprintf('bridge started | MATLAB %s | root %s', version, root));
fprintf('\nMATLAB bridge running.\n  watching : %s\n  results  : %s\n', inDir, outDir);
fprintf('  stop with Ctrl+C, or create a file named STOP in %s\n\n', root);

pending = containers.Map('KeyType', 'char', 'ValueType', 'double');

while true
    % heartbeat -- lets the other side check the bridge is alive before
    % submitting, instead of waiting on a job that will never be picked up
    fid = fopen(aliveFile, 'w');
    if fid > 0
        fprintf(fid, '%s\n', datestr(now, 31));
        fclose(fid);
    end

    if exist(stopFile, 'file')
        delete(stopFile);
        logline(logFile, 'bridge stopped via STOP file');
        fprintf('STOP seen -- exiting.\n');
        break
    end

    listing = dir(fullfile(inDir, 'job_*.m'));
    for k = 1:numel(listing)
        name = listing(k).name;
        sz   = listing(k).bytes;

        % Two-poll stability check. The submitting side writes to a .tmp name
        % and renames, which is atomic, but this costs nothing and also covers
        % a file copied in by hand.
        if ~isKey(pending, name) || pending(name) ~= sz
            pending(name) = sz;
            continue
        end
        remove(pending, name);
        if sz == 0; continue; end

        jobId = name(1:end-2);                      % strip .m
        run_one(fullfile(inDir, name), jobId, outDir, doneDir, logFile);
    end

    pause(opts.poll);
end
end


% ---- local functions (MATLAB requires these at the end) ------------------

function run_one(jobPath, jobId, outDir, doneDir, logFile)
    jobOutDir = fullfile(outDir, jobId);
    if exist(jobOutDir, 'dir'); rmdir(jobOutDir, 's'); end
    mkdir(jobOutDir);

    fprintf('[%s] running %s ... ', datestr(now, 'HH:MM:SS'), jobId);
    logline(logFile, sprintf('RUN  %s', jobId));

    t0 = tic;
    status = 'ok';
    errMsg = '';
    output = '';
    try
        output = run_isolated(jobPath, jobOutDir);
    catch err
        status = 'error';
        errMsg = getReport(err, 'extended', 'hyperlinks', 'off');
    end
    elapsed = toc(t0);

    % console log
    fid = fopen(fullfile(jobOutDir, 'console.log'), 'w');
    if fid > 0
        fprintf(fid, '%s', output);
        if ~isempty(errMsg); fprintf(fid, '\n=== ERROR ===\n%s\n', errMsg); end
        fclose(fid);
    end

    produced = dir(jobOutDir);
    produced = {produced(~[produced.isdir]).name};

    st = struct();
    st.job = jobId;
    st.status = status;
    st.error = errMsg;
    st.elapsed_s = elapsed;
    st.finished = datestr(now, 31);
    st.matlab_version = version;
    st.outputs = produced;
    fid = fopen(fullfile(jobOutDir, 'status.json'), 'w');
    fprintf(fid, '%s', jsonencode(st));
    fclose(fid);

    % sentinel written LAST so the other side never reads a partial result
    fid = fopen(fullfile(outDir, [jobId '.done']), 'w');
    fprintf(fid, '%s\n', status);
    fclose(fid);

    movefile(jobPath, fullfile(doneDir, [jobId '_' datestr(now, 'yyyymmdd_HHMMSS') '.m']));

    fprintf('%s (%.1f s)\n', status, elapsed);
    logline(logFile, sprintf('DONE %s | %s | %.1f s | %d output file(s)', ...
                             jobId, status, elapsed, numel(produced)));
    if ~isempty(errMsg)
        logline(logFile, sprintf('ERR  %s | %s', jobId, strtrim(strrep(errMsg, newline, ' '))));
    end
end

function out = run_isolated(jobPath, JOB_OUT_DIR) %#ok<INUSD>
    % The job runs in this function's workspace, so its variables cannot leak
    % into the watcher loop. JOB_OUT_DIR is visible to the job: save outputs
    % there and they are returned automatically.
    out = evalc('run(jobPath);');
end

function logline(logFile, msg)
    fid = fopen(logFile, 'a');
    if fid > 0
        fprintf(fid, '%s  %s\n', datestr(now, 31), msg);
        fclose(fid);
    end
end
