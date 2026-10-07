close all
clear all %#ok<CLALL>
clc

amps = [0.0280 (0.0300:0.0050:0.2250)];
frqs1 = [0.1 0.2 0.279 0.350 0.384 0.435 0.461 0.497 0.543 0.585 0.615 0.652 0.701 0.763 0.789 0.839233398437500 0.915527343750000 0.953674316406250 0.991821289062500 1.029968261718750...
    1.106262207031250 1.144409179687500 1.220703125000000 1.296997070312500 1.335144042968750 1.449584960937500 1.525878906250000 1.716613769531250 1.716613769531250 1.792907714843750 1.907348632812500 1.983642578125000...
    2.098083496093750 2.212524414062500 2.326965332031250 2.365112304687500 2.555847167968750 2.708435058593750 2.937316894531250 3.242492675781250 3.547668457031250];
f1 = figProperties('ND vs RIB: oscillation frequencies (1)', 'normalized', [0, .005, .97, .90], 'w', 'on');
plot(1e3*amps, frqs1, 'ks:', 'MarkerFaceColor', 'k', 'LineWidth', 2, 'MarkerSize', 10)
hold on

amps = [0.0590 (0.0600:0.0050:0.2250) 0.2280];
frqs2 = [1.109 1.435 2.44 3.311 4.367 5.78 6.536 7.634 9.009 10.101 11.628 12.5 13.33 14.493 15.385 16.67 17.544 18.519 19.608 20.833 21.739 22.727 22.727 24.39 25 25.641 27.027 27.778 27.778 29.412 30.303 30.303 31.25...
    33.333 33.333 34.483];
plot(1e3*amps, frqs2, 'ko:', 'MarkerFaceColor', 'k', 'LineWidth', 2, 'MarkerSize', 10)
hold off

ax1 = axesProperties({}, 1, 'normal', 'off', 'w', 'Calibri', 45, 4/3, 2, [0.01 0.025], 'out', 'on', 'k', 'd.c. (pA)', [25 228], [50 100 150 200], 'on', 'k', 'Frequency (Hz)', [-2.5 35], [0 10 20 30]);
paperSize = resizeFig(f1, ax1, 22.36, 15.92, [4.2 4.55], [0.2 0.4], 0);
legProperties({'ND','RIB'}, 'off', 45, 3, 'NorthWest');
exportFig(f1, ['NDvsRIB1' '.tif'],'-dtiffnocompression','-r300', paperSize);



f2 = figProperties('ND vs RIB: oscillation frequencies (2)', 'normalized', [0, .005, .97, .90], 'w', 'on');
b = bar([frqs1(1)*4 frqs1(end)*4; frqs2(1)*4 frqs2(end)], 'BarWidth', 1);
b(1).FaceColor = 'k';
b(2).FaceColor = 'r';

ax2 = axesProperties({}, 1, 'normal', 'off', 'w', 'Calibri', 40, 4/3, 2, [0.01 0.025], 'out', 'on', 'k', {}, [0.6 2.4], [], 'on', 'k', {}, [0 35], [0 10 20 30]);
ax2.YTickLabel = {'0','2.5','5','30'};
% hText = text([0.85 1.15 1.85 2.15], [-3.5 -3.5 -3.5 -3.5], {'min', 'max', 'min', 'max'});
% set(hText, 'VerticalAlignment','bottom', 'HorizontalAlignment','center', 'FontSize',30, 'Color','k');
paperSize = resizeFig(f2, ax2, 15.92, 15.92, [2.55 0.65], [0.1 0.4], 0);
exportFig(f2, ['NDvsRIB2' '.tif'],'-dtiffnocompression','-r300', paperSize);