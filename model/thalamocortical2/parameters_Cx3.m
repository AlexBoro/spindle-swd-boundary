% TC membrane current simulation parameters
function parameters_Cx3

close all
%clear all %#ok<CLALL>
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
orange = [255/255,165/255,0]; %#ok<NASGU>

visibility = 'off';
xRange = [-120 60];
Vm = xRange(1):0.01:xRange(end);
yRange = [0 1];
lineWidth = 3;
celsius = 37;

axesHandles = gobjects(1,11);
width = 15.92;
height = 15.92;
label = [4.1 4.1];
margin = [0.75 0.75];
gap = 1.5;
legFont = 27;





% INa (HH mechanism):
titleStr = 'I_{Na} steady state activation and inactivation functions';
alpha_m = 0.182 * (Vm + 25)./(1 - exp(-(Vm + 25)/9));
beta_m  = 0.124 * (-(Vm + 25))./(1 - exp((Vm + 25)/9));
m_inf = (alpha_m ./ (alpha_m + beta_m)).^3;
alpha_h = 0.024 * (Vm + 40)./(1 - exp(-(Vm + 40)/5));
beta_h  = 0.0091 * (-(Vm + 65))./(1 - exp((Vm + 65)/5));
h_inf = 1./(1 + exp((Vm + 55)/6.2));
data = [m_inf; h_inf];
lineCols = [green; red];
penSize = ones(1, 4)*lineWidth;
legStr = {'m_{inf}^3', 'h_{inf}'};
[f1, axesHandles(1)] = sStatePlot(titleStr, data, lineCols, penSize, Vm, xRange, yRange, visibility);
paperSize = resizeFig(f1, axesHandles(1), width, height, label, margin, gap);
legProperties(legStr, 'off', legFont, 3, 'NorthEast');

phi = 2.3 ^ ((celsius-23)/10);
titleStr = 'I_{Na} activation and inactivation time constants';
tau_m = 1 ./ (alpha_m + beta_m) ./ phi;
tau_h = 1 ./ (alpha_h + beta_h) ./ phi;
data = [tau_m; tau_h];
legStr = {'\tau_m', '\tau_h'};
[f2, axesHandles(2)] = tauPlot(titleStr, data, lineCols, penSize, Vm, xRange, [0 10], [0 5 10], visibility);
resizeFig(f2, axesHandles(2), width, height, label, margin, gap);
legProperties(legStr, 'off', legFont, 3, 'NorthEast');





% IK (HH mechanism):
titleStr = 'I_{K(DR)} steady state activation function';
alpha = 0.02 * (Vm - 25)./(1 - exp(-(Vm - 25)/9));
beta  = 0.002 * (-(Vm - 25))./(1 - exp((Vm - 25)/9));
data = alpha ./ (alpha + beta);
legStr = {'n_{inf}'};
[f3, axesHandles(3)] = sStatePlot(titleStr, data, lineCols, penSize, Vm, xRange, yRange, visibility);
resizeFig(f3, axesHandles(3), width, height, label, margin, gap);
legProperties(legStr, 'off', legFont, 3, 'NorthWest');

phi = 2.3 ^ ((celsius-23)/10);
titleStr = 'I_{K(DR)} activation time constant';
data = 1 ./ (alpha + beta) ./ phi;
legStr = {'\tau_n'};
[f4, axesHandles(4)] = tauPlot(titleStr, data, lineCols, penSize, Vm, xRange, [0 4], [0 2 4], visibility);
resizeFig(f4, axesHandles(4), width, height, label, margin, gap);
legProperties(legStr, 'off', legFont, 3, 'NorthWest');





% IA:
titleStr = 'I_A steady state activation and inactivation functions';
m_inf  = (1./ (1 + exp(-(Vm + 47)/29))).^4;
h_inf = 1./ (1 + exp((Vm + 66)/10));
data = [m_inf; h_inf];
legStr = {'m_{inf}^4', 'h_{inf}'};
[f5, axesHandles(5)] = sStatePlot(titleStr, data, lineCols, penSize, Vm, xRange, yRange, visibility);
resizeFig(f5, axesHandles(5), width, height, label, margin, gap);
legProperties(legStr, 'off', legFont, 3, 'SouthEast');

phi = 2.3 ^ ((celsius-21)/10);
titleStr = 'I_A activation and inactivation time constants';
tau_m = 0.34 + 0.92 * exp(-((Vm + 71)/59).^2) / phi;
tau_h = ( 8 + 49 * exp(-((Vm + 73)/23).^2) ) / phi;
data = [tau_m; tau_h];
legStr = {'\tau_m', '\tau_h'};
[f6, axesHandles(6)] = tauPlot(titleStr, data, lineCols, penSize, Vm, xRange, [0 16], [0 8 16], visibility);
resizeFig(f6, axesHandles(6), width, height, label, margin, gap);
legProperties(legStr, 'off', legFont, 3, 'NorthEast');





