% I_AHP model in NRT neurons.

close all
clc

celsius = 35;
Cai = (0:0.01:4000)/1e6; % mM; *1e3 uM; *1e6 nM

% Destexhe:
beta = 0.03;
Cac	= 0.025;
power = 2;

% Martynas:
% Kd = 0.05;
% Kd2 = 0.0023;
% K_half1 = 0.00005;
% K_half2 = 0.00005;
% Hill = 5.3;
% Hill_tau = 5.3;
% tau_m1_min = 1;
% tau_m2_min = 400;

% Martynas2:
Kd = 0.05;
Kd2 = 0.0012;
Kd3 = 1;
K_half1 = 0.001; %0.00032;
K_half2 = 0.0015; %0.00032;
K_half3 = 0.00042;
Hill = 5.3;
Hill3 = 5.3;
Hill_tau = 5.3;
Hill_tau3 = 5.3;
tau_m1_min = 15; %11.65;
tau_m2_min = 150; %830;
tau_m3_min = 11.65;

% Steady state activation curve:
figure('Units', 'normalized', 'Position', [0,.01, .48, .89]);
Car = (Cai/Cac).^power;
m_inf_D = zeros(1,length(Cai));
for i = 1:length(Cai)
	m_inf_D(i) = Car(i) / ( 0.5 + Car(i) );
end
m1_inf = 1 ./ ((K_half1 ./ Cai).^Hill + 1);
m2_inf = 1 ./ ((K_half2 ./ Cai).^Hill + 1);
m3_inf = 1 ./ ((K_half3 ./ Cai).^Hill3 + 1);
semilogx(Cai*1e6, m_inf_D)
hold on
semilogx(Cai*1e6, m1_inf, 'r')
semilogx(Cai*1e6, m2_inf, 'r--')
semilogx(Cai*1e6, m3_inf, 'g')
title('I_A_H_P Steady State Activation Curve')
xlabel('Concentration (nM)')
ylabel('I/I_m_a_x')
legend('Destexhe', 'Martynas', 'Martynas', 'Martynas2')
hold off

% Activation time constant:
figure('Units', 'normalized', 'Position', [0,.01, .48, .89]);
phi = 3.0 ^ ((celsius-22)/10);
tau_m_D = 1 / beta ./ (1 + Car) / phi;
phi = 3.0 ^ ((celsius-34.25)/10);
tau_m = ((1 / Kd) ./ ((Cai / K_half1).^Hill_tau + 1) / phi) + tau_m1_min;
tau_m2 = ((1 / Kd2) ./ ((Cai / K_half2).^Hill_tau + 1) / phi) + tau_m2_min;
tau_m3 = ((1 / Kd3) ./ ((Cai / K_half3).^Hill_tau3 + 1) / phi) + tau_m3_min;
semilogx(Cai*1e6, tau_m_D)
hold on
semilogx(Cai*1e6, tau_m, 'r')
semilogx(Cai*1e6, tau_m2, 'r--')
semilogx(Cai*1e6, tau_m3, 'g')
title('I_A_H_P Activation Time Constant (Destexhe)')
xlabel('Concentration (nM)')
ylabel('Time (ms)')
legend('Destexhe', 'Martynas', 'Martynas', 'Martynas2')
hold off