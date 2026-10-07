g_pas = [0.0000333 0.000015 0.00001 0.00000786];
R_i = [114.1 186 227.6 252.5];

figure('Units', 'normalized', 'Position', [0, .01, .48, .89]);
plot(g_pas, R_i)

figure('Units', 'normalized', 'Position', [0, .01, .48, .89]);
plot(R_i, g_pas)