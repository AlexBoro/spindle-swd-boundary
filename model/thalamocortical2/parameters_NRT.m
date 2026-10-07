% TC membrane current simulation parameters
function parameters_NRT

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

visibility = 'off';
xRange = [-120 60];
Vm = xRange(1):0.04:xRange(end);
yRange = [0 1];
lineWidth = 3;
celsius = 37;

axesHandles = gobjects(1,11);
width = 15.92;
height = 15.92;
label = [4.1 4.1];
margin = [0.6 0.6];
gap = 1.5;
legFont = 27;





% INa (HH mechanism):
titleStr = 'I_{Na} steady state activation and inactivation functions';
vTraub = Vm + 50;
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
vTraub = Vm + 50;
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





% ITs:
titleStr = 'I_{Ts} steady state activation and inactivation functions';
m_inf = (1 ./ (1 + exp(-(Vm+50)/7.4))).^2;
h_inf = 1 ./ (1 + exp((Vm+78)/5));
data = [m_inf; h_inf];
legStr = {'m_{inf}^2', 'h_{inf}'};
[f5, axesHandles(5)] = sStatePlot(titleStr, data, lineCols, penSize, Vm, xRange, yRange, visibility);
resizeFig(f5, axesHandles(5), width, height, label, margin, gap);
legProperties(legStr, 'off', legFont, 3, 'NorthEast');

phi = 3.0 ^ ((celsius-24)/10);
titleStr = 'I_{Ts} activation and inactivation time constants';
tau_m = ( 3 + 1.0 ./ ( exp((Vm+25)/10) + exp(-(Vm+100)/15) ) ) / phi;
tau_h = ( 85 + 1.0 ./ ( exp((Vm+46)/4) + exp(-(Vm+405)/50) ) ) / phi;
data = [tau_m; tau_h];
legStr = {'\tau_m', '\tau_h'};
[f6, axesHandles(6)] = tauPlot(titleStr, data, lineCols, penSize, Vm, xRange, [0 164], [0 80 160], visibility);
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





% INaP:
% titleStr = 'I_{Na(P)} steady state activation function';
% data = 1 ./ (1 + exp(-(Vm + 53.87) ./ 8.57));
% legStr = {'m_{inf}'};
% [f12, axesHandles(12)] = sStatePlot(titleStr, data, lineCols, penSize, Vm, xRange, yRange, visibility);
% resizeFig(f12, axesHandles(12), width, height, label, margin, gap);
% legProperties(legStr, 'off', legFont, 3, 'NorthWest');
% 
% phi = 3.0 ^ ((celsius-35)/10);
% titleStr = 'I_{Na(P)} activation time constant';
% alpha = 0.32 * (-66.58 - Vm)./(exp((-66.58 - Vm)./4)-1);
% beta  = 0.28 * (39.58 + Vm)./(exp((39.58 + Vm)./5)-1);
% data = (1 ./ (alpha + beta)) ./ phi;
% legStr = {'\tau_m'};
% [f13, axesHandles(13)] = tauPlot(titleStr, data, lineCols, penSize, Vm, xRange, [0 0.1], [0 0.05 0.1], visibility);
% resizeFig(f13, axesHandles(13), width, height, label, margin, gap);
% legProperties(legStr, 'off', legFont, 3, 'NorthWest');





% IKNa:
titleStr = 'I_{K[Na]} steady state activation functions';
Nai = (0:0.01:100); % mM; *1e3 uM; *1e6 nM
p = 1./(1 + (50./Nai).^2.5);
legStr = {'p'};
f9 = multiPlot(titleStr, p, green, penSize, Nai, visibility);
axesHandles(9) = axesProperties({}, 1, 'normal', 'off', 'w', 'Calibri', 30, 4/3, 2, [0.01 0.025], 'out', 'on', 'k', 'Na_i^+ (mM)', [Nai(1) Nai(end)], [Nai(1) 50 Nai(end)], 'on', 'k', 'Fraction', yRange, [0 0.5 1]);
resizeFig(f9, axesHandles(9), width, height, label, margin, gap);
legProperties(legStr, 'off', legFont, 3, 'NorthWest');





% IHVA:
% titleStr = 'I_{HVA} steady state activation function';
% FARADAY = 96485.309;
% R = 8.3144621;
% z = (1e-3)*2.25*FARADAY/(R*(celsius+273.15));
% shift = 15;
% data = (1./(1 + exp(-z*(Vm + 19.48 - shift)))).^2;
% legStr = {'m_{inf}^2'};
% [f14, axesHandles(14)] = sStatePlot(titleStr, data, lineCols, penSize, Vm, xRange, yRange, visibility);
% resizeFig(f14, axesHandles(14), width, height, label, margin, gap);
% legProperties(legStr, 'off', legFont, 3, 'NorthWest');
% 
% phi = 3.0 ^ ((celsius-21)/10);
% titleStr = 'I_{HVA} activation time constant';
% a = 1.6./(1 + exp(-0.0072*(Vm - shift - 5)));
% b = 0.02*(Vm - shift + 8.69)./(exp((Vm - shift + 8.69)./5.36) - 1);
% data = (1./(a + b)) ./ phi;
% legStr = {'\tau_m'};
% [f15, axesHandles(15)] = tauPlot(titleStr, data, lineCols, penSize, Vm, xRange, [0 0.22], [0 0.11 0.22], visibility);
% resizeFig(f15, axesHandles(15), width, height, label, margin, gap);
% legProperties(legStr, 'off', legFont, 3, 'NorthWest');





