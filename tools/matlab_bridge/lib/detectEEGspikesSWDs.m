function [eegSpikes, eegSpikesSWD, eegSpikesT, eegSpikesLocs, eegSpikesLocsSWD, eegSpikesLarge, eegSpikesLargeSWD,...
    eegSpikesLargeT, eegSpikesLargeLocs, eegSpikesLargeLocsSWD, tWaves, waveLocs, tWavesLarge, waveLocsLarge, SWDs,...
    SWDsLarge, phase, SWCs, phaseLarge, SWCsLarge, interictal, interictalLarge, maxPowerFrequency] = detectEEGspikesSWDs(EEG, dt, edgeOverlap)
% [eegSpikes, eegSpikesSWD, eegSpikesT, eegSpikesLocs, eegSpikesLocsSWD, eegSpikesLarge, eegSpikesLargeSWD,...
%   eegSpikesLargeT, eegSpikesLargeLocs, eegSpikesLargeLocsSWD, tWaves, waveLocs, tWavesLarge, waveLocsLarge, SWDs,...
%   SWDsLarge, phase, SWCs, phaseLarge, SWCsLarge, interictal, interictalLarge, maxPowerFrequency] = detectEEGspikesSWDs(EEG, dt, edgeOverlap)
%
% Function detects EEG SWDs and related spikes.
% Input: EEG - EEG vector.
%        dt - EEG sampling rate in ms.
%        edgeOverlap - if set to be false, SWDs and interictal periods
%                      overlaping with data start and end points are
%                      unmarked. Default is false.
% Output: eegSpikes - a vector of the input EEG vector size marking SWD
%                     spike locations by ones.
%         eegSpikesSWD - a vector of the input EEG vector size marking SWD
%                     spike locations by SWD number.
%         eegSpikesT - EEG spike times.
%         eegSpikesLocs - EEG spike indices.
%         eegSpikesLocsSWD - EEG spike SWD numbers.
%         eegSpikesLarge - EEG spikes exceeding 1.96 standard deviations
%                          relative to the baseline of the EEG signal.
%                          Other related output vectors include
%                          eegSpikesLargeSWD, eegSpikesLargeT,
%                          eegSpikesLargeLocs, and eegSpikesLargeLocsSWD.
%         tWaves - wave times within SWD boundaries.
%         waveLocs - corresponding wave indices.
%         tWaves - wave times within SWD boundaries demarcated by large
%                  spikes exceeding 1.96 SD relative to the baseline.
%         waveLocsLarge - corresponding wave indices.
%         SWDs - a vector of the input EEG vector size marking SWD
%                locations by SWD number.
%         SWDsLarge - a vector of the input EEG vector size marking SWD
%                     locations by SWD number (demarcated only by spikes
%                     exceeding 1.96 SD). Other corresponding output
%                     variables are phaseLarge and SWCsLarge.
%         phase - phases of SWCs. The vector length is the same as the EEG
%                 signal. Phases outside the SWCs are indicated by NaNs.
%         SWCs - Actual SWC number. The vector length is the same as that
%                of the EEG signal. Times outside SWCs are indicated by
%                NaNs.
%         phaseLarge - same as phase but for large SWCs. There is also
%                      SWCsLarge output variable.
%         interictal - same as SWDs but instead marking consecutive
%                      interictal periods.
%         interictalLarge - same as SWDsLarge but instead marking
%                           consecutive interictal periods between
%                           SWDsLarge.
%         maxPowerFrequency - SWD frequency.
%
% SWD detection algorithm works first by detecting the filtered EEG signal
%   baseline. Negative spikes exceeding 1 and 1.96 standard deviation of
%   the EEG signal relative to the baseline and spaced by at least 1 cycle
%   distance from each other are then marked. Lone spikes separated by at
%   least 3 seconds are eliminated. Groupings of spikes smaller than 1.5
%   seconds are also eliminated. The next step is to find individual large
%   (> 1.96 SD relative to baseline) spike clusters that have durations of
%   at least 3 seconds. Smaller clusters are eliminated. The remaining
%   clusters are marked as individual SWDs. Spikes identified in earlier
%   stages are than associated with SWDs. Phase of SWCs is also estimated,
%   as well as SWC number. The same procedure is repeated for SWDs that
%   include only spikes exceeding 1.96 standard deviations.


if nargin < 3
    edgeOverlap = false;
end


%% Local parameters
showFigs = false;
minSWD = 3;


%% Butterworth filter the EEG signal
if exist('filter.mat', 'file')
    load('filter.mat'); %#ok<*LOAD>
