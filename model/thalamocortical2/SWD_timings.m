% The script file plots the membrane potential population data of thalamic cells.
function [] = SWD_timings
clc
close all
clear all %#ok<CLALL>
format longG
AreaCx3(1) = area(5.644, 5.644);
AreaCx3(2) = area(5.644, 160*5.644);
AreaTC = area(60, 90);
AreaNRT = area(42, 63);

list = dir('*dat');
iList = 901:1500;

full = 0;
dt = .25;
xRange = [0 130000];
iRange = xRange./dt+1;
iRange = iRange(1):iRange(end);

% EEG part:
cellType = 'FS';
for i = iList
    i
    fileName = list(i).name;
    cellTypePrev = cellType;
    cellType = fileName(20:21);
    
    if ~strcmp(cellType, 'FS')
        % Load:
        [~, data] = loadFile(fileName, AreaCx3, 'Cx3');

        % Resample:
        if i == iList(1)
            if full
                t = data.t;
            else
                t = data.t(iRange);
            end
            EEG = zeros(size(t));
        end
        if size(data.iGlu,1) > 1
            if full
                data.iGlu = data.iGlu'; %#ok<*UNRCH>
                data.iGABA = data.iGABA';
            else
                data.iGlu = data.iGlu(iRange)';
                data.iGABA = data.iGABA(iRange)';
            end
        end
        [tunique, iunique] = unique(data.t);
        iGlu = interp1(tunique,data.iGlu(iunique),t);
        iGABA = interp1(tunique,data.iGABA(iunique),t);

        % Estimate cell's contribution to EEG:
        cellPos = str2double(fileName(15:18));
        if strcmp(cellTypePrev, 'FS')
            cellPosInit = cellPos;
        end
        cellPos = abs(cellPos - cellPosInit - 49.5)*20;
        if strcmp(fileName(13), '2')
            h = 351.8;
        elseif strcmp(fileName(13), '4')
            h = 693.4;
        elseif strcmp(fileName(13), '5')
            h = 1089.4;
        elseif strcmp(fileName(13), '6')
            h = 1597.2;
        end
        r_i = sqrt(h^2 + cellPos^2);
        convFact = 1e-3*1e1*1e3; % nA --> uA: 1e-3, cm --> mm: 1e1, um^-1 --> mm^-1: 1e3
        %EEG = EEG + convFact*((230/(4*pi))*iSyn./r_i);
        EEG = EEG + convFact*((230/(4*pi))*iGlu./r_i);
        r_i = sqrt((h+500)^2 + cellPos^2);
        EEG = EEG + convFact*((230/(4*pi))*iGABA./r_i);
    end
end

% Butterworth filter:
Rp = 0.5;                                                                   % Passband riple, dB
Rs = 10;                                                                    % Stopband attenuation, dB
NyqFreq = (1000/dt)/2;                                                      % The Nyquist frequency
Wp = 200/NyqFreq;                                                           % Passbands, normalised frequency
Ws = 250/NyqFreq;                                                           % Stopband, normalised frequency
[n, Wn] = buttord(Wp, Ws, Rp, Rs);                                          % n is a filter order
[b, a] = butter(n, Wn, 'low');
EEGfilt = filtfilt(double(b), double(a), EEG);
figure('Units', 'normalized', 'Position', [0, .01, .98, .89]);
plot(t*1e-3, EEGfilt, 'Color', 'k', 'LineWidth', 1)
xlim(xRange./1000)
hold on

waves = [1.3 1.6 1.9 2.15 2.4 2.65 2.95 3.2 3.45 3.7 4 4.2 4.5 4.75 5 5.25 5.55 5.8 6.05 6.3 6.55 6.8 7.1 7.35 7.6 7.85 8.15 8.4 8.65 8.9 9.15 9.4 9.7 9.95 10.2 10.45 10.7 11 11.25 11.5 11.75 12 12.3 12.55 12.8 13.05 13.3...
    13.6 13.8 14.1 14.35 14.6 14.85 15.1 15.35 15.6 47 47.3 47.6 47.8 48.1 48.4 48.65 48.9 49.2 49.4 49.7 49.9 50.2 50.45 50.75 51 51.25 51.5 51.75 52 52.25 52.5 52.8 53.05 53.3 53.55 53.8 54.05 54.3 54.6 54.8 55.1 55.35...
    55.6 55.9 56.1 56.4 56.6 56.9 57.15 57.4 57.65 57.9 58.15 58.4 58.7 58.95 59.2 59.45 59.7 60 60.2 60.5 60.75 61 61.2 61.5 61.75 62 62.25 62.5 62.75 63 63.25 63.5 91.2 91.5 91.75 92 92.3 92.55 92.8 93.1 93.3 93.6 93.85...
    94.1 96.95 97.2 97.4 97.7 97.95 98.2 98.5 98.7 99 99.2 99.5 99.75 100 100.25 100.5 100.8 101 101.3 101.55 101.8 102.05 102.3 102.55 102.8 103.1 103.3 103.6 103.85 104.1 104.35 104.6 104.9 105.15 105.4 105.65 105.9 106.15...
    106.4 106.7 106.95 107.2 107.4 107.7 107.9 108.2 108.45 108.7 108.95 109.2 109.5 109.7 110 110.25 110.5 110.75 111 111.25 111.5 111.75 112 112.25 112.5 112.75 113 113.2 113.5 113.75 114 114.25 114.5 114.5]*1000-xRange(1);
waves = (waves./dt)+1;
spikes = zeros(1,length(waves)-1);
for i = 1:length(waves)-1
    waveRange = round(waves(i)):round(waves(i+1));
    [~,j] = min(EEGfilt(waveRange));
    spikes(i) = waveRange(1)+j-1;   % identify spikes
end
spikes2 = [waves(1) spikes waves(end)];
for i = 1:length(spikes2)-1
    spikeRange = spikes2(i):spikes2(i+1);
    [~,j] = max(EEGfilt(spikeRange));
    waves(i) = spikeRange(1)+j-1;   % identify waves
end
tSpikes = t;
for i = 1:length(waves)-1
    if i == 1
        waveRange = 1:waves(i+1);
    elseif i == length(waves)-1
        waveRange = waves(i):length(tSpikes);
    else
        waveRange = waves(i):waves(i+1);
    end
    tSpikes(waveRange) = t(spikes(i));
end
tSpikesInit = tSpikes;  % spike times delineated by waves
tSpikes = t - tSpikes;  % time relative to nearest spikes

plot(t(waves)*1e-3,EEGfilt(waves),'b.','MarkerSize',20)
plot(t(spikes)*1e-3,EEGfilt(spikes),'r.','MarkerSize',20)
hold off

