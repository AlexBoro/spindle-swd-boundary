cleanUp
format longG
tic

AreaCx3(1) = area(5.644, 5.644);
AreaCx3(2) = area(5.644, 160*5.644);
AreaTC = area(60, 90);
AreaNRT = area(42, 63);

list = dir('*dat');
iList = 001:900;

dt = .25;
dtInterpInit = 10*dt;
dtInterpFinal = 40*dt;
xRange = [015000 1200000]+dt;
nPY = 100;
nIN = 50;
nTC = 100;
nNRT = 50;
if ~exist('nCores','var')
    nCores = 32;
end
if ~exist('fullRun','var')
    fullRun = true;
end
voltage = true;
spiking = true;
type = 'SWDs';
psiWindow = round(1000/dt);

iRange = xRange./dt;
iRange = round(iRange(1):iRange(end));
combosPY = nchoosek(1:nPY,2);
combosIN = nchoosek(1:nIN,2);
combosTC = nchoosek(1:nTC,2);
combosNRT = nchoosek(1:nNRT,2);

% Load the EEG data
EEGinit = readBinary('EEG.bin', 'double');

% Estimate EEG oscillation frequency and band-pass filter the EEG data
oscFrequency = oscFreq(EEGinit, dt, type);
Fpass = [oscFrequency-4; oscFrequency-2; oscFrequency; oscFrequency+2; oscFrequency+4];
Fpass(Fpass <= 0) = 1e-9;
if exist('filter.mat', 'file')
    load('filter.mat'); %#ok<*LOAD>
else
    d = designFilterBP(Fpass, 65, 0.5, 65, 1000/dt);
end
EEGinitFilt = filtfilt(d, EEGinit);
[~, phaseEEGinitHT] = hilbertTransform(EEGinitFilt-mean(EEGinitFilt));

% Detect EEG spikes
if strcmpi(type, 'SWDs')
    [eegSpikes, eegSpikesSWD, eegSpikesT, eegSpikesLocs, eegSpikesLocsSWD, eegSpikesLarge, eegSpikesLargeSWD,...
        eegSpikesLargeT, eegSpikesLargeLocs, eegSpikesLargeLocsSWD, tWaves, waveLocs, tWavesLarge, waveLocsLarge, SWDs,...
        SWDsLarge, phase, SWCs, phaseLarge, SWCsLarge] = detectEEGspikesSWDs(EEGinit(iRange), dt);
%     SWDs = interictal;
%     SWDsLarge = interictalLarge;
else
    eegSpikes = detectEEGspikes(EEGinit(iRange), dt, type);
end

