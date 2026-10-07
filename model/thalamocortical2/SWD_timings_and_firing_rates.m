% The script file plots the membrane potential population data of thalamic cells.
function [] = SWD_timings_and_firing_rates
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

fullLength = 1;
xRange = [0 600000];

% EEG part:
% cellType = 'FS';
% for i = iList
%     i %#ok<*NOPRT>
%     fileName = list(i).name;
%     cellTypePrev = cellType;
%     cellType = fileName(20:21);
%     
%     if ~strcmp(cellType, 'FS')
%         % Load:
%         [~, data] = loadFile(fileName, AreaCx3, 'Cx3');
% 
%         % Resample:
%         [t, iunique] = unique(data.t);
%         iGlu = interp1(t,data.iGlu(iunique),t);
%         iGABA = interp1(t,data.iGABA(iunique),t);
%         dt = t(2)-t(1);
%         if ~fullLength
%             iRange = xRange./dt+1;
%             iRange = iRange(1):iRange(end);
%             t = t(iRange);
%             iGlu = iGlu(iRange);
%             iGABA = iGABA(iRange);
%         end
% 
%         % Estimate cell's contribution to EEG:
%         cellPos = str2double(fileName(15:18));
%         if strcmp(cellTypePrev, 'FS')
%             cellPosInit = cellPos;
%         end
%         cellPos = abs(cellPos - cellPosInit - 49.5)*20;
%         if strcmp(fileName(13), '2')
%             h = 351.8;
%         elseif strcmp(fileName(13), '4')
%             h = 693.4;
%         elseif strcmp(fileName(13), '5')
%             h = 1089.4;
%         elseif strcmp(fileName(13), '6')
%             h = 1597.2;
%         end
%         r_i = sqrt(h^2 + cellPos^2);
%         convFact = 1e-3*1e1*1e3; % nA --> uA: 1e-3, cm --> mm: 1e1, um^-1 --> mm^-1: 1e3
%         if i == iList(1)
%             EEG = zeros(size(t));
%         end
%         EEG = EEG + convFact*((230/(4*pi))*iGlu./r_i);
%         r_i = sqrt((h+500)^2 + cellPos^2);
%         EEG = EEG + convFact*((230/(4*pi))*iGABA./r_i);
%     end
% end
% 
% % Butterworth filter:
% Rp = 0.5;                                                                   % Passband riple, dB
% Rs = 10;                                                                    % Stopband attenuation, dB
% NyqFreq = (1000/dt)/2;                                                      % The Nyquist frequency
% Wp = 200/NyqFreq;                                                           % Passbands, normalised frequency
% Ws = 250/NyqFreq;                                                           % Stopband, normalised frequency
% [n, Wn] = buttord(Wp, Ws, Rp, Rs);                                          % n is a filter order
% [b, a] = butter(n, Wn, 'low');
% EEGfilt = filtfilt(double(b), double(a), EEG);
% f1 = figure('Units', 'normalized', 'Position', [0, .01, .98, .89]);
% plot(t*1e-3, EEGfilt, 'Color', 'k', 'LineWidth', 1)
% xlim(xRange/1000)
% hold on
% 
% EEGmean = mean(EEGfilt)*ones(size(EEGfilt));
% EEGsd = std(EEGfilt);
% upLim = EEGmean + EEGsd;
% loLim = EEGmean - EEGsd;
% plot([t'*1e-3 t'*1e-3 t'*1e-3],[upLim' EEGmean' loLim'],'r')
% 
% % waves = [2.4 2.65 2.95 3.2 3.6 3.85 4.1 4.4 4.7 5 5.25 5.5 5.8 6.1 6.35 6.6 6.9 7.15 7.45 7.7 8 8.3 8.55 8.85 9.1 9.4 9.7 9.95 10.25 10.5 10.8 11.1 11.35 11.65 11.9 12.2 12.5 12.8 13.05 13.35 13.65 13.9 14.25 14.5 14.8 15.1...
% %     15.35 15.65 15.9 16.15 16.45 16.75 55.9 56.15 56.45 56.7 57 57.3 57.55 57.8 58.1 58.4 58.65 58.95 59.2 59.5 59.75 60.05 60.3 60.6 60.9 61.15 61.45 61.75 62 62.3 62.6 62.85 63.1 63.4 63.7 63.95 64.2 64.5 64.8 65.1 65.35...
% %     65.6 65.9 66.2 66.45 66.75 67 67.3 67.6 67.85 68.15 68.45 68.7 69 69.25 69.5 69.8 70.1 70.35 70.6 70.85 71.1 71.35 107.35 107.7 107.9 108.2 108.45 108.75 109 109.3 109.6 109.85 110.1 110.45 110.7 111 111.25 111.5 111.8...
% %     112 112.3 112.55 112.85 113.15 113.4 113.7 114 114.25 114.5 114.8 115.1 115.35 115.65 115.9 116.2 116.5 116.75 117 117.25 117.55 117.8 118.1 118.4 118.65 118.9 119.2 119.45 119.75 120.05 120.3 120.55 120.85 121.1 121.4...
% %     121.65 121.95 122.2 122.5 122.8 123.05 123.3 123.6 123.9 124.2 124.45 124.7 125 125.25 125.55 125.8 126.1 126.35 126.6 126.9 127.15 162.25 162.55 162.8 163.1 163.35 163.6 163.88 164.15 164.45 164.7 165 165.25 165.55...
% %     165.8 166.08 166.35 166.6 166.9 167.15 167.45 167.75 168 168.3 168.55 168.85 169.1 169.4 169.65 169.95 170.2 170.5 170.8 171.05 171.35 171.6 171.9 172.2 172.45 172.75 173 173.3 173.6 173.9 174.2 174.45 174.75 175 175.3...
% %     175.6 175.9 176.2 176.45 176.7 177.05 177.25 177.55 226.15 226.5 226.75 227.07 227.3 227.6 227.85 228.15 228.4 228.7 229 229.25 229.5 229.8 230.1 230.4 230.65 230.9 231.2 231.5 231.75 232.05 232.3 232.6 232.85 233.15...
% %     233.4 233.7 234 234.25 234.5 234.8 235.05 235.4 235.6 235.9 236.2 236.5 236.75 237 237.3 237.6 237.85 238.15 238.4 238.7 239 239.25 239.55 239.8 240.1 240.4 240.65 240.95 241.25 241.5 241.8 242 242.3 242.6 242.85 243.1...
% %     243.4 243.6 243.9 284.5 284.75 285 285.22 285.5 285.8 286.08 286.4 286.62 286.85 287.2 287.5 287.75 288.05 288.3 288.6 288.85 289.15 289.4 289.7 289.95 290.22 290.5 290.8 291.05 291.35 291.6 291.9 292.15 292.45 292.7...
% %     293 293.25 293.55 293.85 294.15 294.4 294.7 295 295.25 295.55 295.8 296.1 296.4 296.7 297 297.25 297.55 297.8 298.1 298.4 298.65 298.9 299.2 299.45 299.7 299.95 300.3 343.5 344.6 344.95 345.24 345.52 345.78 346.04 346.36 346.62 346.92...
% %     347.2 347.45 347.61 347.75 347.9 348.01 348.16 348.3 348.6 348.85 349.1 349.4 349.7 349.92 350.2 350.5 350.8 351.1 351.31 351.6 351.9 352.15 352.45 352.71 353 353.3 353.55 353.85 354.1 354.4 354.7 354.95 355.25 355.52...
% %     355.8 356.1 356.4 356.7 356.93 357.2 357.5 357.8 358 358.3 358.57 358.81 359.1 359.3 359.6 400.7 401.03 401.3 401.6 401.8 402.12 402.4 402.65 402.9 403.22 403.45 403.75 404.03 404.3 404.6 404.9 405.15 405.45 405.75...
% %     405.95 406.25 406.55 406.8 407.1 407.35 407.63 407.9 408.2 408.45 408.71 409 409.27 409.55 409.82 410.1 410.4 410.65 410.92 411.2 411.5 411.77 412.05 412.33 412.6 412.88 413.15 413.45 413.75 414 414.3 414.6 414.85...
% %     415.12 415.4 415.66 415.95 416.2 416.5 416.75 417.05 417.3 417.6 417.83 418.15 418.4 418.7 418.95 419 455.4 455.7 455.91 456.2 456.5 456.8 457.04 457.32 457.56 457.9 458.1 458.4 458.68 458.96 459.25 459.5 459.8 460.1...
% %     460.35 460.65 460.9 461.2 461.41 461.7 462 462.3 462.55 462.8 463.1 463.4 463.65 463.92 464.2 464.5 464.8 465.05 465.3 465.6 465.9 466.15 466.45 466.7 467 467.25 467.52 467.78 468.1 468.35 468.62 468.9 469.17 469.45...
% %     469.72 470 470.3 470.6 470.85 471.1 471.4 471.65 471.9 472.2 472.5 472.75 473.05 473.3 473.6 473.85 474.1 474.4 474.65 474.95 475.2 475.4 475.77 513.25 513.6 513.86 514.15 514.42 514.69 515 515.3 515.51 515.82 516.15...
% %     516.4 516.65 517 517.2 517.5 517.8 518.06 518.35 518.63 518.9 519.2 519.4 519.75 520.03 520.3 520.55 520.85 521.1 521.4 521.65 521.92 522.2 522.5 522.8 523 523.3 523.6 523.9 524.15 524.4 524.7 524.97 525.25 525.52 525.8...
% %     526.1 526.35 526.65 526.95 527.2 527.5 527.8 528.05 528.35 528.6 528.9 529.15 529.45 529.75 530 530.25 530.5 530.8 531 531.28 531.45 531.7 567.25 567.57 567.82 568.18 568.4 568.7 569 569.23 569.58 569.75 570.1 570.35...
% %     570.65 570.9 571.2 571.43 571.7 571.98 572.25 572.5 572.8 573.1 573.35 573.63 573.95 574.2 574.45 574.75 575.01 575.3 575.55 575.85 576.1 576.4 576.7 576.95 577.23 577.5 577.8 578.1 578.37 578.62 578.9 579.2 579.45...
% %     579.75 580.1 580.3 580.6 580.9 581.15 581.43 581.7 582 582.25 582.55 582.8 583.1 583.35 583.6 583.86 584.16 584.45 584.72 585 585.82 586.1 586.35 586.63 ]*1000-xRange(1);
% waves = [55.9 56.15 56.45 56.7 57 57.3 57.55 57.8 58.1 58.4 58.65 58.95 59.2 59.5 59.75 60.05 60.3 60.6 60.9 61.15 61.45 61.75 62 62.3 62.6 62.85 63.1 63.4 63.7 63.95 64.2 64.5 64.8 65.1 65.35...
%     65.6 65.9 66.2 66.45 66.75 67 67.3 67.6 67.85 68.15 68.45 68.7 69 69.25 69.5 69.8 70.1 70.35 70.6 70.85 71.1 71.35 107.35 107.7 107.9 108.2 108.45 108.75 109 109.3 109.6 109.85 110.1 110.45 110.7 111 111.25 111.5 111.8...
%     112 112.3 112.55 112.85 113.15 113.4 113.7 114 114.25 114.5 114.8 115.1 115.35 115.65 115.9 116.2 116.5 116.75 117 117.25 117.55 117.8 118.1 118.4 118.65 118.9 119.2 119.45 119.75 120.05 120.3 120.55 120.85 121.1 121.4...
%     121.65 121.95 122.2 122.5 122.8 123.05 123.3 123.6 123.9 124.2 124.45 124.7 125 125.25 125.55 125.8 126.1 126.35 126.6 126.9 127.15 162.25 162.55 162.8 163.1 163.35 163.6 163.88 164.15 164.45 164.7 165 165.25 165.55...
%     165.8 166.08 166.35 166.6 166.9 167.15 167.45 167.75 168 168.3 168.55 168.85 169.1 169.4 169.65 169.95 170.2 170.5 170.8 171.05 171.35 171.6 171.9 172.2 172.45 172.75 173 173.3 173.6 173.9 174.2 174.45 174.75 175 175.3...
%     175.6 175.9 176.2 176.45 176.7 177.05 177.25 177.55 226.15 226.5 226.75 227.07 227.3 227.6 227.85 228.15 228.4 228.7 229 229.25 229.5 229.8 230.1 230.4 230.65 230.9 231.2 231.5 231.75 232.05 232.3 232.6 232.85 233.15...
%     233.4 233.7 234 234.25 234.5 234.8 235.05 235.4 235.6 235.9 236.2 236.5 236.75 237 237.3 237.6 237.85 238.15 238.4 238.7 239 239.25 239.55 239.8 240.1 240.4 240.65 240.95 241.25 241.5 241.8 242 242.3 242.6 242.85 243.1...
%     243.4 243.6 243.9 284.5 284.75 285 285.22 285.5 285.8 286.08 286.4 286.62 286.85 287.2 287.5 287.75 288.05 288.3 288.6 288.85 289.15 289.4 289.7 289.95 290.22 290.5 290.8 291.05 291.35 291.6 291.9 292.15 292.45 292.7...
%     293 293.25 293.55 293.85 294.15 294.4 294.7 295 295.25 295.55 295.8 296.1 296.4 296.7 297 297.25 297.55 297.8 298.1 298.4 298.65 298.9 299.2 299.45 299.7 299.95 300.3 343.5 344.6 344.95 345.24 345.52 345.78 346.04 346.36 346.62 346.92...
%     347.2 347.45 347.61 347.75 347.9 348.01 348.16 348.3 348.6 348.85 349.1 349.4 349.7 349.92 350.2 350.5 350.8 351.1 351.31 351.6 351.9 352.15 352.45 352.71 353 353.3 353.55 353.85 354.1 354.4 354.7 354.95 355.25 355.52...
%     355.8 356.1 356.4 356.7 356.93 357.2 357.5 357.8 358 358.3 358.57 358.81 359.1 359.3 359.6 400.7 401.03 401.3 401.6 401.8 402.12 402.4 402.65 402.9 403.22 403.45 403.75 404.03 404.3 404.6 404.9 405.15 405.45 405.75...
%     405.95 406.25 406.55 406.8 407.1 407.35 407.63 407.9 408.2 408.45 408.71 409 409.27 409.55 409.82 410.1 410.4 410.65 410.92 411.2 411.5 411.77 412.05 412.33 412.6 412.88 413.15 413.45 413.75 414 414.3 414.6 414.85...
%     415.12 415.4 415.66 415.95 416.2 416.5 416.75 417.05 417.3 417.6 417.83 418.15 418.4 418.7 418.95 419 455.4 455.7 455.91 456.2 456.5 456.8 457.04 457.32 457.56 457.9 458.1 458.4 458.68 458.96 459.25 459.5 459.8 460.1...
%     460.35 460.65 460.9 461.2 461.41 461.7 462 462.3 462.55 462.8 463.1 463.4 463.65 463.92 464.2 464.5 464.8 465.05 465.3 465.6 465.9 466.15 466.45 466.7 467 467.25 467.52 467.78 468.1 468.35 468.62 468.9 469.17 469.45...
%     469.72 470 470.3 470.6 470.85 471.1 471.4 471.65 471.9 472.2 472.5 472.75 473.05 473.3 473.6 473.85 474.1 474.4 474.65 474.95 475.2 475.4 475.77 513.25 513.6 513.86 514.15 514.42 514.69 515 515.3 515.51 515.82 516.15...
%     516.4 516.65 517 517.2 517.5 517.8 518.06 518.35 518.63 518.9 519.2 519.4 519.75 520.03 520.3 520.55 520.85 521.1 521.4 521.65 521.92 522.2 522.5 522.8 523 523.3 523.6 523.9 524.15 524.4 524.7 524.97 525.25 525.52 525.8...
%     526.1 526.35 526.65 526.95 527.2 527.5 527.8 528.05 528.35 528.6 528.9 529.15 529.45 529.75 530 530.25 530.5 530.8 531 531.28 531.45 531.7 567.25 567.57 567.82 568.18 568.4 568.7 569 569.23 569.58 569.75 570.1 570.35...
%     570.65 570.9 571.2 571.43 571.7 571.98 572.25 572.5 572.8 573.1 573.35 573.63 573.95 574.2 574.45 574.75 575.01 575.3 575.55 575.85 576.1 576.4 576.7 576.95 577.23 577.5 577.8 578.1 578.37 578.62 578.9 579.2 579.45...
%     579.75 580.1 580.3 580.6 580.9 581.15 581.43 581.7 582 582.25 582.55 582.8 583.1 583.35 583.6 583.86 584.16 584.45 584.72 585 585.82 586.1 586.35 586.63 ]*1000-xRange(1);
% % figure('Units', 'normalized', 'Position', [0, .01, .98, .89]);
% % plot(waves, 1:length(waves))
% waves = (waves./dt)+1;
% spikes = zeros(1,length(waves)-1);
% for i = 1:length(waves)-1
%     waveRange = round(waves(i)):round(waves(i+1));
%     [~,j] = min(EEGfilt(waveRange));
%     spikes(i) = waveRange(1)+j-1;   % identify spikes
% end
% spikes2 = [waves(1) spikes waves(end)];
% for i = 1:length(spikes2)-1
%     spikeRange = spikes2(i):spikes2(i+1);
%     [~,j] = max(EEGfilt(spikeRange));
%     waves(i) = spikeRange(1)+j-1;   % identify waves
% end
% for i = 2:length(spikes)-1
%     if i < length(spikes)
%         if t(spikes(i))-t(spikes(i-1)) > 500 && t(spikes(i+1))-t(spikes(i)) > 500
%             spikes(i) = [];
%             waves(i+1) = [];
%         end
%     end
% end
% tSpikes = t;
% for i = 1:length(waves)-1
%     if i == 1
%         waveRange = 1:waves(i+1);
%     elseif i == length(waves)-1
%         waveRange = waves(i):length(tSpikes);
%     else
%         waveRange = waves(i):waves(i+1);
%     end
%     tSpikes(waveRange) = t(spikes(i));
% end
% tSpikesInit = tSpikes;  % spike times delineated by waves
% tSpikes = t - tSpikes;  % time relative to nearest spikes
% 
% plot(t(waves)*1e-3,EEGfilt(waves),'b.','MarkerSize',20)
% plot(t(spikes)*1e-3,EEGfilt(spikes),'r.','MarkerSize',20)
% hold off
% 
% save('EEG.mat','t','dt','EEG','EEGfilt','tSpikes','spikes','waves','tSpikesInit','AreaCx3','AreaTC','AreaNRT','list','fullLength','xRange');
% load('EEG.mat');
% 
% % Membrane potential part:
% iList = 1:900;
% cellTypes = cell(length(iList),1);
% nPY = 100;
% nIN = 50;
% nTC = 100;
% nNRT = 50;
% 
% binSize = 2.5;
% histRange = [-100-binSize 100+binSize];
% binCentres = (histRange(1):binSize:histRange(2));
% 
% for i = iList
%     i
%     fileName = list(i).name;
%     if i <= 4*(nPY+nIN)
%         [~, data, cellTypes{i}] = loadFile(fileName, AreaCx3, 'Cx3');
%     elseif i <= 4*(nPY+nIN)+2*nNRT
%         [~, data, cellTypes{i}] = loadFile(fileName, AreaNRT, 'NRT');
%     elseif i <= 4*(nPY+nIN)+2*nNRT+2*nTC
%         [~, data, cellTypes{i}] = loadFile(fileName, AreaTC, 'TC');
%     end
%     
%     % Resample:
%     [t, iunique] = unique(data.t);
%     v = interp1(t,data.v(iunique),t);
%     if ~fullLength
%         t = t(iRange);
%         v = v(iRange);
%     end
%     
%     if i == iList(1)
%         vTC = zeros(nTC, length(v));
%         TCraster = vTC;
%         TCtiming = zeros(1,length(binCentres));
%         TCtimingFirst = TCtiming;
%         slide = 100;
%         window = 1000;
%         ISI_Cx = 18;
%         ISI_Th = 18;
%         spikeVic = 80;
%         TCFR = zeros(nTC, floor(t(end)/slide));
%         TCBR = TCFR;
%         TCTR = TCFR;
%         TCBR2 = zeros(nTC, length(spikes));
%         TCTR2 = TCBR2;
%         TCSR2 = TCBR2;
%         vNRT = zeros(nNRT, length(v));
%         NRTraster = vNRT;
%         NRTtiming = TCtiming;
%         NRTtimingFirst = TCtiming;
%         NRTFR = zeros(nNRT, floor(t(end)/slide));
%         NRTBR = NRTFR;
%         NRTTR = NRTFR;
%         NRTBR2 = zeros(nNRT, length(spikes));
%         NRTTR2 = NRTBR2;
%         NRTSR2 = NRTBR2;
%         vTC2 = vTC;
%         TC2raster = vTC;
%         TC2timing = TCtiming;
%         TC2timingFirst = TCtiming;
%         TC2FR = TCFR;
%         TC2BR = TCFR;
%         TC2TR = TCFR;
%         TC2BR2 = TCBR2;
%         TC2TR2 = TCBR2;
%         TC2SR2 = TCBR2;
%         vNRT2 = vNRT;
%         NRT2raster = vNRT;
%         NRT2timing = TCtiming;
%         NRT2timingFirst = TCtiming;
%         NRT2FR = NRTFR;
%         NRT2BR = NRTFR;
%         NRT2TR = NRTFR;
%         NRT2FR = NRTFR;
%         NRT2BR = NRTFR;
%         NRT2TR = NRTFR;
%         NRT2BR2 = NRTBR2;
%         NRT2TR2 = NRTBR2;
%         NRT2SR2 = NRTBR2;
%         vCx23 = zeros(nPY, length(v));
%         Cx23raster = vCx23;
%         Cx23timing = TCtiming;
%         Cx23timingFirst = TCtiming;
%         Cx23FR = zeros(nPY, floor(t(end)/slide));
%         Cx23BR = Cx23FR;
%         Cx23TR = Cx23FR;
%         Cx23BR2 = zeros(nPY, length(spikes));
%         Cx23TR2 = Cx23BR2;
%         Cx23SR2 = Cx23BR2;
%         vCx23i = zeros(nIN, length(v));
%         Cx23iraster = vCx23i;
%         Cx23itiming = TCtiming;
%         Cx23itimingFirst = TCtiming;
%         Cx23iFR = zeros(nIN, floor(t(end)/slide));
%         Cx23iBR = Cx23iFR;
%         Cx23iTR = Cx23iFR;
%         Cx23iBR2 = zeros(nIN, length(spikes));
%         Cx23iTR2 = Cx23iBR2;
%         Cx23iSR2 = Cx23iBR2;
%         vCx4 = vCx23;
%         Cx4raster = vCx23;
%         Cx4timing = TCtiming;
%         Cx4timingFirst = TCtiming;
%         Cx4FR = Cx23FR;
%         Cx4BR = Cx23FR;
%         Cx4TR = Cx23FR;
%         Cx4BR2 = Cx23BR2;
%         Cx4TR2 = Cx23BR2;
%         Cx4SR2 = Cx23BR2;
%         vCx4i = vCx23i;
%         Cx4iraster = vCx23i;
%         Cx4itiming = TCtiming;
%         Cx4itimingFirst = TCtiming;
%         Cx4iFR = Cx23iFR;
%         Cx4iBR = Cx23iFR;
%         Cx4iTR = Cx23iFR;
%         Cx4iBR2 = Cx23iBR2;
%         Cx4iTR2 = Cx23iBR2;
%         Cx4iSR2 = Cx23iBR2;
%         vCx5 = vCx23;
%         Cx5raster = vCx23;
%         Cx5timing = TCtiming;
%         Cx5timingFirst = TCtiming;
%         Cx5FR = Cx23FR;
%         Cx5BR = Cx23FR;
%         Cx5TR = Cx23FR;
%         Cx5BR2 = Cx23BR2;
%         Cx5TR2 = Cx23BR2;
%         Cx5SR2 = Cx23BR2;
%         Cx5NDtiming = TCtiming;
%         Cx5NDtimingFirst = TCtiming;
%         vCx5i = vCx23i;
%         Cx5iraster = vCx23i;
%         Cx5itiming = TCtiming;
%         Cx5itimingFirst = TCtiming;
%         Cx5iFR = Cx23iFR;
%         Cx5iBR = Cx23iFR;
%         Cx5iTR = Cx23iFR;
%         Cx5iBR2 = Cx23iBR2;
%         Cx5iTR2 = Cx23iBR2;
%         Cx5iSR2 = Cx23iBR2;
%         vCx6 = vCx23;
%         Cx6raster = vCx23;
%         Cx6timing = TCtiming;
%         Cx6timingFirst = TCtiming;
%         Cx6FR = Cx23FR;
%         Cx6BR = Cx23FR;
%         Cx6TR = Cx23FR;
%         Cx6BR2 = Cx23BR2;
%         Cx6TR2 = Cx23BR2;
%         Cx6SR2 = Cx23BR2;
%         vCx6i = vCx23i;
%         Cx6iraster = vCx23i;
%         Cx6itiming = TCtiming;
%         Cx6itimingFirst = TCtiming;
%         Cx6iFR = Cx23iFR;
%         Cx6iBR = Cx23iFR;
%         Cx6iTR = Cx23iFR;
%         Cx6iBR2 = Cx23iBR2;
%         Cx6iTR2 = Cx23iBR2;
%         Cx6iSR2 = Cx23iBR2;
%     end
%     
%     if i >= 1 && i <= nPY
%         [vCx23(i,:), Cx23raster(i,:), Cx23timing, ~, Cx23timingFirst, ~, Cx23FR(i,:), Cx23BR(i,:), Cx23TR(i,:), tSlide, Cx23BR2(i,:), Cx23TR2(i,:), Cx23SR2(i,:)] = tFunc(t,v,tSpikes,tSpikesInit,Cx23timing,binCentres,Cx23timingFirst,slide,window,ISI_Cx,spikeVic,spikes);
%     elseif i >= nPY+1 && i <= nPY+nIN
%         ind = i-nPY;
%         [vCx23i(ind,:), Cx23iraster(ind,:), Cx23itiming, ~, Cx23itimingFirst, ~, Cx23iFR(ind,:), Cx23iBR(ind,:), Cx23iTR(ind,:), ~, Cx23iBR2(ind,:), Cx23iTR2(ind,:), Cx23iSR2(ind,:)] = tFunc(t,v,tSpikes,tSpikesInit,Cx23itiming,binCentres,Cx23itimingFirst,slide,window,ISI_Cx,spikeVic,spikes);
%     elseif i >= nPY+nIN && i <= 2*nPY+nIN
%         ind = i-(nPY+nIN);
%         [vCx4(ind,:), Cx4raster(ind,:), Cx4timing, ~, Cx4timingFirst, ~, Cx4FR(ind,:), Cx4BR(ind,:), Cx4TR(ind,:), ~, Cx4BR2(ind,:), Cx4TR2(ind,:), Cx4SR2(ind,:)] = tFunc(t,v,tSpikes,tSpikesInit,Cx4timing,binCentres,Cx4timingFirst,slide,window,ISI_Cx,spikeVic,spikes);
%     elseif i >= 2*nPY+nIN+1 && i <= 2*nPY+2*nIN
%         ind = i-(2*nPY+nIN);
%         [vCx4i(ind,:), Cx4iraster(ind,:), Cx4itiming, ~, Cx4itimingFirst, ~, Cx4iFR(ind,:), Cx4iBR(ind,:), Cx4iTR(ind,:), ~, Cx4iBR2(ind,:), Cx4iTR2(ind,:), Cx4iSR2(ind,:)] = tFunc(t,v,tSpikes,tSpikesInit,Cx4itiming,binCentres,Cx4itimingFirst,slide,window,ISI_Cx,spikeVic,spikes);
%     elseif i >= 2*nPY+2*nIN+1 && i <= 3*nPY+2*nIN
%         ind = i-(2*nPY+2*nIN);
%         [vCx5(ind,:), Cx5raster(ind,:), Cx5timing, timing, Cx5timingFirst, timingFirst, Cx5FR(ind,:), Cx5BR(ind,:), Cx5TR(ind,:), ~, Cx5BR2(ind,:), Cx5TR2(ind,:), Cx5SR2(ind,:)] = tFunc(t,v,tSpikes,tSpikesInit,Cx5timing,binCentres,Cx5timingFirst,slide,window,ISI_Cx,spikeVic,spikes);
%         if strcmp(cellTypes{i},'ND')
%             Cx5NDtiming = Cx5NDtiming + timing;
%             Cx5NDtimingFirst = Cx5NDtimingFirst + timingFirst;
%         end
%     elseif i >= 3*nPY+2*nIN+1 && i <= 3*nPY+3*nIN
%         ind = i-(3*nPY+2*nIN);
%         [vCx5i(ind,:), Cx5iraster(ind,:), Cx5itiming, ~, Cx5itimingFirst, ~, Cx5iFR(ind,:), Cx5iBR(ind,:), Cx5iTR(ind,:), ~, Cx5iBR2(ind,:), Cx5iTR2(ind,:), Cx5iSR2(ind,:)] = tFunc(t,v,tSpikes,tSpikesInit,Cx5itiming,binCentres,Cx5itimingFirst,slide,window,ISI_Cx,spikeVic,spikes);
%     elseif i >= 3*nPY+3*nIN+1 && i <= 4*nPY+3*nIN
%         ind = i-(3*nPY+3*nIN);
%         [vCx6(ind,:), Cx6raster(ind,:), Cx6timing, ~, Cx6timingFirst, ~, Cx6FR(ind,:), Cx6BR(ind,:), Cx6TR(ind,:), ~, Cx6BR2(ind,:), Cx6TR2(ind,:), Cx6SR2(ind,:)] = tFunc(t,v,tSpikes,tSpikesInit,Cx6timing,binCentres,Cx6timingFirst,slide,window,ISI_Cx,spikeVic,spikes);
%     elseif i >= 4*nPY+3*nIN+1 && i <= 4*nPY+4*nIN
%         ind = i-(4*nPY+3*nIN);
%         [vCx6i(ind,:), Cx6iraster(ind,:), Cx6itiming, ~, Cx6itimingFirst, ~, Cx6iFR(ind,:), Cx6iBR(ind,:), Cx6iTR(ind,:), ~, Cx6iBR2(ind,:), Cx6iTR2(ind,:), Cx6iSR2(ind,:)] = tFunc(t,v,tSpikes,tSpikesInit,Cx6itiming,binCentres,Cx6itimingFirst,slide,window,ISI_Cx,spikeVic,spikes);
%     elseif i >= 4*nPY+4*nIN+1 && i <= 4*nPY+4*nIN+nNRT
%         ind = i-(4*nPY+4*nIN);
%         [vNRT(ind,:), NRTraster(ind,:), NRTtiming, ~, NRTtimingFirst, ~, NRTFR(ind,:), NRTBR(ind,:), NRTTR(ind,:), ~, NRTBR2(ind,:), NRTTR2(ind,:), NRTSR2(ind,:)] = tFunc(t,v,tSpikes,tSpikesInit,NRTtiming,binCentres,NRTtimingFirst,slide,window,ISI_Th,spikeVic,spikes);
%     elseif i >= 4*nPY+4*nIN+nNRT+1 && i <= 4*nPY+4*nIN+2*nNRT
%         ind = i-(4*nPY+4*nIN+nNRT);
%         [vNRT2(ind,:), NRT2raster(ind,:), NRT2timing, ~, NRT2timingFirst, ~, NRT2FR(ind,:), NRT2BR(ind,:), NRT2TR(ind,:), ~, NRT2BR2(ind,:), NRT2TR2(ind,:), NRT2SR2(ind,:)] = tFunc(t,v,tSpikes,tSpikesInit,NRT2timing,binCentres,NRT2timingFirst,slide,window,ISI_Th,spikeVic,spikes);
%     elseif i >= 4*nPY+4*nIN+2*nNRT+1 && i <= 4*nPY+4*nIN+2*nNRT+nTC
%         ind = i-(4*nPY+4*nIN+2*nNRT);
%         [vTC(ind,:), TCraster(ind,:), TCtiming, ~, TCtimingFirst, ~, TCFR(ind,:), TCBR(ind,:), TCTR(ind,:), ~, TCBR2(ind,:), TCTR2(ind,:), TCSR2(ind,:)] = tFunc(t,v,tSpikes,tSpikesInit,TCtiming,binCentres,TCtimingFirst,slide,window,ISI_Th,spikeVic,spikes);
%     elseif i >= 4*nPY+4*nIN+2*nNRT+nTC+1 && i <= 4*nPY+4*nIN+2*nNRT+2*nTC
%         ind = i-(4*nPY+4*nIN+2*nNRT+nTC);
%         [vTC2(ind,:), TC2raster(ind,:), TC2timing, ~, TC2timingFirst, ~, TC2FR(ind,:), TC2BR(ind,:), TC2TR(ind,:), ~, TC2BR2(ind,:), TC2TR2(ind,:), TC2SR2(ind,:)] = tFunc(t,v,tSpikes,tSpikesInit,TC2timing,binCentres,TC2timingFirst,slide,window,ISI_Th,spikeVic,spikes);
%     end
% end
% 
% binCentres = binCentres(2:end-1);
% Cx23timing = Cx23timing(2:end-1);
% Cx23itiming = Cx23itiming(2:end-1); %#ok<*NASGU>
% Cx4timing = Cx4timing(2:end-1);
% Cx4itiming = Cx4itiming(2:end-1);
% Cx5timing = Cx5timing(2:end-1);
% Cx5NDtiming = Cx5NDtiming(2:end-1);
% Cx5noNDtiming = Cx5timing-Cx5NDtiming;
% Cx5itiming = Cx5itiming(2:end-1);
% Cx6timing = Cx6timing(2:end-1);
% Cx6itiming = Cx6itiming(2:end-1);
% Cx56timing = Cx5timing+Cx6timing;
% NRTtiming = NRTtiming(2:end-1);
% NRT2timing = NRT2timing(2:end-1);
% NRT3timing = NRTtiming + NRT2timing;
% TCtiming = TCtiming(2:end-1);
% TC2timing = TC2timing(2:end-1);
% TC3timing = TCtiming + TC2timing;
% 
% Cx23timingFirst = Cx23timingFirst(2:end-1);
% Cx23itimingFirst = Cx23itimingFirst(2:end-1);
% Cx4timingFirst = Cx4timingFirst(2:end-1);
% Cx4itimingFirst = Cx4itimingFirst(2:end-1);
% Cx5timingFirst = Cx5timingFirst(2:end-1);
% Cx5NDtimingFirst = Cx5NDtimingFirst(2:end-1);
% Cx5noNDtimingFirst = Cx5timingFirst-Cx5NDtimingFirst;
% Cx5itimingFirst = Cx5itimingFirst(2:end-1);
% Cx6timingFirst = Cx6timingFirst(2:end-1);
% Cx6itimingFirst = Cx6itimingFirst(2:end-1);
% Cx56timingFirst = Cx5timingFirst+Cx6timingFirst;
% NRTtimingFirst = NRTtimingFirst(2:end-1);
% NRT2timingFirst = NRT2timingFirst(2:end-1);
% NRT3timingFirst = NRTtimingFirst + NRT2timingFirst;
% TCtimingFirst = TCtimingFirst(2:end-1);
% TC2timingFirst = TC2timingFirst(2:end-1);
% TC3timingFirst = TCtimingFirst + TC2timingFirst;
% 
% save('SWD_timings_100_1000_18_18_2.5.mat','TCtiming','TCtimingFirst','TCBR','TCFR','TCTR','TCBR2','TCTR2','TCSR2','NRTtiming','NRTtimingFirst','NRTBR','NRTFR','NRTTR','NRTBR2','NRTTR2','NRTSR2','TC2timing','TC2timingFirst',...
%     'TC2BR','TC2FR','TC2TR','TC2BR2','TC2TR2','TC2SR2','TC3timing','TC3timingFirst','NRT2raster','NRT2timing','NRT2timingFirst','NRT2BR','NRT2FR','NRT2TR','NRT2BR2','NRT2TR2','NRT2SR2','NRT3timing','NRT3timingFirst',...
%     'Cx23timing','Cx23timingFirst','Cx23BR','Cx23FR','Cx23TR','Cx23BR2','Cx23TR2','Cx23SR2','Cx23itiming','Cx23itimingFirst','Cx23iBR','Cx23iFR','Cx23iTR','Cx23iBR2','Cx23iTR2','Cx23iSR2','Cx4timing','Cx4timingFirst',...
%     'Cx4BR','Cx4FR','Cx4TR','Cx4BR2','Cx4TR2','Cx4SR2','Cx4itiming','Cx4itimingFirst','Cx4iBR','Cx4iFR','Cx4iTR','Cx4iBR2','Cx4iTR2','Cx4iSR2','Cx5timing','Cx5timingFirst','Cx5BR','Cx5FR','Cx5TR','Cx5BR2','Cx5TR2','Cx5SR2',...
%     'Cx5NDtiming','Cx5NDtimingFirst','Cx5noNDtiming','Cx5noNDtiming','Cx5itimingFirst','Cx5itiming','Cx5itimingFirst','Cx5iBR','Cx5iFR','Cx5iTR','Cx5iBR2','Cx5iTR2','Cx5iSR2','Cx6timing','Cx6timingFirst','Cx6BR','Cx6FR',...
%     'Cx6TR','Cx6BR2','Cx6TR2','Cx6SR2','Cx6itiming','Cx6itimingFirst','Cx6iBR','Cx6iFR','Cx6iTR','Cx6iBR2','Cx6iTR2','Cx6iSR2','Cx56timing','Cx56timingFirst','binCentres','tSlide','t','spikes','dt');
load('SWD_timings_100_1000_18_18_2.5.mat');