% Membrane potential part:
iList = 1:900;
cellTypes = cell(length(iList),1);
nPY = 100;
nIN = 50;
nTC = 100;
nNRT = 50;

histRange = [-101 201];
binSize = 1;
binCentres = (histRange(1):binSize:histRange(2));

for i = iList
    i
    fileName = list(i).name;
    if i <= 4*(nPY+nIN)
        [~, data, cellTypes{i}] = loadFile(fileName, AreaCx3, 'Cx3');
    elseif i <= 4*(nPY+nIN)+2*nNRT
        [~, data, cellTypes{i}] = loadFile(fileName, AreaNRT, 'NRT');
    elseif i <= 4*(nPY+nIN)+2*nNRT+2*nTC
        [~, data, cellTypes{i}] = loadFile(fileName, AreaTC, 'TC');
    end
    
    % Resample:
    if i == iList(1)
        if full
            t = data.t;
        else
            t = data.t(iRange);
        end
        vTC = zeros(nTC, length(t));
        TCraster = vTC;
        TCtiming = zeros(1,length(binCentres));
        TCtimingFirst = TCtiming;
        vNRT = zeros(nNRT, length(t));
        NRTraster = vNRT;
        NRTtiming = TCtiming;
        NRTtimingFirst = TCtiming;
        vTC2 = vTC;
        TC2raster = vTC;
        TC2timing = TCtiming;
        TC2timingFirst = TCtiming;
        vNRT2 = vNRT;
        NRT2raster = vNRT;
        NRT2timing = TCtiming;
        NRT2timingFirst = TCtiming;
        vCx23 = zeros(nPY, length(t));
        Cx23raster = vCx23;
        Cx23timing = TCtiming;
        Cx23timingFirst = TCtiming;
        vCx23i = zeros(nIN, length(t));
        Cx23iraster = vCx23i;
        Cx23itiming = TCtiming;
        Cx23itimingFirst = TCtiming;
        vCx4 = vCx23;
        Cx4raster = vCx23;
        Cx4timing = TCtiming;
        Cx4timingFirst = TCtiming;
        vCx4i = vCx23i;
        Cx4iraster = vCx23i;
        Cx4itiming = TCtiming;
        Cx4itimingFirst = TCtiming;
        vCx5 = vCx23;
        Cx5raster = vCx23;
        Cx5timing = TCtiming;
        Cx5timingFirst = TCtiming;
        Cx5NDtiming = TCtiming;
        Cx5NDtimingFirst = TCtiming;
        vCx5i = vCx23i;
        Cx5iraster = vCx23i;
        Cx5itiming = TCtiming;
        Cx5itimingFirst = TCtiming;
        vCx6 = vCx23;
        Cx6raster = vCx23;
        Cx6timing = TCtiming;
        Cx6timingFirst = TCtiming;
        vCx6i = vCx23i;
        Cx6iraster = vCx23i;
        Cx6itiming = TCtiming;
        Cx6itimingFirst = TCtiming;
    end
    if ~full
        data.v = data.v(iRange);
    end
    if i >= 1 && i <= nPY
        [vCx23(i,:), Cx23raster(i,:), Cx23timing, ~, Cx23timingFirst] = tFunc(data.v,tSpikes,tSpikesInit,Cx23timing,binCentres,Cx23timingFirst);
    elseif i >= nPY+1 && i <= nPY+nIN
        [vCx23i(i-nPY,:), Cx23iraster(i-nPY,:), Cx23itiming, ~, Cx23itimingFirst] = tFunc(data.v,tSpikes,tSpikesInit,Cx23itiming,binCentres,Cx23itimingFirst);
    elseif i >= nPY+nIN && i <= 2*nPY+nIN
        [vCx4(i-(nPY+nIN),:), Cx4raster(i-(nPY+nIN),:), Cx4timing, ~, Cx4timingFirst] = tFunc(data.v,tSpikes,tSpikesInit,Cx4timing,binCentres,Cx4timingFirst);
    elseif i >= 2*nPY+nIN+1 && i <= 2*nPY+2*nIN
        [vCx4i(i-(2*nPY+nIN),:), Cx4iraster(i-(2*nPY+nIN),:), Cx4itiming, ~, Cx4itimingFirst] = tFunc(data.v,tSpikes,tSpikesInit,Cx4itiming,binCentres,Cx4itimingFirst);
    elseif i >= 2*nPY+2*nIN+1 && i <= 3*nPY+2*nIN
        [vCx5(i-(2*nPY+2*nIN),:), Cx5raster(i-(2*nPY+2*nIN),:), Cx5timing, timing, Cx5timingFirst, timingFirst] = tFunc(data.v,tSpikes,tSpikesInit,Cx5timing,binCentres,Cx5timingFirst);
        if strcmp(cellTypes{i},'ND')
            Cx5NDtiming = Cx5NDtiming + timing;
            Cx5NDtimingFirst = Cx5NDtimingFirst + timingFirst;
        end
    elseif i >= 3*nPY+2*nIN+1 && i <= 3*nPY+3*nIN
        [vCx5i(i-(3*nPY+2*nIN),:), Cx5iraster(i-(3*nPY+2*nIN),:), Cx5itiming, ~, Cx5itimingFirst] = tFunc(data.v,tSpikes,tSpikesInit,Cx5itiming,binCentres,Cx5itimingFirst);
    elseif i >= 3*nPY+3*nIN+1 && i <= 4*nPY+3*nIN
        [vCx6(i-(3*nPY+3*nIN),:), Cx6raster(i-(3*nPY+3*nIN),:), Cx6timing, ~, Cx6timingFirst] = tFunc(data.v,tSpikes,tSpikesInit,Cx6timing,binCentres,Cx6timingFirst);
    elseif i >= 4*nPY+3*nIN+1 && i <= 4*nPY+4*nIN
        [vCx6i(i-(4*nPY+3*nIN),:), Cx6iraster(i-(4*nPY+3*nIN),:), Cx6itiming, ~, Cx6itimingFirst] = tFunc(data.v,tSpikes,tSpikesInit,Cx6itiming,binCentres,Cx6itimingFirst);
    elseif i >= 4*nPY+4*nIN+1 && i <= 4*nPY+4*nIN+nNRT
        [vNRT(i-(4*nPY+4*nIN),:), NRTraster(i-(4*nPY+4*nIN),:), NRTtiming, ~, NRTtimingFirst] = tFunc(data.v,tSpikes,tSpikesInit,NRTtiming,binCentres,NRTtimingFirst);
    elseif i >= 4*nPY+4*nIN+nNRT+1 && i <= 4*nPY+4*nIN+2*nNRT
        [vNRT2(i-(4*nPY+4*nIN+nNRT),:), NRT2raster(i-(4*nPY+4*nIN+nNRT),:), NRT2timing, ~, NRT2timingFirst] = tFunc(data.v,tSpikes,tSpikesInit,NRT2timing,binCentres,NRT2timingFirst);
    elseif i >= 4*nPY+4*nIN+2*nNRT+1 && i <= 4*nPY+4*nIN+2*nNRT+nTC
        [vTC(i-(4*nPY+4*nIN+2*nNRT),:), TCraster(i-(4*nPY+4*nIN+2*nNRT),:), TCtiming, ~, TCtimingFirst] = tFunc(data.v,tSpikes,tSpikesInit,TCtiming,binCentres,TCtimingFirst);
    elseif i >= 4*nPY+4*nIN+2*nNRT+nTC+1 && i <= 4*nPY+4*nIN+2*nNRT+2*nTC
        [vTC2(i-(4*nPY+4*nIN+2*nNRT+nTC),:), TC2raster(i-(4*nPY+4*nIN+2*nNRT+nTC),:), TC2timing, ~, TC2timingFirst] = tFunc(data.v,tSpikes,tSpikesInit,TC2timing,binCentres,TC2timingFirst);
    end
