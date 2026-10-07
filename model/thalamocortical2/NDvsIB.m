% The script comparing a 'Network Driver' (ND) and an intrinsically
% bursting (IB) cells in terms of their oscillation frequencies.

clc
close all
clear all
format long

% NDdc = [21 (25:5:155) 158];
% ND = [0.21, 0.37, 0.48, 0.56, 0.64, 0.71, 0.80, 0.88, 0.94, 1.02, 1.10,...
%     1.17, 1.22, 1.28, 1.40, 1.46, 1.56, 1.62, 1.74, 1.83, 1.91, 1.98,...
%     2.08, 2.23, 2.26, 2.35, 2.41, 2.47, 2.47];
%ND = [];
% IBdc = [(95:5:210) 214];
% IB = [1.50, 1.56, 2.08, 2.53, 2.96, 3.42, 3.91, 4.43, 4.97, 5.55, 6.20,...
%     6.93, 7.72, 8.61, 9.52, 10.47, 11.35, 12.18, 12.88, 13.46, 13.92,...
%     14.25, 14.43, 14.43, 14.30];

NDdc = [20:5:170];
ND = [0.23 0.38 0.46 0.52 0.66 0.73 0.81 0.88 0.95 1.02 1.10 1.10 1.25...
    1.34 1.40 1.47 1.56 1.64 1.71 1.83 1.93 1.95 2.08 2.20 2.32 2.43 2.54...
    2.61 2.65 2.68 2.61];
IBdc = (95:5:205);
IB = [1.16 1.79 2.20 2.81 3.30 3.66 4.27 4.88 5.49 6.23 7.08 7.93 8.91...
    9.89 10.74 11.60 12.33 12.94 13.55 14.04 14.28 14.53 14.77];

figure('Units', 'normalized', 'Position', [0, .01, .48, .89]);
plot(NDdc, ND, '-s', 'MarkerFaceColor','b')
hold on
plot(IBdc, IB, '-ko', 'MarkerFaceColor','k')
hold off
titleStr = sprintf('Injected current vs. Oscillation frequency');
set(gcf,'name',titleStr)
title(titleStr)
xlabel('Injected current (pA)')
ylabel('Frequency (Hz)')
xlim([0 250])
ylim([0 15])
legend('ND', 'IB')