%% Calculate coherence
if fullRun
    
    % Initialise variables
    [~, data1] = loadFile(list(1).name, AreaCx3, 'Cx3');
    t = data1.t(iRange);
    tInterpInit = t(1):dtInterpInit:t(end);
    tInterpFinal = t(1):dtInterpFinal:t(end);
    if voltage
        vTC = zeros(nTC, length(tInterpInit));
        vNRT = zeros(nNRT, length(tInterpInit));
        vTC2 = vTC;
        vNRT2 = vNRT;
        vCx23 = zeros(nPY, length(tInterpInit));
        vCx23i = zeros(nIN, length(tInterpInit));
        vCx4 = vCx23;
        vCx4i = vCx23i;
        vCx5 = vCx23;
        vCx5i = vCx23i;
        vCx6 = vCx23;
        vCx6i = vCx23i;
        vAll = zeros(numel(iList), length(tInterpInit));
    end
    
    if spiking
        rasterTC = sparse(nTC, length(t));
        rasterNRT = sparse(nNRT, length(t));
        rasterTC2 = rasterTC;
        rasterNRT2 = rasterNRT;
        rasterCx23 = sparse(nPY, length(t));
        rasterCx23i = sparse(nIN, length(t));
        rasterCx4 = rasterCx23;
        rasterCx4i = rasterCx23i;
        rasterCx5 = rasterCx23;
        rasterCx5i = rasterCx23i;
        rasterCx6 = rasterCx23;
        rasterCx6i = rasterCx23i;
        rasterAll = sparse(numel(iList), length(t));
    end
    
    %for l = iList
    parpool(nCores);
    parfor l = iList
        disp(['Loading file: ' num2str(l)])
        fileName = list(l).name;
        if l <= 4*(nPY+nIN)
            [~, data, cellType] = loadFile(fileName, AreaCx3, 'Cx3');
        elseif l <= 4*(nPY+nIN)+2*nNRT
            [~, data, cellType] = loadFile(fileName, AreaNRT, 'NRT');
        elseif l <= 4*(nPY+nIN)+2*nNRT+2*nTC
            [~, data, cellType] = loadFile(fileName, AreaTC, 'TC');
        end
        
        vAll(l,:) = interp1(t, data.v(iRange), tInterpInit);
        rasterAll(l,:) = sparse(rastergram(data.v(iRange))); %#ok<*SPRIX>
    end
    
    for l = iList
        if voltage
            if l >= 1 && l <= nPY
                vCx23(l,:) = vAll(l,:);
            elseif l >= nPY+1 && l <= nPY+nIN
                vCx23i(l-nPY,:) = vAll(l,:);
            elseif l >= nPY+nIN && l <= 2*nPY+nIN
                vCx4(l-(nPY+nIN),:) = vAll(l,:);
            elseif l >= 2*nPY+nIN+1 && l <= 2*nPY+2*nIN
                vCx4i(l-(2*nPY+nIN),:) = vAll(l,:);
            elseif l >= 2*nPY+2*nIN+1 && l <= 3*nPY+2*nIN
                vCx5(l-(2*nPY+2*nIN),:) = vAll(l,:);
            elseif l >= 3*nPY+2*nIN+1 && l <= 3*nPY+3*nIN
                vCx5i(l-(3*nPY+2*nIN),:) = vAll(l,:);
            elseif l >= 3*nPY+3*nIN+1 && l <= 4*nPY+3*nIN
                vCx6(l-(3*nPY+3*nIN),:) = vAll(l,:);
            elseif l >= 4*nPY+3*nIN+1 && l <= 4*nPY+4*nIN
                vCx6i(l-(4*nPY+3*nIN),:) = vAll(l,:);
            elseif l >= 4*nPY+4*nIN+1 && l <= 4*nPY+4*nIN+nNRT
                vNRT(l-(4*nPY+4*nIN),:) = vAll(l,:);
            elseif l >= 4*nPY+4*nIN+nNRT+1 && l <= 4*nPY+4*nIN+2*nNRT
                vNRT2(l-(4*nPY+4*nIN+nNRT),:) = vAll(l,:);
            elseif l >= 4*nPY+4*nIN+2*nNRT+1 && l <= 4*nPY+4*nIN+2*nNRT+nTC
                vTC(l-(4*nPY+4*nIN+2*nNRT),:) = vAll(l,:);
            elseif l >= 4*nPY+4*nIN+2*nNRT+nTC+1 && l <= 4*nPY+4*nIN+2*nNRT+2*nTC
                vTC2(l-(4*nPY+4*nIN+2*nNRT+nTC),:) = vAll(l,:);
            end
        end
        if spiking
            if l >= 1 && l <= nPY
                rasterCx23(l,:) = rasterAll(l,:);
            elseif l >= nPY+1 && l <= nPY+nIN
                rasterCx23i(l-nPY,:) = rasterAll(l,:);
            elseif l >= nPY+nIN && l <= 2*nPY+nIN
                rasterCx4(l-(nPY+nIN),:) = rasterAll(l,:);
            elseif l >= 2*nPY+nIN+1 && l <= 2*nPY+2*nIN
                rasterCx4i(l-(2*nPY+nIN),:) = rasterAll(l,:);
            elseif l >= 2*nPY+2*nIN+1 && l <= 3*nPY+2*nIN
                rasterCx5(l-(2*nPY+2*nIN),:) = rasterAll(l,:);
            elseif l >= 3*nPY+2*nIN+1 && l <= 3*nPY+3*nIN
                rasterCx5i(l-(3*nPY+2*nIN),:) = rasterAll(l,:);
            elseif l >= 3*nPY+3*nIN+1 && l <= 4*nPY+3*nIN
                rasterCx6(l-(3*nPY+3*nIN),:) = rasterAll(l,:);
            elseif l >= 4*nPY+3*nIN+1 && l <= 4*nPY+4*nIN
                rasterCx6i(l-(4*nPY+3*nIN),:) = rasterAll(l,:);
            elseif l >= 4*nPY+4*nIN+1 && l <= 4*nPY+4*nIN+nNRT
                rasterNRT(l-(4*nPY+4*nIN),:) = rasterAll(l,:);
            elseif l >= 4*nPY+4*nIN+nNRT+1 && l <= 4*nPY+4*nIN+2*nNRT
                rasterNRT2(l-(4*nPY+4*nIN+nNRT),:) = rasterAll(l,:);
            elseif l >= 4*nPY+4*nIN+2*nNRT+1 && l <= 4*nPY+4*nIN+2*nNRT+nTC
                rasterTC(l-(4*nPY+4*nIN+2*nNRT),:) = rasterAll(l,:);
            elseif l >= 4*nPY+4*nIN+2*nNRT+nTC+1 && l <= 4*nPY+4*nIN+2*nNRT+2*nTC
                rasterTC2(l-(4*nPY+4*nIN+2*nNRT+nTC),:) = rasterAll(l,:);
            end
        end
    end
    
    clear vAll rasterAll
    
    % Initialise variables
    if voltage
        psiCx23 = zeros(size(combosPY,1), 1);
        psiCx23i = zeros(size(combosIN,1), 1);
        psiCx4 = zeros(size(combosPY,1), 1);
        psiCx4i = zeros(size(combosIN,1), 1);
        psiCx5 = zeros(size(combosPY,1), 1);
        psiCx5i = zeros(size(combosIN,1), 1);
        psiCx6 = zeros(size(combosPY,1), 1);
        psiCx6i = zeros(size(combosIN,1), 1);
        psiNRT = zeros(size(combosNRT,1), 1);
        psiNRT2 = zeros(size(combosNRT,1), 1);
        psiTC = zeros(size(combosTC,1), 1);
        psiTC2 = zeros(size(combosTC,1), 1);
    end
    if spiking
        psiRasterCx23 = zeros(size(combosPY,1), 1);
        psiRasterCx23i = zeros(size(combosIN,1), 1);
        psiRasterCx4 = zeros(size(combosPY,1), 1);
        psiRasterCx4i = zeros(size(combosIN,1), 1);
        psiRasterCx5 = zeros(size(combosPY,1), 1);
        psiRasterCx5i = zeros(size(combosIN,1), 1);
        psiRasterCx6 = zeros(size(combosPY,1), 1);
        psiRasterCx6i = zeros(size(combosIN,1), 1);
        psiRasterNRT = zeros(size(combosNRT,1), 1);
        psiRasterNRT2 = zeros(size(combosNRT,1), 1);
        psiRasterTC = zeros(size(combosTC,1), 1);
        psiRasterTC2 = zeros(size(combosTC,1), 1);
    end
    if voltage
        psiCx23_t = zeros(1, length(tInterpFinal));
        psiCx23i_t = zeros(1, length(tInterpFinal));
        psiCx4_t = zeros(1, length(tInterpFinal));
        psiCx4i_t = zeros(1, length(tInterpFinal));
        psiCx5_t = zeros(1, length(tInterpFinal));
        psiCx5i_t = zeros(1, length(tInterpFinal));
        psiCx6_t = zeros(1, length(tInterpFinal));
        psiCx6i_t = zeros(1, length(tInterpFinal));
        psiNRT_t = zeros(1, length(tInterpFinal));
        psiNRT2_t = zeros(1, length(tInterpFinal));
        psiTC_t = zeros(1, length(tInterpFinal));
        psiTC2_t = zeros(1, length(tInterpFinal));
    end
    if spiking
        psiRasterCx23_t = zeros(1, length(tInterpFinal));
        psiRasterCx23i_t = zeros(1, length(tInterpFinal));
        psiRasterCx4_t = zeros(1, length(tInterpFinal));
        psiRasterCx4i_t = zeros(1, length(tInterpFinal));
        psiRasterCx5_t = zeros(1, length(tInterpFinal));
        psiRasterCx5i_t = zeros(1, length(tInterpFinal));
        psiRasterCx6_t = zeros(1, length(tInterpFinal));
        psiRasterCx6i_t = zeros(1, length(tInterpFinal));
        psiRasterNRT_t = zeros(1, length(tInterpFinal));
        psiRasterNRT2_t = zeros(1, length(tInterpFinal));
        psiRasterTC_t = zeros(1, length(tInterpFinal));
        psiRasterTC2_t = zeros(1, length(tInterpFinal));
    end
    
    for iCombo = 1:max([size(combosPY,1) size(combosIN,1) size(combosNRT,1) size(combosTC,1)])
    %parfor iCombo = 1:max([size(combosPY,1) size(combosIN,1) size(combosNRT,1) size(combosTC,1)])
        disp(['Processing combo: ' num2str(iCombo)])
        
        % Membrane potential
        if voltage
            if iCombo <= size(combosPY,1)
                cell1 = combosPY(iCombo,1);
                cell2 = combosPY(iCombo,2);
                
                vFilt = filtfilt(d, vCx23(cell1,:)); %#ok<*PFBNS>
                vFiltNorm = (vFilt-min(vFilt))./max(vFilt-min(vFilt));
                vFilt2 = filtfilt(d, vCx23(cell2,:));
                vFiltNorm2 = (vFilt2-min(vFilt2))./max(vFilt2-min(vFilt2));
                [psiCx23(iCombo), psi_t] = hilbertPhaseSync(vFiltNorm, vFiltNorm2, round(psiWindow*(dt/dtInterpInit)));
                psiCx23_t = psiCx23_t + interp1(tInterpInit, psi_t, tInterpFinal);
                
                vFilt = filtfilt(d, vCx4(cell1,:));
                vFiltNorm = (vFilt-min(vFilt))./max(vFilt-min(vFilt));
                vFilt2 = filtfilt(d, vCx4(cell2,:));
                vFiltNorm2 = (vFilt2-min(vFilt2))./max(vFilt2-min(vFilt2));
                [psiCx4(iCombo), psi_t] = hilbertPhaseSync(vFiltNorm, vFiltNorm2, round(psiWindow*(dt/dtInterpInit)));
                psiCx4_t = psiCx4_t + interp1(tInterpInit, psi_t, tInterpFinal);
                
                vFilt = filtfilt(d, vCx5(cell1,:));
                vFiltNorm = (vFilt-min(vFilt))./max(vFilt-min(vFilt));
                vFilt2 = filtfilt(d, vCx5(cell2,:));
                vFiltNorm2 = (vFilt2-min(vFilt2))./max(vFilt2-min(vFilt2));
                [psiCx5(iCombo), psi_t] = hilbertPhaseSync(vFiltNorm, vFiltNorm2, round(psiWindow*(dt/dtInterpInit)));
                psiCx5_t = psiCx5_t + interp1(tInterpInit, psi_t, tInterpFinal);
                
                vFilt = filtfilt(d, vCx6(cell1,:));
                vFiltNorm = (vFilt-min(vFilt))./max(vFilt-min(vFilt));
                vFilt2 = filtfilt(d, vCx6(cell2,:));
                vFiltNorm2 = (vFilt2-min(vFilt2))./max(vFilt2-min(vFilt2));
                [psiCx6(iCombo), psi_t] = hilbertPhaseSync(vFiltNorm, vFiltNorm2, round(psiWindow*(dt/dtInterpInit)));
                psiCx6_t = psiCx6_t + interp1(tInterpInit, psi_t, tInterpFinal);
            end
            
            if iCombo <= size(combosIN,1)
                cell1 = combosIN(iCombo,1);
                cell2 = combosIN(iCombo,2);
                
                vFilt = filtfilt(d, vCx23i(cell1,:));
                vFiltNorm = (vFilt-min(vFilt))./max(vFilt-min(vFilt));
                vFilt2 = filtfilt(d, vCx23i(cell2,:));
                vFiltNorm2 = (vFilt2-min(vFilt2))./max(vFilt2-min(vFilt2));
                [psiCx23i(iCombo), psi_t] = hilbertPhaseSync(vFiltNorm, vFiltNorm2, round(psiWindow*(dt/dtInterpInit)));
                psiCx23i_t = psiCx23i_t + interp1(tInterpInit, psi_t, tInterpFinal);
                
                vFilt = filtfilt(d, vCx4i(cell1,:));
                vFiltNorm = (vFilt-min(vFilt))./max(vFilt-min(vFilt));
                vFilt2 = filtfilt(d, vCx4i(cell2,:));
                vFiltNorm2 = (vFilt2-min(vFilt2))./max(vFilt2-min(vFilt2));
                [psiCx4i(iCombo), psi_t] = hilbertPhaseSync(vFiltNorm, vFiltNorm2, round(psiWindow*(dt/dtInterpInit)));
                psiCx4i_t = psiCx4i_t + interp1(tInterpInit, psi_t, tInterpFinal);
                
                vFilt = filtfilt(d, vCx5i(cell1,:));
                vFiltNorm = (vFilt-min(vFilt))./max(vFilt-min(vFilt));
                vFilt2 = filtfilt(d, vCx5i(cell2,:));
                vFiltNorm2 = (vFilt2-min(vFilt2))./max(vFilt2-min(vFilt2));
                [psiCx5i(iCombo), psi_t] = hilbertPhaseSync(vFiltNorm, vFiltNorm2, round(psiWindow*(dt/dtInterpInit)));
                psiCx5i_t = psiCx5i_t + interp1(tInterpInit, psi_t, tInterpFinal);
                
                vFilt = filtfilt(d, vCx6i(cell1,:));
                vFiltNorm = (vFilt-min(vFilt))./max(vFilt-min(vFilt));
                vFilt2 = filtfilt(d, vCx6i(cell2,:));
                vFiltNorm2 = (vFilt2-min(vFilt2))./max(vFilt2-min(vFilt2));
                [psiCx6i(iCombo), psi_t] = hilbertPhaseSync(vFiltNorm, vFiltNorm2, round(psiWindow*(dt/dtInterpInit)));
                psiCx6i_t = psiCx6i_t + interp1(tInterpInit, psi_t, tInterpFinal);
            end
            
            if iCombo <= size(combosNRT,1)
                cell1 = combosNRT(iCombo,1);
                cell2 = combosNRT(iCombo,2);
                
                vFilt = filtfilt(d, vNRT(cell1,:));
                vFiltNorm = (vFilt-min(vFilt))./max(vFilt-min(vFilt));
                vFilt2 = filtfilt(d, vNRT(cell2,:));
                vFiltNorm2 = (vFilt2-min(vFilt2))./max(vFilt2-min(vFilt2));
                [psiNRT(iCombo), psi_t] = hilbertPhaseSync(vFiltNorm, vFiltNorm2, round(psiWindow*(dt/dtInterpInit)));
                psiNRT_t = psiNRT_t + interp1(tInterpInit, psi_t, tInterpFinal);
                
                vFilt = filtfilt(d, vNRT2(cell1,:));
                vFiltNorm = (vFilt-min(vFilt))./max(vFilt-min(vFilt));
                vFilt2 = filtfilt(d, vNRT2(cell2,:));
                vFiltNorm2 = (vFilt2-min(vFilt2))./max(vFilt2-min(vFilt2));
                [psiNRT2(iCombo), psi_t] = hilbertPhaseSync(vFiltNorm, vFiltNorm2, round(psiWindow*(dt/dtInterpInit)));
                psiNRT2_t = psiNRT2_t + interp1(tInterpInit, psi_t, tInterpFinal);
            end
            
            if iCombo <= size(combosTC,1)
                cell1 = combosTC(iCombo,1);
                cell2 = combosTC(iCombo,2);
                
                vFilt = filtfilt(d, vTC(cell1,:));
                vFiltNorm = (vFilt-min(vFilt))./max(vFilt-min(vFilt));
                vFilt2 = filtfilt(d, vTC(cell2,:));
                vFiltNorm2 = (vFilt2-min(vFilt2))./max(vFilt2-min(vFilt2));
                [psiTC(iCombo), psi_t] = hilbertPhaseSync(vFiltNorm, vFiltNorm2, round(psiWindow*(dt/dtInterpInit)));
                psiTC_t = psiTC_t + interp1(tInterpInit, psi_t, tInterpFinal);
                
                vFilt = filtfilt(d, vTC2(cell1,:));
                vFiltNorm = (vFilt-min(vFilt))./max(vFilt-min(vFilt));
                vFilt2 = filtfilt(d, vTC2(cell2,:));
                vFiltNorm2 = (vFilt2-min(vFilt2))./max(vFilt2-min(vFilt2));
                [psiTC2(iCombo), psi_t] = hilbertPhaseSync(vFiltNorm, vFiltNorm2, round(psiWindow*(dt/dtInterpInit)));
                psiTC2_t = psiTC2_t + interp1(tInterpInit, psi_t, tInterpFinal);
            end
        end
        
        % Cell spiking
        if spiking
            if iCombo <= size(combosPY,1)
                cell1 = combosPY(iCombo,1);
                cell2 = combosPY(iCombo,2);
                
                rasterFilt = filtfilt(d, full(rasterCx23(cell1,:)));
                rasterFiltNorm = (rasterFilt-min(rasterFilt))./max(rasterFilt-min(rasterFilt));
                rasterFilt2 = filtfilt(d, full(rasterCx23(cell2,:)));
                rasterFiltNorm2 = (rasterFilt2-min(rasterFilt2))./max(rasterFilt2-min(rasterFilt2));
                [psiRasterCx23(iCombo), psi_t] = hilbertPhaseSync(rasterFiltNorm, rasterFiltNorm2, psiWindow);
                psiRasterCx23_t = psiRasterCx23_t + interp1(t, psi_t, tInterpFinal);
                
                rasterFilt = filtfilt(d, full(rasterCx4(cell1,:)));
                rasterFiltNorm = (rasterFilt-min(rasterFilt))./max(rasterFilt-min(rasterFilt));
                rasterFilt2 = filtfilt(d, full(rasterCx4(cell2,:)));
                rasterFiltNorm2 = (rasterFilt2-min(rasterFilt2))./max(rasterFilt2-min(rasterFilt2));
                [psiRasterCx4(iCombo), psi_t] = hilbertPhaseSync(rasterFiltNorm, rasterFiltNorm2, psiWindow);
                psiRasterCx4_t = psiRasterCx4_t + interp1(t, psi_t, tInterpFinal);
                
                rasterFilt = filtfilt(d, full(rasterCx5(cell1,:)));
                rasterFiltNorm = (rasterFilt-min(rasterFilt))./max(rasterFilt-min(rasterFilt));
                rasterFilt2 = filtfilt(d, full(rasterCx5(cell2,:)));
                rasterFiltNorm2 = (rasterFilt2-min(rasterFilt2))./max(rasterFilt2-min(rasterFilt2));
                [psiRasterCx5(iCombo), psi_t] = hilbertPhaseSync(rasterFiltNorm, rasterFiltNorm2, psiWindow);
                psiRasterCx5_t = psiRasterCx5_t + interp1(t, psi_t, tInterpFinal);
                
                rasterFilt = filtfilt(d, full(rasterCx6(cell1,:)));
                rasterFiltNorm = (rasterFilt-min(rasterFilt))./max(rasterFilt-min(rasterFilt));
                rasterFilt2 = filtfilt(d, full(rasterCx6(cell2,:)));
                rasterFiltNorm2 = (rasterFilt2-min(rasterFilt2))./max(rasterFilt2-min(rasterFilt2));
                [psiRasterCx6(iCombo), psi_t] = hilbertPhaseSync(rasterFiltNorm, rasterFiltNorm2, psiWindow);
                psiRasterCx6_t = psiRasterCx6_t + interp1(t, psi_t, tInterpFinal);
            end
            
            if iCombo <= size(combosIN,1)
                cell1 = combosIN(iCombo,1);
                cell2 = combosIN(iCombo,2);
                
                rasterFilt = filtfilt(d, full(rasterCx23i(cell1,:)));
                rasterFiltNorm = (rasterFilt-min(rasterFilt))./max(rasterFilt-min(rasterFilt));
                rasterFilt2 = filtfilt(d, full(rasterCx23i(cell2,:)));
                rasterFiltNorm2 = (rasterFilt2-min(rasterFilt2))./max(rasterFilt2-min(rasterFilt2));
                [psiRasterCx23i(iCombo), psi_t] = hilbertPhaseSync(rasterFiltNorm, rasterFiltNorm2, psiWindow);
                psiRasterCx23i_t = psiRasterCx23i_t + interp1(t, psi_t, tInterpFinal);
                
                rasterFilt = filtfilt(d, full(rasterCx4i(cell1,:)));
                rasterFiltNorm = (rasterFilt-min(rasterFilt))./max(rasterFilt-min(rasterFilt));
                rasterFilt2 = filtfilt(d, full(rasterCx4i(cell2,:)));
                rasterFiltNorm2 = (rasterFilt2-min(rasterFilt2))./max(rasterFilt2-min(rasterFilt2));
                [psiRasterCx4i(iCombo), psi_t] = hilbertPhaseSync(rasterFiltNorm, rasterFiltNorm2, psiWindow);
                psiRasterCx4i_t = psiRasterCx4i_t + interp1(t, psi_t, tInterpFinal);
                
                rasterFilt = filtfilt(d, full(rasterCx5i(cell1,:)));
                rasterFiltNorm = (rasterFilt-min(rasterFilt))./max(rasterFilt-min(rasterFilt));
                rasterFilt2 = filtfilt(d, full(rasterCx5i(cell2,:)));
                rasterFiltNorm2 = (rasterFilt2-min(rasterFilt2))./max(rasterFilt2-min(rasterFilt2));
                [psiRasterCx5i(iCombo), psi_t] = hilbertPhaseSync(rasterFiltNorm, rasterFiltNorm2, psiWindow);
                psiRasterCx5i_t = psiRasterCx5i_t + interp1(t, psi_t, tInterpFinal);
                
                rasterFilt = filtfilt(d, full(rasterCx6i(cell1,:)));
                rasterFiltNorm = (rasterFilt-min(rasterFilt))./max(rasterFilt-min(rasterFilt));
                rasterFilt2 = filtfilt(d, full(rasterCx6i(cell2,:)));
                rasterFiltNorm2 = (rasterFilt2-min(rasterFilt2))./max(rasterFilt2-min(rasterFilt2));
                [psiRasterCx6i(iCombo), psi_t] = hilbertPhaseSync(rasterFiltNorm, rasterFiltNorm2, psiWindow);
                psiRasterCx6i_t = psiRasterCx6i_t + interp1(t, psi_t, tInterpFinal);
            end
            
            if iCombo <= size(combosNRT,1)
                cell1 = combosNRT(iCombo,1);
                cell2 = combosNRT(iCombo,2);
                
                rasterFilt = filtfilt(d, full(rasterNRT(cell1,:)));
                rasterFiltNorm = (rasterFilt-min(rasterFilt))./max(rasterFilt-min(rasterFilt));
                rasterFilt2 = filtfilt(d, full(rasterNRT(cell2,:)));
                rasterFiltNorm2 = (rasterFilt2-min(rasterFilt2))./max(rasterFilt2-min(rasterFilt2));
                [psiRasterNRT(iCombo), psi_t] = hilbertPhaseSync(rasterFiltNorm, rasterFiltNorm2, psiWindow);
                psiRasterNRT_t = psiRasterNRT_t + interp1(t, psi_t, tInterpFinal);
                
                rasterFilt = filtfilt(d, full(rasterNRT2(cell1,:)));
                rasterFiltNorm = (rasterFilt-min(rasterFilt))./max(rasterFilt-min(rasterFilt));
                rasterFilt2 = filtfilt(d, full(rasterNRT2(cell2,:)));
                rasterFiltNorm2 = (rasterFilt2-min(rasterFilt2))./max(rasterFilt2-min(rasterFilt2));
                [psiRasterNRT2(iCombo), psi_t] = hilbertPhaseSync(rasterFiltNorm, rasterFiltNorm2, psiWindow);
                psiRasterNRT2_t = psiRasterNRT2_t + interp1(t, psi_t, tInterpFinal);
            end
            
            if iCombo <= size(combosTC,1)
                cell1 = combosTC(iCombo,1);
                cell2 = combosTC(iCombo,2);
                
                rasterFilt = filtfilt(d, full(rasterTC(cell1,:)));
                rasterFiltNorm = (rasterFilt-min(rasterFilt))./max(rasterFilt-min(rasterFilt));
                rasterFilt2 = filtfilt(d, full(rasterTC(cell2,:)));
                rasterFiltNorm2 = (rasterFilt2-min(rasterFilt2))./max(rasterFilt2-min(rasterFilt2));
                [psiRasterTC(iCombo), psi_t] = hilbertPhaseSync(rasterFiltNorm, rasterFiltNorm2, psiWindow);
                psiRasterTC_t = psiRasterTC_t + interp1(t, psi_t, tInterpFinal);
                
                rasterFilt = filtfilt(d, full(rasterTC2(cell1,:)));
                rasterFiltNorm = (rasterFilt-min(rasterFilt))./max(rasterFilt-min(rasterFilt));
                rasterFilt2 = filtfilt(d, full(rasterTC2(cell2,:)));
                rasterFiltNorm2 = (rasterFilt2-min(rasterFilt2))./max(rasterFilt2-min(rasterFilt2));
                [psiRasterTC2(iCombo), psi_t] = hilbertPhaseSync(rasterFiltNorm, rasterFiltNorm2, psiWindow);
                psiRasterTC2_t = psiRasterTC2_t + interp1(t, psi_t, tInterpFinal);
            end
        end
    end
    
    if voltage
        [psi2Cx23mean, psi2Cx23CI95] = datamean(psiCx23);
        [psi2Cx23imean, psi2Cx23iCI95] = datamean(psiCx23i);
        [psi2Cx4mean, psi2Cx4CI95] = datamean(psiCx4);
        [psi2Cx4imean, psi2Cx4iCI95] = datamean(psiCx4i);
        [psi2Cx5mean, psi2Cx5CI95] = datamean(psiCx5);
        [psi2Cx5imean, psi2Cx5iCI95] = datamean(psiCx5i);
        [psi2Cx6mean, psi2Cx6CI95] = datamean(psiCx6);
        [psi2Cx6imean, psi2Cx6iCI95] = datamean(psiCx6i);
        [psi2NRTmean, psi2NRTCI95] = datamean(psiNRT);
        [psi2NRT2mean, psi2NRT2CI95] = datamean(psiNRT2);
        [psi2TCmean, psi2TCCI95] = datamean(psiTC);
        [psi2TC2mean, psi2TC2CI95] = datamean(psiTC2);
        clear psiCx23 psiCx23i psiCx4 psiCx4i psiCx5 psiCx5i psiCx6 psiCx6i psiNRT psiNRT2 psiTC psiTC2
        clear vTC vNRT vTC2 vNRT2 vCx23 vCx23i vCx4 vCx4i vCx5 vCx5i vCx6 vCx6i
    end
    
    if spiking
        [psi2RasterCx23mean, psi2RasterCx23CI95] = datamean(psiRasterCx23);
        [psi2RasterCx23imean, psi2RasterCx23iCI95] = datamean(psiRasterCx23i);
        [psi2RasterCx4mean, psi2RasterCx4CI95] = datamean(psiRasterCx4);
        [psi2RasterCx4imean, psi2RasterCx4iCI95] = datamean(psiRasterCx4i);
        [psi2RasterCx5mean, psi2RasterCx5CI95] = datamean(psiRasterCx5);
        [psi2RasterCx5imean, psi2RasterCx5iCI95] = datamean(psiRasterCx5i);
        [psi2RasterCx6mean, psi2RasterCx6CI95] = datamean(psiRasterCx6);
        [psi2RasterCx6imean, psi2RasterCx6iCI95] = datamean(psiRasterCx6i);
        [psi2RasterNRTmean, psi2RasterNRTCI95] = datamean(psiRasterNRT);
        [psi2RasterNRT2mean, psi2RasterNRT2CI95] = datamean(psiRasterNRT2);
        [psi2RasterTCmean, psi2RasterTCCI95] = datamean(psiRasterTC);
        [psi2RasterTC2mean, psi2RasterTC2CI95] = datamean(psiRasterTC2);
        clear psiRasterCx23 psiRasterCx23i psiRasterCx4 psiRasterCx4i psiRasterCx5 psiRasterCx5i psiRasterCx6 psiRasterCx6i
        clear psiRasterNRT psiRasterNRT2 psiRasterTC psiRasterTC2
        clear rasterTC rasterNRT rasterTC2 rasterNRT2 rasterCx23 rasterCx23i
        clear rasterCx4 rasterCx4i rasterCx5 rasterCx5i rasterCx6 rasterCx6i
    end