[Cx23fit, L23params] = gaussian(binCentres,Cx23timing/100); %#ok<*ASGLU>
[Cx4fit, L4params] = gaussian(binCentres,Cx4timing/100);
[Cx5fit, L5params] = gaussian(binCentres,Cx5timing/100);
[Cx6fit, L6params] = gaussian(binCentres,Cx6timing/100);
[Cx56fit, L56params] = gaussian(binCentres,Cx56timing/200);
[NRTfit, NRTparams] = gaussian(binCentres,NRTtiming/100);
[NRT2fit, NRT2params] = gaussian(binCentres,NRT2timing/100);
[NRT3fit, NRT3params] = gaussian(binCentres,NRT3timing/200);
[TCfit, TCparams] = gaussian(binCentres,TCtiming/100);
[TC2fit, TC2params] = gaussian(binCentres,TC2timing/100);
[TC3fit, TC3params] = gaussian(binCentres,TC3timing/200);
% [Cx23fit L23params] = gaussian(binCentres,Cx23timing/sum(Cx23timing));
% [Cx4fit L4params] = gaussian(binCentres,Cx4timing/sum(Cx4timing));
% [Cx5fit L5params] = gaussian(binCentres,Cx5timing/sum(Cx5timing));
% [Cx6fit L6params] = gaussian(binCentres,Cx6timing/sum(Cx6timing));
% [Cx56fit L56params] = gaussian(binCentres,Cx56timing/sum(Cx56timing));
% [NRTfit NRTparams] = gaussian(binCentres,NRTtiming/sum(NRTtiming));
% [NRT2fit NRT2params] = gaussian(binCentres,NRT2timing/sum(NRT2timing));
% [NRT3fit NRT3params] = gaussian(binCentres,NRT3timing/sum(NRT3timing));
% [TCfit TCparams] = gaussian(binCentres,TCtiming/sum(TCtiming));
% [TC2fit TC2params] = gaussian(binCentres,TC2timing/sum(TC2timing));
% [TC3fit TC3params] = gaussian(binCentres,TC3timing/sum(TC3timing));

