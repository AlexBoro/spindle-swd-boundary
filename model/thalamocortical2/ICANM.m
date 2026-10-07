cai = 0:0.000001:0.001000;
cac_h = 0.00045;
n = 20;
hCa_inf = 1./(1 + (cai./cac_h).^n);
celsius = 37;
phi = 3.0 ^ ((celsius-22)/10);
tau_hCa = ((1 / 0.00019) ./ ((cac_h ./ cai).^n + 1) ./ phi) + 0.1;

figure('Units', 'normalized', 'Position', [0, .01, .48, .89]);
yyaxis left
plot(cai, hCa_inf, 'b');
hold on
plot(cai, tau_hCa, 'b--');


Kd = 0.00019; %0.05;
K_half = 0.0003; %0.00032;
Hill_tau = 5.3;
tau_m_min = 200; %10;
tau_m = ((1 / Kd) ./ ((K_half ./ cai).^Hill_tau + 1) / phi) + tau_m_min;
yyaxis right
plot(cai, tau_m, 'r');

Hill_tau = 10;
tau_m = ((1 / Kd) ./ ((K_half ./ cai).^Hill_tau + 1) / phi) + tau_m_min;
yyaxis right
plot(cai, tau_m, '--r');


n = 2;
beta = 0.0001;
cac = 0.00036; %0.00025;
%alpha2 = beta * (cai./cac).^n;
alpha2 = beta * (cac./cai).^n;
tau_mCa = 1 ./ (alpha2 + beta) / phi;
mCa_inf = alpha2 ./ (alpha2 + beta);
yyaxis left
plot(cai, mCa_inf, 'k');
yyaxis right
plot(cai, tau_mCa, 'g');
hold off