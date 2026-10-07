clc
close all

v = -100:50;
Mg_b = 1;
K0_b = 4.1;
z = 2;
delta_b = 0.8;
F = 9.648e4;
R = 8.315;
T = 273.16;
celsius = 37;

Mgblock = 1 ./ (1 + (Mg_b/K0_b)*exp((0.001)*(-z)*delta_b*F*v./R./(T+celsius)));
plot(v, Mgblock, 'g')
hold on

Mg_b = 2;
Mgblock = 1 ./ (1 + (Mg_b/K0_b)*exp((0.001)*(-z)*delta_b*F*v./R./(T+celsius)));
plot(v, Mgblock, 'r')

Mg_b = 0.5;
Mgblock = 1 ./ (1 + (Mg_b/K0_b)*exp((0.001)*(-z)*delta_b*F*v./R./(T+celsius)));
plot(v, Mgblock, 'r')
hold off