[Cx23fitFirst, L23paramsFirst] = gaussian(binCentres,Cx23timingFirst/100);
[Cx4fitFirst, L4paramsFirst] = gaussian(binCentres,Cx4timingFirst/100);
[Cx5fitFirst, L5paramsFirst] = gaussian(binCentres,Cx5timingFirst/100);
[Cx6fitFirst, L6paramsFirst] = gaussian(binCentres,Cx6timingFirst/100);
[Cx56fitFirst, L56paramsFirst] = gaussian(binCentres,Cx56timingFirst/200);
[NRTfitFirst, NRTparamsFirst] = gaussian(binCentres,NRTtimingFirst/100);
[NRT2fitFirst, NRT2paramsFirst] = gaussian(binCentres,NRT2timingFirst/100);
[NRT3fitFirst, NRT3paramsFirst] = gaussian(binCentres,NRT3timingFirst/200);
[TCfitFirst, TCparamsFirst] = gaussian(binCentres,TCtimingFirst/100);
[TC2fitFirst, TC2paramsFirst] = gaussian(binCentres,TC2timingFirst/100);
[TC3fitFirst, TC3paramsFirst] = gaussian(binCentres,TC3timingFirst/200);
% [Cx23fitFirst L23paramsFirst] = gaussian(binCentres,Cx23timingFirst/sum(Cx23timingFirst));
% [Cx4fitFirst L4paramsFirst] = gaussian(binCentres,Cx4timingFirst/sum(Cx4timingFirst));
% [Cx5fitFirst L5paramsFirst] = gaussian(binCentres,Cx5timingFirst/sum(Cx5timingFirst));
% [Cx6fitFirst L6paramsFirst] = gaussian(binCentres,Cx6timingFirst/sum(Cx6timingFirst));
% [Cx56fitFirst L56paramsFirst] = gaussian(binCentres,Cx56timingFirst/sum(Cx56timingFirst));
% [NRTfitFirst NRTparamsFirst] = gaussian(binCentres,NRTtimingFirst/sum(NRTtimingFirst));
% [NRT2fitFirst NRT2paramsFirst] = gaussian(binCentres,NRT2timingFirst/sum(NRT2timingFirst));
% [NRT3fitFirst NRT3paramsFirst] = gaussian(binCentres,NRT3timingFirst/sum(NRT3timingFirst));
% [TCfitFirst TCparamsFirst] = gaussian(binCentres,TCtimingFirst/sum(TCtimingFirst));
% [TC2fitFirst TC2paramsFirst] = gaussian(binCentres,TC2timingFirst/sum(TC2timingFirst));
% [TC3fitFirst TC3paramsFirst] = gaussian(binCentres,TC3timingFirst/sum(TC3timingFirst));