end

binCentres = binCentres(2:end-1);
Cx23timing = Cx23timing(2:end-1);
Cx23itiming = Cx23itiming(2:end-1);
Cx4timing = Cx4timing(2:end-1);
Cx4itiming = Cx4itiming(2:end-1);
Cx5timing = Cx5timing(2:end-1);
Cx5NDtiming = Cx5NDtiming(2:end-1);
Cx5noNDtiming = Cx5timing-Cx5NDtiming;
Cx5itiming = Cx5itiming(2:end-1);
Cx6timing = Cx6timing(2:end-1);
Cx6itiming = Cx6itiming(2:end-1);
NRTtiming = NRTtiming(2:end-1);
NRT2timing = NRT2timing(2:end-1);
NRT3timing = NRTtiming + NRT2timing;
TCtiming = TCtiming(2:end-1);
TC2timing = TC2timing(2:end-1);
TC3timing = TCtiming + TC2timing;

Cx23timingFirst = Cx23timingFirst(2:end-1);
Cx23itimingFirst = Cx23itimingFirst(2:end-1);
Cx4timingFirst = Cx4timingFirst(2:end-1);
Cx4itimingFirst = Cx4itimingFirst(2:end-1);
Cx5timingFirst = Cx5timingFirst(2:end-1);
Cx5NDtimingFirst = Cx5NDtimingFirst(2:end-1);
Cx5noNDtimingFirst = Cx5timingFirst-Cx5NDtimingFirst;
Cx5itimingFirst = Cx5itimingFirst(2:end-1);
Cx6timingFirst = Cx6timingFirst(2:end-1);
Cx6itimingFirst = Cx6itimingFirst(2:end-1);
NRTtimingFirst = NRTtimingFirst(2:end-1);
NRT2timingFirst = NRT2timingFirst(2:end-1);
NRT3timingFirst = NRTtimingFirst + NRT2timingFirst;
TCtimingFirst = TCtimingFirst(2:end-1);
TC2timingFirst = TC2timingFirst(2:end-1);
TC3timingFirst = TCtimingFirst + TC2timingFirst;

Cx5fit = gaussian(binCentres,Cx5timing./100);
Cx56fit = gaussian(binCentres,(Cx5timing+Cx6timing)./200);
Cx6fit = gaussian(binCentres,Cx6timing./100);
Cx23fit = gaussian(binCentres,Cx23timing./100);
Cx4fit = gaussian(binCentres,Cx4timing./100);
TCfit = gaussian(binCentres,TCtiming./100);
TC2fit = gaussian(binCentres,TC2timing./100);
TC3fit = gaussian(binCentres,TC3timing./200);

Cx5fitFirst = gaussian(binCentres,Cx5timingFirst./100);
Cx56fitFirst = gaussian(binCentres,(Cx5timingFirst+Cx6timingFirst)./200);
Cx6fitFirst = gaussian(binCentres,Cx6timingFirst./100);
Cx23fitFirst = gaussian(binCentres,Cx23timingFirst./100);
Cx4fitFirst = gaussian(binCentres,Cx4timingFirst./100);
TCfitFirst = gaussian(binCentres,TCtimingFirst./100);
TC2fitFirst = gaussian(binCentres,TC2timingFirst./100);
TC3fitFirst = gaussian(binCentres,TC3timingFirst./200);

figure('Units', 'normalized', 'Position', [0, .01, .98, .89]);
%plot(binCentres, (Cx5timing+Cx6timing)./200,'r','LineWidth',1)
%plot(binCentres, Cx5timing./100,'r','LineWidth',1)
plot(binCentres, Cx6timing./100,'r','LineWidth',1)
hold on
%plot(binCentres, Cx5fit,'r','LineWidth',5)
%plot(binCentres, Cx56fit,'r','LineWidth',5)
plot(binCentres, Cx6fit,'r','LineWidth',5)
plot(binCentres, Cx23timing./100,'g','LineWidth',1)
plot(binCentres, Cx23fit,'g','LineWidth',5)
plot(binCentres, Cx4timing./100,'b','LineWidth',1)
plot(binCentres, Cx4fit,'b','LineWidth',5)
% plot(binCentres, TC3timing./200,'c','LineWidth',1)
% plot(binCentres, TC3fit,'c','LineWidth',5)
plot(binCentres, TCtiming./100,'c','LineWidth',1)
plot(binCentres, TCfit,'c','LineWidth',5)
plot(binCentres, TC2timing./100,'y','LineWidth',1)
plot(binCentres, TC2fit,'y','LineWidth',5)
hold off

figure('Units', 'normalized', 'Position', [0, .01, .98, .89]);
plot(binCentres, (Cx5timingFirst+Cx6timingFirst)./200,'r','LineWidth',1)
%plot(binCentres, Cx6timingFirst./100,'r','LineWidth',1)
hold on
plot(binCentres, Cx56fitFirst,'r','LineWidth',5)
%plot(binCentres, Cx6fitFirst,'r','LineWidth',5)
plot(binCentres, Cx23timingFirst./100,'g','LineWidth',1)
plot(binCentres, Cx23fitFirst,'g','LineWidth',5)
plot(binCentres, Cx4timingFirst./100,'b','LineWidth',1)
plot(binCentres, Cx4fitFirst,'b','LineWidth',5)
plot(binCentres, TCtimingFirst./100,'c','LineWidth',1)
plot(binCentres, TCfitFirst,'c','LineWidth',5)
plot(binCentres, TC2timingFirst./100,'y','LineWidth',1)
plot(binCentres, TC2fitFirst,'y','LineWidth',5)
hold off

