% v = -120:80;
% shift = -10;
% 
% a_inf  = 1./ (1 + exp(-(v + 47)/29));
% tau_a  = 0.34 + 0.92 * exp(-((v + 71)/59).^2);
% 
% b_inf  = 1./ (1 + exp((v + 66)/10));
% tau_b  = 8 + 49 * exp(-((v + 73)/23).^2);
% 
% a_inf2  = 1./ (1 + exp(-(v + 47 - shift)/29));
% tau_a2  = 0.34 + 0.92 * exp(-((v + 71 - shift)/59).^2);
% 
% b_inf2  = 1./ (1 + exp((v + 66 - shift)/10));
% tau_b2  = 8 + 49 * exp(-((v + 73 - shift)/23).^2);
% 
% figure(1)
% plot(v, a_inf.^4)
% hold on
% plot(v, a_inf2.^4, 'r')
% hold off
% 
% figure(2)
% plot(v, tau_a)
% hold on
% plot(v, tau_a2, 'r')
% hold off
% 
% figure(3)
% plot(v, b_inf)
% hold on
% plot(v, b_inf2, 'r')
% hold off
% 
% figure(4)
% plot(v, tau_b)
% hold on
% plot(v, tau_b2, 'r')
% hold off



% v = -120:80;
% shift = -10;
% 
% m_inf  = 1./ (1 + exp(-(v + 38)/10));
% tau_m  = 0.058 + 0.114 * exp(-((v + 36)/28).^2);
% 
% h_inf  = 1./ (1 + exp((v + 66)/6));
% tau_h  = 0.28 + 16.7 * exp(-((v + 60)/25).^2);
% 
% m_inf2  = 1./ (1 + exp(-(v + 38 - shift)/10));
% tau_m2  = 0.058 + 0.114 * exp(-((v + 36 - shift)/28).^2);
% 
% h_inf2  = 1./ (1 + exp((v + 66 - shift)/6));
% tau_h2  = 0.28 + 16.7 * exp(-((v + 60 - shift)/25).^2);
% 
% alpha = 0.182 * (v + 25)./(1 - exp(-(v + 25)/9));
% beta  = -0.124 * (v + 25)./(1 - exp((v + 25)/9));
% tau_m3 = 1 ./ (alpha + beta);
% m_inf3 = alpha ./ (alpha + beta);
% 
% alpha = 0.024 * (v + 40)./(1 - exp(-(v + 40)/5));
% beta  = 0.0091 * (v + 65)./(1 - exp(-(v + 65)/5));
% tau_h3 = 1 ./ (alpha + beta);
% h_inf3 = 1 ./ (1 + exp((v + 55)/6.2));
% 
% figure(1)
% plot(v, m_inf.^4)
% hold on
% plot(v, m_inf2.^4, 'r')
% plot(v, m_inf3.^3, 'g')
% hold off
% 
% figure(2)
% plot(v, tau_m)
% hold on
% plot(v, tau_m2, 'r')
% plot(v, tau_m3, 'g')
% hold off
% 
% figure(3)
% plot(v, h_inf)
% hold on
% plot(v, h_inf2, 'r')
% plot(v, h_inf3, 'g')
% hold off
% 
% figure(4)
% plot(v, tau_h)
% hold on
% plot(v, tau_h2, 'r')
% plot(v, tau_h3, 'g')
% hold off



% v = -120:80;
% shift = -10;
% 
% alpha = 0.0052 * (v + 11.1)./(1 - exp(-(v + 11.1)/13.1));
% beta   = 0.02 * exp(-(v + 1.27)/71) - 0.005;
% tau_r = 1 ./ (alpha + beta);
% r_inf = alpha ./ (alpha + beta);
% 
% alpha = 0.02 * (v - 25)./(1 - exp(-(v - 25)/9));
% beta = -0.002 * (v - 25)./(1 - exp((v - 25)/9));
% tau_n = 1 ./ (alpha + beta);
% n_inf = alpha ./ (alpha + beta);
% 
% figure(1)
% plot(v, r_inf.^2)
% hold on
% plot(v, n_inf, 'g')
% hold off
% 
% figure(2)
% plot(v, tau_r)
% hold on
% plot(v, tau_n, 'g')
% hold off



alpha = 0.182 * (v + 25)./(1 - exp(-(v + 25)/9));
beta  = -0.124 * (v + 25)./(1 - exp((v + 25)/9));
tau_m = 1 ./ (alpha + beta);
m_inf = alpha ./ (alpha + beta);

tau_m2 = 0.2*ones(1,length(v));
m_inf2 = 1 ./ (1 + exp(-(v + 42) / 5));

figure(1)
plot(v, m_inf.^3)
hold on
plot(v, m_inf, 'g')
hold off

figure(2)
plot(v, tau_m)
hold on
plot(v, tau_m2, 'g')
hold off