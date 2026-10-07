% IT parameters and transformations
function parameters_IT

close all
clear all
clc

xRange = [-100 -30];
Vm = -100:0.01:xRange(end);
celsius = 37;
IT = zeros(4, length(Vm));





% IT:
titleString = 'I_T steady state activation and inactivation functions'; %#ok<*NASGU>
mString1 = 'm_{inf}^2';
mString2 = '';
hString1 = 'h_{inf}';
hString2 = '';
m_inf1 = (1 ./ (1 + exp(-(Vm+57)/6.2))).^2;
m_inf2 = 0;
h_inf1 = 1 ./ (1 + exp((Vm+81)/4));
h_inf2 = 0;
% sStatePlot(titleString, mString1, mString2, hString1, hString2, m_inf1,...
%     m_inf2, h_inf1, h_inf2, Vm, xRange);

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
% tauPlot(titleString, taumString1, taumString2, tauhString1, tauhString2,...
%     tau_m1, tau_m2, tau_h1, tau_h2, Vm, xRange);
IT(1,:) = m_inf1;
IT(2,:) = h_inf1;





% IT transformed:
% mString2 = 'm_{inf}^2';
% hString2 = 'h_{inf}';
% mshift = 10;
% hshift = 12;
% m_inf2 = (1 ./ (1 + exp(-(Vm+57-mshift)/6.2))).^2;
% h_inf2 = 1 ./ (1 + exp((Vm+81-hshift)/4));
% sStatePlotT(titleString, mString1, mString2, hString1, hString2, m_inf1,...
%     m_inf2, h_inf1, h_inf2, Vm, xRange);
% 
% taumString2 = 'tau_m';
% tauhString2 = 'tau_h';
% tau_m2 = zeros(1,length(Vm));
% for i = 1:length(Vm)
%     if Vm(i) < -55
% 		tau_m2(i) = 3.5 + (20-3.5)*exp(-((Vm(i)+55)^2)/(2*5^2));
%     else
% 		tau_m2(i) = 0.5 + (20-0.5)*exp(-((Vm(i)+55)^2)/(2*5^2));
%     end
% end
% tau_h2 = zeros(1,length(Vm));
% for i = 1:length(Vm)
%     if Vm(i) < -80
% 		tau_h2(i) = exp((Vm(i)+467-hshift)/66.6) / phi;
%     else
% 		tau_h2(i) = ( 28 + exp(-(Vm(i)+22-hshift)/10.5) ) / phi;
%     end
% end
% tauPlotT(titleString, taumString1, taumString2, tauhString1, tauhString2,...
%     tau_m1, tau_m2, tau_h1, tau_h2, Vm, xRange);





% IT2:
% titleString = 'I_{T(Crunelli)} steady state activation and inactivation functions'; %#ok<*NASGU>
% mString1 = 'm_{inf}^3';
% mString2 = '';
% hString1 = 'h_{inf}';
% hString2 = '';
% m_inf1 = (1 ./ (1 + exp(-(Vm+63)/7.8))).^3;
% m_inf2 = 0;
% h_inf1 = 1 ./ (1 + exp((Vm+83.5)/6.3));
% h_inf2 = 0;
% % sStatePlot(titleString, mString1, mString2, hString1, hString2, m_inf1,...
% %     m_inf2, h_inf1, h_inf2, Vm, xRange);
% 
% phi = 3.0 ^ ((celsius-35)/10);
% titleString = 'I_{T(Crunelli)} activation and inactivation time constants';
% taumString1 = 'tau_m';
% taumString2 = '';
% tauhString1 = 'tau_h';
% tauhString2 = '';
% tau_m1 = (2.44 + 0.02506 * exp(-0.0984 * Vm)) ./ phi;
% tau_m2 = 0;
% tau_h1 = (7.66 + 0.02868 * exp(-0.1054 * Vm)) ./ phi;
% tau_h2 = 0;
% % tauPlot(titleString, taumString1, taumString2, tauhString1, tauhString2,...
% %     tau_m1, tau_m2, tau_h1, tau_h2, Vm, xRange);
% IT(3,:) = m_inf1;
% IT(4,:) = h_inf1;





