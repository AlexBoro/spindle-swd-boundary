% The script file plots the membrane potential traces of single thalamic cells.

clc
close all
clear all %#ok<CLALL>
format longG
AreaCx3(1) = area(5.644, 5.644);
AreaCx3(2) = area(5.644, 160*5.644);
AreaTC = area(60, 90);
AreaNRT = area(42, 63);

list = dir('*dat');
%iList = 901:1500;
iList = 1:600;

fullLength = 1;
xRange = [0 1200000];

% EEG part:
if exist('EEG.bin', 'file')
    EEG = readBinary('EEG.bin', 'double');
    dt = 0.25;
    t = dt:dt:numel(EEG)*dt;
else
    cellType = 'FS';
    for i = iList
        i %#ok<*NOPRT>
        fileName = list(i).name;
        cellTypePrev = cellType;
        cellType = fileName(20:21);
        
        if ~strcmp(cellType, 'FS')
            % Load:
            [~, data] = loadFile(fileName, AreaCx3, 'Cx3');
            
            % Resample:
            [t, iunique] = unique(data.t);
            iGlu = interp1(t,data.iGlu(iunique),t);
            iGABA = interp1(t,data.iGABA(iunique),t);
            dt = t(2)-t(1);
            if ~fullLength
                iRange = xRange./dt+1;
                iRange = iRange(1):iRange(end);
                t = t(iRange);
                iGlu = iGlu(iRange);
                iGABA = iGABA(iRange);
            end
            
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
            if i == iList(1)
                EEG = zeros(size(t));
            end
            EEG = EEG + convFact*((230/(4*pi))*iGlu./r_i);
            r_i = sqrt((h+500)^2 + cellPos^2);
            EEG = EEG + convFact*((230/(4*pi))*iGABA./r_i);
        end
    end
end

% Butterworth filter:
Rp = 0.5;                                                                   % Passband riple, dB
Rs = 10;                                                                    % Stopband attenuation, dB
NyqFreq = (1000/dt)/2;                                                      % The Nyquist frequency
Wp = 40/NyqFreq;                                                           % Passbands, normalised frequency
Ws = 50/NyqFreq;                                                           % Stopband, normalised frequency
[n, Wn] = buttord(Wp, Ws, Rp, Rs);                                          % n is a filter order
[b, a] = butter(n, Wn, 'low');
EEGfilt = filtfilt(double(b), double(a), EEG);

% load('EEG.mat');
%xRange = [415000 595000];
%xRange = [521500 533500];
%xRange = [528428.155547246 528848.752737567];
%xRange = [949000.2562 1149000.2562];
%xRange = [78382.8 278382.8];
%xRange = [270909.1 470909.1];
%xRange = [566446.314964599 766446.314964599];
%xRange = [868.595028396485 1068.59502839649].*1000;
%xRange = [659.173548876533 859.173548876533].*1000;
%xRange = [296.859521074531 496.859521074531].*1000;
%xRange = [45.7851242254588 245.785124225459].*1000;
%xRange = [0 200000];
%xRange = [885785.123966942 1085785.12396694];
figure('Units', 'normalized', 'Position', [0, .01, .98, .89]);
plot(t*1e-3, EEGfilt, 'Color', 'k', 'LineWidth', 0.1)
%plot(t*1e-3, EEGfilt, 'Color', 'k', 'LineWidth', 2)
%plot(t*1e-3, EEGfilt, 'Color', 'k', 'LineWidth', 3)
xlim(xRange/1000)

titleStr = 'EEG';
xLims = xRange/1000;
xTicks = xLims(1):(xLims(end)-xLims(1))/4:xLims(end);
yLims = [-26 3];
yTicks = [yLims(1) 0 yLims(end)];
axesProperties(titleStr, 1, 'normal', 'off', 'w', 'Calibri', 20, 1, 2, [0.01 0.025], 'out', 'off', 'k', 'Time (s)', xLims, xTicks, 'off', 'k', 'Voltage (\muV)', yLims, yTicks);
width = 2*15;
% height = width/(112.326/5.7150);
%height = width/(38.883/5.7150);
height = width/(81.704/11.562);
label = [0 0];
margin = [0 0];
paperSize = resizeFig(gcf, gca, width, height, label, margin, 0);
name = 'EEG';
exportFig(gcf, [name '.eps'],'-depsc','-r1200', paperSize);