end


%% Average coherence over all SWDs
if fullRun
    SWDsInterp = interp1(t, SWDs, tInterpFinal, 'linear', 'extrap');
    SWDsLargeInterp = interp1(t, SWDsLarge, tInterpFinal, 'linear', 'extrap');
    if voltage
        disp('Processing voltage PSIs')
        [psi2Cx23MeanAligned, psi2Cx23CI95Aligned, ~, ~,...
            psi2Cx23MeanAlignedScaled, psi2Cx23CI95AlignedScaled] = frAlign(SWDsInterp, psiCx23_t, tInterpFinal);
        [psi2Cx23MeanAlignedLarge, psi2Cx23CI95AlignedLarge, ~, ~,...
            psi2Cx23MeanAlignedScaledLarge, psi2Cx23CI95AlignedScaledLarge] = frAlign(SWDsLargeInterp, psiCx23_t, tInterpFinal);
        [psi2Cx23iMeanAligned, psi2Cx23iCI95Aligned, ~, ~,...
            psi2Cx23iMeanAlignedScaled, psi2Cx23iCI95AlignedScaled] = frAlign(SWDsInterp, psiCx23i_t, tInterpFinal);
        [psi2Cx23iMeanAlignedLarge, psi2Cx23iCI95AlignedLarge, ~, ~,...
            psi2Cx23iMeanAlignedScaledLarge, psi2Cx23iCI95AlignedScaledLarge] = frAlign(SWDsLargeInterp, psiCx23i_t, tInterpFinal);
        [psi2Cx4MeanAligned, psi2Cx4CI95Aligned, ~, ~,...
            psi2Cx4MeanAlignedScaled, psi2Cx4CI95AlignedScaled] = frAlign(SWDsInterp, psiCx4_t, tInterpFinal);
        [psi2Cx4MeanAlignedLarge, psi2Cx4CI95AlignedLarge, ~, ~,...
            psi2Cx4MeanAlignedScaledLarge, psi2Cx4CI95AlignedScaledLarge] = frAlign(SWDsLargeInterp, psiCx4_t, tInterpFinal);
        [psi2Cx4iMeanAligned, psi2Cx4iCI95Aligned, ~, ~,...
            psi2Cx4iMeanAlignedScaled, psi2Cx4iCI95AlignedScaled] = frAlign(SWDsInterp, psiCx4i_t, tInterpFinal);
        [psi2Cx4iMeanAlignedLarge, psi2Cx4iCI95AlignedLarge, ~, ~,...
            psi2Cx4iMeanAlignedScaledLarge, psi2Cx4iCI95AlignedScaledLarge] = frAlign(SWDsLargeInterp, psiCx4i_t, tInterpFinal);
        [psi2Cx5MeanAligned, psi2Cx5CI95Aligned, ~, ~,...
            psi2Cx5MeanAlignedScaled, psi2Cx5CI95AlignedScaled] = frAlign(SWDsInterp, psiCx5_t, tInterpFinal);
        [psi2Cx5MeanAlignedLarge, psi2Cx5CI95AlignedLarge, ~, ~,...
            psi2Cx5MeanAlignedScaledLarge, psi2Cx5CI95AlignedScaledLarge] = frAlign(SWDsLargeInterp, psiCx5_t, tInterpFinal);
        [psi2Cx5iMeanAligned, psi2Cx5iCI95Aligned, ~, ~,...
            psi2Cx5iMeanAlignedScaled, psi2Cx5iCI95AlignedScaled] = frAlign(SWDsInterp, psiCx5i_t, tInterpFinal);
        [psi2Cx5iMeanAlignedLarge, psi2Cx5iCI95AlignedLarge, ~, ~,...
            psi2Cx5iMeanAlignedScaledLarge, psi2Cx5iCI95AlignedScaledLarge] = frAlign(SWDsLargeInterp, psiCx5i_t, tInterpFinal);
        [psi2Cx6MeanAligned, psi2Cx6CI95Aligned, ~, ~,...
            psi2Cx6MeanAlignedScaled, psi2Cx6CI95AlignedScaled] = frAlign(SWDsInterp, psiCx6_t, tInterpFinal);
        [psi2Cx6MeanAlignedLarge, psi2Cx6CI95AlignedLarge, ~, ~,...
            psi2Cx6MeanAlignedScaledLarge, psi2Cx6CI95AlignedScaledLarge] = frAlign(SWDsLargeInterp, psiCx6_t, tInterpFinal);
        [psi2Cx6iMeanAligned, psi2Cx6iCI95Aligned, ~, ~,...
            psi2Cx6iMeanAlignedScaled, psi2Cx6iCI95AlignedScaled] = frAlign(SWDsInterp, psiCx6i_t, tInterpFinal);
        [psi2Cx6iMeanAlignedLarge, psi2Cx6iCI95AlignedLarge, ~, ~,...
            psi2Cx6iMeanAlignedScaledLarge, psi2Cx6iCI95AlignedScaledLarge] = frAlign(SWDsLargeInterp, psiCx6i_t, tInterpFinal);
        [psi2NRTMeanAligned, psi2NRTCI95Aligned, ~, ~,...
            psi2NRTMeanAlignedScaled, psi2NRTCI95AlignedScaled] = frAlign(SWDsInterp, psiNRT_t, tInterpFinal);
        [psi2NRTMeanAlignedLarge, psi2NRTCI95AlignedLarge, ~, ~,...
            psi2NRTMeanAlignedScaledLarge, psi2NRTCI95AlignedScaledLarge] = frAlign(SWDsLargeInterp, psiNRT_t, tInterpFinal);
        [psi2NRT2MeanAligned, psi2NRT2CI95Aligned, ~, ~,...
            psi2NRT2MeanAlignedScaled, psi2NRT2CI95AlignedScaled] = frAlign(SWDsInterp, psiNRT2_t, tInterpFinal);
        [psi2NRT2MeanAlignedLarge, psi2NRT2CI95AlignedLarge, ~, ~,...
            psi2NRT2MeanAlignedScaledLarge, psi2NRT2CI95AlignedScaledLarge] = frAlign(SWDsLargeInterp, psiNRT2_t, tInterpFinal);
        [psi2TCMeanAligned, psi2TCCI95Aligned, ~, ~,...
            psi2TCMeanAlignedScaled, psi2TCCI95AlignedScaled] = frAlign(SWDsInterp, psiTC_t, tInterpFinal);
        [psi2TCMeanAlignedLarge, psi2TCCI95AlignedLarge, ~, ~,...
            psi2TCMeanAlignedScaledLarge, psi2TCCI95AlignedScaledLarge] = frAlign(SWDsLargeInterp, psiTC_t, tInterpFinal);
        [psi2TC2MeanAligned, psi2TC2CI95Aligned, ~, ~,...
            psi2TC2MeanAlignedScaled, psi2TC2CI95AlignedScaled] = frAlign(SWDsInterp, psiTC2_t, tInterpFinal);
        [psi2TC2MeanAlignedLarge, psi2TC2CI95AlignedLarge, ~, ~,...
            psi2TC2MeanAlignedScaledLarge, psi2TC2CI95AlignedScaledLarge] = frAlign(SWDsLargeInterp, psiTC2_t, tInterpFinal);
    end
    
    if spiking
        disp('Processing spiking PSIs')
        [psi2RasterCx23MeanAligned, psi2RasterCx23CI95Aligned, tStartAligned, tEndAligned,...
            psi2RasterCx23MeanAlignedScaled, psi2RasterCx23CI95AlignedScaled, tStartAlignedScaled, tEndAlignedScaled] = frAlign(SWDsInterp,...
            psiRasterCx23_t, tInterpFinal);
        [psi2RasterCx23MeanAlignedLarge, psi2RasterCx23CI95AlignedLarge, tStartAlignedLarge, tEndAlignedLarge,...
            psi2RasterCx23MeanAlignedScaledLarge, psi2RasterCx23CI95AlignedScaledLarge, tStartAlignedScaledLarge,...
            tEndAlignedScaledLarge] = frAlign(SWDsLargeInterp, psiRasterCx23_t, tInterpFinal);
        [psi2RasterCx23iMeanAligned, psi2RasterCx23iCI95Aligned, ~, ~,...
            psi2RasterCx23iMeanAlignedScaled, psi2RasterCx23iCI95AlignedScaled] = frAlign(SWDsInterp, psiRasterCx23i_t, tInterpFinal);
        [psi2RasterCx23iMeanAlignedLarge, psi2RasterCx23iCI95AlignedLarge, ~, ~,...
            psi2RasterCx23iMeanAlignedScaledLarge, psi2RasterCx23iCI95AlignedScaledLarge] = frAlign(SWDsLargeInterp, psiRasterCx23i_t, tInterpFinal);
        [psi2RasterCx4MeanAligned, psi2RasterCx4CI95Aligned, ~, ~,...
            psi2RasterCx4MeanAlignedScaled, psi2RasterCx4CI95AlignedScaled] = frAlign(SWDsInterp, psiRasterCx4_t, tInterpFinal);
        [psi2RasterCx4MeanAlignedLarge, psi2RasterCx4CI95AlignedLarge, ~, ~,...
            psi2RasterCx4MeanAlignedScaledLarge, psi2RasterCx4CI95AlignedScaledLarge] = frAlign(SWDsLargeInterp, psiRasterCx4_t, tInterpFinal);
        [psi2RasterCx4iMeanAligned, psi2RasterCx4iCI95Aligned, ~, ~,...
            psi2RasterCx4iMeanAlignedScaled, psi2RasterCx4iCI95AlignedScaled] = frAlign(SWDsInterp, psiRasterCx4i_t, tInterpFinal);
        [psi2RasterCx4iMeanAlignedLarge, psi2RasterCx4iCI95AlignedLarge, ~, ~,...
            psi2RasterCx4iMeanAlignedScaledLarge, psi2RasterCx4iCI95AlignedScaledLarge] = frAlign(SWDsLargeInterp, psiRasterCx4i_t, tInterpFinal);
        [psi2RasterCx5MeanAligned, psi2RasterCx5CI95Aligned, ~, ~,...
            psi2RasterCx5MeanAlignedScaled, psi2RasterCx5CI95AlignedScaled] = frAlign(SWDsInterp, psiRasterCx5_t, tInterpFinal);
        [psi2RasterCx5MeanAlignedLarge, psi2RasterCx5CI95AlignedLarge, ~, ~,...
            psi2RasterCx5MeanAlignedScaledLarge, psi2RasterCx5CI95AlignedScaledLarge] = frAlign(SWDsLargeInterp, psiRasterCx5_t, tInterpFinal);
        [psi2RasterCx5iMeanAligned, psi2RasterCx5iCI95Aligned, ~, ~,...
            psi2RasterCx5iMeanAlignedScaled, psi2RasterCx5iCI95AlignedScaled] = frAlign(SWDsInterp, psiRasterCx5i_t, tInterpFinal);
        [psi2RasterCx5iMeanAlignedLarge, psi2RasterCx5iCI95AlignedLarge, ~, ~,...
            psi2RasterCx5iMeanAlignedScaledLarge, psi2RasterCx5iCI95AlignedScaledLarge] = frAlign(SWDsLargeInterp, psiRasterCx5i_t, tInterpFinal);
        [psi2RasterCx6MeanAligned, psi2RasterCx6CI95Aligned, ~, ~,...
            psi2RasterCx6MeanAlignedScaled, psi2RasterCx6CI95AlignedScaled] = frAlign(SWDsInterp, psiRasterCx6_t, tInterpFinal);
        [psi2RasterCx6MeanAlignedLarge, psi2RasterCx6CI95AlignedLarge, ~, ~,...
            psi2RasterCx6MeanAlignedScaledLarge, psi2RasterCx6CI95AlignedScaledLarge] = frAlign(SWDsLargeInterp, psiRasterCx6_t, tInterpFinal);
        [psi2RasterCx6iMeanAligned, psi2RasterCx6iCI95Aligned, ~, ~,...
            psi2RasterCx6iMeanAlignedScaled, psi2RasterCx6iCI95AlignedScaled] = frAlign(SWDsInterp, psiRasterCx6i_t, tInterpFinal);
        [psi2RasterCx6iMeanAlignedLarge, psi2RasterCx6iCI95AlignedLarge, ~, ~,...
            psi2RasterCx6iMeanAlignedScaledLarge, psi2RasterCx6iCI95AlignedScaledLarge] = frAlign(SWDsLargeInterp, psiRasterCx6i_t, tInterpFinal);
        [psi2RasterNRTMeanAligned, psi2RasterNRTCI95Aligned, ~, ~,...
            psi2RasterNRTMeanAlignedScaled, psi2RasterNRTCI95AlignedScaled] = frAlign(SWDsInterp, psiRasterNRT_t, tInterpFinal);
        [psi2RasterNRTMeanAlignedLarge, psi2RasterNRTCI95AlignedLarge, ~, ~,...
            psi2RasterNRTMeanAlignedScaledLarge, psi2RasterNRTCI95AlignedScaledLarge] = frAlign(SWDsLargeInterp, psiRasterNRT_t, tInterpFinal);
        [psi2RasterNRT2MeanAligned, psi2RasterNRT2CI95Aligned, ~, ~,...
            psi2RasterNRT2MeanAlignedScaled, psi2RasterNRT2CI95AlignedScaled] = frAlign(SWDsInterp, psiRasterNRT2_t, tInterpFinal);
        [psi2RasterNRT2MeanAlignedLarge, psi2RasterNRT2CI95AlignedLarge, ~, ~,...
            psi2RasterNRT2MeanAlignedScaledLarge, psi2RasterNRT2CI95AlignedScaledLarge] = frAlign(SWDsLargeInterp, psiRasterNRT2_t, tInterpFinal);
        [psi2RasterTCMeanAligned, psi2RasterTCCI95Aligned, ~, ~,...
            psi2RasterTCMeanAlignedScaled, psi2RasterTCCI95AlignedScaled] = frAlign(SWDsInterp, psiRasterTC_t, tInterpFinal);
        [psi2RasterTCMeanAlignedLarge, psi2RasterTCCI95AlignedLarge, ~, ~,...
            psi2RasterTCMeanAlignedScaledLarge, psi2RasterTCCI95AlignedScaledLarge] = frAlign(SWDsLargeInterp, psiRasterTC_t, tInterpFinal);
        [psi2RasterTC2MeanAligned, psi2RasterTC2CI95Aligned, ~, ~,...
            psi2RasterTC2MeanAlignedScaled, psi2RasterTC2CI95AlignedScaled] = frAlign(SWDsInterp, psiRasterTC2_t, tInterpFinal);
        [psi2RasterTC2MeanAlignedLarge, psi2RasterTC2CI95AlignedLarge, ~, ~,...
            psi2RasterTC2MeanAlignedScaledLarge, psi2RasterTC2CI95AlignedScaledLarge] = frAlign(SWDsLargeInterp, psiRasterTC2_t, tInterpFinal);
    end
