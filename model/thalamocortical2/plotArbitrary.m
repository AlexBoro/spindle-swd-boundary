% Plot an arbitrary squared graph
function plotArbitrary

close all
clear all %#ok<CLALL>
clc

visibility = 'on';
width = 15.92;
height = 15.92;
label = [4.2 4.2];
margin = [0.7 0.7];
gap = 0;
lineWidth = 3;

% Frequency range:
x = 0:2.5:20;
titleStr = 'Frequency range';
data = [0.687 0.687 0.877 1.183 1.068 1.259 1.259 1.373 1.373];
penSz = ones(1, size(data,1))*lineWidth;
f1 = multiPlot(titleStr, data, [1 1 1], penSz, x, visibility);
hold on
plot(x,data,'b.','MarkerSize',50)
bfl = lsline(gca);
bfl.Color = 'b';
bfl.LineWidth = 3;
hold off
ax = axesProperties({}, 1, 'normal', 'off', 'w', 'Calibri', 40, 4/3, 2, [0.01 0.025], 'out', 'on', 'k', 'Weight', [x(1) x(end)], [0 10 20], 'on', 'k', 'Frequency (Hz)', [0.5 1.5], [0.5 1 1.5]);
paperSize = resizeFig(f1, ax, width, height, label, margin, gap);

% Save figures:
exportFig(f1,  ['frequencies' '.tif'],'-dtiffnocompression','-r300', paperSize);



% Up-state duration range:
x = [0 2.5 2.6 2.75 3 3.75 5:2.5:20];
titleStr = 'Up-state duration range';
data  = [405.50   373.57   377.52   392.75   400.84   390.37   419.09   403.16   419.23   437.86   411.58   394.26   363.51];
data2 = [879.97   838.90   742.34   681.69   642.12   581.92   487.33   494.99   428.11   430.67   428.58   436.89   450.76];
penSz = ones(1, size(data,1))*lineWidth;
f2 = multiPlot(titleStr, data, [1 1 1], penSz, x, visibility);
hold on

plot(x,data,'g.','MarkerSize',50)
bfl = lsline(gca);
bfl.Color = 'g';
bfl.LineWidth = lineWidth;

plot(x,data2,'r.','MarkerSize',50)
sigfunc = @(A, x)(A(1) ./ (A(2) + exp(A(3)*(x-A(4)))) + A(5));
A0 = [450 1 1 3 450]; % Initial values fed into the iterative algorithm
A = nlinfit(x, data2, sigfunc, A0);
x = 0:0.05:20;
sigfunc = A(1) ./ (A(2) + exp(A(3)*(x-A(4)))) + A(5);
p = plot(x,sigfunc,'r','LineWidth',lineWidth);

hold off
ax = axesProperties({}, 1, 'normal', 'off', 'w', 'Calibri', 40, 4/3, 2, [0.01 0.025], 'out', 'on', 'k', 'Weight', [x(1) x(end)], [0 10 20], 'on', 'k', 'Duration (ms)', [300 900], [300 600 900]);
paperSize = resizeFig(f2, ax, width, height, label, margin, gap);
legStr = {'Up-state', 'Down-state'};
l = legend([bfl p],legStr);
l.Box = 'off';
l.FontSize = 40;
l.Location = 'NorthEast';

% Save figures:
exportFig(f2,  ['durations' '.tif'],'-dtiffnocompression','-r300', paperSize);
