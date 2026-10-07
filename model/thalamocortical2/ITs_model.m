% Steady state activation and Inactivation functions and time constants of
% I_Ts in NRT neurons.

close all
clear all
clc

Vm = -110:0.1:40;
shift = 0;
actshift = -3;
acttaushift = 0;
taushift = 0;
k_m = 7.4;
k_h = 5;
celsius = 35;

% Steady state activation curve:
figure('Units', 'normalized', 'Position', [0,.01, .48, .89]);
m_inf = (1.0 ./ (1 + exp(-(Vm+shift+actshift+50)./k_m))).^2;
plot(Vm, m_inf, 'r')
hold on

% Steady state inactivation curve:
h_inf = 1.0 ./ (1 + exp((Vm+shift+78)./k_h));
plot(Vm, h_inf)
hold off

phi_m = 3.0 ^ ((celsius-24)/10);
phi_h = 3.0 ^ ((celsius-24)/10);

% Activation time constant:
figure('Units', 'normalized', 'Position', [0,.01, .48, .89]);
tau_m = ((3 + 1.0 ./ (exp((Vm+shift+actshift+25)/10) + exp(-(Vm+shift+actshift+100)/15))) + acttaushift) / phi_m;
%tau_m = 0.44 + 0.15 ./ (exp( (Vm + 27) / 10) + exp ( -(Vm + 102) / 15));
plot(Vm, tau_m, 'r')
hold on

% Inactivation time constant:
% tau_h = zeros(1,31);
% tau_h(1:15) = ((85 + 1.0 ./ (exp((Vm(1:15)+shift+46)/4) + exp(-(Vm(1:15)+shift+405)/50))) + taushift) / phi_h;
% tau_h(16:31) = (-1.05275*Vm(16:31) + 43.11) / phi_h;
% %tau_h = 22.7 + 0.27 ./ (exp ( (Vm + 48) / 4) + exp ( -(Vm + 407) / 50));
% plot(Vm, tau_h)
% tau_h(1:15) = ((85 + 0.05 ./ (exp((Vm(1:15)+shift+46)/4) + exp(-(Vm(1:15)+shift+405)/50))) + taushift) / phi_h;
% plot(Vm, tau_h, '--')
% tau_h(1:6) = exp((Vm(1:6)+467)./66.6) ./ phi_h;
% tau_h(7:end) = ( 28 + exp(-(Vm(7:end)+22)./10.5) ) ./ phi_h;
tau_h = ( 85 + 1.0 ./ ( exp((Vm+46)/4) + exp(-(Vm+405)/50) ) ) / phi_h;
plot(Vm, tau_h, 'g')