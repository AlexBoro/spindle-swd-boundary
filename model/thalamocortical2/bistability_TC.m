% IT parameters and transformations
function bistability_TC

close all
%clear all %#ok<CLFUN>
clc

yellow = [1 1 0]; %#ok<NASGU>
magenta = [1 0 1]; %#ok<NASGU>
cyan = [0 1 1]; %#ok<NASGU>
red = [1 0 0];
green = [0 1 0];
%blue = [0 0 1];
blue = [0 0.75 1];
white = [1 1 1]; %#ok<NASGU>
black = [0 0 0];

visibility = 'on';
xRange = [-90 -30];
Vm = xRange(1):0.01:xRange(end);
yRange = [0 280];
yRangeNet = [-20 40];
traceWidth = 3;
celsius = 37;
Area = area(60, 90);

axesHandles = gobjects(1,11);
width = 15.92;
height = 15.92;
label = [4.1 4.1];
margin = [0.6 0.6];
gap = 1.5;
legFont = 27;





% Line 1:
titleStr = 'Key membrane currents involved in bistability';
m_inf = (1 ./ (1 + exp(-(Vm+57)/6.2))).^2;
h_inf = 1 ./ (1 + exp((Vm+81)/4)); % Could depolarise by 1.6 mV to produce a closer match to the data
iw = 1e9*Area*m_inf.*h_inf.*ghk(Vm, celsius);
INaP = 1e9*Area*0.00001612*(1 ./ (1 + exp(-(Vm + 53.87) ./ 8.57))).*(Vm-30);
INaP = 1e9*Area*0.00002015*(1 ./ (1 + exp(-(Vm + 53.87) ./ 8.57))).*(Vm-30);
iKLeak = 1e9*Area*0.000023.*(Vm+90);
data = [iw; INaP; iKLeak];
lineCols = [red; blue; black];
penSz = ones(1, size(data,1))*3;
legStr = {'I_{Twindow}', 'I_{Na(P)}', 'I_{K(leak)}'};
[f1, axesHandles(1)] = biPlot(titleStr, data, lineCols, penSz, Vm, xRange, yRange, visibility);
paperSize = resizeFig(f1, axesHandles(1), width, height, label, margin, gap);
legProperties(legStr, 'off', legFont, 3, 'NorthWest');

titleStr2 = 'Sum of key membrane currents involved in bistability';
data = [INaP+iw; iKLeak];
lineCols = [green; black];
legStr = {'I_{Na(P)} + I_{Twindow}', 'I_{K(leak)}'};
[f2, axesHandles(2)] = biPlot(titleStr2, data, lineCols, penSz, Vm, xRange, yRange, visibility);
resizeFig(f2, axesHandles(2), width, height, label, margin, gap);
legProperties(legStr, 'off', legFont, 3, 'NorthWest');

titleStr3 = 'Net current';
data = [INaP+iKLeak; INaP+iw+iKLeak];
lineCols = [blue; green];
legStr = {'I_{Na(P)} + I_{K(leak)}', 'I_{Na(P)} + I_{Twindow} + I_{K(leak)}'};
[f3, axesHandles(3)] = netPlot(titleStr3, data, lineCols, penSz, Vm, xRange, yRangeNet, visibility);
resizeFig(f3, axesHandles(3), width, height, label, margin, gap);
legProperties(legStr, 'off', legFont, 3, 'NorthWest');