f2 = figure('Units', 'normalized', 'Position', [0, .01, .98, .89]);
hold on
orange = [255 140 0]/255;
gold = [255 215 0]/255;
plot(binCentres, Cx56timing/200,'r','LineWidth',1)
plot(binCentres, Cx56fit,'r','LineWidth',5)
%plot([L56params.b1 L56params.b1], [0 L56params.a1],'r--','LineWidth',1)
%plot(binCentres, Cx5timing/100,'r--','LineWidth',1)
%plot(binCentres, Cx5fit,'r--','LineWidth',5)
%plot(binCentres, Cx6timing/100,'r','LineWidth',1)
%plot(binCentres, Cx6fit,'r','LineWidth',5)
plot(binCentres, Cx23timing/100,'g','LineWidth',1)
plot(binCentres, Cx23fit,'g','LineWidth',5)
%plot([L23params.b1 L23params.b1], [0 L23params.a1],'g--','LineWidth',1)
plot(binCentres, Cx4timing/100,'m','LineWidth',1)
plot(binCentres, Cx4fit,'m','LineWidth',5)
%plot([L4params.b1 L4params.b1], [0 L4params.a1],'m--','LineWidth',1)
plot(binCentres, TCtiming/100,'Color',gold,'LineWidth',1)
plot(binCentres, TCfit,'Color',gold,'LineWidth',5)
%plot([TCparams.b1 TCparams.b1], [0 TCparams.a1],'Color',gold,'LineStyle','--','LineWidth',1)
plot(binCentres, TC2timing/100,'Color',orange,'LineWidth',1)
plot(binCentres, TC2fit,'Color',orange,'LineWidth',5)
%plot([TC2params.b1 TC2params.b1], [0 TC2params.a1],'Color',orange,'LineStyle','--','LineWidth',1)
% plot(binCentres, TC3timing/200,'Color',orange,'LineWidth',1)
% plot(binCentres, TC3fit,'Color',orange,'LineWidth',5)
plot(binCentres, NRTtiming/100,'c','LineWidth',1)
plot(binCentres, NRTfit,'c','LineWidth',5)
%plot([NRTparams.b1 NRTparams.b1], [0 NRTparams.a1],'c--','LineWidth',1)
plot(binCentres, NRT2timing/100,'b','LineWidth',1)
plot(binCentres, NRT2fit,'b','LineWidth',5)
%plot([NRT2params.b1 NRT2params.b1], [0 NRT2params.a1],'b--','LineWidth',1)
% plot(binCentres, NRT3timing/200,'b','LineWidth',1)
% plot(binCentres, NRT3fit,'b','LineWidth',5)
% plot(binCentres, Cx23timing/sum(Cx23timing),'r','LineWidth',1)
% plot(binCentres, Cx23fit,'g','LineWidth',5)
% plot(binCentres, Cx4timing/sum(Cx4timing),'m','LineWidth',1)
% plot(binCentres, Cx4fit,'m','LineWidth',5)
% plot(binCentres, Cx56timing/sum(Cx56timing),'r','LineWidth',1)
% plot(binCentres, Cx56fit,'r','LineWidth',5)
% %plot(binCentres, Cx5timing/sum(Cx5timing),'r--','LineWidth',1)
% %plot(binCentres, Cx5fit,'r--','LineWidth',5)
% %plot(binCentres, Cx6timing/sum(Cx6timing),'r','LineWidth',1)
% %plot(binCentres, Cx6fit,'r','LineWidth',5)
% plot(binCentres, TCtiming/sum(TCtiming),'Color',gold,'LineWidth',1)
% plot(binCentres, TCfit,'Color',gold,'LineWidth',5)
% plot(binCentres, TC2timing/sum(TC2timing),'Color',orange,'LineWidth',1)
% plot(binCentres, TC2fit,'Color',orange,'LineWidth',5)
% % plot(binCentres, TC3timing/sum(TC3timing),'Color',orange,'LineWidth',1)
% % plot(binCentres, TC3fit,'Color',orange,'LineWidth',5)
% plot(binCentres, NRTtiming/sum(NRTtiming),'c','LineWidth',1)
% plot(binCentres, NRTfit,'c','LineWidth',5)
% plot(binCentres, NRT2timing/sum(NRT2timing),'b','LineWidth',1)
% plot(binCentres, NRT2fit,'b','LineWidth',5)
% % plot(binCentres, NRT3timing/sum(NRT3timing),'b','LineWidth',1)
% % plot(binCentres, NRT3fit,'b','LineWidth',5)
hold off
ax = axesProperties({}, 1, 'normal', 'off', 'w', 'Calibri', 30, 4/3, 2, [0.01 0.025], 'out', 'on', 'k', '{\Delta}time (ms)', [-60 80], [-60 -30 0 40 80], 'on', 'k', '# of APs per bin', [0 80], [0 40 80]);
width = 15.92;
height = 15.92;
label = [4.1 4.1];
margin = [0.75 0.75];
gap = 1.5;
paperSize = resizeFig(f2, ax, width, height, label, margin, gap);
exportFig(f2, ['1' '.tif'], '-dtiffnocompression','-r300', paperSize);

f3 = figure('Units', 'normalized', 'Position', [0, .01, .98, .89]);
hold on
plot(binCentres, Cx56timingFirst/200,'r','LineWidth',1)
p3 = plot(binCentres, Cx56fitFirst,'r','LineWidth',5);
%plot([L56paramsFirst.b1 L56paramsFirst.b1], [0 L56paramsFirst.a1],'r--','LineWidth',1)
%plot(binCentres, Cx5timingFirst/100,'r--','LineWidth',1)
%plot(binCentres, Cx5fitFirst,'r--','LineWidth',5)
%plot(binCentres, Cx6timingFirst/100,'r','LineWidth',1)
%plot(binCentres, Cx6fitFirst,'r','LineWidth',5)
plot(binCentres, Cx23timingFirst/100,'g','LineWidth',1)
p1 = plot(binCentres, Cx23fitFirst,'g','LineWidth',5);
%plot([L23paramsFirst.b1 L23paramsFirst.b1], [0 L23paramsFirst.a1],'g--','LineWidth',1)
plot(binCentres, Cx4timingFirst/100,'m','LineWidth',1)
p2 = plot(binCentres, Cx4fitFirst,'m','LineWidth',5);
%plot([L4paramsFirst.b1 L4paramsFirst.b1], [0 L4paramsFirst.a1],'m--','LineWidth',1)
plot(binCentres, TCtimingFirst/100,'Color',gold,'LineWidth',1)
p6 = plot(binCentres, TCfitFirst,'Color',gold,'LineWidth',5);
%plot([TCparamsFirst.b1 TCparamsFirst.b1], [0 TCparamsFirst.a1],'Color',gold,'LineStyle','--','LineWidth',1)
plot(binCentres, TC2timingFirst/100,'Color',orange,'LineWidth',1)
p7 = plot(binCentres, TC2fitFirst,'Color',orange,'LineWidth',5);
%plot([TC2paramsFirst.b1 TC2paramsFirst.b1], [0 TC2paramsFirst.a1],'Color',orange,'LineStyle','--','LineWidth',1)
% plot(binCentres, TC3timingFirst/200,'Color',orange,'LineWidth',1)
% plot(binCentres, TC3fitFirst,'Color',orange,'LineWidth',5)
plot(binCentres, NRTtimingFirst/100,'c','LineWidth',1)
p4 = plot(binCentres, NRTfitFirst,'c','LineWidth',5);
%plot([NRTparamsFirst.b1 NRTparamsFirst.b1], [0 NRTparamsFirst.a1],'c--','LineWidth',1)
plot(binCentres, NRT2timingFirst/100,'b','LineWidth',1)
p5 = plot(binCentres, NRT2fitFirst,'b','LineWidth',5);
%plot([NRT2paramsFirst.b1 NRT2paramsFirst.b1], [0 NRT2paramsFirst.a1],'b--','LineWidth',1)
% plot(binCentres, NRT3timingFirst/200,'b','LineWidth',1)
% plot(binCentres, NRT3fitFirst,'b','LineWidth',5)
% plot(binCentres, Cx56timingFirst/sum(Cx56timingFirst),'r','LineWidth',1)
% plot(binCentres, Cx56fitFirst,'r','LineWidth',5)
% %plot(binCentres, Cx5timingFirst/sum(Cx5timingFirst),'r--','LineWidth',1)
% %plot(binCentres, Cx5fitFirst,'r--','LineWidth',5)
% %plot(binCentres, Cx6timingFirst/sum(Cx6timingFirst),'r','LineWidth',1)
% %plot(binCentres, Cx6fitFirst,'r','LineWidth',5)
% plot(binCentres, Cx23timingFirst/sum(Cx23timingFirst),'r','LineWidth',1)
% plot(binCentres, Cx23fitFirst,'g','LineWidth',5)
% plot(binCentres, Cx4timingFirst/sum(Cx4timingFirst),'m','LineWidth',1)
% plot(binCentres, Cx4fitFirst,'m','LineWidth',5)
% plot(binCentres, TCtimingFirst/sum(TCtimingFirst),'Color',gold,'LineWidth',1)
% plot(binCentres, TCfitFirst,'Color',gold,'LineWidth',5)
% plot(binCentres, TC2timingFirst/sum(TC2timingFirst),'Color',orange,'LineWidth',1)
% plot(binCentres, TC2fitFirst,'Color',orange,'LineWidth',5)
% % plot(binCentres, TC3timingFirst/sum(TC3timingFirst),'Color',orange,'LineWidth',1)
% % plot(binCentres, TC3fitFirst,'Color',orange,'LineWidth',5)
% plot(binCentres, NRTtimingFirst/sum(NRTtimingFirst),'c','LineWidth',1)
% plot(binCentres, NRTfitFirst,'c','LineWidth',5)
% plot(binCentres, NRT2timingFirst/sum(NRT2timingFirst),'b','LineWidth',1)
% plot(binCentres, NRT2fitFirst,'b','LineWidth',5)
% % plot(binCentres, NRT3timingFirst/sum(NRT3timingFirst),'b','LineWidth',1)
% % plot(binCentres, NRT3fitFirst,'b','LineWidth',5)
hold off
ax = axesProperties({}, 1, 'normal', 'off', 'w', 'Calibri', 30, 4/3, 2, [0.01 0.025], 'out', 'on', 'k', '{\Delta}time (ms)', [-80 50], [-80 -40 0 25 50], 'on', 'k', '# of APs per bin', [0 18], [0 9 18]);
paperSize = resizeFig(f3, ax, width, height, label, margin, gap);
legStr = {'L2/3', 'L4', 'L5/6', 'NRT_{FO}', 'NRT_{HO}', 'TC_{FO}', 'TC_{HO}'};
legFont = 27;
l = legend([p1 p2 p3 p4 p5 p6 p7],legStr, 'Box', 'off', 'FontSize', legFont, 'LineWidth', 3, 'Location', 'NorthEast');
exportFig(f3, ['2' '.tif'], '-dtiffnocompression','-r300', paperSize);

