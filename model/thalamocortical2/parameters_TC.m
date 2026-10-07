% TC membrane current simulation parameters
function parameters_TC

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
black = [0 0 0]; %#ok<NASGU>
orange = [255/255,165/255,0];

visibility = 'on';
xRange = [-120 60];
Vm = xRange(1):0.04:xRange(end);
yRange = [0 1];
lineWidth = 3;
celsius = 37;

axesHandles = gobjects(1,11);
width = 15.92;
height = 15.92;
label = 4.1;
margin = 0.6;
gap = 1.5;
legFont = 27;





% INa (HH mechanism):
titleStr = 'I_{Na} steady state activation and inactivation functions';
vTraub = Vm + 42;
alpha_m = 0.32 * (13.1 - vTraub)./(exp((13.1 - vTraub)./4) - 1);
beta_m = 0.28 * (vTraub - 40.1)./(exp((vTraub - 40.1)./5) - 1);
m_inf = (alpha_m ./ (alpha_m + beta_m)).^3;
alpha_h = 0.128 * (exp((17 - vTraub)./18));
beta_h = 4 ./ (1 + exp((40 - vTraub) ./ 5));
h_inf = alpha_h ./ (alpha_h + beta_h);
data = [m_inf; h_inf];
lineCols = [green; red];
penSize = ones(1, size(data,1))*lineWidth;
legStr = {'m_{inf}^3', 'h_{inf}'};
[f1, axesHandles(1)] = sStatePlot(titleStr, data, lineCols, penSize, Vm, xRange, yRange, visibility);
paperSize = resizeFig(f1, axesHandles(1), width, height, label, margin, gap);
legProperties(legStr, 'off', legFont, 3, 'NorthWest');

phi = 3.0 ^ ((celsius-35)/10);
titleStr = 'I_{Na} activation and inactivation time constants';
tau_m = 1 ./ (alpha_m + beta_m) ./ phi;
tau_h = 1 ./ (alpha_h + beta_h) ./ phi;
data = [tau_m; tau_h];
legStr = {'\tau_m', '\tau_h'};
[f2, axesHandles(2)] = tauPlot(titleStr, data, lineCols, penSize, Vm, xRange, [0 6], [0 3 6], visibility);
resizeFig(f2, axesHandles(2), width, height, label, margin, gap);
legProperties(legStr, 'off', legFont, 3, 'NorthWest');





% IK (HH mechanism):
titleStr = 'I_{K(DR)} steady state activation function';
vTraub = Vm + 38;
alpha = 0.016 * (35.1 - vTraub)./(exp((35.1 - vTraub)./5) - 1);
beta = 0.25 * exp((20 - vTraub)./40);
data = (alpha ./ (alpha + beta)).^4;
legStr = {'n_{inf}^4'};
[f3, axesHandles(3)] = sStatePlot(titleStr, data, lineCols, penSize, Vm, xRange, yRange, visibility);
resizeFig(f3, axesHandles(3), width, height, label, margin, gap);
legProperties(legStr, 'off', legFont, 3, 'NorthWest');

phi = 3.0 ^ ((celsius-35)/10);
titleStr = 'I_{K(DR)} activation time constant';
data = 1 ./ (alpha + beta) ./ phi;
legStr = {'\tau_n'};
[f4, axesHandles(4)] = tauPlot(titleStr, data, lineCols, penSize, Vm, xRange, [0 4], [0 2 4], visibility);
resizeFig(f4, axesHandles(4), width, height, label, margin, gap);
legProperties(legStr, 'off', legFont, 3, 'NorthWest');





% IT:
titleStr = 'I_T steady state activation and inactivation functions';
m_inf = (1 ./ (1 + exp(-(Vm+57)/6.2))).^2;
h_inf = 1 ./ (1 + exp((Vm+81)/4));
data = [m_inf; h_inf];
legStr = {'m_{inf}^2', 'h_{inf}'};
[f5, axesHandles(5)] = sStatePlot(titleStr, data, lineCols, penSize, Vm, xRange, yRange, visibility);
resizeFig(f5, axesHandles(5), width, height, label, margin, gap);
legProperties(legStr, 'off', legFont, 3, 'NorthEast');

phi = 3.0 ^ ((celsius-24)/10);
titleStr = 'I_T activation and inactivation time constants';
tau_m = ( 0.612 + 1.0 ./ ( exp(-(Vm+132)/16.7) + exp((Vm+16.8)/18.2) ) ) / phi;
tau_h = zeros(1,length(Vm));
for i = 1:length(Vm)
    if Vm(i) < -80
		tau_h(i) = exp((Vm(i)+467)/66.6) / phi;
    else
		tau_h(i) = ( 28 + exp(-(Vm(i)+22)/10.5) ) / phi;
    end