% Line 2:
fileName = 'z1_TCdata0.000120_93.0_0.000019200_0.0045.dat';
[~, TC] = loadFile(fileName, Area, 'TC');
f4 = figProperties('Trace #1', 'normalized', [0, .005, .97, .90], 'w', visibility);
subplot(2,1,1)
i1 = findInd(TC.t*1e-3, 80.4);
plot(TC.t(i1:end)*1e-3, TC.v(i1:end), 'Color', black, 'LineWidth', traceWidth)
axesProperties({}, 1, 'normal', 'off', 'w', 'Calibri', 30, 4/3, 2, [0.01 0.025], 'out', 'off', 'w', {}, [80 100], [], 'on', 'k', 'Vm (mV)', [-85 0], [-85 0]);
axesHandles(4) = gca;
subplot(2,1,2)
hold on
plot(TC.t(i1:end)*1e-3, TC.ICAN(i1:end)*1e3, 'k', 'LineWidth', traceWidth)
inds = findRange(TC.t*1e-3, [80 90]);
[ICAN1, i2] = min(TC.ICAN(inds(1):inds(2))*1e3);
i2 = inds(1)-1+i2;
plot(TC.t(i2)*1e-3, ICAN1, 'r.', 'MarkerSize', 20)
plot([TC.t(i1)*1e-3 TC.t(i2)*1e-3], [ICAN1 ICAN1], 'r--', 'LineWidth', 2)
plot([TC.t(i2)*1e-3 TC.t(i2)*1e-3], [0 ICAN1], 'r--', 'LineWidth', 2)
i3 = findInd(TC.t*1e-3, 93.5);
ICAN2 = TC.ICAN(i3)*1e3;
plot(TC.t(i3)*1e-3, ICAN2, 'r.', 'MarkerSize', 20)
plot([TC.t(i1)*1e-3 TC.t(i3)*1e-3], [ICAN2 ICAN2], 'r--', 'LineWidth', 2)
plot([TC.t(i3)*1e-3 TC.t(i3)*1e-3], [0 ICAN2], 'r--', 'LineWidth', 2)
hold off
axesProperties({}, 1, 'normal', 'off', 'w', 'Calibri', 30, 4/3, 2, [0.01 0.025], 'out', 'off', 'w', {}, [80 100], [], 'on', 'k', 'I_{CAN} (pA)', [-2.5 0], [-2.5 0]);
axesHandles(5) = gca;
resizeFig(f4, axesHandles(4:5), width, height, label, margin, gap);

data = [INaP+iw+ICAN1; INaP+iw+ICAN2; iKLeak];
lineCols = [green; blue; black];
legStr = {'I_{Na(P)} + I_{Twindow} + I_{CAN} @ t_1', 'I_{Na(P)} + I_{Twindow} + I_{CAN} @ t_2', 'I_{K(leak)}'};
[f5, axesHandles(6)] = biPlot(titleStr2, data, lineCols, penSz, Vm, xRange, yRange, visibility);
resizeFig(f5, axesHandles(6), width, height, label, margin, gap);
legProperties(legStr, 'off', legFont, 3, 'NorthWest');

data = [INaP+iw+ICAN1+iKLeak; INaP+iw+ICAN2+iKLeak];
lineCols = [green; blue];
legStr = {'I_{Na(P)} + I_{Twindow} + I_{CAN} + I_{K(leak)} @ t_1', 'I_{Na(P)} + I_{Twindow} + I_{CAN} + I_{K(leak)} @ t_2'};
[f6, axesHandles(7)] = netPlot(titleStr3, data, lineCols, penSz, Vm, xRange, yRangeNet, visibility);
resizeFig(f6, axesHandles(7), width, height, label, margin, gap);
legProperties(legStr, 'off', legFont, 3, 'NorthWest');





% Line 3:
fileName = 'z1_TCdata0.000120_93.0_0.000019200_0.0050.dat';
[~, TC] = loadFile(fileName, Area, 'TC');
f7 = figProperties('Trace #2', 'normalized', [0, .005, .97, .90], 'w', visibility);
subplot(2,1,1)
i1 = findInd(TC.t*1e-3, 40.4);
plot(TC.t(i1:end)*1e-3, TC.v(i1:end), 'Color', black, 'LineWidth', traceWidth)
axesProperties({}, 1, 'normal', 'off', 'w', 'Calibri', 30, 4/3, 2, [0.01 0.025], 'out', 'off', 'w', {}, [40 60], [], 'on', 'k', 'Vm (mV)', [-85 0], [-85 0]);
axesHandles(8) = gca;
subplot(2,1,2)
hold on
plot(TC.t(i1:end)*1e-3, TC.ICAN(i1:end)*1e3, 'k', 'LineWidth', traceWidth)
inds = findRange(TC.t*1e-3, [40 50]);
[ICAN1, i2] = min(TC.ICAN(inds(1):inds(2))*1e3);
i2 = inds(1)-1+i2;
plot(TC.t(i2)*1e-3, ICAN1, 'r.', 'MarkerSize', 20)
plot([TC.t(i1)*1e-3 TC.t(i2)*1e-3], [ICAN1 ICAN1], 'r--', 'LineWidth', 2)
plot([TC.t(i2)*1e-3 TC.t(i2)*1e-3], [0 ICAN1], 'r--', 'LineWidth', 2)
i3 = findInd(TC.t*1e-3, 53);
ICAN2 = TC.ICAN(i3)*1e3;
plot(TC.t(i3)*1e-3, ICAN2, 'r.', 'MarkerSize', 20)
plot([TC.t(i1)*1e-3 TC.t(i3)*1e-3], [ICAN2 ICAN2], 'r--', 'LineWidth', 2)
plot([TC.t(i3)*1e-3 TC.t(i3)*1e-3], [0 ICAN2], 'r--', 'LineWidth', 2)
hold off
axesProperties({}, 1, 'normal', 'off', 'w', 'Calibri', 30, 4/3, 2, [0.01 0.025], 'out', 'off', 'w', {}, [40 60], [], 'on', 'k', 'I_{CAN} (pA)', [-12 0], [-12 0]);
axesHandles(9) = gca;
resizeFig(f7, axesHandles(8:9), width, height, label, margin, gap);