% Bistability mechanism:
% diam = 60; %[uf]
% L = 90;    %[uf]
% Area = pi*(L*1e-4)*(diam*1e-4);
% titleString = 'I_{Twindow} comparison';
% wString1 = 'I_{Twindow}';
% wString2 = 'I_{T2window}';
% iw1 = 1e6*Area*IT(1,:).*IT(2,:).*ghk(Vm, celsius);
% iw2 = 0; %1e6*Area*0.0021*IT(3,:).*IT(4,:).*(Vm-180);
% windowPlot(titleString, wString1, wString2, iw1, iw2, Vm, xRange, 'g');
% iKLeak = 1e6*Area*0.0000198.*(Vm+90);
% %iKLeak = 1e6*Area*0.000012.*(Vm+90);
% hold on
% plot(Vm, iKLeak, 'k', 'LineWidth', 3)
% hold off
% %legend(wString1, wString2, 'I_{Kleak}')
% legend(wString1, 'I_{Kleak}')
% ax1 = gca;
% 
% INaP = 1e6*Area*0.00001612*(1 ./ (1 + exp(-(Vm + 53.87) ./ 8.57))).*(Vm-30);
% for i = 1:2
%     windowPlot(titleString, [wString1 ' + I_{Na(P)}'], wString2, iw1+INaP, iw2, Vm, xRange, 'g');
%     hold on
%     plot(Vm, iKLeak, 'k', 'LineWidth', 3)
%     hold off
%     %legend([wString1 ' + I_{Na(P)}'], wString2, 'I_{Kleak}')
%     legend([wString1 ' + I_{Na(P)}'], 'I_{Kleak}')
%     ax2 = gca;
%     yRange = get(ax2, 'YLim');
%     ylim(ax1, yRange);
% end
% ylim([0.11 0.17])
% xlim([-58 -40])
% 
% wString1 = 'I_{T2window}';
% wString2 = '';
% iw1 = 1e6*Area*0.0021*IT(3,:).*IT(4,:).*(Vm-180);
% iw2 = 0;
% windowPlot(titleString, wString1, wString2, iw1, iw2, Vm, xRange, 'b');
% hold on
% plot(Vm, iKLeak, 'k', 'LineWidth', 3)
% for g = 0.0001:0.0001:0.0021
%     iw1 = 1e6*Area*g*IT(3,:).*IT(4,:).*(Vm-180);
%     plot(Vm, abs(iw1), 'b', 'LineWidth', 3)
% end
% ylim([0 max(abs(iw1))+max(abs(iw1))*0.01]);
% hold off

diam = 60; %[uf]
L = 90;    %[uf]
Area = pi*(L*1e-4)*(diam*1e-4);
titleString = 'I_{Twindow} comparison';
wString1 = 'I_{Twindow}';
wString2 = 'I_{Twindow} + I_{Na(P)}';
iw1 = 1e9*Area*IT(1,:).*IT(2,:).*ghk(Vm, celsius);
INaP = 1e9*Area*0.00001612*(1 ./ (1 + exp(-(Vm + 53.87) ./ 8.57))).*(Vm-30);
iw2 = iw1+INaP;
f1 = windowPlot(titleString, wString1, wString2, iw1, iw2, Vm, xRange, 'r', 'g');
iKLeak = 1e9*Area*0.0000198.*(Vm+90);
hold on
plot(Vm, iKLeak, 'k', 'LineWidth', 3)
hold off
legend(wString1, wString2, 'I_{Kleak}', 'Location', 'NorthWest')
legend boxoff
set(gca, 'box', 'off')
set(gca, 'YTick', 40:40:160)
xt = get(gca, 'XTick');
set(gca, 'FontSize', 20)


