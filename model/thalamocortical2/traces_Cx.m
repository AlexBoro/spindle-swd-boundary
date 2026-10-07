% Membrane potential ploting function

clc
close all
clear all %#ok<CLALL>
format long
AreaCx3(1) = area(5.644, 5.644);
AreaCx3(2) = area(5.644, 160*5.644);
AreaTC = area(60, 90);
AreaNRT = area(42, 63);
zoom = true;

lineWidth = ones(1,7)*2; %#ok<*NASGU>
if zoom
    lineWidth = ones(1,7)*3; %#ok<*UNRCH>
end
side = 13.042;
width(1) = 112.326;
width(2) = 112.326;
width(3) = 112.326;
width(4) = 112.326;
width(5) = 112.326;
width(6) = 112.326;
width(7) = 112.326;
if zoom
    width(1) = 38.883;
    width(2) = 38.883;
    width(3) = 38.883;
    width(4) = 38.883;
    width(5) = 38.883;
    width(6) = 38.883;
    width(7) = 38.883;
end
height(1) = side;
height(2) = side;
height(3) = side;
height(4) = side;
height(5) = side;
height(6) = side;
height(7) = side;
label = [0 0];
margin = [0 0];

files{1} = 'z50_Cx3data_4_0169_IB.dat';
files{2} = 'z50_Cx3data_5_0323_RIB.dat';
files{3} = 'z50_Cx3data_5_0411_FS.dat';
files{4} = 'z50_TCdata_1_0678_TC.dat';
files{5} = 'z50_NRTdata_1_0712_WA.dat';
files{6} = 'z50_TCdata_2_0775_TC.dat';
files{7} = 'z50_NRTdata_2_0870_WA.dat';

xRange(1,1) = 521.5;
xRange(1,2) = 533.5;
xRange(2,1) = 521.5;
xRange(2,2) = 533.5;
xRange(3,1) = 521.5;
xRange(3,2) = 533.5;
xRange(4,1) = 521.5;
xRange(4,2) = 533.5;
xRange(5,1) = 521.5;
xRange(5,2) = 533.5;
xRange(6,1) = 521.5;
xRange(6,2) = 533.5;
xRange(7,1) = 521.5;
xRange(7,2) = 533.5;
if zoom
    xRange(1,1) = 528.428155547246;
    xRange(1,2) = 528.848752737567;
    xRange(2,1) = 528.428155547246;
    xRange(2,2) = 528.848752737567;
    xRange(3,1) = 528.428155547246;
    xRange(3,2) = 528.848752737567;
    xRange(4,1) = 528.428155547246;
    xRange(4,2) = 528.848752737567;
    xRange(5,1) = 528.428155547246;
    xRange(5,2) = 528.848752737567;
    xRange(6,1) = 528.428155547246;
    xRange(6,2) = 528.848752737567;
    xRange(7,1) = 528.428155547246;
    xRange(7,2) = 528.848752737567;
end

yRange(1,1) = -72.5;
yRange(1,2) = yRange(1,1)+75;
yRange(2,1) = -73.25;
yRange(2,2) = yRange(2,1)+75;
yRange(3,1) = -78.5;
yRange(3,2) = yRange(3,1)+75;
yRange(4,1) = -72.5;
yRange(4,2) = yRange(4,1)+75;
yRange(5,1) = -81;
yRange(5,2) = yRange(5,1)+75;
yRange(6,1) = -83;
yRange(6,2) = yRange(6,1)+75;
yRange(7,1) = -81.5;
yRange(7,2) = yRange(7,1)+75;

for i = 1:length(files)
    if i <= 3
        [~, data] = loadFile(files{i}, AreaCx3, 'Cx3');
    elseif i == 5 || i == 7
        [~, data] = loadFile(files{i}, AreaNRT, 'NRT');
    elseif i == 4 || i == 6
        [~, data] = loadFile(files{i}, AreaTC, 'TC');
    end
    tracePlot(files{i}, data.t*1e-3, data.v, xRange(i,:), yRange(i,:), lineWidth(i));
    paperSize = resizeFig(gcf, gca, width(i), height(i), label, margin, 0);
    name = files{i};
    savefig(gcf, [name(1:end-4) '.fig'], 'compact');
    %exportFig(gcf, [name(1:end-4) '.tif'],'-dtiffnocompression','-r300', paperSize);
    exportFig(gcf, [name(1:end-4) '.eps'],'-depsc','-r1200', paperSize);
    %exportFig(gcf, [name(1:end-4) '.png'],'-dpng','-r300', paperSize);
end