% IM:
titleStr = 'I_M steady state activation function';
alpha = 1e-4 * (Vm + 30)./(1 - exp(-(Vm + 30)/9));
beta  = 1e-4 * -(Vm + 30)./(1 - exp((Vm + 30)/9));
data = alpha ./ (alpha + beta);
legStr = {'n_{inf}'};
[f7, axesHandles(7)] = sStatePlot(titleStr, data, lineCols, penSize, Vm, xRange, yRange, visibility);
resizeFig(f7, axesHandles(7), width, height, label, margin, gap);
legProperties(legStr, 'off', legFont, 3, 'NorthWest');

phi = 2.3 ^ ((celsius-23)/10);
titleStr = 'I_M activation time constants';
data = (1 ./ (alpha + beta)) / phi;
legStr = {'\tau_n'};
[f8, axesHandles(8)] = tauPlot(titleStr, data, lineCols, penSize, Vm, xRange, [0 180], [0 90 180], visibility);
resizeFig(f8, axesHandles(8), width, height, label, margin, gap);
legProperties(legStr, 'off', legFont, 3, 'NorthWest');





% IK[Ca]:
titleStr = 'I_{K[Ca]} steady state activation functions';
Cai = (0:0.0001:0.04); % mM; *1e3 uM; *1e6 nM
alpha = 10 * Cai;
beta  = 0.02; %20;
data = alpha ./ (alpha + beta);
Cai = Cai*1e3;
legStr = {'m_{inf}'};
f9 = multiPlot(titleStr, data, green, penSize, Cai, visibility);
axesHandles(9) = axesProperties({}, 1, 'normal', 'off', 'w', 'Calibri', 30, 4/3, 2, [0.01 0.025], 'out', 'on', 'k', 'Ca_i^{2+} (\muM)', [Cai(1) Cai(end)], [Cai(1) Cai(end)/2 Cai(end)], 'on', 'k', 'Fraction', yRange, [0 0.5 1]);
resizeFig(f9, axesHandles(9), width, height, label, margin, gap);
legProperties(legStr, 'off', legFont, 3, 'NorthWest');

phi = 2.3 ^ ((celsius-23)/10);
data = (1 ./ (alpha + beta)) / phi;
legStr = {'\tau_m'};
f10 = multiPlot(titleStr, data, lineCols, penSize, Cai, visibility);
axesHandles(10) = axesProperties({}, 1, 'normal', 'off', 'w', 'Calibri', 30, 4/3, 2, [0.01 0.025], 'out', 'on', 'k', 'Ca_i^{2+} (\muM)', [Cai(1) Cai(end)], [Cai(1) Cai(end)/2 Cai(end)], 'on', 'k', 'Time constant (ms)', [0 16], [0 8 16]);
resizeFig(f10, axesHandles(10), width, height, label, margin, gap);
legProperties(legStr, 'off', legFont, 3, 'NorthWest');