mean5noND = sum(Cx5noNDtiming.*binCentres)./sum(Cx5noNDtiming)
meanL56 = sum((Cx5timing+Cx6timing).*binCentres)./sum(Cx5timing+Cx6timing)
meanL23 = sum(Cx23timing.*binCentres)./sum(Cx23timing)
meanL4 = sum(Cx4timing.*binCentres)./sum(Cx4timing)
meanTC3 = sum(TC3timing.*binCentres)./sum(TC3timing)

startCycle = dt+([[1.3;1.3] [1.6;1.6] [1.9;1.9] [2.15;2.15] [2.4;2.4] [2.65;2.65] [2.95;2.95] [3.2;3.2] [3.45;3.45] [3.7;3.7] [4;4] [4.2;4.2] [4.5;4.5] [4.75;4.75] [5;5] [5.25;5.25] [5.55;5.55] [5.8;5.8] [6.05;6.05] [6.3;6.3]...
    [6.55;6.55] [6.8;6.8] [7.1;7.1] [7.35;7.35] [7.6;7.6] [7.85;7.85] [8.15;8.15] [8.4;8.4] [8.65;8.65] [8.9;8.9] [9.15;9.15] [9.4;9.4] [9.7;9.7] [9.95;9.95] [10.2;10.2] [10.45;10.45] [10.7;10.7] [11;11] [11.25;11.25]...
    [11.5;11.5] [11.75;11.75] [12;12] [12.3;12.3] [12.55;12.55] [12.8;12.8] [13.05;13.05] [13.3;13.3] [13.6;13.6] [13.8;13.8] [14.1;14.1] [14.35;14.35] [14.6;14.6] [14.85;14.85] [15.1;15.1] [15.35;15.35] [15.6;15.6]...
    [47;47] [47.3;47.3] [47.6;47.6] [47.8;47.8] [48.1;48.1] [48.4;48.4] [48.65;48.65] [48.9;48.9] [49.2;49.2] [49.4;49.4] [49.7;49.7] [49.9;49.9] [50.2;50.2] [50.45;50.45] [50.75;50.75] [51;51] [51.25;51.25] [51.5;51.5]...
    [51.75;51.75] [52;52] [52.25;52.25] [52.5;52.5] [52.8;52.8] [53.05;53.05] [53.3;53.3] [53.55;53.55] [53.8;53.8] [54.05;54.05] [54.3;54.3] [54.6;54.6] [54.8;54.8] [55.1;55.1] [55.35;55.35] [55.6;55.6] [55.9;55.9]...
    [56.1;56.1] [56.4;56.4] [56.6;56.6] [56.9;56.9] [57.15;57.15] [57.4;57.4] [57.65;57.65] [57.9;57.9] [58.15;58.15] [58.4;58.4] [58.7;58.7] [58.95;58.95] [59.2;59.2] [59.45;59.45] [59.7;59.7] [60;60] [60.2;60.2] [60.5;60.5]...
    [60.75;60.75] [61;61] [61.2;61.2] [61.5;61.5] [61.75;61.75] [62;62] [62.25;62.25] [62.5;62.5] [62.75;62.75] [63;63] [63.25;63.25] [63.5;63.5] [91.2;91.2] [91.5;91.5] [91.75;91.75] [92;92] [92.3;92.3] [92.55;92.55]...
    [92.8;92.8] [93.1;93.1] [93.3;93.3] [93.6;93.6] [93.85;93.85] [94.1;94.1] [96.95;96.95] [97.2;97.2] [97.4;97.4] [97.7;97.7] [97.95;97.95] [98.2;98.2] [98.5;98.5] [98.7;98.7] [99;99] [99.2;99.2] [99.5;99.5] [99.75;99.75]...
    [100;100] [100.25;100.25] [100.5;100.5] [100.8;100.8] [101;101] [101.3;101.3] [101.55;101.55] [101.8;101.8] [102.05;102.05] [102.3;102.3] [102.55;102.55] [102.8;102.8] [103.1;103.1] [103.3;103.3] [103.6;103.6]...
    [103.85;103.85] [104.1;104.1] [104.35;104.35] [104.6;104.6] [104.9;104.9] [105.15;105.15] [105.4;105.4] [105.65;105.65] [105.9;105.9] [106.15;106.15] [106.4;106.4] [106.7;106.7] [106.95;106.95] [107.2;107.2] [107.4;107.4]...
    [107.7;107.7] [107.9;107.9] [108.2;108.2] [108.45;108.45] [108.7;108.7] [108.95;108.95] [109.2;109.2] [109.5;109.5] [109.7;109.7] [110;110] [110.25;110.25] [110.5;110.5] [110.75;110.75] [111;111] [111.25;111.25]...
    [111.5;111.5] [111.75;111.75] [112;112] [112.25;112.25] [112.5;112.5] [112.75;112.75] [113;113] [113.2;113.2] [113.5;113.5] [113.75;113.75] [114;114] [114.25;114.25] [114.5;114.5]])*1000-xRange(1);
endCycle = ([startCycle(:,2:end) dt+[114800;114800]-xRange(1)]);
iOnsetMat = NaN(size(Cx23raster,1),size(startCycle,2));
tOnsetMat = iOnsetMat;
tOnsetVec = zeros(1,length(startCycle));
raster = [Cx23raster; Cx23iraster; Cx4raster; Cx4iraster; Cx5raster; Cx5iraster; Cx6raster; Cx6iraster; NRTraster; NRT2raster; TCraster; TC2raster];
rasterI = logical(raster);
timeMat = zeros(size(raster));
for i = 1:size(timeMat,1)
    timeMat(i,:) = t;
