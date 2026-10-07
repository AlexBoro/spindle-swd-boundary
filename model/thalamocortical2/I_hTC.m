% I_h model:

close all
clc

cai = 0.0004:0.0000001:0.0009;
cac = 0.00075;
k2 = 1; %0.0015;
nca = 4;
k1 = k2 * (cai./cac).^nca;
k1_ = k2 * (cai./cac).^8;
k1__ = k2 * (cai./cac).^16;

p1 = 0:0.001:1;
pc = 0.017;
k4 = 0.0001;
nexp = 1;
k3 = k4 * (p1./pc).^nexp;

figure('Units', 'normalized', 'Position', [0, .01, .48, .89]);
plot(cai, k1)
hold on
plot(cai, k1_)
plot(cai, k1__)
hold off

figure('Units', 'normalized', 'Position', [0, .01, .48, .89]);
plot(p1, k3, 'r')

% v = -130:0.1:60;
% 
% V_half = -75;
% shift = 0; %-30;
% shiftCaP = 0;
% m_inf = 1 ./ (1 + exp((v-(V_half+shift+shiftCaP))./5.5));
% tau_min = 20;
% phi = 3.0 ^ ((35-37)/10);
% tau_m = (tau_min + 2000 ./ ( exp((v+71.5-shift-shiftCaP)./14.2) + exp(-(v+89-shift-shiftCaP)./11.6) ) ) / phi;
% 
% shiftCaP = 0;
% m_inf2 = 1 ./ (1 + exp((v-(V_half+shift+shiftCaP))./2));
% tau_m2 = (6600 ./ ( exp((v+71.5-shift-shiftCaP)./14.2) + exp(-(v+89-shift-shiftCaP)./11.6) ) ) / phi;
% 
% figure('Units', 'normalized', 'Position', [0, .01, .48, .89]);
% plot(v, m_inf)
% hold on
% plot(v, m_inf2, 'r')
% hold off
% 
% figure('Units', 'normalized', 'Position', [0, .01, .48, .89]);
% plot(v, tau_m)
% hold on
% plot(v, tau_m2, 'r')
% hold off