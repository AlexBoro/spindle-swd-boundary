function I_NaP
close all
v = -100:0.1:60;

tau_m = zeros(1,length(v));
for i = 1:length(v)
    %alpha = 0.182 * vtrap(v(i) + 25 +13, 9);
    alpha = 0.32 * vtrap(-66.58 - 6.13 - v(i), 4);
    %beta  = 0.124 * vtrap(-(v(i) + 25 +13), 9);
    beta = 0.28 * vtrap(39.58 + v(i) + 6.13, 5);
    tau_m(i) = 1 / (alpha + beta);
end

figure(1)
plot(v, tau_m)
hold on
plot(v, ones(1,length(v))*0.2, 'r')
hold off

m_inf = 1 ./ (1 + exp(-(v + 42) / 5));
m_inf2 = 1 ./ (1 + exp(-(v + 53.87 + 3.5) / 1.5));

figure(2)
plot(v, m_inf)
hold on
plot(v, m_inf2, 'r')
hold off
    
    
function [exponent] = vtrap(x, y)
if (abs(x/y) < 1e-6)
    exponent = y*(1 - x/y/2);
else
    exponent = x/(1 - exp(-x/y));
end