% make_reference.m
% Generate reference output from the ORIGINAL MATLAB detectEEGspikesSWDs.m,
% for validating the Python port (criterion C6.1 in docs/acceptance_criteria.md).
%
% HOW TO RUN
%   1. Open MATLAB and cd to this folder.
%   2. >> make_reference
%   3. Send back the file swd_reference.mat that it writes here.
%
% Needs the Signal Processing Toolbox (butter, filtfilt, findpeaks, gausswin).
% detectEEGspikesSWDs.m sets showFigs = false internally, so nothing is plotted.
% Runs in well under a minute.

clear; close all;
fprintf('MATLAB %s\n', version);
assert(exist('detectEEGspikesSWDs', 'file') == 2, 'detectEEGspikesSWDs.m not on path');
assert(exist('oscFreq', 'file') == 2, 'oscFreq.m not on path');

rng(42, 'twister');   % fixed seed -- the port regenerates these traces identically

% ---- cases ---------------------------------------------------------------
% Each pins a documented behaviour of the detector rather than merely looking
% realistic. Episodes are [start_s end_s] pairs; amplitudes are in units of the
% baseline noise SD, which is what the 1 and 1.96 SD thresholds are measured in.

cases = struct('name', {}, 'EEG', {}, 'dt', {}, 'edgeOverlap', {}, ...
               'oscType', {}, 'note', {});
c = 0;

c = c + 1;
cases(c).name = 'three_swds';   cases(c).dt = 1.0;  cases(c).edgeOverlap = false;
cases(c).oscType = 'SWDs_human';
cases(c).EEG = swd_trace(90, 1.0, [10 15; 35 43; 60 64], 4.5, [6 8 5], 1);
cases(c).note = 'three episodes of 5, 8 and 4 s -- all exceed minSWD = 3 s';

c = c + 1;
cases(c).name = 'noise_only';   cases(c).dt = 1.0;  cases(c).edgeOverlap = false;
cases(c).oscType = 'SWDs_human';
cases(c).EEG = randn(1, 60000);
cases(c).note = 'pure noise -- expect no SWDs';

c = c + 1;
cases(c).name = 'short_episodes';   cases(c).dt = 1.0;  cases(c).edgeOverlap = false;
cases(c).oscType = 'SWDs_human';
cases(c).EEG = swd_trace(60, 1.0, [10 12; 30 31.5; 45 46.8], 4.5, [7 7 7], 1);
cases(c).note = 'episodes of 2, 1.5 and 1.8 s -- below minSWD, expect elimination';

c = c + 1;
cases(c).name = 'edge_overlap_false';   cases(c).dt = 1.0;  cases(c).edgeOverlap = false;
cases(c).oscType = 'SWDs_human';
cases(c).EEG = swd_trace(60, 1.0, [0 6; 25 31; 54 60], 4.5, [7 7 7], 1);
cases(c).note = 'episodes touching both record edges, edgeOverlap = false';

c = c + 1;
cases(c).name = 'edge_overlap_true';   cases(c).dt = 1.0;  cases(c).edgeOverlap = true;
cases(c).oscType = 'SWDs_human';
cases(c).EEG = cases(c-1).EEG;   % identical trace, opposite flag
cases(c).note = 'same trace as edge_overlap_false; true is what the repo callers use';

c = c + 1;
cases(c).name = 'mixed_amplitude';   cases(c).dt = 1.0;  cases(c).edgeOverlap = false;
cases(c).oscType = 'SWDs_human';
cases(c).EEG = swd_trace(90, 1.0, [12 18; 40 47; 68 74], 4.5, [1.2 3 8], 1);
cases(c).note = 'amplitudes straddle the 1 SD and 1.96 SD thresholds';

c = c + 1;
cases(c).name = 'fine_dt';   cases(c).dt = 0.25;  cases(c).edgeOverlap = false;
cases(c).oscType = 'SWDs_human';
cases(c).EEG = swd_trace(40, 0.25, [8 14; 25 30], 4.5, [7 7], 1);
cases(c).note = 'dt = 0.25 ms, the model integration step';

