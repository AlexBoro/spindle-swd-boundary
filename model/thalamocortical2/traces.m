% Membrane potential ploting function

clc
close all
clear all %#ok<CLALL>
format long
AreaCx3(1) = area(5.644, 5.644);
AreaCx3(2) = area(5.644, 160*5.644);
AreaTC = area(60, 90);
AreaNRT = area(42, 63);
Area = {AreaCx3 AreaCx3 AreaCx3 AreaNRT AreaNRT AreaTC AreaTC};
cellType = {'Cx3' 'Cx3' 'Cx3' 'NRT' 'NRT' 'TC' 'TC'};

lineWidth = [1 1 1 1 1 1 1 1 1 1]*2;
width = 2*15;
height = 2*15/(67.783/25.5551);
height = [height height height height height height height];
label = [0 0];
margin = [0 0];

files{1} = 'z50_Cx3data_5_0355_RS.dat';
files{2} = 'z50_Cx3data_6_0504_EF.dat';
files{3} = 'z50_Cx3data_5_0345_IB.dat';
files{4} = 'z50_Cx3data_5_0372_RIB.dat';
files{5} = 'z50_Cx3data_5_0359_ND.dat';
files{6} = 'z50_Cx3data_5_0431_FS.dat';
files{7} = 'z50_NRTdata_1_0715_WQ.dat';
files{8} = 'z50_TCdata_1_0695_TC.dat';
files{9} = 'z50_NRTdata_2_0857_WA.dat';
files{10} = 'z50_TCdata_2_0810_TC.dat';

xRange(1,1:2) = [5.500 17.000];
xRange(2,1:2) = [5.500 17.000];
xRange(3,1:2) = [5.500 17.000];
xRange(4,1:2) = [5.500 17.000];
xRange(5,1:2) = [5.500 17.000];
xRange(6,1:2) = [5.500 17.000];
xRange(7,1:2) = [5.500 17.000];
xRange(8,1:2) = [5.500 17.000];
xRange(9,1:2) = [5.500 17.000];
xRange(10,1:2) = [5.500 17.000];

yRange(1,1:2) = [-82 46];
% yRange(2,1:2) = [-83.5 46.5];
% yRange(3,1:2) = [-78 46];
% yRange(4,1:2) = [-87.5 27.5];
% yRange(5,1:2) = [-87.5 27.5];
% yRange(6,1:2) = [-77 28.5];
% yRange(7,1:2) = [-80 28.5];

for i = 1:length(files)
    [~, Cx3] = loadFile(files{i}, Area{i}, cellType);
    tracePlot(files{i}, Cx3.t*1e-3, Cx3.v, xRange(i,:), yRange(i,:), lineWidth(i));
    paperSize = resizeFig(gcf, gca, width, height(i), label, margin, 0);
%     name = files{i};
    savefig(gcf, [num2str(i) '.fig'], 'compact');
%     exportFig(gcf, [name(1:end-4) '.tif'],'-dtiffnocompression','-r300', paperSize);
    exportFig(gcf, [num2str(i) '.tif'],'-dtiffnocompression','-r300', paperSize);
end
