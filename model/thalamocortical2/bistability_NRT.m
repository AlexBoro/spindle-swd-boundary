% IT parameters and transformations
function bistability_NRT

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
yRange = [0 225];
yRangeNet = [-35 50];
traceWidth = 3;
celsius = 37;
Area = area(42, 63);

axesHandles = gobjects(1,7);
width = 15.92;
height = 15.92;
label = [3.9 3.9];
margin = [0.7 0.7];
gap = 1.5;
legFont = 27;





% Line 1:
titleStr = 'Key membrane currents involved in bistability';
FARADAY = 96485.309;
R = 8.3144621;
cai = 50e-6;
cao = 1.5;
carev = ((1e3) * (R*(celsius+273.15))/(2*FARADAY)) * log(cao/cai);
m_inf = (1 ./ (1 + exp(-(Vm+50)/7.4))).^2;
h_inf = 1 ./ (1 + exp((Vm+78)/5));
iw = 1e9*Area*0.00069*m_inf.*h_inf.*(Vm-carev);
INaP = 1e9*Area*0.000015*(1 ./ (1 + exp(-(Vm + 53.87) ./ 8.57))).*(Vm-30);
iKLeak = 1e9*Area*0.0000223.*(Vm+90);
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
legProperties(legStr, 'off', legFont, 3, 'SouthEast');





% Line 2:
fileName = '0.000000_NRT0data0.0000100_ 75_0.0000223_0.0020.dat';
[~, NRT] = loadFile(fileName, Area, 'NRT');
f4 = figProperties('Trace #1', 'normalized', [0, .005, .97, .90], 'w', visibility);
subplot(2,1,1)
xRange2 = [51.7 59.7];
inds = findRange(NRT.t*1e-3, xRange2+[0.16 0]);
plot(NRT.t(inds(1):inds(2))*1e-3, NRT.v(inds(1):inds(2)), 'Color', black, 'LineWidth', traceWidth)
axesProperties({}, 1, 'normal', 'off', 'w', 'Calibri', 30, 4/3, 2, [0.01 0.025], 'out', 'off', 'w', {}, xRange2, [], 'on', 'k', 'Vm (mV)', [-80 0], [-80 0]);
axesHandles(4) = gca;
subplot(2,1,2)
hold on
plot(NRT.t(inds(1):inds(2))*1e-3, NRT.ICAN(inds(1):inds(2))*1e3, 'k', 'LineWidth', traceWidth)
inds2 = findRange(NRT.t*1e-3, [xRange2(1) 55]);
[ICAN1, i1] = min(NRT.ICAN(inds2(1):inds2(2))*1e3);
i1 = inds2(1)-1+i1;
plot(NRT.t(i1)*1e-3, ICAN1, 'r.', 'MarkerSize', 20)
plot([NRT.t(inds(1))*1e-3 NRT.t(i1)*1e-3], [ICAN1 ICAN1], 'r--', 'LineWidth', 2)
plot([NRT.t(i1)*1e-3 NRT.t(i1)*1e-3], [0 ICAN1], 'r--', 'LineWidth', 2)
i2 = findInd(NRT.t*1e-3, 57.9);
ICAN2 = NRT.ICAN(i2)*1e3;
plot(NRT.t(i2)*1e-3, ICAN2, 'r.', 'MarkerSize', 20)
plot([NRT.t(inds(1))*1e-3 NRT.t(i2)*1e-3], [ICAN2 ICAN2], 'r--', 'LineWidth', 2)
plot([NRT.t(i2)*1e-3 NRT.t(i2)*1e-3], [0 ICAN2], 'r--', 'LineWidth', 2)
hold off
axesProperties({}, 1, 'normal', 'off', 'w', 'Calibri', 30, 4/3, 2, [0.01 0.025], 'out', 'off', 'w', {}, xRange2, [], 'on', 'k', 'I_{CAN} (pA)', [-40 0], [-40 0]);
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
legStr = {'I_{Na(P)} + I_{Twindow} + I_{CAN} + I_{K(leak)} @ t_1', 'I_{Na(P)} + I_{Twindow} + I_{CAN} + I_{K(leak)} @ t_2', 'AP threshold'};
[f6, axesHandles(7)] = netPlot(titleStr3, data, lineCols, penSz, Vm, xRange, yRangeNet, visibility);
set(get(get(axesHandles(7).Children(1),'Annotation'),'LegendInformation'),'IconDisplayStyle','off');
set(get(get(axesHandles(7).Children(2),'Annotation'),'LegendInformation'),'IconDisplayStyle','off');
set(get(get(axesHandles(7).Children(3),'Annotation'),'LegendInformation'),'IconDisplayStyle','off');
hold on
plot([-50 -50], [yRangeNet(1) 30], 'k:', 'LineWidth', 2)
hold off
resizeFig(f6, axesHandles(7), width, height, label, margin, gap);
l = legProperties(legStr, 'off', legFont, 3, 'NorthWest');
%set(l, 'Box', 'on', 'EdgeColor', [1 1 1])





% Save figures:
exportFig(f1, ['f1_1' '.tif'],'-dtiffnocompression','-r300', paperSize);
exportFig(f2, ['f1_2' '.tif'],'-dtiffnocompression','-r300', paperSize);
exportFig(f3, ['f1_3' '.tif'],'-dtiffnocompression','-r300', paperSize);
exportFig(f4, ['f2_1' '.tif'],'-dtiffnocompression','-r300', paperSize);
exportFig(f5, ['f2_2' '.tif'],'-dtiffnocompression','-r300', paperSize);
exportFig(f6, ['f2_3' '.tif'],'-dtiffnocompression','-r300', paperSize);





function [f, ax] = biPlot(titleStr, data, lineCols, penSz, Vm, xRange, yRange, visibility)
f = multiPlot(titleStr, abs(data), lineCols, penSz, Vm, visibility);
ax = axesProperties({}, 1, 'normal', 'off', 'w', 'Calibri', 30, 4/3, 2, [0.01 0.025], 'out', 'on', 'k', 'V_m (mV)', xRange, [-90 -60 -30], 'on', 'k', '|I| (pA)', yRange, [70 140 210]);

function [f, ax] = netPlot(titleStr, data, lineCols, penSz, Vm, xRange, yRange, visibility)
f = multiPlot(titleStr, data, lineCols, penSz, Vm, visibility);
ax = axesProperties({}, 1, 'normal', 'off', 'w', 'Calibri', 30, 4/3, 2, [0.01 0.025], 'out', 'on', 'k', 'V_m (mV)', xRange, [-90 -60 -30], 'on', 'k', 'I (pA)', yRange, [-25 0 25 50]);
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