% titleStr = 'I_{K[Ca]} steady state activation functions';
% Cai = (0:0.01:100000)./1e6; % mM; *1e3 uM; *1e6 nM
% alpha = 10 * Cai;
% beta  = 20;
% data = alpha ./ (alpha + beta);
% Cai = Cai*1e3;
% legStr = {'m_{inf}', 'm_{inf (corrected)}'};
% f20 = multiPlot(titleStr, data, green, penSize, Cai, 'on');
% hold on
% plot(Cai, alpha ./ (alpha + 0.02), 'Color', blue, 'LineWidth', penSize(2));
% hold off
% axesHandles(20) = axesProperties({}, 1, 'normal', 'off', 'w', 'Calibri', 30, 4/3, 2, [0.01 0.025], 'out', 'on', 'k', 'Ca_i^{2+} (\muM)', [Cai(1) Cai(end)], [Cai(1) 50 Cai(end)], 'on', 'k', 'Fraction', yRange, [0 0.5 1]);
% resizeFig(f20, axesHandles(20), width, height, label, margin, gap);
% legProperties(legStr, 'off', legFont, 3, 'NorthEast');
% 
% titleStr = 'I_{K[Ca]} steady state activation functions';
% Cai = (0:0.01:1000)./1e6; % mM; *1e3 uM; *1e6 nM
% alpha = 10 * Cai;
% beta  = 20;
% data = alpha ./ (alpha + beta);
% Cai = Cai*1e3;
% legStr = {'m_{inf}', 'm_{inf (corrected)}'};
% f21 = multiPlot(titleStr, data, green, penSize, Cai, 'on');
% hold on
% plot(Cai, alpha ./ (alpha + 0.02), 'Color', blue, 'LineWidth', penSize(2));
% hold off
% axesHandles(21) = axesProperties({}, 1, 'normal', 'off', 'w', 'Calibri', 30, 4/3, 2, [0.01 0.025], 'out', 'on', 'k', 'Ca_i^{2+} (\muM)', [Cai(1) Cai(end)], [Cai(1) 0.5 Cai(end)], 'on', 'k', 'Fraction', yRange, [0 0.5 1]);
% resizeFig(f21, axesHandles(21), width, height, label, margin, gap);
% legProperties(legStr, 'off', legFont, 3, 'NorthEast');
% 
% titleStr = 'I_{K[Ca]} steady state activation functions';
% Cai = (0:0.01:1000)./1e6; % mM; *1e3 uM; *1e6 nM
% alpha = 10 * Cai;
% beta  = 20;
% data = 666*alpha ./ (alpha + beta);
% Cai = Cai*1e3;
% legStr = {'m_{inf} x666', 'm_{inf (corrected)}'};
% f22 = multiPlot(titleStr, data, green, penSize, Cai, 'on');
% hold on
% plot(Cai, alpha ./ (alpha + 0.02), 'Color', blue, 'LineWidth', penSize(2));
% hold off
% axesHandles(22) = axesProperties({}, 1, 'normal', 'off', 'w', 'Calibri', 30, 4/3, 2, [0.01 0.025], 'out', 'on', 'k', 'Ca_i^{2+} (\muM)', [Cai(1) Cai(end)], [Cai(1) 0.5 Cai(end)], 'on', 'k', 'Fraction', yRange, [0 0.5 1]);
% resizeFig(f22, axesHandles(22), width, height, label, margin, gap);
% legProperties(legStr, 'off', legFont, 3, 'NorthEast');
% 
% phi = 2.3 ^ ((celsius-23)/10);
% data = (1 ./ (alpha + beta)) / phi;
% legStr = {'\tau_m (original)'};
% f23 = multiPlot(titleStr, data, lineCols, penSize, Cai, 'on');
% axesHandles(23) = axesProperties({}, 1, 'normal', 'off', 'w', 'Calibri', 30, 4/3, 2, [0.01 0.025], 'out', 'on', 'k', 'Ca_i^{2+} (\muM)', [Cai(1) Cai(end)], [Cai(1) 0.5 Cai(end)], 'on', 'k', 'Time constant (ms)', [0 0.02], [0 0.01 0.02]);
% resizeFig(f23, axesHandles(23), width, height, label, margin, gap);
% legProperties(legStr, 'off', legFont, 3, 'NorthWest');
% 
% data = (1 ./ (alpha + 0.02)) / phi;
% legStr = {'\tau_{m (corrected)}'};
% f24 = multiPlot(titleStr, data, blue, penSize, Cai, 'on');
% axesHandles(24) = axesProperties({}, 1, 'normal', 'off', 'w', 'Calibri', 30, 4/3, 2, [0.01 0.025], 'out', 'on', 'k', 'Ca_i^{2+} (\muM)', [Cai(1) Cai(end)], [Cai(1) 0.5 Cai(end)], 'on', 'k', 'Time constant (ms)', [0 18], [0 9 18]);
% resizeFig(f24, axesHandles(24), width, height, label, margin, gap);
% legProperties(legStr, 'off', legFont, 3, 'NorthEast');





% IAHP:
titleStr = 'I_{AHP} steady state activation functions';
Cai = (0:0.01:1000)./1e6; % mM; *1e3 uM; *1e6 nM
cac2 = 0.00032;
power = 5.3;
data = 1 ./ ((cac2 ./ Cai).^power + 1);
Cai = Cai*1e3;
legStr = {'m_{inf (sAHP)}'};
f11 = multiPlot(titleStr, data, green, penSize, Cai, visibility);
axesHandles(11) = axesProperties({}, 1, 'normal', 'off', 'w', 'Calibri', 30, 4/3, 2, [0.01 0.025], 'out', 'on', 'k', 'Ca_i^{2+} (\muM)', [Cai(1) Cai(end)], [Cai(1) 0.5 Cai(end)], 'on', 'k', 'Fraction', yRange, [0 0.5 1]);
resizeFig(f11, axesHandles(11), width, height, label, margin, gap);
legProperties(legStr, 'off', legFont, 3, 'NorthWest');

