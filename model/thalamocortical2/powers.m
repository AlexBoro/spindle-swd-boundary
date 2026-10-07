% f4 = figure('Units', 'normalized', 'Position', [0, .01, .98, .89]);
% load('powers.mat')
% plot(f,powerDBfilt, 'k', 'Linewidth', 3);
% hold on
% load('powers2.mat')
% p = plot(f,powerDBfilt, 'r', 'Linewidth', 3);
% hold off
% titleStr = 'Frequency power spectrum';
% set(f4,'name',titleStr)
% title(titleStr)
% xlabel('Frequency (Hz)')
% ylabel('Power (dB)')
% 
% %xLims = [0 3];
% xLims = [0 1];
% xTicks = xLims(1):(xLims(end)-xLims(1))/4:xLims(end);
% %yLims = [-15 30];
% yLims = [-10 35];
% %yTicks = [yLims(1) 0 yLims(end)/2 yLims(end)];
% yTicks = [yLims(1) 0 yLims(end)];
% axesProperties({}, 1, 'normal', 'off', 'w', 'Calibri', 30, 1, 2, [0.01 0.025], 'out', 'off', 'k', 'Frequency (Hz)', xLims, xTicks, 'off', 'k', 'Power (dB)', yLims, yTicks);
% label = [2.95 2.85];
% margin = [0.2 0.3];
% width = 2*15-label(1)-margin(1);
% height = (2*15)/(46.855/(3*9.941))-label(2)-margin(2);
% paperSize = resizeFig(gcf, gca, width, height, label, margin, 0);
% legStr = {'1*g_{GABA_A}', '0*g_{GABA_A}'};
% legend(legStr, 'Box', 'off', 'FontSize', 30, 'LineWidth', 3, 'Location', 'NorthEast');
% name = 'EEG_power1';
% exportFig(gcf, [name '.tif'],'-dtiffnocompression','-r300', paperSize);

f4 = figure('Units', 'normalized', 'Position', [0, .01, .98, .89]);
load('powers3.mat')
plot(f,powerDBfilt, 'k', 'Linewidth', 3);
hold on
load('powers4.mat')
p = plot(f,powerDBfilt, 'r', 'Linewidth', 3);
hold off
titleStr = 'Frequency power spectrum';
set(f4,'name',titleStr)
title(titleStr)
xlabel('Frequency (Hz)')
ylabel('Power (dB)')

xLims = [0 5];
xTicks = xLims(1):(xLims(end)-xLims(1))/4:xLims(end);
%yLims = [-15 30];
yLims = [-35 40];
%yTicks = [yLims(1) 0 yLims(end)/2 yLims(end)];
yTicks = [yLims(1) 0 yLims(end)];
axesProperties({}, 1, 'normal', 'off', 'w', 'Calibri', 30, 1, 2, [0.01 0.025], 'out', 'off', 'k', 'Frequency (Hz)', xLims, xTicks, 'off', 'k', 'Power (dB)', yLims, yTicks);
label = [2.95 2.85];
margin = [0.2 0.3];
width = 2*15-label(1)-margin(1);
height = (2*15)/(46.855/(3*9.941))-label(2)-margin(2);
paperSize = resizeFig(gcf, gca, width, height, label, margin, 0);
legStr = {'1*g_{GABA_A}', '0*g_{GABA_A}'};
legend(legStr, 'Box', 'off', 'FontSize', 30, 'LineWidth', 3, 'Location', 'NorthEast');
name = 'EEG_power2';
exportFig(gcf, [name '.tif'],'-dtiffnocompression','-r300', paperSize);