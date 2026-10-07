% Steady state activation and Inactivation functions and time constants of
% I_Ts in NRT neurons.

close all
clear all %#ok<*CLALL>
clc

Vm = -100:0.1:40;
shift = 0;
actshift = 0;
acttaushift = 0;
taushift = 0;
k_m = 7.4;
k_h = 5;
celsius = 35;

% Steady state activation curve:
figure('Units', 'normalized', 'Position', [0,.01, .48, .89]);
m_inf = (1 ./ (1 + exp(-(Vm+shift+actshift+50)./k_m))).^2;
plot(Vm, m_inf.^2, 'r')
hold on
m_inf_TC = (1 ./ (1 + exp(-(Vm+57)/6.2))).^2;
plot(Vm, m_inf_TC.^2, 'b')

% Steady state inactivation curve:
h_inf = 1 ./ (1 + exp((Vm+shift+78)./k_h));
plot(Vm, h_inf, 'r')
h_inf_TC = 1 ./ (1 + exp((Vm+81)/4));
plot(Vm, h_inf_TC, 'b')
hold off

phi = 3.0 ^ ((celsius-24)/10);

% Activation time constant:
figure('Units', 'normalized', 'Position', [0,.01, .48, .89]);
tau_m = ((3 + 1.0 ./ (exp((Vm+shift+actshift+25)/10) + exp(-(Vm+shift+actshift+100)/15))) + acttaushift) / phi;
plot(Vm, tau_m, 'r')
hold on
tau_m20 = tau_m / 2;
plot(Vm, tau_m20, 'r--')
tau_m_TC = ( 0.612 + 1.0 ./ ( exp(-(Vm+132)/16.7) + exp((Vm+16.8)/18.2) ) ) / phi;
plot(Vm, tau_m_TC, 'b')

% Inactivation time constant:
tau_h = ((85 + 1.0 ./ (exp((Vm+shift+46)/4) + exp(-(Vm+shift+405)/50))) + taushift) / phi;
plot(Vm, tau_h, 'r')
tau_h25 = tau_h / 2.5;
plot(Vm, tau_h25, 'r--')
orange = [255 140 0]/255;
tau_h30 = tau_h / 3;
plot(Vm, tau_h30, 'color', orange)
tau_h60 = tau_h / 6;
plot(Vm, tau_h60, 'color', orange, 'LineStyle', '--')
Vm1 = -100:0.1:-80.1;
Vm2 = -80:0.1:40;
tau_h_TC1 = exp((Vm1+467)/66.6) / phi;
tau_h_TC2 = (28 + exp(-(Vm2+22)./10.5)) / phi;
tau_h_TC = [tau_h_TC1 tau_h_TC2];
plot(Vm, tau_h_TC, 'b')
hold off