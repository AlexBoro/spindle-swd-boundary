% Membrane potential ploting function

clc
close all
clear all
format long
Area = area(60, 90);

lineWidth = 2;
width = 3*15;
height = 15;
label = [0 0];
margin = [0 0];

files{1} = 'z2_NRTdata0.dat';

xRange(1,1:2) = [30.1 39.5];

yRange(1,1:2) = [-88 30];

[~, TC] = loadFile(files{1}, Area, 'TC');
tracePlot(files{1}, TC.t*1e-3, TC.v, xRange(1,:), yRange(1,:), lineWidth);
paperSize = resizeFig(gcf, gca, width, height, label, margin, 0);
name = files{1};
exportFig(gcf, [name(1:end-4) '.tif'],'-dtiffnocompression','-r300', paperSize);