data = [INaP+iw+ICAN1; INaP+iw+ICAN2; iKLeak];
lineCols = [green; blue; black];
[f8, axesHandles(10)] = biPlot(titleStr2, data, lineCols, penSz, Vm, xRange, yRange, visibility);
resizeFig(f8, axesHandles(10), width, height, label, margin, gap);

data = [INaP+iw+ICAN1+iKLeak; INaP+iw+ICAN2+iKLeak];
lineCols = [green; blue];
[f9, axesHandles(11)] = netPlot(titleStr3, data, lineCols, penSz, Vm, xRange, yRangeNet, visibility);
resizeFig(f9, axesHandles(11), width, height, label, margin, gap);





% Save figures:
% exportFig(f1, ['f1_1' '.tif'],'-dtiffnocompression','-r300', paperSize);
% exportFig(f2, ['f1_2' '.tif'],'-dtiffnocompression','-r300', paperSize);
% exportFig(f3, ['f1_3' '.tif'],'-dtiffnocompression','-r300', paperSize);
% exportFig(f4, ['f2_1' '.tif'],'-dtiffnocompression','-r300', paperSize);
% exportFig(f5, ['f2_2' '.tif'],'-dtiffnocompression','-r300', paperSize);
% exportFig(f6, ['f2_3' '.tif'],'-dtiffnocompression','-r300', paperSize);
% exportFig(f7, ['f3_1' '.tif'],'-dtiffnocompression','-r300', paperSize);
% exportFig(f8, ['f3_2' '.tif'],'-dtiffnocompression','-r300', paperSize);
% exportFig(f9, ['f3_3' '.tif'],'-dtiffnocompression','-r300', paperSize);





% Full figure:
% titleStr = 'Fig1_6';
% arrangeImages(titleStr, 'portrait', 2.54, 1, 1, 1, 1, imageHandles, 'rectangle', [1 1]);
% print([titleStr '.tif'],'-dtiffnocompression','-r300');





function [f, ax] = biPlot(titleStr, data, lineCols, penSz, Vm, xRange, yRange, visibility)
f = multiPlot(titleStr, abs(data), lineCols, penSz, Vm, visibility);
ax = axesProperties({}, 1, 'normal', 'off', 'w', 'Calibri', 30, 4/3, 2, [0.01 0.025], 'out', 'on', 'k', 'V_m (mV)', xRange, [-90 -60 -30], 'on', 'k', '|I| (pA)', yRange, [60 120 180]);

function [f, ax] = netPlot(titleStr, data, lineCols, penSz, Vm, xRange, yRange, visibility)
f = multiPlot(titleStr, data, lineCols, penSz, Vm, visibility);
ax = axesProperties({}, 1, 'normal', 'off', 'w', 'Calibri', 30, 4/3, 2, [0.01 0.025], 'out', 'on', 'k', 'V_m (mV)', xRange, [-90 -60 -30], 'on', 'k', 'I (pA)', yRange, [-20 0 20 40]);
hold on
plot(Vm, zeros(1,length(Vm)), 'k', 'LineWidth', 2)
for i = 1:size(data,1)
    spPlot(data(i,:), Vm);
end
hold off

function sp = spPlot(i1, Vm)
sp = zeros(1,3);
count = 1;
for i = 2:length(i1)
    if (i1(i) > 0 && i1(i-1) < 0) || (i1(i) < 0 && i1(i-1) > 0)
        sp(count) = (Vm(i)+Vm(i-1))/2;
        count = count+1;
    end
end
plot(sp, zeros(1,3), 'k.', 'MarkerSize', 40)