titleStr = 'I_{AHP} activation time constants';
data = ones(1,length(Cai))*830;
legStr = {'\tau_{m (sAHP)}'};
f12 = multiPlot(titleStr, data, lineCols, penSize, Cai, visibility);
axesHandles(12) = axesProperties({}, 1, 'normal', 'off', 'w', 'Calibri', 30, 4/3, 2, [0.01 0.025], 'out', 'on', 'k', 'Ca_i^{2+} (\muM)', [Cai(1) Cai(end)], [Cai(1) 0.5 Cai(end)], 'on', 'k', 'Time constant (ms)', [0 1660], [0 830 1660]);
resizeFig(f12, axesHandles(12), width, height, label, margin, gap);
legProperties(legStr, 'off', legFont, 3, 'NorthWest');





% IKNa:
titleStr = 'I_{K[Na]} steady state activation functions';
Nai = (0:0.01:100); % mM; *1e3 uM; *1e6 nM
data = 1./(1 + (38.7./Nai).^3.5);
legStr = {'m_{inf}'};
f13 = multiPlot(titleStr, data, green, penSize, Nai, visibility);
axesHandles(13) = axesProperties({}, 1, 'normal', 'off', 'w', 'Calibri', 30, 4/3, 2, [0.01 0.025], 'out', 'on', 'k', 'Na_i^+ (mM)', [Nai(1) Nai(end)], [Nai(1) 50 Nai(end)], 'on', 'k', 'Fraction', yRange, [0 0.5 1]);
resizeFig(f13, axesHandles(13), width, height, label, margin, gap);
legProperties(legStr, 'off', legFont, 3, 'NorthWest');





% IHVA:
titleStr = 'I_{HVA} steady state activation function';
alpha_m = 0.055 * (Vm + 27)./(1 - exp(-(Vm + 27)/3.8));
beta_m = 0.94 * exp(-(Vm + 75)/17);
m_inf = (alpha_m ./ (alpha_m + beta_m)).^2;
alpha_h = 4.57e-4 * exp(-(Vm + 13)/50);
beta_h = 0.0065 ./ (1 + exp(-(Vm + 15)/28));
h_inf = alpha_h ./ (alpha_h + beta_h);
data = [m_inf; h_inf];
legStr = {'m_{inf}', 'h_{inf}'};
[f14, axesHandles(14)] = sStatePlot(titleStr, data, lineCols, penSize, Vm, xRange, yRange, visibility);
resizeFig(f14, axesHandles(14), width, height, label, margin, gap);
legProperties(legStr, 'off', legFont, 3, 'NorthEast');

phi = 2.3 ^ ((celsius-23)/10);
titleStr = 'I_{HVA} activation time constant';
tau_m = (1 ./ (alpha_m + beta_m)) / phi;
tau_h = (1 ./ (alpha_h + beta_h)) / phi;
addTick = 3;
fact = 15;
cutoff = fact*addTick;
tau_m = tau_m*fact;
tau_h = tau_h + ((150 - tau_h)*(cutoff-addTick))/150;
data = [tau_m; tau_h];
legStr = {'\tau_m', '\tau_h'};
[f15, axesHandles(15)] = tauPlot(titleStr, data, lineCols, penSize, Vm, xRange, [0 150], [0 cutoff 75+((150-75)*(cutoff-addTick))/150 150], visibility);
axesHandles(15).YTickLabel = {'0',num2str(addTick),'75','150'};
resizeFig(f15, axesHandles(15), width, height, label, margin, gap);
legProperties(legStr, 'off', legFont, 3, 'NorthEast');





% Ih:
titleStr = 'I_h steady state activation function';
data = 1 ./ (1 + exp((Vm+91)/6));
legStr = {'m_{inf}'};
[f16, axesHandles(16)] = sStatePlot(titleStr, data, lineCols, penSize, Vm, xRange, yRange, visibility);
resizeFig(f16, axesHandles(16), width, height, label, margin, gap);
legProperties(legStr, 'off', legFont, 3, 'NorthEast');

phi = 3.5 ^ ((celsius-22)/10);
titleStr = 'I_h activation time constant';
data = (1./(0.0004 * exp(-0.025*Vm) + 0.088*exp(0.062*Vm))) / phi;
legStr = {'\tau_m'};
[f17, axesHandles(17)] = tauPlot(titleStr, data, lineCols, penSize, Vm, xRange, [0 50], [0 25 50], visibility);
resizeFig(f17, axesHandles(17), width, height, label, margin, gap);
legProperties(legStr, 'off', legFont, 3, 'NorthEast');





