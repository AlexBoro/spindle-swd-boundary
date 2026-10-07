% Membrane potential ploting function

clc
close all
%clear all
format long
Area = area(42, 63);

%lineWidth = 1;
lineWidth = 2;
%width = 1.75*15;
width = 1.3*15;
height = 15;
label = 0;
margin = 0;

files{1} = '0.000000_NRT0data0.0000100_ 75_0.0000223_0.0001.dat';
files{2} = '0.000000_NRT0data0.0000100_ 75_0.0000223_0.0020.dat';
files{3} = '0.000000_NRT0data0.0000100_ 75_0.0000223_0.0062.dat';
files{4} = '0.000000_NRT0data0.0000100_ 75_0.0000223_0.0125.dat';
files{5} = '0.000000_NRT0data0.0000100_ 75_0.0000223_0.0147.dat';
%files{6} = '0.000000_NRT0data0.0000100_ 75_0.0000223_0.0148.dat';

% xRange(1,1:2) = [90 100];
% xRange(2,1:2) = [61.55 94.55];
% xRange(3,1:2) = [80 100];
% xRange(4,1:2) = [75 90];
% xRange(5,1:2) = [81 91];
% xRange(6,1:2) = [70 75];

xRange(1,1:2) = [94.1 95.19];
xRange(2,1:2) = [76.4 81];
xRange(3,1:2) = [88.2 91.18];
xRange(4,1:2) = [77.7 80.734];
xRange(5,1:2) = [88.4 91];
%xRange(6,1:2) = [70 75];

yRange(1,1:2) = [-80 30];
yRange(2,1:2) = [-80 30];
yRange(3,1:2) = [-80 30];
yRange(4,1:2) = [-80 30];
yRange(5,1:2) = [-80 30];
%yRange(6,1:2) = [-80 30];

widths = zeros(1,length(files));
for i = 1:length(files)
    %widths(i) = width*((xRange(i,2)-xRange(i,1))/33);
    widths(i) = width*((xRange(i,2)-xRange(i,1))/4.6);
end

for i = 1:length(files)
    [~, NRT] = loadFile(files{i}, Area, 'NRT');
    tracePlot(files{i}, NRT.t*1e-3, NRT.v, xRange(i,:), yRange(i,:), lineWidth);
    paperSize = resizeFig(gcf, gca, widths(i), height, label, margin, 0);
    name = files{i};
    exportFig(gcf, [name(1:end-4) '.tif'],'-dtiffnocompression','-r300', paperSize);
end