meanL23 = sum(Cx23timing.*binCentres)./sum(Cx23timing)
meanL4 = sum(Cx4timing.*binCentres)./sum(Cx4timing)
meanL5 = sum(Cx5timing.*binCentres)./sum(Cx5timing)
meanL6 = sum(Cx6timing.*binCentres)./sum(Cx6timing)
meanL56 = sum(Cx56timing.*binCentres)./sum(Cx56timing)
meanNRT = sum(NRTtiming.*binCentres)./sum(NRTtiming)
meanNRT2 = sum(NRT2timing.*binCentres)./sum(NRT2timing)
meanNRT3 = sum(NRT3timing.*binCentres)./sum(NRT3timing)
meanTC = sum(TCtiming.*binCentres)./sum(TCtiming)
meanTC2 = sum(TC2timing.*binCentres)./sum(TC2timing)
meanTC3 = sum(TC3timing.*binCentres)./sum(TC3timing)

meanL23First = sum(Cx23timingFirst.*binCentres)./sum(Cx23timingFirst)
meanL4First = sum(Cx4timingFirst.*binCentres)./sum(Cx4timingFirst)
meanL5First = sum(Cx5timingFirst.*binCentres)./sum(Cx5timingFirst)
meanL6First = sum(Cx6timingFirst.*binCentres)./sum(Cx6timingFirst)
meanL56First = sum(Cx56timingFirst.*binCentres)./sum(Cx56timingFirst)
meanNRTFirst = sum(NRTtimingFirst.*binCentres)./sum(NRTtimingFirst)
meanNRT2First = sum(NRT2timingFirst.*binCentres)./sum(NRT2timingFirst)
meanNRT3First = sum(NRT3timingFirst.*binCentres)./sum(NRT3timingFirst)
meanTCFirst = sum(TCtimingFirst.*binCentres)./sum(TCtimingFirst)
meanTC2First = sum(TC2timingFirst.*binCentres)./sum(TC2timingFirst)
meanTC3First = sum(TC3timingFirst.*binCentres)./sum(TC3timingFirst)



Cx23FRmean = mean(Cx23FR);
Cx23BRmean = mean(Cx23BR);
Cx23TRmean = mean(Cx23TR);
Cx23iFRmean = mean(Cx23iFR);
Cx23iBRmean = mean(Cx23iBR);
Cx23iTRmean = mean(Cx23iTR);
Cx4FRmean = mean(Cx4FR);
Cx4BRmean = mean(Cx4BR);
Cx4TRmean = mean(Cx4TR);
Cx4iFRmean = mean(Cx4iFR);
Cx4iBRmean = mean(Cx4iBR);
Cx4iTRmean = mean(Cx4iTR);
CxSupFRmean = Cx23FRmean/3 + Cx23iFRmean/6 + Cx4FRmean/3 + Cx4iFRmean/6;
CxSupBRmean = Cx23BRmean/3 + Cx23iBRmean/6 + Cx4BRmean/3 + Cx4iBRmean/6;
CxSupTRmean = Cx23TRmean/3 + Cx23iTRmean/6 + Cx4TRmean/3 + Cx4iTRmean/6;
Cx5FRmean = mean(Cx5FR);
Cx5BRmean = mean(Cx5BR);
Cx5TRmean = mean(Cx5TR);
Cx5iFRmean = mean(Cx5iFR);
Cx5iBRmean = mean(Cx5iBR);
Cx5iTRmean = mean(Cx5iTR);
Cx6FRmean = mean(Cx6FR);
Cx6BRmean = mean(Cx6BR);
Cx6TRmean = mean(Cx6TR);
Cx6iFRmean = mean(Cx6iFR);
Cx6iBRmean = mean(Cx6iBR);
Cx6iTRmean = mean(Cx6iTR);
CxInfFRmean = Cx5FRmean/3 + Cx5iFRmean/6 + Cx6FRmean/3 + Cx6iFRmean/6;
CxInfBRmean = Cx5BRmean/3 + Cx5iBRmean/6 + Cx6BRmean/3 + Cx6iBRmean/6;
CxInfTRmean = Cx5TRmean/3 + Cx5iTRmean/6 + Cx6TRmean/3 + Cx6iTRmean/6;
CxFRmean = Cx23FRmean/6 + Cx23iFRmean/12 + Cx4FRmean/6 + Cx4iFRmean/12 + Cx5FRmean/6 + Cx5iFRmean/12 + Cx6FRmean/6 + Cx6iFRmean/12;
CxBRmean = Cx23BRmean/6 + Cx23iBRmean/12 + Cx4BRmean/6 + Cx4iBRmean/12 + Cx5BRmean/6 + Cx5iBRmean/12 + Cx6BRmean/6 + Cx6iBRmean/12;
CxTRmean = Cx23TRmean/6 + Cx23iTRmean/12 + Cx4TRmean/6 + Cx4iTRmean/12 + Cx5TRmean/6 + Cx5iTRmean/12 + Cx6TRmean/6 + Cx6iTRmean/12;
NRTFRmean = mean(NRTFR);
NRTBRmean = mean(NRTBR);
NRTTRmean = mean(NRTTR);
NRT2FRmean = mean(NRT2FR);
NRT2BRmean = mean(NRT2BR);
NRT2TRmean = mean(NRT2TR);
NRT3FRmean = NRTFRmean/2 + NRT2FRmean/2;
NRT3BRmean = NRTBRmean/2 + NRT2BRmean/2;
NRT3TRmean = NRTTRmean/2 + NRT2TRmean/2;
TCFRmean = mean(TCFR);
TCBRmean = mean(TCBR);
TCTRmean = mean(TCTR);
TC2FRmean = mean(TC2FR);
TC2BRmean = mean(TC2BR);
TC2TRmean = mean(TC2TR);
TC3FRmean = TCFRmean/2 + TC2FRmean/2;
TC3BRmean = TCBRmean/2 + TC2BRmean/2;
TC3TRmean = TCTRmean/2 + TC2TRmean/2;

% f4 = figure('Units', 'normalized', 'Position', [0, .01, .98, .89]);
% hold on
% %plot(tSlide, CxFRmean,'r','LineWidth',1)
% plot(tSlide, CxSupFRmean,'m','LineWidth',1)
% plot(tSlide, CxInfFRmean,'r','LineWidth',1)
% plot(tSlide, TCFRmean,'Color',gold,'LineWidth',1)
% plot(tSlide, TC2FRmean,'Color',orange,'LineWidth',1)
% plot(tSlide, NRTFRmean,'c','LineWidth',1)
% plot(tSlide, NRT2FRmean,'b','LineWidth',1)
% hold off
% 
% f5 = figure('Units', 'normalized', 'Position', [0, .01, .98, .89]);
% hold on
% %plot(tSlide, CxBRmean,'r','LineWidth',1)
% plot(tSlide, CxSupBRmean,'m','LineWidth',1)
% plot(tSlide, CxInfBRmean,'r','LineWidth',1)
% plot(tSlide, TCBRmean,'Color',gold,'LineWidth',1)
% plot(tSlide, TC2BRmean,'Color',orange,'LineWidth',1)
% plot(tSlide, NRTBRmean,'c','LineWidth',1)
% plot(tSlide, NRT2BRmean,'b','LineWidth',1)
% hold off
% 
% f6 = figure('Units', 'normalized', 'Position', [0, .01, .98, .89]);
% hold on
% %plot(tSlide, CxTRmean,'r','LineWidth',1)
% plot(tSlide, CxSupTRmean,'m','LineWidth',1)
% plot(tSlide, CxInfTRmean,'r','LineWidth',1)
% plot(tSlide, TCTRmean,'Color',gold,'LineWidth',1)
% plot(tSlide, TC2TRmean,'Color',orange,'LineWidth',1)
% plot(tSlide, NRTTRmean,'c','LineWidth',1)
% plot(tSlide, NRT2TRmean,'b','LineWidth',1)
% hold off

count = 1;
iStart(count) = spikes(1);
for i = 2:length(spikes)
    if t(spikes(i))-t(spikes(i-1)) > 7500
        iEnd(count) = spikes(i-1); %#ok<AGROW>
        count = count + 1;
        iStart(count) = spikes(i);
    end
end
iEnd(count) = spikes(i);
iMid = iStart + round((iEnd-iStart)/2);
DT = tSlide(2)-tSlide(1);
iStart = round(iStart/(DT/dt));
iMid = round(iMid/(DT/dt));
iEnd = round(iEnd/(DT/dt));

