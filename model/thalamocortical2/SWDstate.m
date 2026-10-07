%% Load files
EEGinit = readBinary('EEG.bin', 'double');
load('psiData.mat');


%% Extract parameters
[eegSpikes, eegSpikesSWD, eegSpikesT, eegSpikesLocs, eegSpikesLocsSWD, eegSpikesLarge, eegSpikesLargeSWD,...
    eegSpikesLargeT, eegSpikesLargeLocs, eegSpikesLargeLocsSWD, tWaves, waveLocs, tWavesLarge, waveLocsLarge, SWDs,...
    SWDsLarge, phase, SWCs, phaseLarge, SWCsLarge, interictal, interictalLarge, swdFrequency] = detectEEGspikesSWDs(EEGinit(iRange), dt, true);
eegSpikeAmplitudes = zeros(size(eegSpikesT));
instantFreq = zeros(size(eegSpikesT));
EEGinit = EEGinit(iRange);
for spike = 1:numel(eegSpikesT)
    spikeLoc = eegSpikesLocs(spike);
    iWaveLoc = find(waveLocs > spikeLoc, 1);
    waveLoc = waveLocs(iWaveLoc);
    eegSpikeAmplitudes(spike) = EEGinit(waveLoc) - EEGinit(spikeLoc);
    if iWaveLoc > 1
        instantFreq(spike) = 1/(tWaves(iWaveLoc) - tWaves(iWaveLoc-1));
    else
        instantFreq(spike) = 0.5/(tWaves(iWaveLoc) - eegSpikesT(iWaveLoc));
    end
end
nSWDs = max(eegSpikesLocsSWD);
instantFreqSWD = [];
for iSWD = 1:nSWDs
    iInstantFreqSWD = instantFreq(eegSpikesLocsSWD == iSWD);
    if iSWD == 1
        instantFreqSWD = iInstantFreqSWD;
    else
        if size(iInstantFreqSWD,2) > size(instantFreqSWD,2)
            try
                instantFreqSWD = [interp1(1:size(instantFreqSWD,2), instantFreqSWD',...
                    1:(size(instantFreqSWD,2)-1)/(size(iInstantFreqSWD,2)-1):size(instantFreqSWD,2))'; iInstantFreqSWD];
            catch
                instantFreqSWD = [interp1(1:size(instantFreqSWD,2), instantFreqSWD',...
                    1:(size(instantFreqSWD,2)-1)/(size(iInstantFreqSWD,2)-1):size(instantFreqSWD,2)); iInstantFreqSWD];
            end
        elseif size(iInstantFreqSWD,2) < size(instantFreqSWD,2)
            instantFreqSWD = [instantFreqSWD; interp1(1:size(iInstantFreqSWD,2), iInstantFreqSWD',...
                1:(size(iInstantFreqSWD,2)-1)/(size(instantFreqSWD,2)-1):size(iInstantFreqSWD,2))]; %#ok<*AGROW>
        else
            instantFreqSWD = [instantFreqSWD; iInstantFreqSWD];
        end
    end
end
instantFreqSWD = datamean(instantFreqSWD);
figure; plot(instantFreqSWD)

dtEEG = 0.00025;
idSWD = unique(SWDs);
idSWD(idSWD < 1) = [];
swdDurations = zeros(1,numel(idSWD));
for iSWD = 1:numel(idSWD)
    swdDurations(iSWD) = dtEEG*sum(SWDs == idSWD(iSWD));
end
idInterictal = unique(interictal);
idInterictal(idInterictal < 1) = [];
interictalDurations = zeros(1,numel(idInterictal));
for iInterictal = 1:numel(idInterictal)
    interictalDurations(iInterictal) = dtEEG*sum(interictal == idInterictal(iInterictal));
end

SWDsInterp = interp1(t, SWDs, tInterp, 'linear', 'extrap');
[psiRasterAllMeanAligned, psiRasterAllCI95Aligned, tStartAligned, tEndAligned,...
    psiRasterAllMeanAlignedScaled, psiRasterAllCI95AlignedScaled, tStartAlignedScaled, tEndAlignedScaled,...
    psiRasterAllMean_SWDs, psiRasterAllCI95_SWDs] = frAlign(SWDsInterp, psiRasterAll_t, tInterp);

indsOI = tStartAlignedScaled >= 0 & tStartAlignedScaled <= 1;
dataOI_2 = datamean(phaseDiffRasterMeanAlignedScaledInitial(:,indsOI)');
dataOICI95_2 = datamean(phaseDiffRasterCI95AlignedScaledInitial(:,indsOI)');

%% Display parameter values
nSWDs %#ok<*NOPTS>
swdIncidence = nSWDs/((1200-iRange(1)*dt/1000)/60)
[meanSWDduration, CI95SWDduration] = datamean(swdDurations')
[meanInterictalPeriodDuration, CI95InterictalPeriodDuration] = datamean(interictalDurations')
timeSpentInSWD = meanSWDduration/(meanSWDduration + meanInterictalPeriodDuration)
[meanSpikeAmplitude, CI95SpikeAmplitude] = datamean(eegSpikeAmplitudes')
[meanEEGpsi, CI95EEGpsi] = datamean(psiRasterAllMean_SWDs)
swdFrequency

meanPhaseCx23 = dataOI_2(1)
CI95PhaseCx23 = dataOICI95_2(1:2)
meanPhaseCx23i = dataOI_2(2)
CI95PhaseCx23i = dataOICI95_2(3:4)
meanPhaseCx4 = dataOI_2(3)
CI95PhaseCx4 = dataOICI95_2(5:6)
meanPhaseCx4i = dataOI_2(4)
CI95PhaseCx4i = dataOICI95_2(7:8)
meanPhaseCx5 = dataOI_2(5)
CI95PhaseCx5 = dataOICI95_2(9:10)
meanPhaseCx5i = dataOI_2(6)
CI95PhaseCx5i = dataOICI95_2(11:12)
meanPhaseCx6 = dataOI_2(7)
CI95PhaseCx6 = dataOICI95_2(13:14)
meanPhaseCx6i = dataOI_2(8)
CI95PhaseCx6i = dataOICI95_2(15:16)
meanPhaseNRT = dataOI_2(9)
CI95PhaseNRT = dataOICI95_2(17:18)
meanPhaseNRT2 = dataOI_2(10)
CI95PhaseNRT2 = dataOICI95_2(19:20)
meanPhaseTC = dataOI_2(11)
CI95PhaseTC = dataOICI95_2(21:22)
meanPhaseTC2 = dataOI_2(12)
CI95PhaseTC2 = dataOICI95_2(23:24)

frFractions;
brFrTCmean
brFrTCCI95
trFrTCmean
trFrTCCI95