end


%% Save data
if fullRun
    disp('Saving data')
    if voltage && spiking
        save('psiData2.mat', 'dt','t','dtInterpInit','dtInterpFinal','tInterpInit','tInterpFinal',...
            'psi2Cx23mean','psi2Cx23CI95','psi2Cx23imean','psi2Cx23iCI95',...
            'psi2Cx4mean','psi2Cx4CI95','psi2Cx4imean','psi2Cx4iCI95',...
            'psi2Cx5mean','psi2Cx5CI95','psi2Cx5imean','psi2Cx5iCI95',...
            'psi2Cx6mean','psi2Cx6CI95','psi2Cx6imean','psi2Cx6iCI95',...
            'psi2NRTmean','psi2NRTCI95','psi2NRT2mean','psi2NRT2CI95',...
            'psi2TCmean','psi2TCCI95','psi2TC2mean','psi2TC2CI95',...
            'psi2RasterCx23mean','psi2RasterCx23CI95','psi2RasterCx23imean','psi2RasterCx23iCI95',...
            'psi2RasterCx4mean','psi2RasterCx4CI95','psi2RasterCx4imean','psi2RasterCx4iCI95',...
            'psi2RasterCx5mean','psi2RasterCx5CI95','psi2RasterCx5imean','psi2RasterCx5iCI95',...
            'psi2RasterCx6mean','psi2RasterCx6CI95','psi2RasterCx6imean','psi2RasterCx6iCI95',...
            'psi2RasterNRTmean','psi2RasterNRTCI95','psi2RasterNRT2mean','psi2RasterNRT2CI95',...
            'psi2RasterTCmean','psi2RasterTCCI95','psi2RasterTC2mean','psi2RasterTC2CI95',...
            'psi2Cx23MeanAligned','psi2Cx23CI95Aligned','psi2Cx23iMeanAligned','psi2Cx23iCI95Aligned',...
            'psi2Cx4MeanAligned','psi2Cx4CI95Aligned','psi2Cx4iMeanAligned','psi2Cx4iCI95Aligned',...
            'psi2Cx5MeanAligned','psi2Cx5CI95Aligned','psi2Cx5iMeanAligned','psi2Cx5iCI95Aligned',...
            'psi2Cx6MeanAligned','psi2Cx6CI95Aligned','psi2Cx6iMeanAligned','psi2Cx6iCI95Aligned',...
            'psi2NRTMeanAligned','psi2NRTCI95Aligned','psi2NRT2MeanAligned','psi2NRT2CI95Aligned',...
            'psi2TCMeanAligned','psi2TCCI95Aligned','psi2TC2MeanAligned','psi2TC2CI95Aligned',...
            'psi2RasterCx23MeanAligned','psi2RasterCx23CI95Aligned','psi2RasterCx23iMeanAligned','psi2RasterCx23iCI95Aligned',...
            'psi2RasterCx4MeanAligned','psi2RasterCx4CI95Aligned','psi2RasterCx4iMeanAligned','psi2RasterCx4iCI95Aligned',...
            'psi2RasterCx5MeanAligned','psi2RasterCx5CI95Aligned','psi2RasterCx5iMeanAligned','psi2RasterCx5iCI95Aligned',...
            'psi2RasterCx6MeanAligned','psi2RasterCx6CI95Aligned','psi2RasterCx6iMeanAligned','psi2RasterCx6iCI95Aligned',...
            'psi2RasterNRTMeanAligned','psi2RasterNRTCI95Aligned','psi2RasterNRT2MeanAligned','psi2RasterNRT2CI95Aligned',...
            'psi2RasterTCMeanAligned','psi2RasterTCCI95Aligned','psi2RasterTC2MeanAligned','psi2RasterTC2CI95Aligned',...
            'psi2Cx23MeanAlignedScaled','psi2Cx23CI95AlignedScaled','psi2Cx23iMeanAlignedScaled','psi2Cx23iCI95AlignedScaled',...
            'psi2Cx4MeanAlignedScaled','psi2Cx4CI95AlignedScaled','psi2Cx4iMeanAlignedScaled','psi2Cx4iCI95AlignedScaled',...
            'psi2Cx5MeanAlignedScaled','psi2Cx5CI95AlignedScaled','psi2Cx5iMeanAlignedScaled','psi2Cx5iCI95AlignedScaled',...
            'psi2Cx6MeanAlignedScaled','psi2Cx6CI95AlignedScaled','psi2Cx6iMeanAlignedScaled','psi2Cx6iCI95AlignedScaled',...
            'psi2NRTMeanAlignedScaled','psi2NRTCI95AlignedScaled','psi2NRT2MeanAlignedScaled','psi2NRT2CI95AlignedScaled',...
            'psi2TCMeanAlignedScaled','psi2TCCI95AlignedScaled','psi2TC2MeanAlignedScaled','psi2TC2CI95AlignedScaled',...
            'psi2RasterCx23MeanAlignedScaled','psi2RasterCx23CI95AlignedScaled','psi2RasterCx23iMeanAlignedScaled','psi2RasterCx23iCI95AlignedScaled',...
            'psi2RasterCx4MeanAlignedScaled','psi2RasterCx4CI95AlignedScaled','psi2RasterCx4iMeanAlignedScaled','psi2RasterCx4iCI95AlignedScaled',...
            'psi2RasterCx5MeanAlignedScaled','psi2RasterCx5CI95AlignedScaled','psi2RasterCx5iMeanAlignedScaled','psi2RasterCx5iCI95AlignedScaled',...
            'psi2RasterCx6MeanAlignedScaled','psi2RasterCx6CI95AlignedScaled','psi2RasterCx6iMeanAlignedScaled','psi2RasterCx6iCI95AlignedScaled',...
            'psi2RasterNRTMeanAlignedScaled','psi2RasterNRTCI95AlignedScaled','psi2RasterNRT2MeanAlignedScaled','psi2RasterNRT2CI95AlignedScaled',...
            'psi2RasterTCMeanAlignedScaled','psi2RasterTCCI95AlignedScaled','psi2RasterTC2MeanAlignedScaled','psi2RasterTC2CI95AlignedScaled',...
            'psi2Cx23MeanAlignedLarge','psi2Cx23CI95AlignedLarge','psi2Cx23iMeanAlignedLarge','psi2Cx23iCI95AlignedLarge',...
            'psi2Cx4MeanAlignedLarge','psi2Cx4CI95AlignedLarge','psi2Cx4iMeanAlignedLarge','psi2Cx4iCI95AlignedLarge',...
            'psi2Cx5MeanAlignedLarge','psi2Cx5CI95AlignedLarge','psi2Cx5iMeanAlignedLarge','psi2Cx5iCI95AlignedLarge',...
            'psi2Cx6MeanAlignedLarge','psi2Cx6CI95AlignedLarge','psi2Cx6iMeanAlignedLarge','psi2Cx6iCI95AlignedLarge',...
            'psi2NRTMeanAlignedLarge','psi2NRTCI95AlignedLarge','psi2NRT2MeanAlignedLarge','psi2NRT2CI95AlignedLarge',...
            'psi2TCMeanAlignedLarge','psi2TCCI95AlignedLarge','psi2TC2MeanAlignedLarge','psi2TC2CI95AlignedLarge',...
            'psi2RasterCx23MeanAlignedLarge','psi2RasterCx23CI95AlignedLarge','psi2RasterCx23iMeanAlignedLarge','psi2RasterCx23iCI95AlignedLarge',...
            'psi2RasterCx4MeanAlignedLarge','psi2RasterCx4CI95AlignedLarge','psi2RasterCx4iMeanAlignedLarge','psi2RasterCx4iCI95AlignedLarge',...
            'psi2RasterCx5MeanAlignedLarge','psi2RasterCx5CI95AlignedLarge','psi2RasterCx5iMeanAlignedLarge','psi2RasterCx5iCI95AlignedLarge',...
            'psi2RasterCx6MeanAlignedLarge','psi2RasterCx6CI95AlignedLarge','psi2RasterCx6iMeanAlignedLarge','psi2RasterCx6iCI95AlignedLarge',...
            'psi2RasterNRTMeanAlignedLarge','psi2RasterNRTCI95AlignedLarge','psi2RasterNRT2MeanAlignedLarge','psi2RasterNRT2CI95AlignedLarge',...
            'psi2RasterTCMeanAlignedLarge','psi2RasterTCCI95AlignedLarge','psi2RasterTC2MeanAlignedLarge','psi2RasterTC2CI95AlignedLarge',...
            'psi2Cx23MeanAlignedScaledLarge','psi2Cx23CI95AlignedScaledLarge','psi2Cx23iMeanAlignedScaledLarge','psi2Cx23iCI95AlignedScaledLarge',...
            'psi2Cx4MeanAlignedScaledLarge','psi2Cx4CI95AlignedScaledLarge','psi2Cx4iMeanAlignedScaledLarge','psi2Cx4iCI95AlignedScaledLarge',...
            'psi2Cx5MeanAlignedScaledLarge','psi2Cx5CI95AlignedScaledLarge','psi2Cx5iMeanAlignedScaledLarge','psi2Cx5iCI95AlignedScaledLarge',...
            'psi2Cx6MeanAlignedScaledLarge','psi2Cx6CI95AlignedScaledLarge','psi2Cx6iMeanAlignedScaledLarge','psi2Cx6iCI95AlignedScaledLarge',...
            'psi2NRTMeanAlignedScaledLarge','psi2NRTCI95AlignedScaledLarge','psi2NRT2MeanAlignedScaledLarge','psi2NRT2CI95AlignedScaledLarge',...
            'psi2TCMeanAlignedScaledLarge','psi2TCCI95AlignedScaledLarge','psi2TC2MeanAlignedScaledLarge','psi2TC2CI95AlignedScaledLarge',...
            'psi2RasterCx23MeanAlignedScaledLarge','psi2RasterCx23CI95AlignedScaledLarge','psi2RasterCx23iMeanAlignedScaledLarge','psi2RasterCx23iCI95AlignedScaledLarge',...
            'psi2RasterCx4MeanAlignedScaledLarge','psi2RasterCx4CI95AlignedScaledLarge','psi2RasterCx4iMeanAlignedScaledLarge','psi2RasterCx4iCI95AlignedScaledLarge',...
            'psi2RasterCx5MeanAlignedScaledLarge','psi2RasterCx5CI95AlignedScaledLarge','psi2RasterCx5iMeanAlignedScaledLarge','psi2RasterCx5iCI95AlignedScaledLarge',...
            'psi2RasterCx6MeanAlignedScaledLarge','psi2RasterCx6CI95AlignedScaledLarge','psi2RasterCx6iMeanAlignedScaledLarge','psi2RasterCx6iCI95AlignedScaledLarge',...
            'psi2RasterNRTMeanAlignedScaledLarge','psi2RasterNRTCI95AlignedScaledLarge','psi2RasterNRT2MeanAlignedScaledLarge','psi2RasterNRT2CI95AlignedScaledLarge',...
            'psi2RasterTCMeanAlignedScaledLarge','psi2RasterTCCI95AlignedScaledLarge','psi2RasterTC2MeanAlignedScaledLarge','psi2RasterTC2CI95AlignedScaledLarge',...
            'iRange','nIN','nNRT','nPY','nTC','psiWindow');
    end
    if voltage && ~spiking
        save('psiData2.mat', 'dt','t','dtInterpInit','dtInterpFinal','tInterpInit','tInterpFinal',...
            'psi2Cx23mean','psi2Cx23CI95','psi2Cx23imean','psi2Cx23iCI95',...
            'psi2Cx4mean','psi2Cx4CI95','psi2Cx4imean','psi2Cx4iCI95',...
            'psi2Cx5mean','psi2Cx5CI95','psi2Cx5imean','psi2Cx5iCI95',...
            'psi2Cx6mean','psi2Cx6CI95','psi2Cx6imean','psi2Cx6iCI95',...
            'psi2NRTmean','psi2NRTCI95','psi2NRT2mean','psi2NRT2CI95',...
            'psi2TCmean','psi2TCCI95','psi2TC2mean','psi2TC2CI95',...
            'psi2Cx23MeanAligned','psi2Cx23CI95Aligned','psi2Cx23iMeanAligned','psi2Cx23iCI95Aligned',...
            'psi2Cx4MeanAligned','psi2Cx4CI95Aligned','psi2Cx4iMeanAligned','psi2Cx4iCI95Aligned',...
            'psi2Cx5MeanAligned','psi2Cx5CI95Aligned','psi2Cx5iMeanAligned','psi2Cx5iCI95Aligned',...
            'psi2Cx6MeanAligned','psi2Cx6CI95Aligned','psi2Cx6iMeanAligned','psi2Cx6iCI95Aligned',...
            'psi2NRTMeanAligned','psi2NRTCI95Aligned','psi2NRT2MeanAligned','psi2NRT2CI95Aligned',...
            'psi2TCMeanAligned','psi2TCCI95Aligned','psi2TC2MeanAligned','psi2TC2CI95Aligned',...
            'psi2Cx23MeanAlignedScaled','psi2Cx23CI95AlignedScaled','psi2Cx23iMeanAlignedScaled','psi2Cx23iCI95AlignedScaled',...
            'psi2Cx4MeanAlignedScaled','psi2Cx4CI95AlignedScaled','psi2Cx4iMeanAlignedScaled','psi2Cx4iCI95AlignedScaled',...
            'psi2Cx5MeanAlignedScaled','psi2Cx5CI95AlignedScaled','psi2Cx5iMeanAlignedScaled','psi2Cx5iCI95AlignedScaled',...
            'psi2Cx6MeanAlignedScaled','psi2Cx6CI95AlignedScaled','psi2Cx6iMeanAlignedScaled','psi2Cx6iCI95AlignedScaled',...
            'psi2NRTMeanAlignedScaled','psi2NRTCI95AlignedScaled','psi2NRT2MeanAlignedScaled','psi2NRT2CI95AlignedScaled',...
            'psi2TCMeanAlignedScaled','psi2TCCI95AlignedScaled','psi2TC2MeanAlignedScaled','psi2TC2CI95AlignedScaled',...
            'psi2Cx23MeanAlignedLarge','psi2Cx23CI95AlignedLarge','psi2Cx23iMeanAlignedLarge','psi2Cx23iCI95AlignedLarge',...
            'psi2Cx4MeanAlignedLarge','psi2Cx4CI95AlignedLarge','psi2Cx4iMeanAlignedLarge','psi2Cx4iCI95AlignedLarge',...
            'psi2Cx5MeanAlignedLarge','psi2Cx5CI95AlignedLarge','psi2Cx5iMeanAlignedLarge','psi2Cx5iCI95AlignedLarge',...
            'psi2Cx6MeanAlignedLarge','psi2Cx6CI95AlignedLarge','psi2Cx6iMeanAlignedLarge','psi2Cx6iCI95AlignedLarge',...
            'psi2NRTMeanAlignedLarge','psi2NRTCI95AlignedLarge','psi2NRT2MeanAlignedLarge','psi2NRT2CI95AlignedLarge',...
            'psi2TCMeanAlignedLarge','psi2TCCI95AlignedLarge','psi2TC2MeanAlignedLarge','psi2TC2CI95AlignedLarge',...
            'psi2Cx23MeanAlignedScaledLarge','psi2Cx23CI95AlignedScaledLarge','psi2Cx23iMeanAlignedScaledLarge','psi2Cx23iCI95AlignedScaledLarge',...
            'psi2Cx4MeanAlignedScaledLarge','psi2Cx4CI95AlignedScaledLarge','psi2Cx4iMeanAlignedScaledLarge','psi2Cx4iCI95AlignedScaledLarge',...
            'psi2Cx5MeanAlignedScaledLarge','psi2Cx5CI95AlignedScaledLarge','psi2Cx5iMeanAlignedScaledLarge','psi2Cx5iCI95AlignedScaledLarge',...
            'psi2Cx6MeanAlignedScaledLarge','psi2Cx6CI95AlignedScaledLarge','psi2Cx6iMeanAlignedScaledLarge','psi2Cx6iCI95AlignedScaledLarge',...
            'psi2NRTMeanAlignedScaledLarge','psi2NRTCI95AlignedScaledLarge','psi2NRT2MeanAlignedScaledLarge','psi2NRT2CI95AlignedScaledLarge',...
            'psi2TCMeanAlignedScaledLarge','psi2TCCI95AlignedScaledLarge','psi2TC2MeanAlignedScaledLarge','psi2TC2CI95AlignedScaledLarge',...
            'iRange','nIN','nNRT','nPY','nTC','psiWindow');
    end
    if ~voltage && spiking
        save('psiData2.mat', 'dt','t','dtInterpInit','dtInterpFinal','tInterpInit','tInterpFinal',...
            'psi2RasterCx23mean','psi2RasterCx23CI95','psi2RasterCx23imean','psi2RasterCx23iCI95',...
            'psi2RasterCx4mean','psi2RasterCx4CI95','psi2RasterCx4imean','psi2RasterCx4iCI95',...
            'psi2RasterCx5mean','psi2RasterCx5CI95','psi2RasterCx5imean','psi2RasterCx5iCI95',...
            'psi2RasterCx6mean','psi2RasterCx6CI95','psi2RasterCx6imean','psi2RasterCx6iCI95',...
            'psi2RasterNRTmean','psi2RasterNRTCI95','psi2RasterNRT2mean','psi2RasterNRT2CI95',...
            'psi2RasterTCmean','psi2RasterTCCI95','psi2RasterTC2mean','psi2RasterTC2CI95',...
            'psi2RasterCx23MeanAligned','psi2RasterCx23CI95Aligned','psi2RasterCx23iMeanAligned','psi2RasterCx23iCI95Aligned',...
            'psi2RasterCx4MeanAligned','psi2RasterCx4CI95Aligned','psi2RasterCx4iMeanAligned','psi2RasterCx4iCI95Aligned',...
            'psi2RasterCx5MeanAligned','psi2RasterCx5CI95Aligned','psi2RasterCx5iMeanAligned','psi2RasterCx5iCI95Aligned',...
            'psi2RasterCx6MeanAligned','psi2RasterCx6CI95Aligned','psi2RasterCx6iMeanAligned','psi2RasterCx6iCI95Aligned',...
            'psi2RasterNRTMeanAligned','psi2RasterNRTCI95Aligned','psi2RasterNRT2MeanAligned','psi2RasterNRT2CI95Aligned',...
            'psi2RasterTCMeanAligned','psi2RasterTCCI95Aligned','psi2RasterTC2MeanAligned','psi2RasterTC2CI95Aligned',...
            'psi2RasterCx23MeanAlignedScaled','psi2RasterCx23CI95AlignedScaled','psi2RasterCx23iMeanAlignedScaled','psi2RasterCx23iCI95AlignedScaled',...
            'psi2RasterCx4MeanAlignedScaled','psi2RasterCx4CI95AlignedScaled','psi2RasterCx4iMeanAlignedScaled','psi2RasterCx4iCI95AlignedScaled',...
            'psi2RasterCx5MeanAlignedScaled','psi2RasterCx5CI95AlignedScaled','psi2RasterCx5iMeanAlignedScaled','psi2RasterCx5iCI95AlignedScaled',...
            'psi2RasterCx6MeanAlignedScaled','psi2RasterCx6CI95AlignedScaled','psi2RasterCx6iMeanAlignedScaled','psi2RasterCx6iCI95AlignedScaled',...
            'psi2RasterNRTMeanAlignedScaled','psi2RasterNRTCI95AlignedScaled','psi2RasterNRT2MeanAlignedScaled','psi2RasterNRT2CI95AlignedScaled',...
            'psi2RasterTCMeanAlignedScaled','psi2RasterTCCI95AlignedScaled','psi2RasterTC2MeanAlignedScaled','psi2RasterTC2CI95AlignedScaled',...
            'psi2RasterCx23MeanAlignedLarge','psi2RasterCx23CI95AlignedLarge','psi2RasterCx23iMeanAlignedLarge','psi2RasterCx23iCI95AlignedLarge',...
            'psi2RasterCx4MeanAlignedLarge','psi2RasterCx4CI95AlignedLarge','psi2RasterCx4iMeanAlignedLarge','psi2RasterCx4iCI95AlignedLarge',...
            'psi2RasterCx5MeanAlignedLarge','psi2RasterCx5CI95AlignedLarge','psi2RasterCx5iMeanAlignedLarge','psi2RasterCx5iCI95AlignedLarge',...
            'psi2RasterCx6MeanAlignedLarge','psi2RasterCx6CI95AlignedLarge','psi2RasterCx6iMeanAlignedLarge','psi2RasterCx6iCI95AlignedLarge',...
            'psi2RasterNRTMeanAlignedLarge','psi2RasterNRTCI95AlignedLarge','psi2RasterNRT2MeanAlignedLarge','psi2RasterNRT2CI95AlignedLarge',...
            'psi2RasterTCMeanAlignedLarge','psi2RasterTCCI95AlignedLarge','psi2RasterTC2MeanAlignedLarge','psi2RasterTC2CI95AlignedLarge',...
            'psi2RasterCx23MeanAlignedScaledLarge','psi2RasterCx23CI95AlignedScaledLarge','psi2RasterCx23iMeanAlignedScaledLarge','psi2RasterCx23iCI95AlignedScaledLarge',...
            'psi2RasterCx4MeanAlignedScaledLarge','psi2RasterCx4CI95AlignedScaledLarge','psi2RasterCx4iMeanAlignedScaledLarge','psi2RasterCx4iCI95AlignedScaledLarge',...
            'psi2RasterCx5MeanAlignedScaledLarge','psi2RasterCx5CI95AlignedScaledLarge','psi2RasterCx5iMeanAlignedScaledLarge','psi2RasterCx5iCI95AlignedScaledLarge',...
            'psi2RasterCx6MeanAlignedScaledLarge','psi2RasterCx6CI95AlignedScaledLarge','psi2RasterCx6iMeanAlignedScaledLarge','psi2RasterCx6iCI95AlignedScaledLarge',...
            'psi2RasterNRTMeanAlignedScaledLarge','psi2RasterNRTCI95AlignedScaledLarge','psi2RasterNRT2MeanAlignedScaledLarge','psi2RasterNRT2CI95AlignedScaledLarge',...
            'psi2RasterTCMeanAlignedScaledLarge','psi2RasterTCCI95AlignedScaledLarge','psi2RasterTC2MeanAlignedScaledLarge','psi2RasterTC2CI95AlignedScaledLarge',...
            'iRange','nIN','nNRT','nPY','nTC','psiWindow');
    end
