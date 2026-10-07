% TC membrane current simulation parameters
function parameters_TC_old

close all
clear all
clc

Vm = -130:0.01:60;
celsius = 37;
xRange = [-130 60];





% INa (HH mechanism):
titleString = 'I_{Na} steady state activation and inactivation functions';
mString1 = 'm_{inf}^3';
mString2 = '';
hString1 = 'h_{inf}';
hString2 = '';
vTraub = Vm + 42;
alpha_m = 0.32 * (13.1 - vTraub)./(exp((13.1 - vTraub)./4) - 1);
beta_m = 0.28 * (vTraub - 40.1)./(exp((vTraub - 40.1)./5) - 1);
m_inf1 = (alpha_m ./ (alpha_m + beta_m)).^3;
m_inf2 = 0;
alpha_h = 0.128 * (exp((13.1 - vTraub)./18));
beta_h = 4 ./ (1 + exp((40 - vTraub) ./ 5));
h_inf1 = alpha_h ./ (alpha_h + beta_h);
h_inf2 = 0;
sStatePlot(titleString, mString1, mString2, hString1, hString2, m_inf1,...
    m_inf2, h_inf1, h_inf2, Vm, xRange);

phi = 3.0 ^ ((celsius-24)/10);
titleString = 'I_{Na} activation and inactivation time constants';
taumString1 = 'tau_m';
taumString2 = '';
tauhString1 = 'tau_h';
tauhString2 = '';
tau_m1 = 1 ./ (alpha_m + beta_m) ./ phi;
tau_m2 = 0;
tau_h1 = 1 ./ (alpha_h + beta_h) ./ phi;
tau_h2 = 0;
tauPlot(titleString, taumString1, taumString2, tauhString1, tauhString2,...
    tau_m1, tau_m2, tau_h1, tau_h2, Vm, xRange);





% IK (HH mechanism):
titleString = 'I_{K(DR)} steady state activation function';
mString1 = 'n_{inf}^4';
mString2 = '';
hString1 = '';
hString2 = '';
vTraub = Vm + 38;
alpha = 0.016 * (35.1 - vTraub)./(exp((35.1 - vTraub)./5) - 1);
beta = 0.25 * exp((20 - vTraub)./40);
m_inf1 = (alpha ./ (alpha + beta)).^4;
m_inf2 = 0;
h_inf1 = 0;
h_inf2 = 0;
sStatePlot(titleString, mString1, mString2, hString1, hString2, m_inf1,...
    m_inf2, h_inf1, h_inf2, Vm, xRange);

phi = 3.0 ^ ((celsius-24)/10);
titleString = 'I_{K(DR)} activation time constant';
taumString1 = 'tau_n';
taumString2 = '';
tauhString1 = '';
tauhString2 = '';
tau_m1 = 1 ./ (alpha + beta) ./ phi;
tau_m2 = 0;
tau_h1 = 0;
tau_h2 = 0;
tauPlot(titleString, taumString1, taumString2, tauhString1, tauhString2,...
    tau_m1, tau_m2, tau_h1, tau_h2, Vm, xRange);




% IT:
titleString = 'I_T steady state activation and inactivation functions';
mString1 = 'm_{inf}^2';
mString2 = '';
hString1 = 'h_{inf}';
hString2 = '';
m_inf1 = (1 ./ (1 + exp(-(Vm+57)/6.2))).^2;
m_inf2 = 0;
h_inf1 = 1 ./ (1 + exp((Vm+81)/4));
h_inf2 = 0;
sStatePlot(titleString, mString1, mString2, hString1, hString2, m_inf1,...
    m_inf2, h_inf1, h_inf2, Vm, xRange);

phi = 3.0 ^ ((celsius-24)/10);
titleString = 'I_T activation and inactivation time constants';
taumString1 = 'tau_m';
taumString2 = '';
tauhString1 = 'tau_h';
tauhString2 = '';
tau_m1 = ( 0.612 + 1.0 ./ ( exp(-(Vm+132)/16.7) + exp((Vm+16.8)/18.2) ) ) / phi;
tau_m2 = 0;
tau_h1 = zeros(1,length(Vm));
for i = 1:length(Vm)
    if Vm(i) < -80
		tau_h1(i) = exp((Vm(i)+467)/66.6) / phi;
    else
		tau_h1(i) = ( 28 + exp(-(Vm(i)+22)/10.5) ) / phi;
    end
end
tau_h2 = 0;
tauPlot(titleString, taumString1, taumString2, tauhString1, tauhString2,...
    tau_m1, tau_m2, tau_h1, tau_h2, Vm, xRange);





% IT2:
titleString = 'I_{T(Crunelli)} steady state activation and inactivation functions';
mString1 = 'm_{inf}^3';
mString2 = '';
hString1 = 'h_{inf}';
hString2 = '';
m_inf1 = (1 ./ (1 + exp(-(Vm+63)/7.8))).^3;
m_inf2 = 0;
h_inf1 = 1 ./ (1 + exp((Vm+83.5)/6.3));
h_inf2 = 0;
sStatePlot(titleString, mString1, mString2, hString1, hString2, m_inf1,...
    m_inf2, h_inf1, h_inf2, Vm, xRange);

phi = 3.0 ^ ((celsius-35)/10);
titleString = 'I_{T(Crunelli)} activation and inactivation time constants';
taumString1 = 'tau_m';
taumString2 = '';
tauhString1 = 'tau_h';
tauhString2 = '';
tau_m1 = (2.44 + 0.02506 * exp(-0.0984 * Vm)) ./ phi;
tau_m2 = 0;
tau_h1 = (7.66 + 0.02868 * exp(-0.1054 * Vm)) ./ phi;
tau_h2 = 0;
tauPlot(titleString, taumString1, taumString2, tauhString1, tauhString2,...
    tau_m1, tau_m2, tau_h1, tau_h2, Vm, xRange);