end
data = [tau_m; tau_h];
legStr = {'\tau_m', '\tau_h'};
[f6, axesHandles(6)] = tauPlot(titleStr, data, lineCols, penSize, Vm, xRange, [0 80], [0 40 80], visibility);
resizeFig(f6, axesHandles(6), width, height, label, margin, gap);
legProperties(legStr, 'off', legFont, 3, 'NorthEast');





% Ih:
titleStr = 'I_h steady state activation function';
shift = -18;
data = 1 ./ (1 + exp((Vm-shift+93)./5.5));
legStr = {'m_{inf}'};
[f7, axesHandles(7)] = sStatePlot(titleStr, data, lineCols, penSize, Vm, xRange, yRange, visibility);
resizeFig(f7, axesHandles(7), width, height, label, margin, gap);
legProperties(legStr, 'off', legFont, 3, 'NorthEast');

phi = 3.0 ^ ((celsius-36)/10);
titleStr = 'I_h activation time constant';
data = (20 + 1000 ./ (exp((Vm+71.5-shift)./14.2) + exp(-(Vm+89-shift)./11.6))) ./ phi;
legStr = {'\tau_m'};
[f8, axesHandles(8)] = tauPlot(titleStr, data, lineCols, penSize, Vm, xRange, [0 1000], [0 500 1000], visibility);
resizeFig(f8, axesHandles(8), width, height, label, margin, gap);
legProperties(legStr, 'off', legFont, 3, 'NorthEast');





% Ih2:
% titleStr = 'I_{h2} steady state activation function';
% data = (1 ./ (1 + exp((Vm+75)./5.5))).^3;
% legStr = {'m_{inf}^3'};
% [f19, axesHandles(19)] = sStatePlot(titleStr, data, lineCols, penSize, Vm, xRange, yRange, visibility);
% resizeFig(f19, axesHandles(19), width, height, label, margin, gap);
% legProperties(legStr, 'off', legFont, 3, 'NorthEast');
% 
% phi = 3.0 ^ ((celsius-35)/10);
% titleStr = 'I_{h2} activation time constant';
% for i = 1:length(Vm)
%     if Vm(i) <= -77.5
%         data(i) = (29.54/exp(-0.046*Vm(i)))/phi;
%     else
%         data(i) = (12.0820/exp(0.061*Vm(i)))/phi;
%     end
% end
% legStr = {'\tau_m'};
% [f20, axesHandles(20)] = tauPlot(titleStr, data, lineCols, penSize, Vm, xRange, [0 1200], [0 600 1200], visibility);
% resizeFig(f20, axesHandles(20), width, height, label, margin, gap);
% legProperties(legStr, 'off', legFont, 3, 'NorthEast');





% INaP:
titleStr = 'I_{Na(P)} steady state activation function';
data = 1 ./ (1 + exp(-(Vm + 53.87) ./ 8.57));
legStr = {'m_{inf}'};
[f9, axesHandles(9)] = sStatePlot(titleStr, data, lineCols, penSize, Vm, xRange, yRange, visibility);
resizeFig(f9, axesHandles(9), width, height, label, margin, gap);
legProperties(legStr, 'off', legFont, 3, 'NorthWest');

phi = 3.0 ^ ((celsius-35)/10);
titleStr = 'I_{Na(P)} activation time constant';
alpha = 0.32 * (-66.58 - Vm)./(exp((-66.58 - Vm)./4)-1);
beta  = 0.28 * (39.58 + Vm)./(exp((39.58 + Vm)./5)-1);
data = (1 ./ (alpha + beta)) ./ phi;
legStr = {'\tau_m'};
[f10, axesHandles(10)] = tauPlot(titleStr, data, lineCols, penSize, Vm, xRange, [0 0.1], [0 0.05 0.1], visibility);
resizeFig(f10, axesHandles(10), width, height, label, margin, gap);
legProperties(legStr, 'off', legFont, 3, 'NorthWest');





% IA:
titleStr = 'I_A steady state activation and inactivation functions';
minf1 = (1 ./ (1 + exp(-(Vm + 60) ./ 8.5))).^4;
minf2 = (1 ./ (1 + exp(-(Vm + 36) ./ 20))).^4;
hinf = 1 ./ (1 + exp((Vm + 78) ./ 6));
data = [minf1; minf2; hinf];
lineCols = [green; blue; red];
penSize = ones(1, size(data,1))*lineWidth;
legStr = {'m_{inf1}^4', 'm_{inf2}^4', 'h_{inf1}', 'h_{inf2}'};
[f11, axesHandles(11)] = sStatePlot(titleStr, data, lineCols, penSize, Vm, xRange, yRange, visibility);
hold on
plot(Vm, hinf, 'Color', orange, 'LineWidth', penSize(1), 'LineStyle', '--')
hold off
resizeFig(f11, axesHandles(11), width, height, label, margin, gap);
legProperties(legStr, 'off', legFont, 3, 'SouthEast');

