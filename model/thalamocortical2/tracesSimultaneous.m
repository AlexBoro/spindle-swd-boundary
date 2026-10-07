% Membrane potential ploting function

clc
close all
%clear all
format long
Area = area(60, 90);

lineWidth = 3;
width = (31/25.68)*15;
height = 15;
label = 0;
margin = 0;

files{1} = 'z2_TCdata0.dat';
files{2} = 'z2_TCdata1.dat';
files{3} = 'z2_TCdata2.dat';

xRange = [43-0.367647 43-0.367647+3.34];
yRange = [-66-9.519 -66-9.519+18];

%shift = [2.5 0 0];
shift = [0 0 0];

color{1} = 'r';
color{2} = 'g';
color{3} = 'k';

titleStr = 'AHP';
f = figProperties(titleStr, 'normalized', [0, .005, .97, .90], 'w', 'on');
hold on
for i = 1:length(files)
    [~, TC] = loadFile(files{i}, Area, 'TC');
    plot(TC.t*1e-3, TC.v + shift(i), 'Color', color{i}, 'LineWidth', lineWidth)
end
plot(xRange(1), -66, 'k.', 'MarkerSize', 30)
hold off
axesProperties({}, 1, 'normal', 'off', 'w', 'Calibri', 30, 4/3, 0.5, [0.025 0.025], 'out', 'off', 'k', {}, xRange, [], 'on', 'k', {}, yRange, []);
paperSize = resizeFig(gcf, gca, width, height, label, margin, 0);
legStr = {'sAHP', 'mAHP', 'no Ca^{2+}-dependent AHP'};
legProperties(legStr, 'off', 27, 3, 'NorthEast');

exportFig(gcf, [titleStr '.tif'],'-dtiffnocompression','-r300', paperSize);