% IAHP:
titleStr = 'I_{AHP} steady state activation functions';
Cai = (0:0.01:1000)./1e6; % mM; *1e3 uM; *1e6 nM
cac1 = 0.00032;
power = 5.3;
m_inf1 = 1 ./ ((cac1 ./ Cai).^power + 1);
Cai = Cai*1e3;
legStr = {'m_{inf (mAHP)}'};
f10 = multiPlot(titleStr, m_inf1, green, penSize, Cai, visibility);
axesHandles(10) = axesProperties({}, 1, 'normal', 'off', 'w', 'Calibri', 30, 4/3, 2, [0.01 0.025], 'out', 'on', 'k', 'Ca_i^{2+} (\muM)', [Cai(1) Cai(end)], [Cai(1) 0.5 Cai(end)], 'on', 'k', 'Fraction', yRange, [0 0.5 1]);
resizeFig(f10, axesHandles(10), width, height, label, margin, gap);
l = legend(legStr, 'Box', 'off', 'FontSize', legFont, 'LineWidth', lineWidth, 'Location', 'NorthWest');
position = get(l, 'Position');
position(2) = position(2) + 0.03;
set(l, 'Position', position);

titleStr = 'I_{AHP} activation time constants';
tau_m1 = ones(1,length(Cai))*90;
lineCols = [green; blue];
legStr = {'\tau_{m (mAHP)}'};
f11 = multiPlot(titleStr, tau_m1, lineCols, penSize, Cai, visibility);
axesHandles(11) = axesProperties({}, 1, 'normal', 'off', 'w', 'Calibri', 30, 4/3, 2, [0.01 0.025], 'out', 'on', 'k', 'Ca_i^{2+} (\muM)', [Cai(1) Cai(end)], [Cai(1) 0.5 Cai(end)], 'on', 'k', 'Time constant (ms)', [0 120], [0 60 120]);
resizeFig(f11, axesHandles(11), width, height, label, margin, gap);
l = legend(legStr, 'Box', 'off', 'FontSize', legFont, 'LineWidth', lineWidth, 'Location', 'NorthWest');
position = get(l, 'Position');
position(2) = position(2) + 0.03;
set(l, 'Position', position);





% Save figures:
exportFig(f1,  ['f1_1' '.tif'],'-dtiffnocompression','-r300', paperSize);
exportFig(f2,  ['f1_2' '.tif'],'-dtiffnocompression','-r300', paperSize);
exportFig(f3,  ['f2_1' '.tif'],'-dtiffnocompression','-r300', paperSize);
exportFig(f4,  ['f2_2' '.tif'],'-dtiffnocompression','-r300', paperSize);
exportFig(f5,  ['f3_1' '.tif'],'-dtiffnocompression','-r300', paperSize);
exportFig(f6,  ['f3_2' '.tif'],'-dtiffnocompression','-r300', paperSize);
exportFig(f7,  ['f4_1' '.tif'],'-dtiffnocompression','-r300', paperSize);
exportFig(f8,  ['f4_2' '.tif'],'-dtiffnocompression','-r300', paperSize);
exportFig(f9,  ['f5_1' '.tif'],'-dtiffnocompression','-r300', paperSize);
exportFig(f10, ['f6_1' '.tif'],'-dtiffnocompression','-r300', paperSize);
exportFig(f11, ['f6_2' '.tif'],'-dtiffnocompression','-r300', paperSize);





function [f, ax] = sStatePlot(titleStr, data, lineCols, penSz, Vm, xRange, yRange, visibility)
f = multiPlot(titleStr, data, lineCols, penSz, Vm, visibility);
ax = axesProperties({}, 1, 'normal', 'off', 'w', 'Calibri', 30, 4/3, 2, [0.01 0.025], 'out', 'on', 'k', 'V_m (mV)', xRange, [-120 -60 0 60], 'on', 'k', 'Fraction', yRange, [0 0.5 1]);

function [f, ax, p] = tauPlot(titleStr, data, lineCols, penSz, Vm, xRange, yRange, yTicks, visibility)
[f, p] = multiPlot(titleStr, data, lineCols, penSz, Vm, visibility);
ax = axesProperties({}, 1, 'normal', 'off', 'w', 'Calibri', 30, 4/3, 2, [0.01 0.025], 'out', 'on', 'k', 'V_m (mV)', xRange, [-120 -60 0 60], 'on', 'k', 'Time constant (ms)', yRange, yTicks);
