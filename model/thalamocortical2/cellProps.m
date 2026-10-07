clc
close all
clear all %#ok<CLALL>

x = 1:6;
y = [ 0  0  0  0  0  0 100 50; ...
      0  0  0  0  0  0 100 50; ...
     70 10 20  0  0 50   0  0; ...
     30 20 25 15 10 50   0  0; ...
     80  0 20  0  0 50   0  0; ...
     70 10 20  0  0 50   0  0];

f = figure;
hold on
size = 28;
plot(-1,-1, 'g', 'LineWidth', size)
plot(-1,-1, 'b', 'LineWidth', size)
plot(-1,-1, 'm', 'LineWidth', size)
plot(-1,-1, 'r', 'LineWidth', size)
plot(-1,-1, 'y', 'LineWidth', size)
plot(-1,-1, 'c', 'LineWidth', size)
plot(-1,-1, 'Color', [0 102 51]/255, 'LineWidth', size)
plot(-1,-1, 'Color', [153 153 255]/255, 'LineWidth', size)
b = barh(x,y,'stacked'); % stacks values in each row together
hold off

orange = [255 140 0]/255;
gold = [255 215 0]/255;

b(1).FaceColor = 'g';
b(1).EdgeColor = 'g';
b(2).FaceColor = 'b';
b(2).EdgeColor = 'b';
b(3).FaceColor = 'm';
b(3).EdgeColor = 'm';
b(4).FaceColor = 'r';
b(4).EdgeColor = 'r';
b(5).FaceColor = 'y';
b(5).EdgeColor = 'y';
b(6).FaceColor = 'c';
b(6).EdgeColor = 'c';
b(7).FaceColor = [0 102 51]/255;
b(7).EdgeColor = [0 102 51]/255;
b(8).FaceColor = [153 153 255]/255;
b(8).EdgeColor = [153 153 255]/255;

ax = axesProperties({}, 1, 'normal', 'off', 'w', 'Calibri', 40, 4/3, 3, [0.01 0], 'out', 'off', 'k', {'Latency (ms)'}, [0 180], [0 50 100 150], 'off', 'k', {}, [0 7], []);
paperSize = resizeFig(f, ax, 2.5*15, 7.5, [0.35 2.4], [-0.3 0.4], 0);
legStr = {'RS';'EF';'IB';'RIB';'ND';'FS';'TC';'NRT'};
legProperties(legStr, 'off', 30, 3, 'NorthEast');
exportFig(f, ['cellProps' '.tif'],'-dtiffnocompression','-r300', paperSize);