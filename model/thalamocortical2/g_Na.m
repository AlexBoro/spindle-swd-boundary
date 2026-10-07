clc

g_naSoma = 278;
g_naDend = 154;
na_dist = 685;
x = 1:685;

g_na = (g_naSoma + x*(g_naDend - g_naSoma)./na_dist)*1e-4;
mean(g_na)
g_na(1)
g_na(end)

figure('Units', 'normalized', 'Position', [0, .01, .48, .89]);
plot(x, g_na)
titleStr = sprintf('g_N_a');
set(gcf,'name',titleStr)
title(titleStr)
xlabel('Distance from the soma (um)')
ylabel('Membrane conductance density (S/cm^2)')



% g_kfSoma = 294;
% g_kfDend = 28;
% kf_slope = -0.018;
% x = 1:454;
% 
% g_kf = (g_kfDend + g_kfSoma * exp(kf_slope * x))*1e-4;
% mean(g_kf)
% 
% figure('Units', 'normalized', 'Position', [0, .01, .48, .89]);
% plot(x, g_kf)
% titleStr = sprintf('g_K_f');
% set(gcf,'name',titleStr)
% title(titleStr)
% xlabel('Distance from the soma (um)')
% ylabel('Membrane conductance density (S/cm^2)')



% g_ksSoma = 278;
% g_ksDend = 154;
% ks_slope = -0.05;
% x = 1:305;
% 
% g_ks = (g_ksDend + g_ksSoma * exp(ks_slope * x))*1e-4;
% mean(g_ks)
% g_ks(1)
% g_ks(end)
% 
% figure('Units', 'normalized', 'Position', [0, .01, .48, .89]);
% plot(x, g_ks)
% titleStr = sprintf('g_K_s');
% set(gcf,'name',titleStr)
% title(titleStr)
% xlabel('Distance from the soma (um)')
% ylabel('Membrane conductance density (S/cm^2)')



% g_hSoma = 2.2;
% g_hDend = 228;
% h_slope = -0.07;
% h_xhalf = 482;
% x = 1:800;
% 
% g_h = (g_hSoma + g_hDend./(1 + exp(h_slope*(x - h_xhalf))))*1e-4;
% mean(g_h)
% g_h(1)
% g_h(end)
% 
% figure('Units', 'normalized', 'Position', [0, .01, .48, .89]);
% plot(x, g_h)
% titleStr = sprintf('g_h');
% set(gcf,'name',titleStr)
% title(titleStr)
% xlabel('Distance from the soma (um)')
% ylabel('Membrane conductance density (S/cm^2)')



% g_skSoma = 1.93;
% g_skDend = 1.85;
% sk_dist = 84;
% x = 1:84;
% 
% g_sk = (g_skSoma + x*(g_skDend - g_skSoma)./sk_dist)*1e-4;
% mean(g_sk)
% g_sk(1)
% g_sk(end)
% 
% figure('Units', 'normalized', 'Position', [0, .01, .48, .89]);
% plot(x, g_sk)
% titleStr = sprintf('g_S_K');
% set(gcf,'name',titleStr)
% title(titleStr)
% xlabel('Distance from the soma (um)')
% ylabel('Membrane conductance density (S/cm^2)')