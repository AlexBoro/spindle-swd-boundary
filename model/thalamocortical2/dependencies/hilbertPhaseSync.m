function [phaseSyncInd, phaseSyncInd_t, phase1, phase2, phaseDiff] = hilbertPhaseSync(signal1, signal2, averagingWindowSize, raster1, raster2)
% [phaseSyncInd, phaseSyncInd_t, phase1, phase2, phaseDiff] = hilbertPhaseSync(signal1, signal2, averagingWindowSize, raster1, raster2)
%
% Function calculates Hilbert phase synchronisation measures.
% Input: signal1, signal2
%        averagingWindowSize - averaging window size used when calculating
%                              the evolution of Hilbert phase
%                              synchronisation index over time. Default is
%                              100.
%        raster1 - raster vector corresponding to signal1. Use this input
%                  variable if you want to zero out periods with no spikes.
%                  In this case phaseSyncInd_t, phase1, and phaseDiff
%                  variables will contain zeros corresponding to periods
%                  with no spikes. By default, all periods are assumed to
%                  contain spikes.
%        raster2 - raster vector corresponding to signal2. Use this input
%                  variable if you want to zero out periods with no spikes.
%                  In this case phaseSyncInd_t, phase2, and phaseDiff
%                  variables will contain zeros corresponding to periods
%                  with no spikes. By default, all periods are assumed to
%                  contain spikes.
% Output: phaseSyncInd - Hilbert phase synchronisation index.
%         phaseSyncInd_t - Hilbert phase synchronisation index over time.
%         phase1 - phase of signal1 estimated using Hilbert transform.
%         phase2 - phase of signal2 estimated using Hilbert transform.
%         phaseDiff - phase of signal1 with regards to signal2. Positive
%                     phase means signal1 is preceding signal2.

signal1 = torow(signal1);
signal2 = torow(signal2);
assert(numel(signal1) == numel(signal2));

if nargin < 5
    raster2 = ones(size(signal2));
end
if nargin < 4
    raster1 = ones(size(signal1));
end
if nargin < 3
    averagingWindowSize = 100;
end

% Estimate phase using Hilbert transform
[~, phase1] = hilbertTransform(signal1-mean(signal1));
phase1 = recentrePhase(phase1, 0);
[~, phase2] = hilbertTransform(signal2-mean(signal2));
phase2 = recentrePhase(phase2, 0);

% Calculate Hilbert phase synchronisation index
phaseDiff = recentrePhase(phase2 - phase1, 0);
phaseSyncInd = sqrt(mean(cos(phaseDiff))^2 + mean(sin(phaseDiff))^2);

% Calculate the evolution of Hilbert phase synchronisation index over time
phaseDiffCos = smoothdata(cos(phaseDiff), 'movmean', averagingWindowSize);
phaseDiffSin = smoothdata(sin(phaseDiff), 'movmean', averagingWindowSize);
phaseSyncInd_t = sqrt(phaseDiffCos.^2 + phaseDiffSin.^2);

% Disqualify empty data windows
if nargin >= 4 && (sum(raster1, 'omitnan') < numel(raster1) || sum(raster2, 'omitnan') < numel(raster2))
    emptyData1 = ~logical(smoothdata(raster1, 'movmean', averagingWindowSize));
    emptyData2 = ~logical(smoothdata(raster2, 'movmean', averagingWindowSize));
    phaseSyncInd_t(emptyData1 | emptyData2) = NaN;
    phase1(emptyData1) = NaN;
    phase2(emptyData2) = NaN;
    phaseDiff(emptyData1 | emptyData2) = NaN;
end