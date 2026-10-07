clc
close all
v = -100:0.001:80;

% Equations:
celsius = 37;
phi = 3 ^ ((celsius-24)/10);
phiW = 3 ^ ((celsius-35)/10);
mshift = 3;
hshift = 3;
km = 6.2;
kh = 4;
m_inf = 1 ./ ( 1 + exp(-(v-mshift+57)/km) );
m_infAdj = 1 ./ ( 1 + exp(-(v-57)/6.2) );
m_infW = 1 ./ (1 + exp(-(v + 63) / 7.8));
m_infWAdj = 1 ./ (1 + exp(-(v + 63 - mshift) / 7.8));
h_inf = 1 ./ ( 1 + exp((v-hshift+81)/kh) );
h_infAdj = 1 ./ ( 1 + exp((v-3+81)/5) );
h_infW = 1 ./ (1 + exp((v + 83.5) / 6.3));
h_infWAdj = 1 ./ (1 + exp((v + 83.5 - hshift) / 6.3));
tau_m = (0.612 + 1.0 ./ ( exp(-(v-mshift+132)/16.7) + exp((v-mshift+16.8)/18.2) ) ) / phi;
a = 132;
aa = 16.7;
b = 16.8; %16.8;
bb = 10; %18.2;
c = 1;
tau_mAdj = ( 0.612 + 1.0 ./ ( exp(-(v-mshift+a)/aa) + exp((v-mshift+b)/bb) ) ) / phi;
tau_mW = (2.44 + 0.02506 * exp(-0.0984 * (v - mshift))) / phiW;
tau_h = zeros(1,length(v));
tau_hAdj = zeros(1,length(v));
for i = 1:length(v)
    if v(i)-hshift < -80
		tau_h(i) = exp((v(i)-hshift+467)/66.6) / phi;
    else
		tau_h(i) = ( 28 + exp(-(v(i)-hshift+22)/10.5) ) / phi;
    end
end
tau_hW = (7.66 + 0.02868 * exp(-0.1054 * (v - hshift))) / phiW;

tau_mWAdj = zeros(1,length(v));
tau_mWAdj2 = zeros(1,length(v));
tau_hWAdj = zeros(1,length(v));
tau_hWAdj2 = zeros(1,length(v));
for i = 1:length(v)
    if (v(i)-mshift) > -60
        tau_mWAdj(i) = (2.44 + 0.02506 * exp(-0.0984 * (v(i)-mshift))) / phiW;
    else
        tau_mWAdj(i) = exp(((v(i)-mshift)+223.35)/66.6) / phiW;
    end
    if (v(i)-mshift) > -80
        tau_mWAdj2(i) = (2.44 + 0.02506 * exp(-0.0984 * (v(i)-mshift))) / phiW;
    else
        tau_mWAdj2(i) = exp(((v(i)-mshift)+361.2)/66.6) / phiW;
    end
    if (v(i)-hshift) > -80
        tau_hWAdj(i) = (7.66 + 0.02868 * exp(-0.1054 * (v(i)-hshift))) / phiW;
        tau_hWAdj2(i) = (10 + 7.66 + 0.02868 * exp(-0.1054 * (v(i)-hshift))) / phiW;
    else
        tau_hWAdj(i) = exp(((v(i)-hshift)+408.8)/66.6) / phiW;
        tau_hWAdj2(i) = exp(((v(i)-hshift)+413.4)/66.6) / phiW;
    end
end

% Figures:
f1 = figure('Units', 'normalized', 'Position', [0, .01, 1.00, .89]);
%plot(v, m_inf.^2, 'b')
hold on
%plot(v, h_inf, 'b')
%plot(v, m_infAdj.^2, '--')
%plot(v, h_infAdj, '--')
plot(v, m_infW.^3, 'r')
plot(v, m_infWAdj.^3, 'r--')
plot(v, h_infW, 'r')
plot(v, h_infWAdj, 'r--')
hold off
titleStr = sprintf('Steady state functions');
set(f1,'name',titleStr)
title(titleStr)
xlabel('Membrane potential (mV)')
ylabel('Proportion')

f2 = figure('Units', 'normalized', 'Position', [0, .01, 1.00, .89]);
%plot(v, tau_m, 'g')
hold on
% plot(v, tau_mAdj, 'g')
% plot(v, ((tau_mAdj*phi).^1.16)/phi, 'g--') %1 - 10 mV, 1.16 - 20 mV, 1.35 - 40 mV
% plot(-63:-50, 5*ones(1,length(-68:-55)), 'r')
% Amp = 9.5;
% SD = 5;
% tau_m_adj = 0.5 + Amp*exp(-((v + 55).^2)/(2*SD^2));
%plot(v, tau_m_adj, 'r')
% Amp = 6.5;
% SD = 5;
% tau_m_adj = 3.5 + Amp*exp(-((v + 55).^2)/(2*SD^2));
% plot(v, tau_m_adj, 'g')
%plot(v, tau_h, 'r')
%plot(v, tau_hAdj, 'r-.')
plot(v, tau_mW, 'b')
plot(v, tau_hW, 'm')
plot(v, tau_mWAdj, 'b--')
plot(v, tau_mWAdj2, 'b-.')
plot(v, tau_hWAdj, 'm--')
plot(v, tau_hWAdj2, 'm-.')
hold off
titleStr = sprintf('Time constants');
set(f1,'name',titleStr)
title(titleStr)
xlabel('Membrane potential (mV)')
ylabel('Time (ms)')