else
    Rp = 0.5;                                                               % Passband riple, dB
    Rs = 10;                                                                % Stopband attenuation, dB
    NyqFreq = (1000/dt)/2;                                                  % The Nyquist frequency
    Wp = 8/NyqFreq;
    Ws = 12/NyqFreq;
    [n, Wn] = buttord(Wp, Ws, Rp, Rs);                                      % n is a filter order
    [b, a] = butter(n, Wn, 'low');
end
EEGfilt = filtfilt(double(b), double(a), EEG);


%% Estimate the oscilation frequency
[maxPowerFrequency, maxPower, f, powerDBfilt] = oscFreq(EEGfilt, dt, 'SWDs_human');
cycle = (1000/maxPowerFrequency)*1.1;

% Plot power and mark the estimated oscilation frequency
if showFigs
    figure
    semilogx(f, powerDBfilt)
    hold on
    semilogx(maxPowerFrequency, maxPower, 'r.', 'MarkerSize',10)
    hold off
    title('Low-pass filtered EEG power and oscillation frequency');
    set(gcf, 'Name','Low-pass filtered EEG power and oscillation frequency');
end


%% Band-pass filter the EEG signal
passbandRipple = 0.5;
stopbandAttenuation = 16;
bandWidth = [maxPowerFrequency maxPowerFrequency maxPowerFrequency maxPowerFrequency maxPowerFrequency] + [-0.75 -0.5 0 0.5 0.75];
dBP = designFilterBP(bandWidth', stopbandAttenuation, passbandRipple, stopbandAttenuation, 1000/dt);
EEGfiltBP = filtfilt(dBP, EEG);
if showFigs
    figure; plot(EEG); hold on; plot(EEGfiltBP); hold off
    title('Band-pass filtered EEG signal');
    set(gcf, 'Name','Band-pass filtered EEG signal');
end


%% Calculate descriptive stats
meanEEGfilt = mean(EEGfiltBP); %#ok<*NASGU>
medianEEG = median(EEG);
medianEEGfilt = median(EEGfiltBP);
modeEEG = mode(EEG);
modeEEGfilt = mode(EEGfiltBP);
sdEEG = std(EEG);
%sdEEGfilt = std(EEGfiltBP);
sdEEGfilt = 1.28074765136489;


%% Estimate the baseline and standard deviation of the signal
range = [floor(min(EEGfiltBP)) ceil(max(EEGfiltBP))];
edges = range(1):0.0001:range(2);
[voltageValues, edges] = histcounts(EEGfiltBP, edges);
centres = edges(1:end-1) + (edges(2)-edges(1))/2;
[~, iMostCommon] = max(voltageValues);
%baseline = centres(iMostCommon);
f = fit(centres.',voltageValues.','gauss1');
gaussFit = f.a1*exp(-((centres-f.b1)./f.c1).^2);
sdBaseline = f.c1;
baseline = f.b1;
%lowCI95baseline = baseline - norminv(1-0.05/2)*sdBaseline;
lowSDeeg = baseline - sdEEGfilt;
lowCI95eeg = baseline - norminv(1-0.05/2)*sdEEGfilt;
lowCI99eeg = baseline - norminv(1-0.01/2)*sdEEGfilt;
%lowSD6 = baseline - 6*sdBaseline;

% Plot filtered EEG voltage values and fit a Gaussian function
if showFigs
    figure %#ok<*UNRCH>
    plot(centres, voltageValues)
    hold on
    plot(centres, gaussFit)
    hold off
    title('Low-pass filtered EEG values');
    set(gcf, 'Name','Low-pass filtered EEG values');
end


%% Detect and threshold the EEG spikes
t = (dt:dt:numel(EEGfiltBP)*dt)./1000;
[tPks, pks, pksLocs] = thPks(t, dt, cycle, EEGfiltBP, lowSDeeg);
[tPks95, pks95, pksLocs95] = thPks(t, dt, cycle, EEGfiltBP, lowCI95eeg);
[tPks99, pks99, pksLocs99] = thPks(t, dt, cycle, EEGfiltBP, lowCI99eeg); %#ok<*ASGLU>
[tPksLP, pksLP, pksLocsLP] = thPks(t, dt, cycle, EEGfilt, lowSDeeg);


%% Eliminate EEG spikes
[tPksGrp, pksGrp, pksLocsGrp] = eliminatePks(tPks, pks, pksLocs, 1.5*cycle/1000); % Eliminate peaks separated by more than a cycle from their neighbours
%[tPksGrp2, pksGrp2, pksLocsGrp2] = eliminatePks2(tPksGrp, pksGrp, pksLocsGrp, minSWD/2,...
%    floor((minSWD/2)*maxPowerFrequency)); % Eliminate peaks that do not form a 3 second-long sequence of peaks
tPksGrp2 = tPksGrp; pksGrp2 = pksGrp; pksLocsGrp2 = pksLocsGrp;
[tPksGrp95, pksGrp95, pksLocsGrp95] = eliminatePks(tPks95, pks95, pksLocs95, 1.5*cycle/1000); % Eliminate large peaks separated by more than a cycle from their neighbour large peaks
%[tPksGrp99, pksGrp99, pksLocsGrp99] = eliminatePks(tPks99, pks99, pksLocs99, 1.5*cycle/1000); % Eliminate extra large peaks separated by more than a cycle from their neighbour large peaks
tPksGrp99 = tPksGrp95; pksGrp99 = pksGrp95; pksLocsGrp99 = pksLocsGrp95;


%% Identify individual spike clusters equal to or longer than minSWD (i.e., 3 secs)
t = (dt:dt:numel(EEGfilt)*dt)./1000;
k = numel(tPksGrp2); %min([numel(tPksGrp2) ceil((t(end)/1000)*120)]);
if isempty(tPksGrp2)
    if isempty(tPksGrp95)
        eegSpikes = [];
        eegSpikesSWD = [];
        eegSpikesT = [];
        eegSpikesLocs = [];
        eegSpikesLocsSWD = [];
        eegSpikesLarge = [];
        eegSpikesLargeSWD = [];
        eegSpikesLargeT = [];
        eegSpikesLargeLocs = [];
        eegSpikesLargeLocsSWD = [];
        tWaves = [];
        waveLocs = [];
        tWavesLarge = [];
        waveLocsLarge = [];
        SWDs = [];
        SWDsLarge = [];
        phase = [];
        SWCs = [];
        phaseLarge = [];
        SWCsLarge = [];
        interictal = ones(size(EEGfilt));
        interictalLarge = ones(size(EEGfilt));
    else
        eegSpikes = zeros(size(EEGfilt));
        eegSpikes(pksLocsGrp95) = 1;
        eegSpikesSWD = [];
        eegSpikesT = tPksGrp95;
        eegSpikesLocs = pksLocsGrp95;
        eegSpikesLocsSWD = [];
        eegSpikesLarge = [];
        eegSpikesLargeSWD = [];
        eegSpikesLargeT = tPksGrp95;
        eegSpikesLargeLocs = pksLocsGrp95;
        eegSpikesLargeLocsSWD = [];
        tWaves = [];
        waveLocs = [];
        tWavesLarge = [];
        waveLocsLarge = [];
        SWDs = [];
        SWDsLarge = [];
        phase = [];
        SWCs = [];
        phaseLarge = [];
        SWCsLarge = [];
        interictal = [];
        interictalLarge = [];
    end
    return
else
    clusterIDs = kmeans(tPksGrp2',k)';
    for cl = 1:numel(clusterIDs)-1
        if tPksGrp2(cl+1)-tPksGrp2(cl) <= minSWD/2 %1.5*cycle/1000 % minimum cluster separation is 1.5 oscilation cycles
            clusterIDs(cl+1) = clusterIDs(cl);
        end
    end
end

% Remove clusters shorter than 3 seconds
clusters2remove = zeros(1,numel(clusterIDs));
clusters = unique(clusterIDs);
for cl = 1:numel(clusters)
    clOI = zeros(1,numel(clusterIDs));
    clOI(clusterIDs == clusters(cl)) = 1;
    tOI = tPksGrp2(logical(clOI));
    tOI = tPksGrp95(tPksGrp95 >= tOI(1) & tPksGrp95 <= tOI(end));
    if isempty(tOI) || tOI(end) - tOI(1) + dt/1000 < minSWD
        clusters2remove(logical(clOI)) = 1;
        continue
    end
%     spikeCount = 1;
%     spikeCountMax = spikeCount;
%     for iSpike = 1:numel(tOI)-1
%         if tOI(iSpike+1) - tOI(iSpike) < (cycle/1000)
%             spikeCount = spikeCount + 1;
%         else
%             if spikeCount > spikeCountMax
%                 spikeCountMax = spikeCount;
%                 spikeCount = 1;
%             else
%                 spikeCount = 1;
%             end
%         end
%         if spikeCount >= (minSWD*(1))/(cycle/1000) || spikeCountMax >= (minSWD*(1))/(cycle/1000)
%             break
%         elseif iSpike == numel(tOI)-1
%             clusters2remove(logical(clOI)) = 1;
%         end
%     end
    
    tOI = tPksGrp2(logical(clOI));
    tOI = tPksGrp99(tPksGrp99 >= tOI(1) & tPksGrp99 <= tOI(end));
    if isempty(tOI) || tOI(end) - tOI(1) + dt/1000 < minSWD/2
        clusters2remove(logical(clOI)) = 1;
        continue
    end
    spikeCount = 1;
    spikeCountMax = spikeCount;
    for iSpike = 1:numel(tOI)-1
        if tOI(iSpike+1) - tOI(iSpike) < (cycle/1000)
            spikeCount = spikeCount + 1;
        else
            if spikeCount > spikeCountMax
                spikeCountMax = spikeCount;
                spikeCount = 1;
            else
                spikeCount = 1;
            end
        end
        if spikeCount >= (minSWD*(1/4))/(cycle/1000) || spikeCountMax >= (minSWD*(1/4))/(cycle/1000)
            break
        elseif iSpike == numel(tOI)-1
            clusters2remove(logical(clOI)) = 1;
        end
    end
end
clusterIDs = clusterIDs(~clusters2remove);
tPksGrp2 = tPksGrp2(~clusters2remove);
pksGrp2 = pksGrp2(~clusters2remove);
pksLocsGrp2 = pksLocsGrp2(~clusters2remove);
if isempty(clusterIDs)
    eegSpikes = [];
    eegSpikesSWD = [];
    eegSpikesT = [];
    eegSpikesLocs = [];
    eegSpikesLocsSWD = [];
    eegSpikesLarge = [];
    eegSpikesLargeSWD = [];
    eegSpikesLargeT = [];
    eegSpikesLargeLocs = [];
    eegSpikesLargeLocsSWD = [];
    tWaves = [];
    waveLocs = [];
    tWavesLarge = [];
    waveLocsLarge = [];
    SWDs = [];
    SWDsLarge = [];
    phase = [];
    SWCs = [];
    phaseLarge = [];
    SWCsLarge = [];
    interictal = ones(size(EEGfilt));
    interictalLarge = ones(size(EEGfilt));
    return
end

% Remove large peaks that are not part of the remaining clusters
spks2remove = zeros(1,numel(tPksGrp95));
for cl = 1:numel(tPksGrp95)
    if ~sum(tPksGrp95(cl) == tPksGrp2)
        spks2remove(cl) = 1;
    end
end
tPksGrp95 = tPksGrp95(~spks2remove);
pksGrp95 = pksGrp95(~spks2remove);
pksLocsGrp95 = pksLocsGrp95(~spks2remove);

% Reorder clusters
clusterIDsReordered = zeros(1,numel(clusterIDs));
clusters = unique(clusterIDs, 'stable');
for cl = 1:numel(clusters)
    clusterOI = zeros(1,numel(clusterIDs));
    clusterOI(clusterIDs == clusters(cl)) = 1;
    clusterIDsReordered(logical(clusterOI)) = cl;
end

clusterIDsReorderedLarge = zeros(1,numel(pksLocsGrp95));
for iSpike = 1:numel(pksLocsGrp95)
    [~, loc] = find(pksLocsGrp95(iSpike) == pksLocsGrp2);
    clusterIDsReorderedLarge(iSpike) = clusterIDsReordered(loc);
end


%% Detect EEG waves
[~, waveLocsTemp] = findpeaks(EEGfilt, 'MinPeakDistance',ceil(cycle/2/dt));
wavesTemp = EEGfilt(waveLocsTemp);
tWavesTemp = t(waveLocsTemp);


%% Find EEG signal phase
[~, phaseTemp] = hilbertTransform(-EEGfiltBP);
phaseTemp = recentrePhase(phaseTemp, 0);

% Plot filtered EEG phase
if showFigs
    figure; plot(phaseTemp); hold on
    plot(EEGfilt); hold off
    title('Filtered EEG phase');
    set(gcf, 'Name','Filtered EEG phase');
end


%% Mark SWDs and associate them with spikes
SWDs = zeros(1,numel(EEGfilt));
SWDsLarge = zeros(1,numel(EEGfilt));
clusters = unique(clusterIDsReordered);
clustersLarge = unique(clusterIDsReorderedLarge);

% SWDs
for cl = 1:numel(clusters)
    pksLocsOI = pksLocsGrp2(clusterIDsReordered == clusters(cl));
    leftWaveLocs = waveLocsTemp(waveLocsTemp < pksLocsOI(1));
    if isempty(leftWaveLocs)
        startSWD = 1;
    else
        startSWD = max(leftWaveLocs);
    end
    rightWaveLocs = waveLocsTemp(waveLocsTemp > pksLocsOI(end));
    if isempty(rightWaveLocs)
        endSWD = numel(SWDs);
    else
        endSWD = min(rightWaveLocs);
    end
    SWDs(startSWD:endSWD) = cl;
end

% Large SWDs
for cl = 1:numel(clustersLarge)
    pksLocsOI = pksLocsGrp95(clusterIDsReorderedLarge == clustersLarge(cl));
    leftWaveLocs = waveLocsTemp(waveLocsTemp < pksLocsOI(1));
    if isempty(leftWaveLocs)
        startSWD = 1;
    else
        startSWD = max(leftWaveLocs);
    end
    rightWaveLocs = waveLocsTemp(waveLocsTemp > pksLocsOI(end));
    if isempty(rightWaveLocs)
        endSWD = numel(SWDsLarge);
    else
        endSWD = min(rightWaveLocs);
    end
    SWDsLarge(startSWD:endSWD) = clustersLarge(cl);
end

% Interictal periods
interictal = zeros(1,numel(EEGfilt));
for cl = 1:numel(clusters)
    clOI = find(SWDs == cl);
    if cl == 1
        iStart = 1;
    else
        clOIprev = find(SWDs == cl-1);
        iStart = clOIprev(end) + 1;
    end
    iEnd = clOI(1) - 1;
    interictal(iStart:iEnd) = cl;
end
iStart = clOI(end) + 1;
if iStart <= numel(EEGfilt)
    interictal(iStart:numel(EEGfilt)) = cl+1;
end

% Large interictal periods
interictalLarge = zeros(1,numel(EEGfilt));
for cl = 1:numel(clustersLarge)
    clOI = find(SWDsLarge == cl);
    if cl == 1
        iStart = 1;
    else
        clOIprev = find(SWDsLarge == cl-1);
        iStart = clOIprev(end) + 1;
    end
    iEnd = clOI(1) - 1;
    interictalLarge(iStart:iEnd) = cl;
end
iStart = clOI(end) + 1;
if iStart <= numel(EEGfilt)
    interictalLarge(iStart:numel(EEGfilt)) = cl+1;
end

% Spikes
pksLocs = false(1,numel(EEGfilt));
pksLocs(pksLocsLP) = true;
pksLocs(logical(interictal)) = false;
pksLocsLarge(logical(interictal)) = false;
tPks = t(pksLocs);
pks = EEGfilt(pksLocs);
pksLocs = find(pksLocs);
tPksLarge = t(pksLocsLarge);
pksLarge = EEGfilt(pksLocsLarge);
pksLocsLarge = find(pksLocsLarge);


%% Demarcate individual SWCs
SWCs = NaN(1,numel(EEGfilt));
SWCsLarge = NaN(1,numel(EEGfilt));
phase = NaN(1,numel(EEGfilt));
phaseLarge = NaN(1,numel(EEGfilt));
clusters = unique(clusterIDsReordered);

% SWCs
for swc = 1:numel(pksLocsGrp2)
    leftWaveLocs = waveLocsTemp(waveLocsTemp < pksLocsGrp2(swc));
    startSWC = max(leftWaveLocs);
    rightWaveLocs = waveLocsTemp(waveLocsTemp > pksLocsGrp2(swc));
    if swc == numel(pksLocsGrp2)
        endSWC = min(rightWaveLocs);
    else
        endSWC = min(rightWaveLocs) - 1;
    end
    SWCs(startSWC:endSWC) = swc;
    phase(startSWC:endSWC) = phaseTemp(startSWC:endSWC);
end

% Large SWCs
for swc = 1:numel(pksLocsGrp95)
    leftWaveLocs = waveLocsTemp(waveLocsTemp < pksLocsGrp95(swc));
    startSWC = max(leftWaveLocs);
    rightWaveLocs = waveLocsTemp(waveLocsTemp > pksLocsGrp95(swc));
    if swc == numel(pksLocsGrp95)
        endSWC = min(rightWaveLocs);
    else
        endSWC = min(rightWaveLocs) - 1;
    end
    SWCsLarge(startSWC:endSWC) = swc;
    phaseLarge(startSWC:endSWC) = phaseTemp(startSWC:endSWC);
end


%% Eliminate unwanted waves
waveLocsLogical = zeros(1,numel(EEGfilt));
waveLocsLogical(waveLocsTemp) = 1;
waveLocsLogical = logical(waveLocsLogical);
waveLocs = find(waveLocsLogical & logical(SWDs));
waves = EEGfilt(waveLocs); %#ok<*FNDSB>
tWaves = t(waveLocs);
waveLocsLarge = find(waveLocsLogical & logical(SWDsLarge));
wavesLarge = EEGfilt(waveLocsLarge); %#ok<*FNDSB>
tWavesLarge = t(waveLocsLarge);


%% Insert missing waves
for iSpike = 1:numel(pks)-1
    if isempty(waveLocs(waveLocs > pksLocs(iSpike) & waveLocs < pksLocs(iSpike+1)))
        [~, newWaveLoc] = max(EEGfilt(pksLocs(iSpike):pksLocs(iSpike+1)));
        waveLocs = [waveLocs(waveLocs < pksLocs(iSpike)) pksLocs(iSpike)+newWaveLoc-1 waveLocs(waveLocs > pksLocs(iSpike))];
    end
end
waves = EEGfilt(waveLocs);
tWaves = t(waveLocs);
waveLocsLogical = false(1,numel(EEGfilt));
waveLocsLogical(waveLocs) = true;

for iSpike = 1:numel(pksLarge)-1
    if isempty(waveLocs(waveLocsLarge > pksLocsLarge(iSpike) & waveLocsLarge < pksLocsLarge(iSpike+1)))
        [~, newWaveLoc] = max(EEGfilt(pksLocsLarge(iSpike):pksLocsLarge(iSpike+1)));
        waveLocsLarge = [waveLocsLarge(waveLocsLarge < pksLocsLarge(iSpike)) pksLocsLarge(iSpike)+newWaveLoc-1 waveLocsLarge(waveLocsLarge > pksLocsLarge(iSpike))];
    end
end
wavesLarge = EEGfilt(waveLocsLarge);
tWavesLarge = t(waveLocsLarge);
waveLocsLargeLogical = false(1,numel(EEGfilt));
waveLocsLargeLogical(waveLocsLarge) = true;


%% Assign output variables
eegSpikes = zeros(1,numel(EEG));
eegSpikes(pksLocs) = 1;
eegSpikesSWD = zeros(1,numel(EEG));
eegSpikesSWD(pksLocs) = SWDs(pksLocs);
eegSpikesT = tPks;
eegSpikesLocs = pksLocs;
eegSpikesLocsSWD = SWDs(pksLocs);

eegSpikesLarge = zeros(1,numel(EEG));
eegSpikesLarge(pksLocsLarge) = 1;
eegSpikesLargeSWD = zeros(1,numel(EEG));
eegSpikesLargeSWD(pksLocsLarge) = SWDs(pksLocsLarge);
eegSpikesLargeT = tPksLarge;
eegSpikesLargeLocs = pksLocsLarge;
eegSpikesLargeLocsSWD = SWDs(pksLocsLarge);


%% Plot SWDs
if showFigs
    figure
    plot(t, EEGfiltBP)
    hold on
    pBase = plot(t, ones(1, numel(EEGfiltBP))*baseline);
    pSD = plot(t, ones(1, numel(EEGfiltBP))*lowSDeeg);
    p95 = plot(t, ones(1, numel(EEGfiltBP))*lowCI95eeg);
    plot(tWaves, EEGfiltBP(waveLocs), 'c.', 'MarkerSize',10)
    plot(tPksGrp, pksGrp, 'r.', 'MarkerSize',10)
    plot(tPksGrp95, pksGrp95, 'ro', 'MarkerSize',10)
    plot(tPksGrp2, pksGrp2, 'go', 'MarkerSize',15)
    for cl = 1:numel(clusters)
        tOI = tPksGrp2(clusterIDsReordered == clusters(cl));
        yLim = ylim;
        ciplot([yLim(1) yLim(1)], [yLim(2) yLim(2)], [tOI(1) tOI(end)], 'r', 0.15);
    end
    legend([pBase, pSD, p95], {'Baseline', 'SD', '95% conf'})
    hold off
    title('Clusters with band-pass filtered EEG');
    set(gcf, 'Name','Clusters with band-pass filtered EEG');
    
    figure
    plot(t, EEGfiltBP)
    hold on
    pBase = plot(t, ones(1, numel(EEGfiltBP))*baseline);
    pSD = plot(t, ones(1, numel(EEGfiltBP))*lowSDeeg);
    p95 = plot(t, ones(1, numel(EEGfiltBP))*lowCI95eeg);
    plot(tWaves, EEGfiltBP(waveLocs), 'c.', 'MarkerSize',10)
    plot(tPksGrp, pksGrp, 'r.', 'MarkerSize',10)
    plot(tPksGrp95, pksGrp95, 'ro', 'MarkerSize',10)
    plot(tPksGrp2, pksGrp2, 'go', 'MarkerSize',15)
    for cl = 1:numel(clusters)
        startSWD = find(SWDs == clusters(cl), 1);
        endSWD = find(SWDs == clusters(cl), 1, 'last');
        yLim = ylim;
        ciplot([yLim(1) yLim(1)], [yLim(2) yLim(2)], [t(startSWD) t(endSWD)], 'r', 0.15);
    end
    legend([pBase, pSD, p95], {'Baseline', 'SD', '95% conf'})
    hold off
    title('SWDs with band-pass filtered EEG');
    set(gcf, 'Name','SWDs with band-pass filtered EEG');
    
    figure
    plot(t, EEGfiltBP)
    hold on
    pBase = plot(t, ones(1, numel(EEGfiltBP))*baseline);
    pSD = plot(t, ones(1, numel(EEGfiltBP))*lowSDeeg);
    p95 = plot(t, ones(1, numel(EEGfiltBP))*lowCI95eeg);
    plot(tWavesLarge, EEGfiltBP(waveLocsLarge), 'c.', 'MarkerSize',10)
    plot(tPksGrp, pksGrp, 'r.', 'MarkerSize',10)
    plot(tPksGrp95, pksGrp95, 'ro', 'MarkerSize',10)
    plot(tPksGrp2, pksGrp2, 'go', 'MarkerSize',15)
    for cl = 1:numel(clustersLarge)
        startSWD = find(SWDsLarge == clustersLarge(cl), 1);
        endSWD = find(SWDsLarge == clustersLarge(cl), 1, 'last');
        if isempty(startSWD) || isempty(endSWD)
            continue
        end
        yLim = ylim;
        ciplot([yLim(1) yLim(1)], [yLim(2) yLim(2)], [t(startSWD) t(endSWD)], 'r', 0.15);
    end
    legend([pBase, pSD, p95], {'Baseline', 'SD', '95% conf'})
    hold off
    title('Large SWDs with band-pass filtered EEG');
    set(gcf, 'Name','Large SWDs with band-pass filtered EEG');
end

if showFigs
    figure
    plot(t, EEGfilt)
    hold on
    pBase = plot(t, ones(1, numel(EEGfilt))*baseline);
    pSD = plot(t, ones(1, numel(EEGfilt))*lowSDeeg);
    p95 = plot(t, ones(1, numel(EEGfilt))*lowCI95eeg);
    plot(tWaves, waves, 'c.', 'MarkerSize',10)
    plot(tPks, EEGfilt(pksLocs), 'r.', 'MarkerSize',10)
    plot(tPksLarge, EEGfilt(pksLocsLarge), 'ro', 'MarkerSize',10)
    plot(tPks, EEGfilt(pksLocs), 'go', 'MarkerSize',15)
    for cl = 1:numel(clusters)
        tOI = tPksGrp2(clusterIDsReordered == clusters(cl));
        yLim = ylim;
        ciplot([yLim(1) yLim(1)], [yLim(2) yLim(2)], [tOI(1) tOI(end)], 'r', 0.15);
    end
    legend([pBase, pSD, p95], {'Baseline', 'SD', '95% conf'})
    hold off
    title('Clusters with low-pass filtered EEG');
    set(gcf, 'Name','Clusters with low-pass filtered EEG');
    
    figure
    plot(t, EEGfilt)
    hold on
    pBase = plot(t, ones(1, numel(EEGfilt))*baseline);
    pSD = plot(t, ones(1, numel(EEGfilt))*lowSDeeg);
    p95 = plot(t, ones(1, numel(EEGfilt))*lowCI95eeg);
    plot(tWaves, waves, 'c.', 'MarkerSize',10)
    plot(tPks, EEGfilt(pksLocs), 'r.', 'MarkerSize',10)
    plot(tPksLarge, EEGfilt(pksLocsLarge), 'ro', 'MarkerSize',10)
    plot(tPks, EEGfilt(pksLocs), 'go', 'MarkerSize',15)
    for cl = 1:numel(clusters)
        startSWD = find(SWDs == clusters(cl), 1);
        endSWD = find(SWDs == clusters(cl), 1, 'last');
        yLim = ylim;
        ciplot([yLim(1) yLim(1)], [yLim(2) yLim(2)], [t(startSWD) t(endSWD)], 'r', 0.15);
    end
    legend([pBase, pSD, p95], {'Baseline', 'SD', '95% conf'})
    hold off
    title('SWDs with low-pass filtered EEG');
    set(gcf, 'Name','SWDs with low-pass filtered EEG');
    
    figure
    plot(t, EEGfilt)
    hold on
    pBase = plot(t, ones(1, numel(EEGfilt))*baseline);
    pSD = plot(t, ones(1, numel(EEGfilt))*lowSDeeg);
    p95 = plot(t, ones(1, numel(EEGfilt))*lowCI95eeg);
    plot(tWavesLarge, wavesLarge, 'c.', 'MarkerSize',10)
    plot(tPks, EEGfilt(pksLocs), 'r.', 'MarkerSize',10)
    plot(tPksLarge, EEGfilt(pksLocsLarge), 'ro', 'MarkerSize',10)
    plot(tPks, EEGfilt(pksLocs), 'go', 'MarkerSize',15)
    for cl = 1:numel(clustersLarge)
        startSWD = find(SWDsLarge == clustersLarge(cl), 1);
        endSWD = find(SWDsLarge == clustersLarge(cl), 1, 'last');
        if isempty(startSWD) || isempty(endSWD)
            continue
        end
        yLim = ylim;
        ciplot([yLim(1) yLim(1)], [yLim(2) yLim(2)], [t(startSWD) t(endSWD)], 'r', 0.15);
    end
    legend([pBase, pSD, p95], {'Baseline', 'SD', '95% conf'})
    hold off
    title('Large SWDs with low-pass filtered EEG');
    set(gcf, 'Name','Large SWDs with low-pass filtered EEG');
end



%% Deal with data edge overlaps
if edgeOverlap
    if SWDs(1)
        [~, lastInd] = find(SWDs == SWDs(1), 1, 'last');
        SWDs(1:lastInd) = 0;
    end
    if SWDs(end)
        [~, firstInd] = find(SWDs == SWDs(end), 1, 'first');
        SWDs(firstInd:end) = 0;
    end
    if SWDsLarge(1)
        [~, lastInd] = find(SWDsLarge == SWDsLarge(1), 1, 'last');
        SWDsLarge(1:lastInd) = 0;
    end
    if SWDsLarge(end)
        [~, firstInd] = find(SWDsLarge == SWDsLarge(end), 1, 'first');
        SWDsLarge(firstInd:end) = 0;
    end
    if interictal(1)
        [~, lastInd] = find(interictal == interictal(1), 1, 'last');
        interictal(1:lastInd) = 0;
    end
    if interictal(end)
        [~, firstInd] = find(interictal == interictal(end), 1, 'first');
        interictal(firstInd:end) = 0;
    end
    if interictalLarge(1)
        [~, lastInd] = find(interictalLarge == interictalLarge(1), 1, 'last');
        interictalLarge(1:lastInd) = 0;
    end
    if interictalLarge(end)
        [~, firstInd] = find(interictalLarge == interictalLarge(end), 1, 'first');
        interictalLarge(firstInd:end) = 0;
    end
end



%% Local functions
function [tPks, pks, pksLocs] = thPks(t, dt, cycle, EEG, threshold)

EEGth = EEG;
EEGth(EEGth >= threshold) = 0;
EEGthAbs = abs(EEGth);
[~, pksLocs] = findpeaks(EEGthAbs, 'MinPeakDistance',ceil(cycle/2/dt));
pks = EEG(pksLocs);
tPks = t(pksLocs);


function [tPks, pks, pksLocs] = eliminatePks(tPks, pks, pksLocs, distance)

n = numel(tPks);
eliminate = zeros(1,n);
for peak = 1:n
    if peak == 1 && tPks(peak+1) - tPks(peak) > distance
        eliminate(peak) = 1;
    elseif peak == n && tPks(peak) - tPks(peak-1) > distance
        eliminate(peak) = 1;
    elseif peak > 1 && peak < n &&...
            tPks(peak) - tPks(peak-1) > distance && tPks(peak+1) - tPks(peak) > distance
        eliminate(peak) = 1;
    end
end

tPks = tPks(~eliminate);
pks = pks(~eliminate);
pksLocs = pksLocs(~eliminate);


function [tPks, pks, pksLocs] = eliminatePks2(tPks, pks, pksLocs, distance, count) %#ok<*DEFNU>

n = numel(tPks);
eliminate = zeros(1,n);
for peak = 1:n
    if peak-count+1 < 1 && tPks(peak+count-1) - tPks(peak) > distance
        eliminate(peak) = 1;
    elseif peak+count-1 > n && tPks(peak) - tPks(peak-count+1) > distance
        eliminate(peak) = 1;
    elseif peak-count+1 >= 1 && peak+count-1 <= n &&...
            tPks(peak+count-1) - tPks(peak) > distance && tPks(peak) - tPks(peak-count+1) > distance
        eliminate(peak) = 1;
    end
end

tPks = tPks(~eliminate);
pks = pks(~eliminate);
pksLocs = pksLocs(~eliminate);