else
    load('psiData2.mat'); %#ok<*UNRCH>
end

if ~fullRun
    if voltage
        psi2MeanAlignedScaled = [psi2Cx23MeanAlignedScaled; psi2Cx23iMeanAlignedScaled; psi2Cx4MeanAlignedScaled; psi2Cx4iMeanAlignedScaled;...
            psi2Cx5MeanAlignedScaled; psi2Cx5iMeanAlignedScaled; psi2Cx6MeanAlignedScaled; psi2Cx6iMeanAlignedScaled;
            psi2NRTMeanAlignedScaled; psi2NRT2MeanAlignedScaled; psi2TCMeanAlignedScaled; psi2TC2MeanAlignedScaled];
        psi2CI95AlignedScaled = [psi2Cx23CI95AlignedScaled; psi2Cx23iCI95AlignedScaled; psi2Cx4CI95AlignedScaled; psi2Cx4iCI95AlignedScaled;...
            psi2Cx5CI95AlignedScaled; psi2Cx5iCI95AlignedScaled; psi2Cx6CI95AlignedScaled; psi2Cx6iCI95AlignedScaled;
            psi2NRTCI95AlignedScaled; psi2NRT2CI95AlignedScaled; psi2TCCI95AlignedScaled; psi2TC2CI95AlignedScaled];
        colours = [cellColour('Cx23'); cellColour('Cx23'); cellColour('Cx4'); cellColour('Cx4'); cellColour('Cx5'); cellColour('Cx5');...
            cellColour('Cx6'); cellColour('Cx6'); cellColour('NRT'); cellColour('NRT2'); cellColour('TC'); cellColour('TC2')];
        lineTypes = {'-','--','-','--','-','--','-','--','-','-','-','-'};
        legendEntries = {'L2/3 PY', 'L2/3 IN', 'L4 PY', 'L4 IN', 'L5 PY', 'L5 IN', 'L6 PY', 'L6 IN', 'NRT_F_O', 'NRT_H_O', 'TC_F_O', 'TC_H_O'};
        fPSI2 = frAlignPlot(psi2MeanAlignedScaled, psi2CI95AlignedScaled, tStartAlignedScaled, tEndAlignedScaled, colours, lineTypes, 'PSI',...
            legendEntries, 'V_M PSI2');
    end
    
    if spiking
        psi2RasterMeanAlignedScaled = [psi2RasterCx23MeanAlignedScaled; psi2RasterCx23iMeanAlignedScaled; psi2RasterCx4MeanAlignedScaled;...
            psi2RasterCx4iMeanAlignedScaled; psi2RasterCx5MeanAlignedScaled; psi2RasterCx5iMeanAlignedScaled; psi2RasterCx6MeanAlignedScaled;...
            psi2RasterCx6iMeanAlignedScaled; psi2RasterNRTMeanAlignedScaled; psi2RasterNRT2MeanAlignedScaled; psi2RasterTCMeanAlignedScaled;...
            psi2RasterTC2MeanAlignedScaled];
        psi2RasterCI95AlignedScaled = [psi2RasterCx23CI95AlignedScaled; psi2RasterCx23iCI95AlignedScaled; psi2RasterCx4CI95AlignedScaled;...
            psi2RasterCx4iCI95AlignedScaled; psi2RasterCx5CI95AlignedScaled; psi2RasterCx5iCI95AlignedScaled; psi2RasterCx6CI95AlignedScaled;...
            psi2RasterCx6iCI95AlignedScaled; psi2RasterNRTCI95AlignedScaled; psi2RasterNRT2CI95AlignedScaled; psi2RasterTCCI95AlignedScaled;...
            psi2RasterTC2CI95AlignedScaled];
        colours = [cellColour('Cx23'); cellColour('Cx23'); cellColour('Cx4'); cellColour('Cx4'); cellColour('Cx5'); cellColour('Cx5');...
            cellColour('Cx6'); cellColour('Cx6'); cellColour('NRT'); cellColour('NRT2'); cellColour('TC'); cellColour('TC2')];
        lineTypes = {'-','--','-','--','-','--','-','--','-','-','-','-'};
        legendEntries = {'L2/3 PY', 'L2/3 IN', 'L4 PY', 'L4 IN', 'L5 PY', 'L5 IN', 'L6 PY', 'L6 IN', 'NRT_F_O', 'NRT_H_O', 'TC_F_O', 'TC_H_O'};
        fPSI2Raster = frAlignPlot(psi2RasterMeanAlignedScaled, psi2RasterCI95AlignedScaled, tStartAlignedScaled, tEndAlignedScaled,...
            colours, lineTypes, 'PSI', legendEntries, 'Spiking PSI2');
    end
end
toc