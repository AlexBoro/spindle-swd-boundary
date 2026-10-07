% Membrane potential ploting function

clc
close all
clear all %#ok<CLALL>
format long
AreaCx3(1) = area(5.644, 5.644);
AreaCx3(2) = area(5.644, 160*5.644);
AreaTC = area(60, 90);
AreaNRT = area(42, 63);

lineWidth = 2;
width = 2.5*15;
height = width/(100.822/20.59);
label = [0 0];
margin = [0 0];

files{1}  = 'z2_Cx3data_2_0051_RS.dat';
files{2}  = 'z2_NRTdata_1_0756_WA.dat';
files{3}  = 'z2_TCdata_1_0656_TC.dat';

xRange = [13.2 18.2];

yRange(1)  = -68;
yRange(2)  = -76;
yRange(3) = -82;

for i = 1:length(files)
    if i <= 6
        [~, data] = loadFile(files{i}, AreaCx3, 'Cx3');
    elseif i <= 8
        [~, data] = loadFile(files{i}, AreaNRT, 'NRT');
    elseif i <= 10
        [~, data] = loadFile(files{i}, AreaTC, 'TC');
    end
    tracePlot(files{i}, data.t*1e-3, data.v, xRange, [yRange(i) yRange(i)+55], lineWidth);
    paperSize = resizeFig(gcf, gca, width, height, label, margin, 0);
    name = files{i};
    savefig(gcf, [num2str(i) '_' name(1:end-4) '_zoom_zoom.fig'], 'compact');
    exportFig(gcf, [num2str(i) '_' name(1:end-4) '_zoom_zoom.tif'],'-dtiffnocompression','-r300', paperSize);
end