end
raster(rasterI) = timeMat(rasterI);
raster2 = raster;
for i = 1:size(startCycle,2)
    i
    startStepPY = ((startCycle(2,i)-startCycle(1,i))/size(Cx23raster,1))/dt;
    iStartPY = zeros(size(Cx23raster,1),1);
    for j = 1:length(iStartPY)
        iStartPY(j) = round(startCycle(1,i)/dt+startStepPY*(j-1));
    end
    startStepIN = ((startCycle(2,i)-startCycle(1,i))/size(Cx23iraster,1))/dt;
    iStartIN = zeros(size(Cx23iraster,1),1);
    for j = 1:length(iStartIN)
        iStartIN(j) = round(startCycle(1,i)/dt+startStepIN*(j-1));
    end
    endStepPY = ((endCycle(2,i)-endCycle(1,i))/size(Cx23raster,1))/dt;
    iEndPY = zeros(size(Cx23raster,1),1);
    for j = 1:length(iEndPY)
        iEndPY(j) = round(endCycle(1,i)/dt+endStepPY*(j-1));
    end
    endStepIN = ((endCycle(2,i)-endCycle(1,i))/size(Cx23iraster,1))/dt;
    iEndIN = zeros(size(Cx23iraster,1),1);
    for j = 1:length(iEndIN)
        iEndIN(j) = round(endCycle(1,i)/dt+endStepIN*(j-1));
    end
    ROIPY = zeros(size(Cx23raster));
    for j = 1:size(Cx5raster,1)
        indices = iStartPY(j):iEndPY(j);
        iPeak = iStartPY(j)+find(Cx5raster(j,indices),1)-1;
        if i == 1
            indices = 1:iEndPY(j);
        elseif i == size(startCycle,2)
            indices = iStartPY(j):size(Cx5raster,2);
        end
        ROIPY(j,indices) = 1;
        if isempty(iPeak)
            iOnsetMat(j,i) = NaN;
            tOnsetMat(j,i) = NaN;
        else
            iOnsetMat(j,i) = xRange(1)+iPeak;
            tOnsetMat(j,i) = xRange(1)+iPeak*dt;
        end
    end
    tOnsetVec(i) = min(tOnsetMat(:,i));
    ROIIN = zeros(size(Cx23iraster));
    for j = 1:size(Cx23iraster,1)
        if i == 1
            indices = 1:iEndIN(j);
        elseif i == size(startCycle,2)
            indices = iStartIN(j):size(Cx23iraster,2);
        else
            indices = iStartIN(j):iEndIN(j);
        end
        ROIIN(j,indices) = 1;
    end
    ROIL = [ROIPY; ROIIN];
    ROI = logical([ROIL; ROIL; ROIL; ROIL; ROIIN; ROIIN; ROIPY; ROIPY]);
    raster(ROI) = raster(ROI)-tOnsetVec(i);
end

for i = 1:size(startCycle,2)
    i
    startStepPY = ((startCycle(2,i)-startCycle(1,i))/size(Cx23raster,1))/dt;
    iStartPY = zeros(size(Cx23raster,1),1);
    for j = 1:length(iStartPY)
        iStartPY(j) = round(startCycle(1,i)/dt+startStepPY*(j-1));
    end
    startStepIN = ((startCycle(2,i)-startCycle(1,i))/size(Cx23iraster,1))/dt;
    iStartIN = zeros(size(Cx23iraster,1),1);
    for j = 1:length(iStartIN)
        iStartIN(j) = round(startCycle(1,i)/dt+startStepIN*(j-1));
    end
    endStepPY = ((endCycle(2,i)-endCycle(1,i))/size(Cx23raster,1))/dt;
    iEndPY = zeros(size(Cx23raster,1),1);
    for j = 1:length(iEndPY)
        iEndPY(j) = round(endCycle(1,i)/dt+endStepPY*(j-1));
    end
    endStepIN = ((endCycle(2,i)-endCycle(1,i))/size(Cx23iraster,1))/dt;
    iEndIN = zeros(size(Cx23iraster,1),1);
    for j = 1:length(iEndIN)
        iEndIN(j) = round(endCycle(1,i)/dt+endStepIN*(j-1));
    end
    ROIPY = zeros(size(Cx23raster));
    for j = 1:size(TC2raster,1)
        if i == 1
            indices = 1:iEndPY(j);
        elseif i == size(startCycle,2)
            indices = iStartPY(j):size(TC2raster,2);
        else
            indices = iStartPY(j):iEndPY(j);
        end
        ROIPY(j,indices) = 1;
    end
    ROIIN = zeros(size(Cx23iraster));
    for j = 1:size(Cx23iraster,1)
        if i == 1
            indices = 1:iEndIN(j);
        elseif i == size(startCycle,2)
            indices = iStartIN(j):size(Cx23iraster,2);
        else
            indices = iStartIN(j):iEndIN(j);
        end
        ROIIN(j,indices) = 1;
    end
    ROIL = [ROIPY; ROIIN];
    ROI = logical([ROIL; ROIL; ROIL; ROIL; ROIIN; ROIIN; ROIPY; ROIPY]);
    raster2(ROI) = raster2(ROI)-((startCycle(1,i)+startCycle(2,i))/2+xRange(1))-mean(tOnsetVec-((startCycle(1,:)+startCycle(2,:))./2+xRange(1)),'omitnan');
end
save('histos.mat','raster','raster2','cellTypes');
%load('histos.mat');

histRange = [-101 201];
binSize = 1;
binCentres = (histRange(1):binSize:histRange(2));
Cx23timing = ttFunc(raster(1:100,:),binCentres);
Cx23itiming = ttFunc(raster(101:150,:),binCentres);
Cx4timing = ttFunc(raster(151:250,:),binCentres);
Cx4itiming = ttFunc(raster(251:300,:),binCentres);
Cx5timing = ttFunc(raster(301:400,:),binCentres);
Cx5NDtiming = zeros(size(binCentres));
for i = 301:400
    if strcmp(cellTypes{i},'ND')
        Cx5NDtiming = Cx5NDtiming + hist(raster(i,:),binCentres);
    end
end
Cx5NDtiming = Cx5NDtiming(2:end-1);
Cx5noNDtiming = Cx5timing-Cx5NDtiming; %#ok<*NASGU>
Cx5itiming = ttFunc(raster(401:450,:),binCentres);
Cx6timing = ttFunc(raster(451:550,:),binCentres);
Cx6itiming = ttFunc(raster(551:600,:),binCentres);
NRTtiming = ttFunc(raster(601:650,:),binCentres);
NRT2timing = ttFunc(raster(651:700,:),binCentres);
TCtiming = ttFunc(raster(701:800,:),binCentres);
TC2timing = ttFunc(raster(801:900,:),binCentres);
binCentres = binCentres(2:end-1);

