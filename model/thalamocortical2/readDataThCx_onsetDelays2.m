% The script file plots the membrane potential population data of thalamic cells.

clc
close all
clear all %#ok<CLALL>
format longG

load('delays1.mat');
delayL23_1 = delayL23PY;
delayL4_1 = delayL4PY;
delayL5_1 = delayL5PY;
%delayL5noND_1 = delayL5noND;
delayL6_1 = delayL6PY;
load('delays2.mat');
delayL23_2 = delayL23PY;
delayL4_2 = delayL4PY;
delayL5_2 = delayL5PY;
%delayL5noND_2 = delayL5noND;
delayL6_2 = delayL6PY;
load('delays3.mat');
delayL23_3 = delayL23PY;
delayL4_3 = delayL4PY;
delayL5_3 = delayL5PY;
%delayL5noND_3 = delayL5noND;
delayL6_3 = delayL6PY;
load('delays4.mat');
delayL23_4 = delayL23PY;
delayL4_4 = delayL4PY;
delayL5_4 = delayL5PY;
%delayL5noND_4 = delayL5noND;
delayL6_4 = delayL6PY;

f1 = figProperties('Average Up-state onset delays for different cortical cell types', 'normalized', [0, .005, .97, .90], 'w', 'on');
width = 20;
col = [0,128/255,0];
p(1) = plot(0,0,'g','LineWidth',width);
hold on
%plot(0,0,'Color',col,'LineWidth',width)
p(2) = plot(0,0,'b','LineWidth',width);
p(3) = plot(0,0,'m','LineWidth',width);
p(4) = plot(0,0,'r','LineWidth',width);
bar(1, delayL5_1, 'g');
%bar(2, delayL5noND_1, 'FaceColor',col);
bar(2, delayL6_1, 'b');
bar(3, delayL23_1, 'm');
bar(4, delayL4_1, 'r');

gap = 5.5;
bar(1+gap, delayL5_2, 'g');
%bar(2+gap, delayL5noND_2, 'FaceColor',col);
bar(2+gap, delayL6_2, 'b');
bar(3+gap, delayL23_2, 'm');
bar(4+gap, delayL4_2, 'r');

bar(1+gap+gap, delayL5_3, 'g');
%bar(2+gap+gap, delayL5noND_3, 'FaceColor',col);
bar(2+gap+gap, delayL6_3, 'b');
bar(3+gap+gap, delayL23_3, 'm');
bar(4+gap+gap, delayL4_3, 'r');

bar(1+gap+gap+gap, delayL5_4, 'g');
%bar(2+gap+gap+gap, delayL5noND_4, 'FaceColor',col);
bar(2+gap+gap+gap, delayL6_4, 'b');
bar(3+gap+gap+gap, delayL23_4, 'm');
bar(4+gap+gap+gap, delayL4_4, 'r');
hold off

ax1= axesProperties({}, 1, 'normal', 'off', 'w', 'Calibri', 30, 4/3, 3, [0.01 0], 'out', 'on', 'k', {}, [], [2.5 2.5+gap 2.5+gap*2 2.5+gap*3], 'on', 'k', {'Latency (ms)'}, [500 1810], [500 1150 1800]);
ax1.XTickLabel = {'0*w', '0.5*w', '1*w', '1.5*w'};
%ax1.XTickLabelRotation = 90;
label = [4.1 1.55];
margin = [-5 0.3];
width = 2*15-label(1)-margin(1);
height = (2*15)/(113.913/74.233)-label(2)-margin(2);
paperSize = resizeFig(f1, ax1, width, height, label, margin, 0);
legStr = {'L5', 'L6', 'L2/3', 'L4'};
l = legend(p,legStr, 'Box', 'off', 'FontSize', 30, 'LineWidth', 3, 'Location', 'NorthWest');
position = get(l, 'Position');
position(1) = position(1) + 0.01;
set(l, 'Position', position);
exportFig(f1, ['onset_delays' '.tif'],'-dtiffnocompression','-r300', paperSize);