phi = 3.0 ^ ((celsius-23)/10);
titleStr = 'I_A activation and inactivation time constants';
mtau = (1 ./ (exp((Vm + 35.8) ./ 19.7) + exp((Vm + 79.7) ./ -12.7)) + 0.37) ./ phi;
htau1 = mtau;
htau2 = mtau;
for i = 1:length(Vm)
    if Vm(i) < -63
        htau1(i) = (1 / (exp((Vm(i) + 46) / 5) + exp((Vm(i) + 238) / -37.5))) / phi;
    else
        htau1(i) = 19 / phi;
    end
    if Vm(i) < -73
        htau2(i) = htau1(i);
    else
        htau2(i) = 60 / phi;
    end
end
data = [mtau; htau1; htau2];
lineCols = [green; red; orange];
legStr = {'\tau_{m1}', '\tau_{h1}', '\tau_{h2}', '\tau_{m2}'};
[f12, axesHandles(12), p] = tauPlot(titleStr, data, lineCols, penSize, Vm, xRange, [0 14], [0 7 14], visibility);
hold on
p(4) = plot(Vm, mtau, 'Color', blue, 'LineWidth', penSize(1), 'LineStyle', '--');
hold off
resizeFig(f12, axesHandles(12), width, height, label, margin, gap);
order = [1 4 2 3];
l = legend(p(order),legStr(order), 'Box', 'off', 'FontSize', legFont, 'LineWidth', lineWidth, 'Location', 'SouthEast');
position = get(l, 'Position');
position(2) = position(2) + 0.3;
set(l, 'Position', position);





% IK1:
titleStr = 'I_{K1} steady state activation function';
data = 1 ./ (1 + exp(-(Vm + 5) ./ 8.6));
legStr = {'m_{inf}'};
[f13, axesHandles(13)] = sStatePlot(titleStr, data, lineCols, penSize, Vm, xRange, yRange, visibility);
resizeFig(f13, axesHandles(13), width, height, label, margin, gap);
legProperties(legStr, 'off', legFont, 3, 'NorthWest');

titleStr = 'I_{K1} activation time constant';
data = ones(1,length(Vm))*2.5;
legStr = {'\tau_m'};
[f14, axesHandles(14)] = tauPlot(titleStr, data, lineCols, penSize, Vm, xRange, [0 5], [0 2.5 5], visibility);
resizeFig(f14, axesHandles(14), width, height, label, margin, gap);
legProperties(legStr, 'off', legFont, 3, 'NorthWest');





% IHVA:
titleStr = 'I_{HVA} steady state activation function';
FARADAY = 96485.309;
R = 8.3144621;
z = (1e-3)*2.25*FARADAY/(R*(celsius+273.15));
shift = 15;
data = (1./(1 + exp(-z*(Vm + 19.48 - shift)))).^2;
legStr = {'m_{inf}^2'};
[f15, axesHandles(15)] = sStatePlot(titleStr, data, lineCols, penSize, Vm, xRange, yRange, visibility);
resizeFig(f15, axesHandles(15), width, height, label, margin, gap);
legProperties(legStr, 'off', legFont, 3, 'NorthWest');

phi = 3.0 ^ ((celsius-21)/10);
titleStr = 'I_{HVA} activation time constant';
a = 1.6./(1 + exp(-0.0072*(Vm - shift - 5)));
b = 0.02*(Vm - shift + 8.69)./(exp((Vm - shift + 8.69)./5.36) - 1);
data = (1./(a + b)) ./ phi;
legStr = {'\tau_m'};
[f16, axesHandles(16)] = tauPlot(titleStr, data, lineCols, penSize, Vm, xRange, [0 0.22], [0 0.11 0.22], visibility);
resizeFig(f16, axesHandles(16), width, height, label, margin, gap);
legProperties(legStr, 'off', legFont, 3, 'NorthWest');





% IAHP:
titleStr = 'I_{AHP} steady state activation functions';
Cai = (0:0.01:1000)./1e6; % mM; *1e3 uM; *1e6 nM
cac1 = 0.00032;
cac2 = 0.00032;
power = 5.3;
m_inf1 = 1 ./ ((cac1 ./ Cai).^power + 1);
m_inf2 = 1 ./ ((cac2 ./ Cai).^power + 1);
Cai = Cai*1e3;
legStr = {'m_{inf (mAHP)}', 'm_{inf (sAHP)}'};
f17 = multiPlot(titleStr, m_inf1, green, penSize, Cai, visibility);
hold on
plot(Cai, m_inf2, 'Color', blue, 'LineWidth', penSize(1), 'LineStyle', '--')
hold off
axesHandles(17) = axesProperties({}, 1, 'normal', 'off', 'w', 'Calibri', 30, 4/3, 2, [0.01 0.025], 'out', 'on', 'k', 'Ca_i^{2+} (\muM)', [Cai(1) Cai(end)], [Cai(1) 0.5 Cai(end)], 'on', 'k', 'Fraction', yRange, [0 0.5 1]);
resizeFig(f17, axesHandles(17), width, height, label, margin, gap);
l = legend(legStr, 'Box', 'off', 'FontSize', legFont, 'LineWidth', lineWidth, 'Location', 'NorthWest');
position = get(l, 'Position');
position(2) = position(2) + 0.03;
set(l, 'Position', position);