[~, longest] = max(iEnd-iStart);
SWD = round(iEnd(longest)-iStart(longest))+1;
t_SWD = [(iStart(longest):iMid(longest))-iStart(longest) (iMid(longest)+1:iEnd(longest))-iEnd(longest)]*DT;
vicinity = round(15000/DT);
t_SWD = [(-vicinity:-1)*DT t_SWD (1:vicinity)*DT];
t_SWDinit = 1:length(t_SWD);
SWD = zeros(1,vicinity+SWD+vicinity);
SWDcount = SWD;
Cx23FRmeanShort = SWD;
Cx23BRmeanShort = SWD;
Cx23TRmeanShort = SWD;
Cx23iFRmeanShort = SWD;
Cx23iBRmeanShort = SWD;
Cx23iTRmeanShort = SWD;
Cx4FRmeanShort = SWD;
Cx4BRmeanShort = SWD;
Cx4TRmeanShort = SWD;
Cx4iFRmeanShort = SWD;
Cx4iBRmeanShort = SWD;
Cx4iTRmeanShort = SWD;
CxSupFRmeanShort = SWD;
CxSupBRmeanShort = SWD;
CxSupTRmeanShort = SWD;
Cx5FRmeanShort = SWD;
Cx5BRmeanShort = SWD;
Cx5TRmeanShort = SWD;
Cx5iFRmeanShort = SWD;
Cx5iBRmeanShort = SWD;
Cx5iTRmeanShort = SWD;
Cx6FRmeanShort = SWD;
Cx6BRmeanShort = SWD;
Cx6TRmeanShort = SWD;
Cx6iFRmeanShort = SWD;
Cx6iBRmeanShort = SWD;
Cx6iTRmeanShort = SWD;
CxInfFRmeanShort = SWD;
CxInfBRmeanShort = SWD;
CxInfTRmeanShort = SWD;
CxFRmeanShort = SWD;
CxBRmeanShort = SWD;
CxTRmeanShort = SWD;
NRTFRmeanShort = SWD;
NRTBRmeanShort = SWD;
NRTTRmeanShort = SWD;
NRT2FRmeanShort = SWD;
NRT2BRmeanShort = SWD;
NRT2TRmeanShort = SWD;
NRT3FRmeanShort = SWD;
NRT3BRmeanShort = SWD;
NRT3TRmeanShort = SWD;
TCFRmeanShort = SWD;
TCBRmeanShort = SWD;
TCTRmeanShort = SWD;
TC2FRmeanShort = SWD;
TC2BRmeanShort = SWD;
TC2TRmeanShort = SWD;
TC3FRmeanShort = SWD;
TC3BRmeanShort = SWD;
TC3TRmeanShort = SWD;
for i = 1:length(iEnd)
    ind1 = 1;
    ind2 = iMid(i) - iStart(i) + 1 + vicinity;
    ind3 = iStart(i) - vicinity;
    if ind3 < 1
        ind1 = abs(ind3) + 2;
        ind3 = 1;
    end
    ind4 = iMid(i);
    Cx23FRmeanShort(ind1:ind2) = Cx23FRmeanShort(ind1:ind2) + Cx23FRmean(ind3:ind4);
    Cx23BRmeanShort(ind1:ind2) = Cx23BRmeanShort(ind1:ind2) + Cx23BRmean(ind3:ind4);
    Cx23TRmeanShort(ind1:ind2) = Cx23TRmeanShort(ind1:ind2) + Cx23TRmean(ind3:ind4);
    Cx23iFRmeanShort(ind1:ind2) = Cx23iFRmeanShort(ind1:ind2) + Cx23iFRmean(ind3:ind4);
    Cx23iBRmeanShort(ind1:ind2) = Cx23iBRmeanShort(ind1:ind2) + Cx23iBRmean(ind3:ind4);
    Cx23iTRmeanShort(ind1:ind2) = Cx23iTRmeanShort(ind1:ind2) + Cx23iTRmean(ind3:ind4);
    Cx4FRmeanShort(ind1:ind2) = Cx4FRmeanShort(ind1:ind2) + Cx4FRmean(ind3:ind4);
    Cx4BRmeanShort(ind1:ind2) = Cx4BRmeanShort(ind1:ind2) + Cx4BRmean(ind3:ind4);
    Cx4TRmeanShort(ind1:ind2) = Cx4TRmeanShort(ind1:ind2) + Cx4TRmean(ind3:ind4);
    Cx4iFRmeanShort(ind1:ind2) = Cx4iFRmeanShort(ind1:ind2) + Cx4iFRmean(ind3:ind4);
    Cx4iBRmeanShort(ind1:ind2) = Cx4iBRmeanShort(ind1:ind2) + Cx4iBRmean(ind3:ind4);
    Cx4iTRmeanShort(ind1:ind2) = Cx4iTRmeanShort(ind1:ind2) + Cx4iTRmean(ind3:ind4);
    CxSupFRmeanShort(ind1:ind2) = CxSupFRmeanShort(ind1:ind2) + CxSupFRmean(ind3:ind4);
    CxSupBRmeanShort(ind1:ind2) = CxSupBRmeanShort(ind1:ind2) + CxSupBRmean(ind3:ind4);
    CxSupTRmeanShort(ind1:ind2) = CxSupTRmeanShort(ind1:ind2) + CxSupTRmean(ind3:ind4);
    Cx5FRmeanShort(ind1:ind2) = Cx5FRmeanShort(ind1:ind2) + Cx5FRmean(ind3:ind4);
    Cx5BRmeanShort(ind1:ind2) = Cx5BRmeanShort(ind1:ind2) + Cx5BRmean(ind3:ind4);
    Cx5TRmeanShort(ind1:ind2) = Cx5TRmeanShort(ind1:ind2) + Cx5TRmean(ind3:ind4);
    Cx5iFRmeanShort(ind1:ind2) = Cx5iFRmeanShort(ind1:ind2) + Cx5iFRmean(ind3:ind4);
    Cx5iBRmeanShort(ind1:ind2) = Cx5iBRmeanShort(ind1:ind2) + Cx5iBRmean(ind3:ind4);
    Cx5iTRmeanShort(ind1:ind2) = Cx5iTRmeanShort(ind1:ind2) + Cx5iTRmean(ind3:ind4);
    Cx6FRmeanShort(ind1:ind2) = Cx6FRmeanShort(ind1:ind2) + Cx6FRmean(ind3:ind4);
    Cx6BRmeanShort(ind1:ind2) = Cx6BRmeanShort(ind1:ind2) + Cx6BRmean(ind3:ind4);
    Cx6TRmeanShort(ind1:ind2) = Cx6TRmeanShort(ind1:ind2) + Cx6TRmean(ind3:ind4);
    Cx6iFRmeanShort(ind1:ind2) = Cx6iFRmeanShort(ind1:ind2) + Cx6iFRmean(ind3:ind4);
    Cx6iBRmeanShort(ind1:ind2) = Cx6iBRmeanShort(ind1:ind2) + Cx6iBRmean(ind3:ind4);
    Cx6iTRmeanShort(ind1:ind2) = Cx6iTRmeanShort(ind1:ind2) + Cx6iTRmean(ind3:ind4);
    CxInfFRmeanShort(ind1:ind2) = CxInfFRmeanShort(ind1:ind2) + CxInfFRmean(ind3:ind4);
    CxInfBRmeanShort(ind1:ind2) = CxInfBRmeanShort(ind1:ind2) + CxInfBRmean(ind3:ind4);
    CxInfTRmeanShort(ind1:ind2) = CxInfTRmeanShort(ind1:ind2) + CxInfTRmean(ind3:ind4);
    CxFRmeanShort(ind1:ind2) = CxFRmeanShort(ind1:ind2) + CxFRmean(ind3:ind4);
    CxBRmeanShort(ind1:ind2) = CxBRmeanShort(ind1:ind2) + CxBRmean(ind3:ind4);
    CxTRmeanShort(ind1:ind2) = CxTRmeanShort(ind1:ind2) + CxTRmean(ind3:ind4);
    NRTFRmeanShort(ind1:ind2) = NRTFRmeanShort(ind1:ind2) + NRTFRmean(ind3:ind4);
    NRTBRmeanShort(ind1:ind2) = NRTBRmeanShort(ind1:ind2) + NRTBRmean(ind3:ind4);
    NRTTRmeanShort(ind1:ind2) = NRTTRmeanShort(ind1:ind2) + NRTTRmean(ind3:ind4);
    NRT2FRmeanShort(ind1:ind2) = NRT2FRmeanShort(ind1:ind2) + NRT2FRmean(ind3:ind4);
    NRT2BRmeanShort(ind1:ind2) = NRT2BRmeanShort(ind1:ind2) + NRT2BRmean(ind3:ind4);
    NRT2TRmeanShort(ind1:ind2) = NRT2TRmeanShort(ind1:ind2) + NRT2TRmean(ind3:ind4);
    NRT3FRmeanShort(ind1:ind2) = NRT3FRmeanShort(ind1:ind2) + NRT3FRmean(ind3:ind4);
    NRT3BRmeanShort(ind1:ind2) = NRT3BRmeanShort(ind1:ind2) + NRT3BRmean(ind3:ind4);
    NRT3TRmeanShort(ind1:ind2) = NRT3TRmeanShort(ind1:ind2) + NRT3TRmean(ind3:ind4);
    TCFRmeanShort(ind1:ind2) = TCFRmeanShort(ind1:ind2) + TCFRmean(ind3:ind4);
    TCBRmeanShort(ind1:ind2) = TCBRmeanShort(ind1:ind2) + TCBRmean(ind3:ind4);
    TCTRmeanShort(ind1:ind2) = TCTRmeanShort(ind1:ind2) + TCTRmean(ind3:ind4);
    TC2FRmeanShort(ind1:ind2) = TC2FRmeanShort(ind1:ind2) + TC2FRmean(ind3:ind4);
    TC2BRmeanShort(ind1:ind2) = TC2BRmeanShort(ind1:ind2) + TC2BRmean(ind3:ind4);
    TC2TRmeanShort(ind1:ind2) = TC2TRmeanShort(ind1:ind2) + TC2TRmean(ind3:ind4);
    TC3FRmeanShort(ind1:ind2) = TC3FRmeanShort(ind1:ind2) + TC3FRmean(ind3:ind4);
    TC3BRmeanShort(ind1:ind2) = TC3BRmeanShort(ind1:ind2) + TC3BRmean(ind3:ind4);
    TC3TRmeanShort(ind1:ind2) = TC3TRmeanShort(ind1:ind2) + TC3TRmean(ind3:ind4);
    SWDcount(ind1:ind2) = SWDcount(ind1:ind2) + ones(size(Cx23FRmeanShort(ind1:ind2)));
    ind1 = length(SWD) - (iEnd(i)-iMid(i)+vicinity) + 1;
    ind2 = length(SWD);
    ind3 = iMid(i) + 1;
    ind4 = iEnd(i) + vicinity;
    if ind4 > length(tSlide)
        ind2 = ind2 - (ind4-length(tSlide));
        ind4 = length(tSlide);
    end
    Cx23FRmeanShort(ind1:ind2) = Cx23FRmeanShort(ind1:ind2) + Cx23FRmean(ind3:ind4);
    Cx23BRmeanShort(ind1:ind2) = Cx23BRmeanShort(ind1:ind2) + Cx23BRmean(ind3:ind4);
    Cx23TRmeanShort(ind1:ind2) = Cx23TRmeanShort(ind1:ind2) + Cx23TRmean(ind3:ind4);
    Cx23iFRmeanShort(ind1:ind2) = Cx23iFRmeanShort(ind1:ind2) + Cx23iFRmean(ind3:ind4);
    Cx23iBRmeanShort(ind1:ind2) = Cx23iBRmeanShort(ind1:ind2) + Cx23iBRmean(ind3:ind4);
    Cx23iTRmeanShort(ind1:ind2) = Cx23iTRmeanShort(ind1:ind2) + Cx23iTRmean(ind3:ind4);
    Cx4FRmeanShort(ind1:ind2) = Cx4FRmeanShort(ind1:ind2) + Cx4FRmean(ind3:ind4);
    Cx4BRmeanShort(ind1:ind2) = Cx4BRmeanShort(ind1:ind2) + Cx4BRmean(ind3:ind4);
    Cx4TRmeanShort(ind1:ind2) = Cx4TRmeanShort(ind1:ind2) + Cx4TRmean(ind3:ind4);
    Cx4iFRmeanShort(ind1:ind2) = Cx4iFRmeanShort(ind1:ind2) + Cx4iFRmean(ind3:ind4);
    Cx4iBRmeanShort(ind1:ind2) = Cx4iBRmeanShort(ind1:ind2) + Cx4iBRmean(ind3:ind4);
    Cx4iTRmeanShort(ind1:ind2) = Cx4iTRmeanShort(ind1:ind2) + Cx4iTRmean(ind3:ind4);
    CxSupFRmeanShort(ind1:ind2) = CxSupFRmeanShort(ind1:ind2) + CxSupFRmean(ind3:ind4);
    CxSupBRmeanShort(ind1:ind2) = CxSupBRmeanShort(ind1:ind2) + CxSupBRmean(ind3:ind4);
    CxSupTRmeanShort(ind1:ind2) = CxSupTRmeanShort(ind1:ind2) + CxSupTRmean(ind3:ind4);
    Cx5FRmeanShort(ind1:ind2) = Cx5FRmeanShort(ind1:ind2) + Cx5FRmean(ind3:ind4);
    Cx5BRmeanShort(ind1:ind2) = Cx5BRmeanShort(ind1:ind2) + Cx5BRmean(ind3:ind4);
    Cx5TRmeanShort(ind1:ind2) = Cx5TRmeanShort(ind1:ind2) + Cx5TRmean(ind3:ind4);
    Cx5iFRmeanShort(ind1:ind2) = Cx5iFRmeanShort(ind1:ind2) + Cx5iFRmean(ind3:ind4);
    Cx5iBRmeanShort(ind1:ind2) = Cx5iBRmeanShort(ind1:ind2) + Cx5iBRmean(ind3:ind4);
    Cx5iTRmeanShort(ind1:ind2) = Cx5iTRmeanShort(ind1:ind2) + Cx5iTRmean(ind3:ind4);
    Cx6FRmeanShort(ind1:ind2) = Cx6FRmeanShort(ind1:ind2) + Cx6FRmean(ind3:ind4);
    Cx6BRmeanShort(ind1:ind2) = Cx6BRmeanShort(ind1:ind2) + Cx6BRmean(ind3:ind4);
    Cx6TRmeanShort(ind1:ind2) = Cx6TRmeanShort(ind1:ind2) + Cx6TRmean(ind3:ind4);
    Cx6iFRmeanShort(ind1:ind2) = Cx6iFRmeanShort(ind1:ind2) + Cx6iFRmean(ind3:ind4);
    Cx6iBRmeanShort(ind1:ind2) = Cx6iBRmeanShort(ind1:ind2) + Cx6iBRmean(ind3:ind4);
    Cx6iTRmeanShort(ind1:ind2) = Cx6iTRmeanShort(ind1:ind2) + Cx6iTRmean(ind3:ind4);
    CxInfFRmeanShort(ind1:ind2) = CxInfFRmeanShort(ind1:ind2) + CxInfFRmean(ind3:ind4);
    CxInfBRmeanShort(ind1:ind2) = CxInfBRmeanShort(ind1:ind2) + CxInfBRmean(ind3:ind4);
    CxInfTRmeanShort(ind1:ind2) = CxInfTRmeanShort(ind1:ind2) + CxInfTRmean(ind3:ind4);
    CxFRmeanShort(ind1:ind2) = CxFRmeanShort(ind1:ind2) + CxFRmean(ind3:ind4);
    CxBRmeanShort(ind1:ind2) = CxBRmeanShort(ind1:ind2) + CxBRmean(ind3:ind4);
    CxTRmeanShort(ind1:ind2) = CxTRmeanShort(ind1:ind2) + CxTRmean(ind3:ind4);
    NRTFRmeanShort(ind1:ind2) = NRTFRmeanShort(ind1:ind2) + NRTFRmean(ind3:ind4);
    NRTBRmeanShort(ind1:ind2) = NRTBRmeanShort(ind1:ind2) + NRTBRmean(ind3:ind4);
    NRTTRmeanShort(ind1:ind2) = NRTTRmeanShort(ind1:ind2) + NRTTRmean(ind3:ind4);
    NRT2FRmeanShort(ind1:ind2) = NRT2FRmeanShort(ind1:ind2) + NRT2FRmean(ind3:ind4);
    NRT2BRmeanShort(ind1:ind2) = NRT2BRmeanShort(ind1:ind2) + NRT2BRmean(ind3:ind4);
    NRT2TRmeanShort(ind1:ind2) = NRT2TRmeanShort(ind1:ind2) + NRT2TRmean(ind3:ind4);
    NRT3FRmeanShort(ind1:ind2) = NRT3FRmeanShort(ind1:ind2) + NRT3FRmean(ind3:ind4);
    NRT3BRmeanShort(ind1:ind2) = NRT3BRmeanShort(ind1:ind2) + NRT3BRmean(ind3:ind4);
    NRT3TRmeanShort(ind1:ind2) = NRT3TRmeanShort(ind1:ind2) + NRT3TRmean(ind3:ind4);
    TCFRmeanShort(ind1:ind2) = TCFRmeanShort(ind1:ind2) + TCFRmean(ind3:ind4);
    TCBRmeanShort(ind1:ind2) = TCBRmeanShort(ind1:ind2) + TCBRmean(ind3:ind4);
    TCTRmeanShort(ind1:ind2) = TCTRmeanShort(ind1:ind2) + TCTRmean(ind3:ind4);
    TC2FRmeanShort(ind1:ind2) = TC2FRmeanShort(ind1:ind2) + TC2FRmean(ind3:ind4);
    TC2BRmeanShort(ind1:ind2) = TC2BRmeanShort(ind1:ind2) + TC2BRmean(ind3:ind4);
    TC2TRmeanShort(ind1:ind2) = TC2TRmeanShort(ind1:ind2) + TC2TRmean(ind3:ind4);
    TC3FRmeanShort(ind1:ind2) = TC3FRmeanShort(ind1:ind2) + TC3FRmean(ind3:ind4);
    TC3BRmeanShort(ind1:ind2) = TC3BRmeanShort(ind1:ind2) + TC3BRmean(ind3:ind4);
    TC3TRmeanShort(ind1:ind2) = TC3TRmeanShort(ind1:ind2) + TC3TRmean(ind3:ind4);
    SWDcount(ind1:ind2) = SWDcount(ind1:ind2) + ones(size(Cx23FRmeanShort(ind1:ind2)));
