clc
close all
t = 0:5000;
t0 = 0;
frequency = ((2./(1 + exp(-(t - t0)/400)) - 1)./100);

plot(t,frequency)
ylim([0 0.011])