% Ih:
titleString = 'I_h steady state activation function';
mString1 = 'm_{inf}';
mString2 = '';
hString1 = '';
hString2 = '';
shift = -18;
m_inf1 = 1 ./ (1 + exp((Vm-shift+93)./5.5));
m_inf2 = 0;
h_inf1 = 0;
h_inf2 = 0;
sStatePlot(titleString, mString1, mString2, hString1, hString2, m_inf1,...
    m_inf2, h_inf1, h_inf2, Vm, xRange);

phi = 3.0 ^ ((celsius-24)/10);
titleString = 'I_h activation time constant';
taumString1 = 'tau_m';
taumString2 = '';
tauhString1 = '';
tauhString2 = '';
tau_m1 = (20 + 1000 ./ (exp((Vm+71.5-shift)./14.2) + exp(-(Vm+89-shift)./11.6))) ./ phi;
tau_m2 = 0;
tau_h1 = 0;
tau_h2 = 0;
tauPlot(titleString, taumString1, taumString2, tauhString1, tauhString2,...
    tau_m1, tau_m2, tau_h1, tau_h2, Vm, xRange);





% INa(P):
titleString = 'I_{Na(P)} steady state activation function';
mString1 = 'm_{inf}';
mString2 = '';
hString1 = '';
hString2 = '';
m_inf1 = 1 ./ (1 + exp(-(Vm + 53.87) ./ 8.57));
m_inf2 = 0;
h_inf1 = 0;
h_inf2 = 0;
sStatePlot(titleString, mString1, mString2, hString1, hString2, m_inf1,...
    m_inf2, h_inf1, h_inf2, Vm, xRange);

phi = 3.0 ^ ((celsius-24)/10);
titleString = 'I_{Na(P)} activation time constant';
taumString1 = 'tau_m';
taumString2 = '';
tauhString1 = '';
tauhString2 = '';
alpha = 0.32 * (-66.58 - Vm)./(exp((-66.58 - Vm)./4)-1);
beta  = 0.28 * (39.58 + Vm)./(exp((39.58 + Vm)./5)-1);
tau_m1 = (1 ./ (alpha + beta)) ./ phi;
tau_m2 = 0;
tau_h1 = 0;
tau_h2 = 0;
tauPlot(titleString, taumString1, taumString2, tauhString1, tauhString2,...
    tau_m1, tau_m2, tau_h1, tau_h2, Vm, xRange);





function [f] = sStatePlot(titleString, mString1, mString2, hString1, hString2, m_inf1, m_inf2, h_inf1, h_inf2, Vm, xRange)
f = figure('Units', 'normalized', 'Position', [0,.01, .48, .89]);
set(f, 'Color', 'w');
set(f, 'Name', titleString);
hold on
plot(Vm, m_inf1, 'g', 'LineWidth', 3)
if h_inf1(1)
    plot(Vm, h_inf1, 'r', 'LineWidth', 3)
end
if m_inf2(1)
    plot(Vm, m_inf2, 'g', 'LineWidth', 3)
end
if h_inf2(1)
    plot(Vm, h_inf2, 'r', 'LineWidth', 3)
end
hold off
xlim(xRange);
ylim([0 1]);
ax = gca;
set(gca, 'box', 'on');
set(ax, 'PlotBoxAspectRatio', [1 1 1]);
set(ax, 'Color', 'none');
title(titleString);
xlabel('Membrane potential (mV)');
ylabel('Fraction');
if h_inf1(1) && ~m_inf2(1) && ~h_inf2(1)
    legend(mString1, hString1)
elseif ~h_inf1(1) && ~m_inf2(1) && ~h_inf2(1)
    legend(mString1)
elseif h_inf1(1) && m_inf2(1) && h_inf2(1)
    legend(mString1, hString1, mString2, hString2)
elseif h_inf1(1) && m_inf2(1) && ~h_inf2(1)
    legend(mString1, hString1, mString2)
end

function [f] = tauPlot(titleString, mString1, mString2, hString1, hString2, m_inf1, m_inf2, h_inf1, h_inf2, Vm, xRange)
f = figure('Units', 'normalized', 'Position', [0,.01, .48, .89]);
set(f, 'Color', 'w');
set(f, 'Name', titleString);
hold on
plot(Vm, m_inf1, 'g', 'LineWidth', 3)
if h_inf1(1)
    plot(Vm, h_inf1, 'r', 'LineWidth', 3)
end
if m_inf2(1)
    plot(Vm, m_inf2, 'g', 'LineWidth', 3)
end
if h_inf2(1)
    plot(Vm, h_inf2, 'r', 'LineWidth', 3)
end
hold off
xlim(xRange);
ax = gca;
set(gca, 'box', 'on');
set(ax, 'PlotBoxAspectRatio', [1 1 1]);
set(ax, 'Color', 'none');
yRange = get(ax, 'YLim');
ylim([yRange(1) yRange(2)+(yRange(2)-yRange(1))*0.01]);
title(titleString);
xlabel('Membrane potential (mV)');
ylabel('Time constant (ms)');
if h_inf1(1) && ~m_inf2(1) && ~h_inf2(1)
    legend(mString1, hString1)
elseif ~h_inf1(1) && ~m_inf2(1) && ~h_inf2(1)
    legend(mString1)
elseif h_inf1(1) && m_inf2(1) && h_inf2(1)
    legend(mString1, hString1, mString2, hString2)
elseif h_inf1(1) && m_inf2(1) && ~h_inf2(1)
    legend(mString1, hString1, mString2)
end