c = c + 1;
cases(c).name = 'seven_hz';   cases(c).dt = 1.0;  cases(c).edgeOverlap = false;
cases(c).oscType = 'SWDs_rodent';
cases(c).EEG = swd_trace(60, 1.0, [10 17; 35 42], 7.0, [7 7], 1);
cases(c).note = 'rodent-like ~7 Hz intra-SWD frequency';

% ---- run -----------------------------------------------------------------
outNames = {'eegSpikes','eegSpikesSWD','eegSpikesT','eegSpikesLocs','eegSpikesLocsSWD', ...
            'eegSpikesLarge','eegSpikesLargeSWD','eegSpikesLargeT','eegSpikesLargeLocs', ...
            'eegSpikesLargeLocsSWD','tWaves','waveLocs','tWavesLarge','waveLocsLarge', ...
            'SWDs','SWDsLarge','phase','SWCs','phaseLarge','SWCsLarge','interictal', ...
            'interictalLarge','maxPowerFrequency'};
iSWDs = find(strcmp(outNames, 'SWDs'));
iFreq = find(strcmp(outNames, 'maxPowerFrequency'));

reference = struct();
for k = 1:numel(cases)
    fprintf('[%d/%d] %-20s ', k, numel(cases), cases(k).name);
    out = cell(1, numel(outNames));
    [out{:}] = detectEEGspikesSWDs(cases(k).EEG, cases(k).dt, cases(k).edgeOverlap);

    r = struct();
    r.EEG = cases(k).EEG;
    r.dt = cases(k).dt;
    r.edgeOverlap = cases(k).edgeOverlap;
    r.oscType = cases(k).oscType;
    r.note = cases(k).note;
    for j = 1:numel(outNames)
        r.(outNames{j}) = out{j};
    end
    try
        [r.oscFreq_frequency, r.oscFreq_maxPower] = ...
            oscFreq(cases(k).EEG, cases(k).dt, cases(k).oscType);
    catch err
        r.oscFreq_error = err.message;
    end
    reference.(cases(k).name) = r;

    sw = out{iSWDs};
    fprintf('%d SWD(s), maxPowerFrequency = %.4g Hz\n', ...
            numel(unique(sw(sw > 0))), out{iFreq});
end

reference_meta = struct();
reference_meta.matlab_version = version;
reference_meta.created = datestr(now, 31);
reference_meta.rng_seed = 42;
reference_meta.output_names = outNames;      % cell assigned after construction
reference_meta.case_names = {cases.name};

save('swd_reference.mat', 'reference', 'reference_meta', '-v7');
info = dir('swd_reference.mat');
fprintf('\nWrote swd_reference.mat (%.1f MB). Send this file back.\n', info.bytes / 1e6);


% ---- local functions (MATLAB requires these at the END of a script) -------
function x = swd_trace(dur_s, dt_ms, episodes, spike_hz, amp_sd, noise_sd)
    % Negative spike-and-wave episodes on a noisy baseline. The detector looks
    % for NEGATIVE deflections past 1 and 1.96 SD of the baseline.
    fs = 1000 / dt_ms;
    n  = round(dur_s * fs);
    x  = noise_sd * randn(1, n);
    for e = 1:size(episodes, 1)
        i0 = max(1, round(episodes(e,1) * fs) + 1);
        i1 = min(round(episodes(e,2) * fs), n);
        tt = (i0:i1) / fs;
        wave = 0.4 * amp_sd(e) * sin(2*pi*spike_hz*tt);
        spk  = zeros(1, numel(tt));
        spk(1:round(fs / spike_hz):end) = -amp_sd(e);
        spk  = conv(spk, gausswin(max(3, round(0.004*fs))), 'same');
        x(i0:i1) = x(i0:i1) + wave + spk;
    end
end
