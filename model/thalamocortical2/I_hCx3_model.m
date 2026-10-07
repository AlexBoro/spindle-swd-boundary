v = -160:-10;
tau_m = 1 ./ (0.0004 * exp(-0.025*v) + 0.088*exp(0.062*v));

phi = 3.5 ^ ((34.5-22)/10);
tau_m2 = (1 ./ (0.0004 * exp(-0.025*v) + 0.088*exp(0.062*v))) / phi;

plot(v, tau_m)
hold on
plot(v, tau_m2, 'r')
hold off