histRange = [-101 201];
binSize = 1;
binCentres2 = (histRange(1):binSize:histRange(2));
Cx23timing2 = ttFunc(raster2(1:100,:),binCentres2);
Cx23itiming2 = ttFunc(raster2(101:150,:),binCentres2);
Cx4timing2 = ttFunc(raster2(151:250,:),binCentres2);
Cx4itiming2 = ttFunc(raster2(251:300,:),binCentres2);
Cx5timing2 = ttFunc(raster2(301:400,:),binCentres2);
Cx5NDtiming2 = zeros(size(binCentres2));
for i = 301:400
    if strcmp(cellTypes{i},'ND')
        Cx5NDtiming2 = Cx5NDtiming2 + hist(raster2(i,:),binCentres2);
    end
end
Cx5NDtiming2 = Cx5NDtiming2(2:end-1);
Cx5noNDtiming2 = Cx5timing2-Cx5NDtiming2;
Cx5itiming2 = ttFunc(raster2(401:450,:),binCentres2);
Cx6timing2 = ttFunc(raster2(451:550,:),binCentres2);
Cx6itiming2 = ttFunc(raster2(551:600,:),binCentres2);
NRTtiming2 = ttFunc(raster2(601:650,:),binCentres2);
NRT2timing2 = ttFunc(raster2(651:700,:),binCentres2);
TCtiming2 = ttFunc(raster2(701:800,:),binCentres2);
TC2timing2 = ttFunc(raster2(801:900,:),binCentres2);
binCentres2 = binCentres2(2:end-1);

Cx5fitFull = gaussian(binCentres,(Cx5timing+Cx5itiming)./150);
Cx23fitFull = gaussian(binCentres,(Cx23timing+Cx23itiming)./150);
Cx4fitFull = gaussian(binCentres,(Cx4timing+Cx4itiming)./150);
Cx5fit = gaussian(binCentres,Cx5timing./100);
Cx23fit = gaussian(binCentres,Cx23timing./100);
Cx4fit = gaussian(binCentres,Cx4timing./100);
TCfit = gaussian(binCentres,TCtiming./100);
TC2fit = gaussian(binCentres,TC2timing./100);

Cx5fitFull2 = gaussian(binCentres2,(Cx5timing2+Cx5itiming2)./150);
Cx23fitFull2 = gaussian(binCentres2,(Cx23timing2+Cx23itiming2)./150);
Cx6fitFull2 = gaussian(binCentres2,(Cx6timing2+Cx6itiming2)./150);
Cx4fitFull2 = gaussian(binCentres2,(Cx4timing2+Cx4itiming2)./150);
Cx5fit2 = gaussian(binCentres2,Cx5timing2./100);
Cx23fit2 = gaussian(binCentres2,Cx23timing2./100);
Cx4fit2 = gaussian(binCentres2,Cx4timing2./100);
NRTfit2 = gaussian(binCentres2,NRTtiming2./50);
NRT2fit2 = gaussian(binCentres2,NRT2timing2./50);
TCfit2 = gaussian(binCentres2,TCtiming2./100);
TC2fit2 = gaussian(binCentres2,TC2timing2./100);

% Combined pyramidal cells and interneurons:
f1 = figure('Units', 'normalized', 'Position', [0, .01, .98, .89]);
plot(binCentres, (Cx5timing+Cx5itiming)./150,'r','LineWidth',1)
hold on
plot(binCentres, Cx5fitFull,'r','LineWidth',5)
plot(binCentres, (Cx23timing+Cx23itiming)./150,'g','LineWidth',1)
plot(binCentres, Cx23fitFull,'g','LineWidth',5)
plot(binCentres, (Cx4timing+Cx4itiming)./150,'b','LineWidth',1)
plot(binCentres, Cx4fitFull,'b','LineWidth',5)
plot(binCentres, TCtiming./100,'c','LineWidth',1)
plot(binCentres, TCfit,'c','LineWidth',5)
plot(binCentres, TC2timing./100,'y','LineWidth',1)
plot(binCentres, TC2fit,'y','LineWidth',5)
hold off

f2 = figure('Units', 'normalized', 'Position', [0, .01, .98, .89]);
plot(binCentres, (Cx5timing+Cx5itiming)./max(Cx5timing+Cx5itiming),'r','LineWidth',1)
hold on
plot(binCentres, 150*Cx5fitFull./max(Cx5timing+Cx5itiming),'r','LineWidth',5)
plot(binCentres, (Cx23timing+Cx23itiming)./max(Cx23timing+Cx23itiming),'g','LineWidth',1)
plot(binCentres, 150*Cx23fitFull./max(Cx23timing+Cx23itiming),'g','LineWidth',5)
plot(binCentres, (Cx4timing+Cx4itiming)./max(Cx4timing+Cx4itiming),'b','LineWidth',1)
plot(binCentres, 150*Cx4fitFull./max(Cx4timing+Cx4itiming),'b','LineWidth',5)
plot(binCentres, TCtiming./max(TCtiming),'c','LineWidth',1)
plot(binCentres, 100*TCfit./max(TCtiming),'c','LineWidth',5)
plot(binCentres, TC2timing./max(TC2timing),'y','LineWidth',1)
plot(binCentres, 100*TC2fit./max(TC2timing),'y','LineWidth',5)
hold off

meanL5 = sum((Cx5timing+Cx5itiming).*binCentres)./sum(Cx5timing+Cx5itiming) %#ok<*NOPRT>
meanL23 = sum((Cx23timing+Cx23itiming).*binCentres)./sum(Cx23timing+Cx23itiming)
meanL4 = sum((Cx4timing+Cx4itiming).*binCentres)./sum(Cx4timing+Cx4itiming)
meanTC = sum(TCtiming.*binCentres)./sum(TCtiming)
meanTC2 = sum(TC2timing.*binCentres)./sum(TC2timing)

[~, modeL5] = max(Cx5timing+Cx5itiming);
modeL5 = binCentres(modeL5)
[~, modeL23] = max(Cx23timing+Cx23itiming);
modeL23 = binCentres(modeL23)
[~, modeL4] = max(Cx4timing+Cx4itiming);
modeL4 = binCentres(modeL4)
[~, modeTC] = max(TCtiming);
modeTC = binCentres(modeTC)
[~, modeTC2] = max(TC2timing);
modeTC2 = binCentres(modeTC2)

medianL5 = iMedian(Cx5timing+Cx5itiming);
medianL5 = binCentres(medianL5)
medianL23 = iMedian(Cx23timing+Cx23itiming);
medianL23 = binCentres(medianL23)
medianL4 = iMedian(Cx4timing+Cx4itiming);
medianL4 = binCentres(medianL4)
medianTC = iMedian(TCtiming);
medianTC = binCentres(medianTC)
medianTC2 = iMedian(TC2timing);
medianTC2 = binCentres(medianTC2)