% INaP:
titleStr = 'I_{Na(P)} steady state activation function';
data = 1 ./ (1 + exp(-(Vm + 42) / 5));
legStr = {'m_{inf}'};
[f18, axesHandles(18)] = sStatePlot(titleStr, data, lineCols, penSize, Vm, xRange, yRange, visibility);
resizeFig(f18, axesHandles(18), width, height, label, margin, gap);
legProperties(legStr, 'off', legFont, 3, 'NorthWest');

phi = 2.3 ^ ((celsius-36)/10);
titleStr = 'I_{Na(P)} activation time constant';
data = ones(1,length(Vm))*0.05 / phi;
legStr = {'\tau_m'};
[f19, axesHandles(19)] = tauPlot(titleStr, data, lineCols, penSize, Vm, xRange, [0 0.1], [0 0.05 0.1], visibility);
resizeFig(f19, axesHandles(19), width, height, label, margin, gap);
legProperties(legStr, 'off', legFont, 3, 'NorthWest');





% Save figures:
% exportFig(f1,  ['f1_1' '.tif'], '-dtiffnocompression','-r300', paperSize);
% exportFig(f2,  ['f1_2' '.tif'], '-dtiffnocompression','-r300', paperSize);
% exportFig(f3,  ['f2_1' '.tif'], '-dtiffnocompression','-r300', paperSize);
% exportFig(f4,  ['f2_2' '.tif'], '-dtiffnocompression','-r300', paperSize);
% exportFig(f5,  ['f3_1' '.tif'], '-dtiffnocompression','-r300', paperSize);
% exportFig(f6,  ['f3_2' '.tif'], '-dtiffnocompression','-r300', paperSize);
% exportFig(f7,  ['f4_1' '.tif'], '-dtiffnocompression','-r300', paperSize);
% exportFig(f8,  ['f4_2' '.tif'], '-dtiffnocompression','-r300', paperSize);
exportFig(f9,  ['f5_1' '.tif'], '-dtiffnocompression','-r300', paperSize);
exportFig(f10, ['f5_2' '.tif'], '-dtiffnocompression','-r300', paperSize);
% exportFig(f11, ['f6_1' '.tif'], '-dtiffnocompression','-r300', paperSize);
% exportFig(f12, ['f6_2' '.tif'], '-dtiffnocompression','-r300', paperSize);
% exportFig(f13, ['f7_1' '.tif'], '-dtiffnocompression','-r300', paperSize);
% exportFig(f14, ['f8_1' '.tif'], '-dtiffnocompression','-r300', paperSize);
% exportFig(f15, ['f8_2' '.tif'], '-dtiffnocompression','-r300', paperSize);
% exportFig(f16, ['f9_1' '.tif'], '-dtiffnocompression','-r300', paperSize);
% exportFig(f17, ['f9_2' '.tif'], '-dtiffnocompression','-r300', paperSize);
% exportFig(f18, ['f10_1' '.tif'],'-dtiffnocompression','-r300', paperSize);
% exportFig(f19, ['f10_2' '.tif'],'-dtiffnocompression','-r300', paperSize);
% print(f20, ['f1_m_inf of I_K[Ca] 0-100 uM range' '.jpg'], '-djpeg100');
% print(f21, ['f2_m_inf of I_K[Ca] 0-1 uM physiologically significant range' '.jpg'], '-djpeg100');
% print(f22, ['f3_m_inf of I_K[Ca] 0-1 uM physiologically significant range and conductance compensation' '.jpg'], '-djpeg100');
% print(f23, ['f4_original tau_m' '.jpg'],'-djpeg100');
% print(f24, ['f5_corrected tau_m' '.jpg'],'-djpeg100');





function [f, ax] = sStatePlot(titleStr, data, lineCols, penSz, Vm, xRange, yRange, visibility)
f = multiPlot(titleStr, data, lineCols, penSz, Vm, visibility);
ax = axesProperties({}, 1, 'normal', 'off', 'w', 'Calibri', 30, 4/3, 2, [0.01 0.025], 'out', 'on', 'k', 'V_m (mV)', xRange, [-120 -60 0 60], 'on', 'k', 'Fraction', yRange, [0 0.5 1]);

function [f, ax, p] = tauPlot(titleStr, data, lineCols, penSz, Vm, xRange, yRange, yTicks, visibility)
[f, p] = multiPlot(titleStr, data, lineCols, penSz, Vm, visibility);
ax = axesProperties({}, 1, 'normal', 'off', 'w', 'Calibri', 30, 4/3, 2, [0.01 0.025], 'out', 'on', 'k', 'V_m (mV)', xRange, [-120 -60 0 60], 'on', 'k', 'Time constant (ms)', yRange, yTicks);