f2 = windowPlot(titleString, wString1, wString2, iw1, iw2, Vm, xRange, 'r', 'g');
hold on
plot(Vm, iKLeak, 'k', 'LineWidth', 3)
hold off
ylim([110 170])
xlim([-58 -40])
legend(wString1, wString2, 'I_{Kleak}', 'Location', 'NorthWest')
set(gca, 'box', 'off')

f3 = figure('Units', 'normalized', 'Position', [0,.01, .48, .89]);
set(f3, 'Color', 'w');
titleString = 'Net current';
set(f3, 'Name', titleString);
hold on
netI = iw1+iKLeak+INaP;
plot(Vm, netI, 'b', 'LineWidth', 3)
plot(Vm, zeros(1, length(Vm)), 'k', 'LineWidth', 1)
xlim(xRange);
ax = gca;
set(gca, 'box', 'on');
set(ax, 'PlotBoxAspectRatio', [1 1 1]);
set(ax, 'Color', 'w');
ylim([-10 20]);
title(titleString);
xlabel('Membrane potential (mV)');
ylabel('|Current| (pA)');

plot([-87.85 -55.15 -43.75], zeros(1,3), 'k.', 'MarkerSize', 40)
hold off
set(gca, 'box', 'off')





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
set(ax, 'Color', 'w');
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
set(ax, 'Color', 'w');
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

function [f] = sStatePlotT(titleString, mString1, mString2, hString1, hString2, m_inf1, m_inf2, h_inf1, h_inf2, Vm, xRange) %#ok<*DEFNU>
f = figure('Units', 'normalized', 'Position', [0,.01, .48, .89]);
set(f, 'Color', 'w');
set(f, 'Name', titleString);
hold on
plot(Vm, m_inf1, 'g--', 'LineWidth', 3)
if h_inf1(1)
    plot(Vm, h_inf1, 'r--', 'LineWidth', 3)
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
set(ax, 'Color', 'w');
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

function [f] = tauPlotT(titleString, mString1, mString2, hString1, hString2, m_inf1, m_inf2, h_inf1, h_inf2, Vm, xRange)
f = figure('Units', 'normalized', 'Position', [0,.01, .48, .89]);
set(f, 'Color', 'w');
set(f, 'Name', titleString);
hold on
plot(Vm, m_inf1, 'g--', 'LineWidth', 3)
if h_inf1(1)
    plot(Vm, h_inf1, 'r--', 'LineWidth', 3)
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
set(ax, 'Color', 'w');
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

function [f] = windowPlot(titleString, wString1, wString2, iw1, iw2, Vm, xRange, colorStr1, colorStr2)
f = figure('Units', 'normalized', 'Position', [0,.01, .48, .89]);
set(f, 'Color', 'w');
set(f, 'Name', titleString);
hold on
plot(Vm, abs(iw1), colorStr1, 'LineWidth', 3)
if iw2(1)
    plot(Vm, abs(iw2), colorStr2, 'LineWidth', 3)
end
hold off
xlim(xRange);
ax = gca;
set(gca, 'box', 'on');
set(ax, 'PlotBoxAspectRatio', [1 1 1]);
set(ax, 'Color', 'w');
yRange = get(ax, 'YLim');
ylim([yRange(1) yRange(2)+(yRange(2)-yRange(1))*0.01]);
title(titleString);
xlabel('Membrane potential (mV)');
ylabel('|Current| (pA)');
if iw2(1)
    legend(wString1, wString2)
else
    legend(wString1)
end

function iMax = ghk(Vm, celsius)
FARADAY = 96485.309;
R = 8.3144621;
cai = 50e-6;
cao = 1.5;
pcabar	= 8.8e-5;
z = (1e-3)*2*FARADAY*Vm./(R*(celsius+273.15));
eco = cao*z./(exp(z)-1);
eci = -cai*z./(exp(-z)-1);
iMax = pcabar*(.001)*2*FARADAY*(eci - eco);