titleStr = 'I_{AHP} activation time constants';
tau_m1 = ones(1,length(Cai))*90;
tau_m2 = ones(1,length(Cai))*830;
data = [tau_m1; tau_m2];
lineCols = [green; blue];
legStr = {'\tau_{m (mAHP)}', '\tau_{m (sAHP)}'};
f18 = multiPlot(titleStr, data, lineCols, penSize, Cai, visibility);
axesHandles(18) = axesProperties({}, 1, 'normal', 'off', 'w', 'Calibri', 30, 4/3, 2, [0.01 0.025], 'out', 'on', 'k', 'Ca_i^{2+} (\muM)', [Cai(1) Cai(end)], [Cai(1) 0.5 Cai(end)], 'on', 'k', 'Time constant (ms)', [0 1000], [0 500 1000]);
resizeFig(f18, axesHandles(18), width, height, label, margin, gap);
l = legend(legStr, 'Box', 'off', 'FontSize', legFont, 'LineWidth', lineWidth, 'Location', 'NorthWest');
position = get(l, 'Position');
position(2) = position(2) + 0.03;
set(l, 'Position', position);





% Save figures:
% exportFig(f1,  ['f1_1' '.tif'],'-dtiffnocompression','-r300', paperSize);
% exportFig(f2,  ['f1_2' '.tif'],'-dtiffnocompression','-r300', paperSize);
% exportFig(f3,  ['f2_1' '.tif'],'-dtiffnocompression','-r300', paperSize);
% exportFig(f4,  ['f2_2' '.tif'],'-dtiffnocompression','-r300', paperSize);
% exportFig(f5,  ['f3_1' '.tif'],'-dtiffnocompression','-r300', paperSize);
% exportFig(f6,  ['f3_2' '.tif'],'-dtiffnocompression','-r300', paperSize);
% exportFig(f7,  ['f4_1' '.tif'],'-dtiffnocompression','-r300', paperSize);
% exportFig(f8,  ['f4_2' '.tif'],'-dtiffnocompression','-r300', paperSize);
% exportFig(f9,  ['f5_1' '.tif'],'-dtiffnocompression','-r300', paperSize);
% exportFig(f10, ['f5_2' '.tif'],'-dtiffnocompression','-r300', paperSize);
% exportFig(f11, ['f6_1' '.tif'],'-dtiffnocompression','-r300', paperSize);
% exportFig(f12, ['f6_2' '.tif'],'-dtiffnocompression','-r300', paperSize);
% exportFig(f13, ['f7_1' '.tif'],'-dtiffnocompression','-r300', paperSize);
% exportFig(f14, ['f7_2' '.tif'],'-dtiffnocompression','-r300', paperSize);
% exportFig(f15, ['f8_1' '.tif'],'-dtiffnocompression','-r300', paperSize);
% exportFig(f16, ['f8_2' '.tif'],'-dtiffnocompression','-r300', paperSize);
% exportFig(f17, ['f9_1' '.tif'],'-dtiffnocompression','-r300', paperSize);
% exportFig(f18, ['f9_2' '.tif'],'-dtiffnocompression','-r300', paperSize);





function [f, ax] = sStatePlot(titleStr, data, lineCols, penSz, Vm, xRange, yRange, visibility)
f = multiPlot(titleStr, data, lineCols, penSz, Vm, visibility);
ax = axesProperties({}, 1, 'normal', 'off', 'w', 'Calibri', 30, 4/3, 2, [0.01 0.025], 'out', 'on', 'k', 'V_m (mV)', xRange, [-120 -60 0 60], 'on', 'k', 'Fraction', yRange, [0 0.5 1]);

function [f, ax, p] = tauPlot(titleStr, data, lineCols, penSz, Vm, xRange, yRange, yTicks, visibility)
[f, p] = multiPlot(titleStr, data, lineCols, penSz, Vm, visibility);
ax = axesProperties({}, 1, 'normal', 'off', 'w', 'Calibri', 30, 4/3, 2, [0.01 0.025], 'out', 'on', 'k', 'V_m (mV)', xRange, [-120 -60 0 60], 'on', 'k', 'Time constant (ms)', yRange, yTicks);