% Only pyramidal cells:
f3 = figure('Units', 'normalized', 'Position', [0, .01, .98, .89]);
plot(binCentres, Cx5timing./100,'r','LineWidth',1)
hold on
plot(binCentres, Cx5fit,'r','LineWidth',5)
plot(binCentres, Cx23timing./100,'g','LineWidth',1)
plot(binCentres, Cx23fit,'g','LineWidth',5)
plot(binCentres, Cx4timing./100,'b','LineWidth',1)
plot(binCentres, Cx4fit,'b','LineWidth',5)
plot(binCentres, TCtiming./100,'c','LineWidth',1)
plot(binCentres, TCfit,'c','LineWidth',5)
plot(binCentres, TC2timing./100,'y','LineWidth',1)
plot(binCentres, TC2fit,'y','LineWidth',5)
hold off

f4 = figure('Units', 'normalized', 'Position', [0, .01, .98, .89]);
plot(binCentres, Cx5timing./max(Cx5timing),'r','LineWidth',1)
hold on
plot(binCentres, 100*Cx5fit./max(Cx5timing),'r','LineWidth',5)
plot(binCentres, Cx23timing./max(Cx23timing),'g','LineWidth',1)
plot(binCentres, 100*Cx23fit./max(Cx23timing),'g','LineWidth',5)
plot(binCentres, Cx4timing./max(Cx4timing),'b','LineWidth',1)
plot(binCentres, 100*Cx4fit./max(Cx4timing),'b','LineWidth',5)
plot(binCentres, TCtiming./max(TCtiming),'c','LineWidth',1)
plot(binCentres, 100*TCfit./max(TCtiming),'c','LineWidth',5)
plot(binCentres, TC2timing./max(TC2timing),'y','LineWidth',1)
plot(binCentres, 100*TC2fit./max(TC2timing),'y','LineWidth',5)
hold off

meanL5 = sum(Cx5timing.*binCentres)./sum(Cx5timing)
meanL23 = sum(Cx23timing.*binCentres)./sum(Cx23timing)
meanL4 = sum(Cx4timing.*binCentres)./sum(Cx4timing)
meanTC = sum(TCtiming.*binCentres)./sum(TCtiming)
meanTC2 = sum(TC2timing.*binCentres)./sum(TC2timing)

[~, modeL5] = max(Cx5timing);
modeL5 = binCentres(modeL5)
[~, modeL23] = max(Cx23timing);
modeL23 = binCentres(modeL23)
[~, modeL4] = max(Cx4timing);
modeL4 = binCentres(modeL4)
[~, modeTC] = max(TCtiming);
modeTC = binCentres(modeTC)
[~, modeTC2] = max(TC2timing);
modeTC2 = binCentres(modeTC2)

medianL5 = iMedian(Cx5timing);
medianL5 = binCentres(medianL5)
medianL23 = iMedian(Cx23timing);
medianL23 = binCentres(medianL23)
medianL4 = iMedian(Cx4timing);
medianL4 = binCentres(medianL4)
medianTC = iMedian(TCtiming);
medianTC = binCentres(medianTC)
medianTC2 = iMedian(TC2timing);
medianTC2 = binCentres(medianTC2)

f5 = figure('Units', 'normalized', 'Position', [0, .01, .98, .89]);
plot(binCentres2, (Cx5timing2+Cx5itiming2)./150,'g','LineWidth',1)
hold on
plot(binCentres2, Cx5fitFull2,'g','LineWidth',5)
plot(binCentres2, (Cx23timing2+Cx23itiming2)./150,'m','LineWidth',1)
plot(binCentres2, Cx23fitFull2,'m','LineWidth',5)
plot(binCentres2, (Cx6timing2+Cx6itiming2)./150,'b','LineWidth',1)
plot(binCentres2, Cx6fitFull2,'b','LineWidth',5)
plot(binCentres2, (Cx4timing2+Cx4itiming2)./150,'r','LineWidth',1)
plot(binCentres2, Cx4fitFull2,'r','LineWidth',5)
plot(binCentres2, NRTtiming2./50,'c','LineWidth',1)
plot(binCentres2, NRTfit2,'c','LineWidth',5)
plot(binCentres2, NRT2timing2./50,'Color',[0 153 153]./255,'LineWidth',1)
plot(binCentres2, NRT2fit2,'Color',[0 153 153]./255,'LineWidth',5)
plot(binCentres2, TCtiming2./100,'y','LineWidth',1)
plot(binCentres2, TCfit2,'y','LineWidth',5)
plot(binCentres2, TC2timing2./100,'Color',[153 153 0]./255,'LineWidth',1)
plot(binCentres2, TC2fit2,'Color',[153 153 0]./255,'LineWidth',5)
hold off

f6 = figure('Units', 'normalized', 'Position', [0, .01, .98, .89]);
plot(binCentres2, (Cx5timing2+Cx5itiming2)./max(Cx5timing2+Cx5itiming2),'g','LineWidth',1)
hold on
plot(binCentres2, 150*Cx5fitFull2./max(Cx5timing2+Cx5itiming2),'g','LineWidth',5)
plot(binCentres2, (Cx23timing2+Cx23itiming2)./max(Cx23timing2+Cx23itiming2),'m','LineWidth',1)
plot(binCentres2, 150*Cx23fitFull2./max(Cx23timing2+Cx23itiming2),'m','LineWidth',5)
plot(binCentres2, (Cx6timing2+Cx6itiming2)./max(Cx6timing2+Cx6itiming2),'b','LineWidth',1)
plot(binCentres2, 150*Cx6fitFull2./max(Cx6timing2+Cx6itiming2),'b','LineWidth',5)
plot(binCentres2, (Cx4timing2+Cx4itiming2)./max(Cx4timing2+Cx4itiming2),'r','LineWidth',1)
plot(binCentres2, 150*Cx4fitFull2./max(Cx4timing2+Cx4itiming2),'r','LineWidth',5)
plot(binCentres2, NRTtiming2./max(NRTtiming2),'c','LineWidth',1)
plot(binCentres2, 50*NRTfit2./max(NRTtiming2),'c','LineWidth',5)
plot(binCentres2, NRT2timing2./max(NRT2timing2),'Color',[0 153 153]./255,'LineWidth',1)
plot(binCentres2, 50*NRT2fit2./max(NRT2timing2),'Color',[0 153 153]./255,'LineWidth',5)
plot(binCentres2, TCtiming2./max(TCtiming2),'y','LineWidth',1)
plot(binCentres2, 100*TCfit2./max(TCtiming2),'y','LineWidth',5)
plot(binCentres2, TC2timing2./max(TC2timing2),'Color',[153 153 0]./255,'LineWidth',1)
plot(binCentres2, 100*TC2fit2./max(TC2timing2),'Color',[153 153 0]./255,'LineWidth',5)
hold off