end
Cx23FRmeanShort = Cx23FRmeanShort./SWDcount;
Cx23BRmeanShort = Cx23BRmeanShort./SWDcount;
Cx23TRmeanShort = Cx23TRmeanShort./SWDcount;
Cx23iFRmeanShort = Cx23iFRmeanShort./SWDcount;
Cx23iBRmeanShort = Cx23iBRmeanShort./SWDcount;
Cx23iTRmeanShort = Cx23iTRmeanShort./SWDcount;
Cx4FRmeanShort = Cx4FRmeanShort./SWDcount;
Cx4BRmeanShort = Cx4BRmeanShort./SWDcount;
Cx4TRmeanShort = Cx4TRmeanShort./SWDcount;
Cx4iFRmeanShort = Cx4iFRmeanShort./SWDcount;
Cx4iBRmeanShort = Cx4iBRmeanShort./SWDcount;
Cx4iTRmeanShort = Cx4iTRmeanShort./SWDcount;
CxSupFRmeanShort = CxSupFRmeanShort./SWDcount;
CxSupBRmeanShort = CxSupBRmeanShort./SWDcount;
CxSupTRmeanShort = CxSupTRmeanShort./SWDcount;
Cx5FRmeanShort = Cx5FRmeanShort./SWDcount;
Cx5BRmeanShort = Cx5BRmeanShort./SWDcount;
Cx5TRmeanShort = Cx5TRmeanShort./SWDcount;
Cx5iFRmeanShort = Cx5iFRmeanShort./SWDcount;
Cx5iBRmeanShort = Cx5iBRmeanShort./SWDcount;
Cx5iTRmeanShort = Cx5iTRmeanShort./SWDcount;
Cx6FRmeanShort = Cx6FRmeanShort./SWDcount;
Cx6BRmeanShort = Cx6BRmeanShort./SWDcount;
Cx6TRmeanShort = Cx6TRmeanShort./SWDcount;
Cx6iFRmeanShort = Cx6iFRmeanShort./SWDcount;
Cx6iBRmeanShort = Cx6iBRmeanShort./SWDcount;
Cx6iTRmeanShort = Cx6iTRmeanShort./SWDcount;
CxInfFRmeanShort = CxInfFRmeanShort./SWDcount;
CxInfBRmeanShort = CxInfBRmeanShort./SWDcount;
CxInfTRmeanShort = CxInfTRmeanShort./SWDcount;
CxFRmeanShort = CxFRmeanShort./SWDcount;
CxBRmeanShort = CxBRmeanShort./SWDcount;
CxTRmeanShort = CxTRmeanShort./SWDcount;
NRTFRmeanShort = NRTFRmeanShort./SWDcount;
NRTBRmeanShort = NRTBRmeanShort./SWDcount;
NRTTRmeanShort = NRTTRmeanShort./SWDcount;
NRT2FRmeanShort = NRT2FRmeanShort./SWDcount;
NRT2BRmeanShort = NRT2BRmeanShort./SWDcount;
NRT2TRmeanShort = NRT2TRmeanShort./SWDcount;
NRT3FRmeanShort = NRT3FRmeanShort./SWDcount;
NRT3BRmeanShort = NRT3BRmeanShort./SWDcount;
NRT3TRmeanShort = NRT3TRmeanShort./SWDcount;
TCFRmeanShort = TCFRmeanShort./SWDcount;
TCBRmeanShort = TCBRmeanShort./SWDcount;
TCTRmeanShort = TCTRmeanShort./SWDcount;
TC2FRmeanShort = TC2FRmeanShort./SWDcount;
TC2BRmeanShort = TC2BRmeanShort./SWDcount;
TC2TRmeanShort = TC2TRmeanShort./SWDcount;
TC3FRmeanShort = TC3FRmeanShort./SWDcount;
TC3BRmeanShort = TC3BRmeanShort./SWDcount;
TC3TRmeanShort = TC3TRmeanShort./SWDcount;

f7 = figure('Units', 'normalized', 'Position', [0, .01, .98, .89]);
hold on
lineWidth = 4;
plot(t_SWDinit, CxSupFRmeanShort,'m','LineWidth',lineWidth)
plot(t_SWDinit, CxInfFRmeanShort,'r','LineWidth',lineWidth)
plot(103.3, 3, 'r.', 'MarkerSize', 10)
%plot(117.1, 3, 'r.', 'MarkerSize', 10)
plot(t_SWDinit, TCFRmeanShort,'Color',gold,'LineWidth',lineWidth)
plot(t_SWDinit, TC2FRmeanShort,'Color',orange,'LineWidth',lineWidth)
%plot(84, 3, 'g.', 'MarkerSize', 10)
%plot(90.4, 3, 'g.', 'MarkerSize', 10)
plot(93, 3, 'g.', 'MarkerSize', 10)
plot(t_SWDinit, NRTFRmeanShort,'c','LineWidth',lineWidth)
plot(t_SWDinit, NRT2FRmeanShort,'b','LineWidth',lineWidth)
plot(91, 3, 'b.', 'MarkerSize', 10)
%plot(100.12, 3, 'b.', 'MarkerSize', 10)
%xRange = [t_SWDinit(t_SWD == -7500) t_SWDinit(t_SWD == 15000)];
xRange = [t_SWDinit(t_SWD == -15000) t_SWDinit(t_SWD == 15000)];
xLabel = zeros(1,6);
xLabel([1 4]) = t_SWDinit(t_SWD == -5000);
xLabel([2 5]) = t_SWDinit(t_SWD == 0);
xLabel([3 6]) = t_SWDinit(t_SWD == 5000);
plot([round(length(t_SWD)/2);round(length(t_SWD)/2)], [0;28.6],'w','LineWidth',15)
plot([xLabel([2 5]);xLabel([2 5])], [[0;28.6] [0;28.6]],'r--','LineWidth',2)
hold off
ax = axesProperties({}, 1, 'normal', 'off', 'w', 'Calibri', 30, 4/3, 2, [0.01 0.025], 'out', 'on', 'k', 'Time (s)', [xRange(1) xRange(end)], [xLabel xRange(end)], 'on', 'k', 'Frequency (Hz)', [0 28.6], [0 14 28]);
ax.XTickLabel = {'-5', '0', '5', '-5', '0', '5', '15'};
paperSize = resizeFig(f7, ax, width, height, label, margin, gap);
exportFig(f7, ['7' '.tif'], '-dtiffnocompression','-r300', paperSize);

mRange = [t_SWDinit(t_SWD == -15000) t_SWDinit(t_SWD == -5000)];
CxSupFRmeanInit = mean(CxSupFRmeanShort(mRange(1):mRange(2)));
CxSupFRmeanInitSD = CxSupFRmeanInit + std(CxSupFRmeanShort(mRange(1):mRange(2)));
CxInfFRmeanInit = mean(CxInfFRmeanShort(mRange(1):mRange(2)))
CxInfFRmeanInitSD = CxInfFRmeanInit + std(CxInfFRmeanShort(mRange(1):mRange(2)))
TCFRmeanInit = mean(TCFRmeanShort(mRange(1):mRange(2)));
TCFRmeanInitSD = TCFRmeanInit + std(TCFRmeanShort(mRange(1):mRange(2)));
TC2FRmeanInit = mean(TC2FRmeanShort(mRange(1):mRange(2)))
TC2FRmeanInitSD = TC2FRmeanInit + std(TC2FRmeanShort(mRange(1):mRange(2)))
NRTFRmeanInit = mean(NRTFRmeanShort(mRange(1):mRange(2)));
NRTFRmeanInitSD = NRTFRmeanInit + std(NRTFRmeanShort(mRange(1):mRange(2)));
NRT2FRmeanInit = mean(NRT2FRmeanShort(mRange(1):mRange(2)))
NRT2FRmeanInitSD = NRT2FRmeanInit + std(NRT2FRmeanShort(mRange(1):mRange(2)))
xRange2 = [t_SWDinit(t_SWD == -7500) t_SWDinit(t_SWD == 100)];
xLabel2 = zeros(1,6);
xLabel2([1 4]) = t_SWDinit(t_SWD == -7000);
xLabel2([2 5]) = t_SWDinit(t_SWD == -3500);
xLabel2([3 6]) = t_SWDinit(t_SWD == 0);
ax = axesProperties({}, 1, 'normal', 'off', 'w', 'Calibri', 30, 4/3, 2, [0.01 0.025], 'out', 'on', 'k', 'Time (s)', [xRange2(1) xRange2(3)], xLabel2(1:6), 'on', 'k', 'Frequency (Hz)', [0 22], [0 11 22]);
ax.XTickLabel = {'-7', '-3.5', '0'};
paperSize = resizeFig(f7, ax, width, height, label, margin, gap);
exportFig(f7, ['7_2' '.tif'], '-dtiffnocompression','-r300', paperSize);

