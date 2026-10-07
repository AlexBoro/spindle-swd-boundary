function [FR, TR, BR, vecFR, vecTR, vecBR] = frCalc(raster, t, eegSpikes, eegWaves, ISI)
% [FR, TR, BR, vecFR, vecTR, vecBR] = frCalc(raster, t, eegSpikes, eegWaves)
%
% Function calculates cell firing rate fractions associated with SWCs:
% total, tonic, and bursting.
% Input: raster - cell spiking vector.
%        t - a corresponding time vector.
%        eegSpikes - EEG spike times.
%        eegWaves - EEG wave times.
%        ISI - the maximum interval between two consecutive spikes for them
%              to be considered as part of the same burst.
% Output: FR - fraction of times when the cell fires during a SWC.
%         TR - fraction of times when the cell tonically fires during a SWC.
%         BR - fraction of times when the cell bursts during a SWC.
%         vecFR - a vector showing when the cell fired during a SWC.
%         vecTR - a vector showing when the cell fired a single spike
%                 during a SWC.
%         vecBR - a vector showing when the cell fired a burst of action
%                 potentials during a SWC.

vecFR = zeros(size(eegSpikes));
vecBR = zeros(size(eegSpikes));
vecTR = zeros(size(eegSpikes));
for i = 1:length(eegSpikes)
    leftWaves = eegWaves(eegWaves < eegSpikes(i));
    rightWaves = eegWaves(eegWaves > eegSpikes(i));
    spikeVicATM = max(leftWaves):min(rightWaves);
    rasterROI = raster(spikeVicATM);
    tROI = t(spikeVicATM);
    tROI = tROI(logical(rasterROI));
    if length(tROI) > 1
        for j = 2:length(tROI)
            if tROI(j)-tROI(j-1) <= ISI
                vecBR(i) = 1;
                vecTR(i) = 0;
                break
            else
                vecTR(i) = 1;
            end
        end
    elseif length(tROI) == 1
        vecTR(i) = 1;
    else
        vecFR(i) = 1;
    end
end
FR = (numel(eegSpikes) - sum(vecFR))/numel(eegSpikes);
BR = sum(vecBR)/numel(eegSpikes);
TR = sum(vecTR)/numel(eegSpikes);