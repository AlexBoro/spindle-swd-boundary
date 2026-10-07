% The script file plots the membrane potential population data of thalamic cells.

function xCorrelations

clc
close all
clear all %#ok<CLALL>
format longG
AreaCx3(1) = area(5.644, 5.644);
AreaCx3(2) = area(5.644, 160*5.644);
AreaTC = area(60, 90);
AreaNRT = area(42, 63);

list = dir('*dat');
%iList = 1:900;
iList = 1:100;

dt = .25;
xRange = [100000 200000]+dt;
iRange = xRange./dt;
iRange = iRange(1):iRange(end);
full = false;
nPY = 100;
nIN = 50;
nTC = 100;
nNRT = 50;
NDcells = [];
for i = iList
    i %#ok<*NOPRT>
    fileName = list(i).name;
    if i <= 4*(nPY+nIN)
        [~, data, cellType] = loadFile(fileName, AreaCx3, 'Cx3');
    elseif i <= 4*(nPY+nIN)+2*nNRT
        [~, data, cellType] = loadFile(fileName, AreaNRT, 'NRT');
    elseif i <= 4*(nPY+nIN)+2*nNRT+2*nTC
        [~, data, cellType] = loadFile(fileName, AreaTC, 'TC');
    end
    
    % Resample:
    if i == iList(1)
        t = data.t(1):dt:data.t(end);
        if ~full
            t = t(iRange);
        end
        vTC = zeros(nTC, length(t));
        vNRT = zeros(nNRT, length(t));
        vTC2 = vTC;
        vNRT2 = vNRT;
        vCx23 = zeros(nPY, length(t));
        vCx23i = zeros(nIN, length(t));
        vCx4 = vCx23;
        vCx4i = vCx23i;
        vCx5 = vCx23;
        vCx5i = vCx23i;
        vCx6 = vCx23;
        vCx6i = vCx23i;
    end
    if ~full
        [tunique, iunique] = unique(data.t);
        v = interp1(tunique,data.v(iunique),t);
    else
        [tunique, iunique] = unique(data.t);
        v = interp1(tunique,data.v(iunique),t);
    end
    if i >= 1 && i <= nPY
        vCx23(i,:) = v;
    elseif i >= nPY+1 && i <= nPY+nIN
        vCx23i(i-nPY,:) = v;
    elseif i >= nPY+nIN && i <= 2*nPY+nIN
        vCx4(i-(nPY+nIN),:) = v;
    elseif i >= 2*nPY+nIN+1 && i <= 2*nPY+2*nIN
        vCx4i(i-(2*nPY+nIN),:) = v;
    elseif i >= 2*nPY+2*nIN+1 && i <= 3*nPY+2*nIN
        vCx5(i-(2*nPY+2*nIN),:) = v;
    elseif i >= 3*nPY+2*nIN+1 && i <= 3*nPY+3*nIN
        vCx5i(i-(3*nPY+2*nIN),:) = v;
    elseif i >= 3*nPY+3*nIN+1 && i <= 4*nPY+3*nIN
        vCx6(i-(3*nPY+3*nIN),:) = v;
    elseif i >= 4*nPY+3*nIN+1 && i <= 4*nPY+4*nIN
        vCx6i(i-(4*nPY+3*nIN),:) = v;
    elseif i >= 4*nPY+4*nIN+1 && i <= 4*nPY+4*nIN+nNRT
        vNRT(i-(4*nPY+4*nIN),:) = v;
    elseif i >= 4*nPY+4*nIN+nNRT+1 && i <= 4*nPY+4*nIN+2*nNRT
        vNRT2(i-(4*nPY+4*nIN+nNRT),:) = v;
    elseif i >= 4*nPY+4*nIN+2*nNRT+1 && i <= 4*nPY+4*nIN+2*nNRT+nTC
        vTC(i-(4*nPY+4*nIN+2*nNRT),:) = v;
    elseif i >= 4*nPY+4*nIN+2*nNRT+nTC+1 && i <= 4*nPY+4*nIN+2*nNRT+2*nTC
        vTC2(i-(4*nPY+4*nIN+2*nNRT+nTC),:) = v;
    end
    
    if strcmp('ND', cellType)
        NDcells = [NDcells; (i-300)];
    end
end

% Crosscorrelate
t = t*1e-3;
xLims = xRange/1000;
xLims2 = xRange/1000; %#ok<*NASGU>
xTicks = xLims(1):(xLims(end)-xLims(1))/4:xLims(end);
yLims = [50 100];
yLimsi = [25 50];
width = 2*15;
ratio = 150.566/19.757;
ratio2 = 2*ratio;
label = [0 0.038];
margin = [0 0];
if iList(1) == 1 && iList(end) == nPY
    data = 1;
elseif iList(1) == 1 && iList(end) == nPY+nIN
    data = 1:2;
elseif iList(1) == nPY+nIN+1 && iList(end) == 2*nPY+2*nIN
    data = 3:4;
elseif iList(1) == 2*nPY+2*nIN+1 && iList(end) == 3*nPY+3*nIN
    data = 5:6;
elseif iList(1) == 3*nPY+3*nIN+1 && iList(end) == 4*nPY+4*nIN
    data = 7:8;
elseif iList(1) == 4*nPY+4*nIN+1 && iList(end) == 4*nPY+4*nIN+nNRT
    data = 9;
elseif iList(1) == 4*nPY+4*nIN+nNRT+1 && iList(end) == 4*nPY+4*nIN+2*nNRT
    data = 10;
elseif iList(1) == 4*nPY+4*nIN+2*nNRT+1 && iList(end) == 4*nPY+4*nIN+2*nNRT+nTC
    data = 11;
elseif iList(1) == 4*nPY+4*nIN+2*nNRT+nTC+1 && iList(end) == 4*nPY+4*nIN+2*nNRT+2*nTC
    data = 12;
elseif iList(1) == 4*nPY+4*nIN+1 && iList(end) == 4*nPY+4*nIN+2*nNRT+2*nTC
    data = 9:12;
elseif iList(end) == 4*nPY+4*nIN
    data = 1:8;
elseif iList(end) == 4*nPY+4*nIN+2*nNRT
    data = 1:10;
elseif iList(end) == 4*nPY+4*nIN+2*nNRT+2*nTC
    data = 1:12;
end

data2corr = [];
for data = data
    if data == 1      % L2/3 PY
        data2corr = [data2corr; vCx23]; %#ok<*AGROW>
    elseif data == 2  % L2/3 IN
        data2corr = [data2corr; vCx23i];
    elseif data == 3  % L4 PY
        data2corr = [data2corr; vCx4];
    elseif data == 4  % L4 IN
        data2corr = [data2corr; vCx4i];
    elseif data == 5  % L5 PY
        data2corr = [data2corr; vCx5];
    elseif data == 6  % L5 IN
        data2corr = [data2corr; vCx5i];
    elseif data == 7  % L6 PY
        data2corr = [data2corr; vCx6];
    elseif data == 8  % L6 IN
        data2corr = [data2corr; vCx6i];
    elseif data == 9  % NRT FO
        data2corr = [data2corr; vNRT];
    elseif data == 10 % NRT HO
        data2corr = [data2corr; vNRT2];
    elseif data == 11 % TC FO
        data2corr = [data2corr; vTC];
    elseif data == 12 % TC HO
        data2corr = [data2corr; vTC2];
    end
end
save('xCorrsVars.mat');
xCorrMean = xCorrMat(data2corr);
save('xCorrsVars.mat');
plot(xCorrMean);