meanL5 = sum((Cx5timing2+Cx5itiming2).*binCentres2)./sum(Cx5timing2+Cx5itiming2)
meanL23 = sum((Cx23timing2+Cx23itiming2).*binCentres2)./sum(Cx23timing2+Cx23itiming2)
meanL4 = sum((Cx4timing2+Cx4itiming2).*binCentres2)./sum(Cx4timing2+Cx4itiming2)
meanTC = sum(TCtiming2.*binCentres2)./sum(TCtiming2)
meanTC2 = sum(TC2timing2.*binCentres2)./sum(TC2timing2)

[~, modeL5] = max(Cx5timing2+Cx5itiming2);
modeL5 = binCentres(modeL5)
[~, modeL23] = max(Cx23timing2+Cx23itiming2);
modeL23 = binCentres(modeL23)
[~, modeL4] = max(Cx4timing2+Cx4itiming2);
modeL4 = binCentres(modeL4)
[~, modeTC] = max(TCtiming2);
modeTC = binCentres(modeTC)
[~, modeTC2] = max(TC2timing2);
modeTC2 = binCentres(modeTC2)

[~, modeL5fit] = max(Cx5fitFull2);
modeL5fit = binCentres2(modeL5fit)
[~, modeL23fit] = max(Cx23fitFull2);
modeL23fit = binCentres2(modeL23fit)
[~, modeL4fit] = max(Cx4fitFull2);
modeL4fit = binCentres2(modeL4fit)
[~, modeTCfit] = max(TCfit2);
modeTCfit = binCentres2(modeTCfit)
[~, modeTC2fit] = max(TC2fit2);
modeTC2fit = binCentres2(modeTC2fit)

medianL5 = iMedian(Cx5timing2+Cx5itiming2);
medianL5 = binCentres(medianL5)
medianL23 = iMedian(Cx23timing2+Cx23itiming2);
medianL23 = binCentres(medianL23)
medianL4 = iMedian(Cx4timing2+Cx4itiming2);
medianL4 = binCentres(medianL4)
medianTC = iMedian(TCtiming2);
medianTC = binCentres(medianTC)
medianTC2 = iMedian(TC2timing2);
medianTC2 = binCentres(medianTC2)

f7 = figure('Units', 'normalized', 'Position', [0, .01, .98, .89]);
plot(binCentres2, Cx5timing2./100,'r','LineWidth',1)
hold on
plot(binCentres2, Cx5fit2,'r','LineWidth',5)
plot(binCentres2, Cx23timing2./100,'g','LineWidth',1)
plot(binCentres2, Cx23fit2,'g','LineWidth',5)
plot(binCentres2, Cx4timing2./100,'b','LineWidth',1)
plot(binCentres2, Cx4fit2,'b','LineWidth',5)
plot(binCentres2, TCtiming2./100,'c','LineWidth',1)
plot(binCentres2, TCfit2,'c','LineWidth',5)
plot(binCentres2, TC2timing2./100,'y','LineWidth',1)
plot(binCentres2, TC2fit2,'y','LineWidth',5)
hold off

f8 = figure('Units', 'normalized', 'Position', [0, .01, .98, .89]);
plot(binCentres2, Cx5timing2./max(Cx5timing2),'r','LineWidth',1)
hold on
plot(binCentres2, 100*Cx5fit2./max(Cx5timing2),'r','LineWidth',5)
plot(binCentres2, Cx23timing2./max(Cx23timing2),'g','LineWidth',1)
plot(binCentres2, 100*Cx23fit2./max(Cx23timing2),'g','LineWidth',5)
plot(binCentres2, Cx4timing2./max(Cx4timing2),'b','LineWidth',1)
plot(binCentres2, 100*Cx4fit2./max(Cx4timing2),'b','LineWidth',5)
plot(binCentres2, TCtiming2./max(TCtiming2),'c','LineWidth',1)
plot(binCentres2, 100*TCfit2./max(TCtiming2),'c','LineWidth',5)
plot(binCentres2, TC2timing2./max(TC2timing2),'y','LineWidth',1)
plot(binCentres2, 100*TC2fit2./max(TC2timing2),'y','LineWidth',5)
hold off

meanL5 = sum(Cx5timing2.*binCentres2)./sum(Cx5timing2)
meanL23 = sum(Cx23timing2.*binCentres2)./sum(Cx23timing2)
meanL4 = sum(Cx4timing2.*binCentres2)./sum(Cx4timing2)
meanTC = sum(TCtiming2.*binCentres2)./sum(TCtiming2)
meanTC2 = sum(TC2timing2.*binCentres2)./sum(TC2timing2)
meanTC3 = sum((TCtiming2+TC2timing2).*binCentres2)./sum(TCtiming2+TC2timing2)

[~, modeL5] = max(Cx5timing2);
modeL5 = binCentres2(modeL5)
[~, modeL23] = max(Cx23timing2);
modeL23 = binCentres2(modeL23)
[~, modeL4] = max(Cx4timing2);
modeL4 = binCentres2(modeL4)
[~, modeTC] = max(TCtiming2);
modeTC = binCentres2(modeTC)
[~, modeTC2] = max(TC2timing2);
modeTC2 = binCentres2(modeTC2)

[~, modeL5fit] = max(Cx5fit2);
modeL5fit = binCentres2(modeL5fit)
[~, modeL23fit] = max(Cx23fit2);
modeL23fit = binCentres2(modeL23fit)
[~, modeL4fit] = max(Cx4fit2);
modeL4fit = binCentres2(modeL4fit)
[~, modeTCfit] = max(TCfit2);
modeTCfit = binCentres2(modeTCfit)
[~, modeTC2fit] = max(TC2fit2);
modeTC2fit = binCentres2(modeTC2fit)

medianL5 = iMedian(Cx5timing2);
medianL5 = binCentres2(medianL5)
medianL23 = iMedian(Cx23timing2);
medianL23 = binCentres2(medianL23)
medianL4 = iMedian(Cx4timing2);
medianL4 = binCentres2(medianL4)
medianTC = iMedian(TCtiming2);
medianTC = binCentres2(medianTC)
medianTC2 = iMedian(TC2timing2);
medianTC2 = binCentres2(medianTC2)
medianTC3 = iMedian(TCtiming2+TC2timing2);
medianTC3 = binCentres2(medianTC3)