f8 = figure('Units', 'normalized', 'Position', [0, .01, .98, .89]);
hold on
p1 = plot(t_SWDinit, CxSupBRmeanShort,'m','LineWidth',lineWidth);
p2 = plot(t_SWDinit, CxInfBRmeanShort,'r','LineWidth',lineWidth);
p5 = plot(t_SWDinit, TCBRmeanShort,'Color',gold,'LineWidth',lineWidth);
p6 = plot(t_SWDinit, TC2BRmeanShort,'Color',orange,'LineWidth',lineWidth);
p3 = plot(t_SWDinit, NRTBRmeanShort,'c','LineWidth',lineWidth);
p4 = plot(t_SWDinit, NRT2BRmeanShort,'b','LineWidth',lineWidth);
plot([round(length(t_SWD)/2);round(length(t_SWD)/2)], [0;4.02],'w','LineWidth',15)
plot([xLabel([2 5]);xLabel([2 5])], [[0;4.02] [0;4.02]],'r--','LineWidth',2)
hold off
ax = axesProperties({}, 1, 'normal', 'off', 'w', 'Calibri', 30, 4/3, 2, [0.01 0.025], 'out', 'on', 'k', 'Time (s)', [xRange(1) xRange(end)], [xLabel xRange(end)], 'on', 'k', 'Frequency (Hz)', [0 4.02], [0 2 4]);
ax.XTickLabel = {'-5', '0', '5', '-5', '0', '5', '15'};
paperSize = resizeFig(f8, ax, width, height, label, margin, gap);
% legStr = {'L2/3/4', 'L5/6', 'NRT_{FO}', 'NRT_{HO}', 'TC_{FO}', 'TC_{HO}'};
% l = legend([p1 p2 p3 p4 p5 p6],legStr, 'Box', 'off', 'FontSize', legFont, 'LineWidth', 3, 'Location', 'NorthEast');
exportFig(f8, ['8' '.tif'], '-dtiffnocompression','-r300', paperSize);

CxSupBRmeanInit = mean(CxSupBRmeanShort(mRange(1):mRange(2)));
CxSupBRmeanInitSD = CxSupBRmeanInit + std(CxSupBRmeanShort(mRange(1):mRange(2)));
CxInfBRmeanInit = mean(CxInfBRmeanShort(mRange(1):mRange(2)))
CxInfBRmeanInitSD = CxInfBRmeanInit + std(CxInfBRmeanShort(mRange(1):mRange(2)))
TCBRmeanInit = mean(TCBRmeanShort(mRange(1):mRange(2)));
TCBRmeanInitSD = TCBRmeanInit + std(TCBRmeanShort(mRange(1):mRange(2)));
TC2BRmeanInit = mean(TC2BRmeanShort(mRange(1):mRange(2)))
TC2BRmeanInitSD = TC2BRmeanInit + std(TC2BRmeanShort(mRange(1):mRange(2)))
NRTBRmeanInit = mean(NRTBRmeanShort(mRange(1):mRange(2)));
NRTBRmeanInitSD = NRTBRmeanInit + std(NRTBRmeanShort(mRange(1):mRange(2)));
NRT2BRmeanInit = mean(NRT2BRmeanShort(mRange(1):mRange(2)))
NRT2BRmeanInitSD = NRT2BRmeanInit + std(NRT2BRmeanShort(mRange(1):mRange(2)))
ax = axesProperties({}, 1, 'normal', 'off', 'w', 'Calibri', 30, 4/3, 2, [0.01 0.025], 'out', 'on', 'k', 'Time (s)', [xRange2(1) xRange2(3)], xLabel2(1:6), 'on', 'k', 'Frequency (Hz)', [0 3], [0 1 2 3]);
ax.XTickLabel = {'-7', '-3.5', '0'};
paperSize = resizeFig(f8, ax, width, height, label, margin, gap);
exportFig(f8, ['8_2' '.tif'], '-dtiffnocompression','-r300', paperSize);

f9 = figure('Units', 'normalized', 'Position', [0, .01, .98, .89]);
hold on
plot(t_SWDinit, CxSupTRmeanShort,'m','LineWidth',lineWidth)
plot(t_SWDinit, CxInfTRmeanShort,'r','LineWidth',lineWidth)
plot(t_SWDinit, TCTRmeanShort,'Color',gold,'LineWidth',lineWidth)
plot(t_SWDinit, TC2TRmeanShort,'Color',orange,'LineWidth',lineWidth)
plot(t_SWDinit, NRTTRmeanShort,'c','LineWidth',lineWidth)
plot(t_SWDinit, NRT2TRmeanShort,'b','LineWidth',lineWidth)
plot([xLabel([2 5]);xLabel([2 5])], [[0;16.6] [0;16.6]],'r--','LineWidth',2)
plot([round(length(t_SWD)/2);round(length(t_SWD)/2)], [0;16.6],'w','LineWidth',15)
hold off
ax = axesProperties({}, 1, 'normal', 'off', 'w', 'Calibri', 30, 4/3, 2, [0.01 0.025], 'out', 'on', 'k', 'Time (s)', [xRange(1) xRange(end)], [xLabel xRange(end)], 'on', 'k', 'Frequency (Hz)', [0 16.6], [0 8 16]);
ax.XTickLabel = {'-5', '0', '5', '-5', '0', '5', '15'};
paperSize = resizeFig(f9, ax, width, height, label, margin, gap);
exportFig(f9, ['9' '.tif'], '-dtiffnocompression','-r300', paperSize);



Cx23BR2mean = mean(mean(Cx23BR2));
Cx23TR2mean = mean(mean(Cx23TR2));
Cx23SR2mean = mean(mean(Cx23SR2));
Cx23iBR2mean = mean(mean(Cx23iBR2));
Cx23iTR2mean = mean(mean(Cx23iTR2));
Cx23iSR2mean = mean(mean(Cx23iSR2));
Cx4BR2mean = mean(mean(Cx4BR2));
Cx4TR2mean = mean(mean(Cx4TR2));
Cx4SR2mean = mean(mean(Cx4SR2));
Cx4iBR2mean = mean(mean(Cx4iBR2));
Cx4iTR2mean = mean(mean(Cx4iTR2));
Cx4iSR2mean = mean(mean(Cx4iSR2));
CxSupBR2mean = Cx23BR2mean/3 + Cx23iBR2mean/6 + Cx4BR2mean/3 + Cx4iBR2mean/6;
CxSupTR2mean = Cx23TR2mean/3 + Cx23iTR2mean/6 + Cx4TR2mean/3 + Cx4iTR2mean/6;
CxSupSR2mean = Cx23SR2mean/3 + Cx23iSR2mean/6 + Cx4SR2mean/3 + Cx4iSR2mean/6;
Cx5BR2mean = mean(mean(Cx5BR2));
Cx5TR2mean = mean(mean(Cx5TR2));
Cx5SR2mean = mean(mean(Cx5SR2));
Cx5iBR2mean = mean(mean(Cx5iBR2));
Cx5iTR2mean = mean(mean(Cx5iTR2));
Cx5iSR2mean = mean(mean(Cx5iSR2));
Cx6BR2mean = mean(mean(Cx6BR2));
Cx6TR2mean = mean(mean(Cx6TR2));
Cx6SR2mean = mean(mean(Cx6SR2));
Cx6iBR2mean = mean(mean(Cx6iBR2));
Cx6iTR2mean = mean(mean(Cx6iTR2));
Cx6iSR2mean = mean(mean(Cx6iSR2));
CxInfBR2mean = Cx5BR2mean/3 + Cx5iBR2mean/6 + Cx6BR2mean/3 + Cx6iBR2mean/6;
CxInfTR2mean = Cx5TR2mean/3 + Cx5iTR2mean/6 + Cx6TR2mean/3 + Cx6iTR2mean/6;
CxInfSR2mean = Cx5SR2mean/3 + Cx5iSR2mean/6 + Cx6SR2mean/3 + Cx6iSR2mean/6;
CxBR2mean = Cx23BR2mean/6 + Cx23iBR2mean/12 + Cx4BR2mean/6 + Cx4iBR2mean/12 + Cx5BR2mean/6 + Cx5iBR2mean/12 + Cx6BR2mean/6 + Cx6iBR2mean/12;
CxTR2mean = Cx23TR2mean/6 + Cx23iTR2mean/12 + Cx4TR2mean/6 + Cx4iTR2mean/12 + Cx5TR2mean/6 + Cx5iTR2mean/12 + Cx6TR2mean/6 + Cx6iTR2mean/12;
CxSR2mean = Cx23SR2mean/6 + Cx23iSR2mean/12 + Cx4SR2mean/6 + Cx4iSR2mean/12 + Cx5SR2mean/6 + Cx5iSR2mean/12 + Cx6SR2mean/6 + Cx6iSR2mean/12;
NRTBR2mean = mean(mean(NRTBR2));
NRTTR2mean = mean(mean(NRTTR2));
NRTSR2mean = mean(mean(NRTSR2));
NRT2BR2mean = mean(mean(NRT2BR2));
NRT2TR2mean = mean(mean(NRT2TR2));
NRT2SR2mean = mean(mean(NRT2SR2));
NRT3BR2mean = NRTBR2mean/2 + NRT2BR2mean/2;
NRT3TR2mean = NRTTR2mean/2 + NRT2TR2mean/2;
NRT3SR2mean = NRTSR2mean/2 + NRT2SR2mean/2;
TCBR2mean = mean(mean(TCBR2));
TCTR2mean = mean(mean(TCTR2));
TCSR2mean = mean(mean(TCSR2));
TC2BR2mean = mean(mean(TC2BR2));
TC2TR2mean = mean(mean(TC2TR2));
TC2SR2mean = mean(mean(TC2SR2));
TC3BR2mean = TCBR2mean/2 + TC2BR2mean/2;
TC3TR2mean = TCTR2mean/2 + TC2TR2mean/2;
TC3SR2mean = TCSR2mean/2 + TC2SR2mean/2;

for i = 1:2
    f10 = figProperties('events of SWC', 'normalized', [0, .005, .97, .90], 'w', 'on');
    hold on
    width = 20;
    plot(0,0,'m','LineWidth',width)
    plot(0,0,'r','LineWidth',width)
    plot(0,0,'Color',orange,'LineWidth',width)
    plot(0,0,'Color',gold,'LineWidth',width)
    plot(0,0,'b','LineWidth',width)
    plot(0,0,'c','LineWidth',width)
    bar(1, CxSupBR2mean, 'm');
    bar(2, CxSupTR2mean, 'm');
    bar(3, CxSupSR2mean, 'm');

    gap = 1;
    bar(4+gap, CxInfBR2mean, 'r');
    bar(5+gap, CxInfTR2mean, 'r');
    bar(6+gap, CxInfSR2mean, 'r');

    bar(7+2*gap, TCBR2mean, 'Facecolor',gold);
    bar(8+2*gap, TCTR2mean, 'Facecolor',gold);
    bar(9+2*gap, TCSR2mean, 'Facecolor',gold);

    bar(10+3*gap, TC2BR2mean, 'Facecolor',orange);
    bar(11+3*gap, TC2TR2mean, 'Facecolor',orange);
    bar(12+3*gap, TC2SR2mean, 'Facecolor',orange);

    bar(13+4*gap, NRTBR2mean, 'c');
    bar(14+4*gap, NRTTR2mean, 'c');
    bar(15+4*gap, NRTSR2mean, 'c');

    bar(16+5*gap, NRT2BR2mean, 'b');
    bar(17+5*gap, NRT2TR2mean, 'b');
    bar(18+5*gap, NRT2SR2mean, 'b');
    
    plot([0 25],[0.02 0.02],'r--')
    hold off
    %legStr = {'Cx2/3/4', 'Cx5/6', 'TC_{FO}', 'TC_{HO}', 'NRT_{FO}', 'NRT_{HO}'};
    %legProperties(legStr, 'off', 30, 3, 'NorthEast');
    if i == 1
        ax1 = axesProperties({}, 1, 'normal', 'off', 'w', 'Calibri', 25, 4/3, 2, [0.005 0], 'out', 'on', 'k', {}, [], [1 2 3 5 6 7 9 10 11 13 14 15 17 18 19 21 22 23], 'on', 'k', {'Fraction'}, [-1/3+0.02 1], [0 0.5 1]);
    elseif i == 2
        ax1 = axesProperties({}, 1, 'normal', 'off', 'w', 'Calibri', 25, 4/3, 2, [0.005 0], 'out', 'on', 'k', {}, [], [1 2 3 5 6 7 9 10 11 13 14 15 17 18 19 21 22 23], 'on', 'k', {'Fraction'}, [0 0.08], [0 0.01 0.02]);
    end
    ax1.XTickLabel = {'','L2/3/4','', '','L5/6','', '','TC_{FO}','', '','TC_{HO}','', '','NRT_{FO}','', '','NRT_{HO}',''};
    %ax1.XTickLabelRotation = 90;
    %ax1.XMinorTick = 'on';
    label = [2.7 1.8];
    margin = [-1.5 0.3];
    width = 2*15-label(1)-margin(1);
    height = (2*15)/(166.9/55.972)-label(2)-margin(2);
    paperSize = resizeFig(f10, ax1, width, height, label, margin, 0);
    exportFig(f10, ['10_' num2str(i) '_.tif'],'-dtiffnocompression','-r300', paperSize);
end