% [z, p, k] = butter(n, Wn, 'low');
% SOS = zp2sos(z,p,k);                                                        % Converts to second order sections
% f2 = figure('Units', 'normalized', 'Position', [0, .01, .98, .89]);
% freqz(SOS,2048,2*NyqFreq);                                                  % Plots the frequency response

% Power spectra:
[~, ~, amplitude, ~, power, ~, powerDB, ~, PSD, ratio] = spectra(EEG, dt);
[f, ~, amplitudeFilt, ~, powerFilt, ~, powerDBfilt, ~, PSDfilt, ratioFilt] = spectra(EEGfilt, dt);
% f3 = figure('Units', 'normalized', 'Position', [0, .01, .98, .89]);
% plot(f, amplitude);
% hold on 
% plot(f, amplitudeFilt, 'r');
% hold off
% titleStr = 'Frequency amplitude spectra';
% set(f3,'name',titleStr)
% title(titleStr)
% xlabel('Frequency (Hz)')
% ylabel('Amplitude (\muV)')

f4 = figure('Units', 'normalized', 'Position', [0, .01, .98, .89]);
%plot(f,PSD);
hold on 
plot(f,powerDBfilt, 'k', 'Linewidth', 3);
hold off
titleStr = 'Frequency power spectrum';
set(f4,'name',titleStr)
title(titleStr)
xlabel('Frequency (Hz)')
ylabel('Power (dB)')

xLims = [0 30];
xTicks = xLims(1):(xLims(end)-xLims(1))/6:xLims(end);
%yLims = [-15 30];
yLims = [0 50];
%yTicks = [yLims(1) 0 yLims(end)/2 yLims(end)];
yTicks = [0 yLims(end)];
axesProperties({}, 1, 'normal', 'off', 'w', 'Calibri', 30, 1, 2, [0.01 0.025], 'out', 'off', 'k', 'Frequency (Hz)', xLims, xTicks, 'off', 'k', 'Power (dB)', yLims, yTicks);
label = [2.96 2.85];
margin = [0.2 0.3];
width = 2*15-label(1)-margin(1);
height = (2*15)/(53.7165/18.0176)-label(2)-margin(2);
paperSize = resizeFig(gcf, gca, width, height, label, margin, 0);
name = 'EEG_power';
exportFig(gcf, [name '.tif'],'-dtiffnocompression','-r300', paperSize);

% f5 = figure('Units', 'normalized', 'Position', [0, .01, .98, .89]);
% plot(f,PSD);
% hold on 
% plot(f,PSDfilt,'r');
% hold off
% titleStr = 'Power spectral density';
% set(f5,'name',titleStr)
% title(titleStr)
% xlabel('Frequency (Hz)')
% ylabel('Power/Frequency (dB/Hz)')
% 
% f6 = figure('Units', 'normalized', 'Position', [0, .01, .98, .89]);
% plot(f,powerDBfilt-powerDB);
% titleStr = 'Attenuation';
% set(f6,'name',titleStr)
% title(titleStr)
% xlabel('Frequency (Hz)')
% ylabel('Power (dB)')

f7 = figure('Units', 'normalized', 'Position', [0, .01, .98, .89]);
autoCorrelation = xcorr(EEGfilt);
plot([-fliplr(t) t(2:end)]*1e-3, autoCorrelation/max(autoCorrelation), 'k', 'Linewidth', 3)
xLims = [-2 2];
xTicks = xLims(1):(xLims(end)-xLims(1))/4:xLims(end);
%yLims = [0 1];
%yLims = [-0.05 1];
yLims = [0 1];
yTicks = [0 yLims(end)];
axesProperties({}, 1, 'normal', 'off', 'w', 'Calibri', 30, 1, 2, [0.01 0.025], 'out', 'off', 'k', 'Time lag (s)', xLims, xTicks, 'off', 'k', {}, yLims, yTicks);
label = [1.1 2.85];
margin = [0.2 0.3];
width = 2*15-label(1)-margin(1);
height = (2*15)/(53.7165/18.0176)-label(2)-margin(2);
paperSize = resizeFig(gcf, gca, width, height, label, margin, 0);
name = 'EEG_auto';
exportFig(gcf, [name '.tif'],'-dtiffnocompression','-r300', paperSize);

save('powers.mat','power','powerFilt','f', 'ratio', 'ratioFilt')
ratio %#ok<*NOPTS>
ratioFilt

% Save EEG trace as a binary file
if ~exist('EEG.bin', 'file')
    writeBinary(EEG, 'EEG.bin', 'double');
    writeBinary(EEG, 'EEGfilt.bin', 'double');
end