% The script file plots the membrane potential population data of thalamic cells.

function readDataThCx_population

clc
close all
clear all %#ok<CLALL>
format longG
AreaCx3(1) = area(5.644, 5.644);
AreaCx3(2) = area(5.644, 160*5.644);
AreaTC = area(60, 90);
AreaNRT = area(42, 63);

list = dir('*dat');
%iList = 1:100;
%iList = 1:600;
%iList = 1:750;
%iList = 1:800;
iList = 1:900;
%iList = 601:1200;
%iList = 001:150;
%iList = 001:100;
%iList = 151:300;
%iList = 301:400;
%iList = 301:450;
%iList = 451:600;
%iList = [301:450 601:900];
%iList = 601:700;
%iList = 601:900;
%iList = 701:800;
%iList = 801:900;
%iList = 701:900;

dt = .25;
xRange = [528428.155547246 528848.752737567]+dt;
iRange = round(xRange./dt);
iRange = iRange(1):iRange(end);
full = 0;
disp = [1 0 0 0 1];
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
        TCraster = vTC;
        vNRT = zeros(nNRT, length(t));
        NRTraster = vNRT;
        vTC2 = vTC;
        TC2raster = vTC;
        vNRT2 = vNRT;
        NRT2raster = vNRT;
        vCx23 = zeros(nPY, length(t));
        Cx23raster = vCx23;
        vCx23i = zeros(nIN, length(t));
        Cx23iraster = vCx23i;
        vCx4 = vCx23;
        Cx4raster = vCx23;
        vCx4i = vCx23i;
        Cx4iraster = vCx23i;
        vCx5 = vCx23;
        Cx5raster = vCx23;
        vCx5i = vCx23i;
        Cx5iraster = vCx23i;
        vCx6 = vCx23;
        Cx6raster = vCx23;
        vCx6i = vCx23i;
        Cx6iraster = vCx23i;
    end
    if ~full
        %v = data.v(iRange);
        [tunique, iunique] = unique(data.t);
        v = interp1(tunique,data.v(iunique),t);
    else
        %v = data.v;
        [tunique, iunique] = unique(data.t);
        v = interp1(tunique,data.v(iunique),t);
    end
    if i >= 1 && i <= nPY
        vCx23(i,:) = v;
        Cx23raster(i,:) = rastergram(vCx23(i,:));
    elseif i >= nPY+1 && i <= nPY+nIN
        vCx23i(i-nPY,:) = v;
        Cx23iraster(i-nPY,:) = rastergram(vCx23i(i-nPY,:));
    elseif i >= nPY+nIN && i <= 2*nPY+nIN
        vCx4(i-(nPY+nIN),:) = v;
        Cx4raster(i-(nPY+nIN),:) = rastergram(vCx4(i-(nPY+nIN),:));
    elseif i >= 2*nPY+nIN+1 && i <= 2*nPY+2*nIN
        vCx4i(i-(2*nPY+nIN),:) = v;
        Cx4iraster(i-(2*nPY+nIN),:) = rastergram(vCx4i(i-(2*nPY+nIN),:));
    elseif i >= 2*nPY+2*nIN+1 && i <= 3*nPY+2*nIN
        vCx5(i-(2*nPY+2*nIN),:) = v;
        Cx5raster(i-(2*nPY+2*nIN),:) = rastergram(vCx5(i-(2*nPY+2*nIN),:));
    elseif i >= 3*nPY+2*nIN+1 && i <= 3*nPY+3*nIN
        vCx5i(i-(3*nPY+2*nIN),:) = v;
        Cx5iraster(i-(3*nPY+2*nIN),:) = rastergram(vCx5i(i-(3*nPY+2*nIN),:));
    elseif i >= 3*nPY+3*nIN+1 && i <= 4*nPY+3*nIN
        vCx6(i-(3*nPY+3*nIN),:) = v;
        Cx6raster(i-(3*nPY+3*nIN),:) = rastergram(vCx6(i-(3*nPY+3*nIN),:));
    elseif i >= 4*nPY+3*nIN+1 && i <= 4*nPY+4*nIN
        vCx6i(i-(4*nPY+3*nIN),:) = v;
        Cx6iraster(i-(4*nPY+3*nIN),:) = rastergram(vCx6i(i-(4*nPY+3*nIN),:));
    elseif i >= 4*nPY+4*nIN+1 && i <= 4*nPY+4*nIN+nNRT
        vNRT(i-(4*nPY+4*nIN),:) = v;
        NRTraster(i-(4*nPY+4*nIN),:) = rastergram(vNRT(i-(4*nPY+4*nIN),:));
    elseif i >= 4*nPY+4*nIN+nNRT+1 && i <= 4*nPY+4*nIN+2*nNRT
        vNRT2(i-(4*nPY+4*nIN+nNRT),:) = v;
        NRT2raster(i-(4*nPY+4*nIN+nNRT),:) = rastergram(vNRT2(i-(4*nPY+4*nIN+nNRT),:));
    elseif i >= 4*nPY+4*nIN+2*nNRT+1 && i <= 4*nPY+4*nIN+2*nNRT+nTC
        vTC(i-(4*nPY+4*nIN+2*nNRT),:) = v;
        TCraster(i-(4*nPY+4*nIN+2*nNRT),:) = rastergram(vTC(i-(4*nPY+4*nIN+2*nNRT),:));
    elseif i >= 4*nPY+4*nIN+2*nNRT+nTC+1 && i <= 4*nPY+4*nIN+2*nNRT+2*nTC
        vTC2(i-(4*nPY+4*nIN+2*nNRT+nTC),:) = v;
        TC2raster(i-(4*nPY+4*nIN+2*nNRT+nTC),:) = rastergram(vTC2(i-(4*nPY+4*nIN+2*nNRT+nTC),:));
    end
    
    if strcmp('ND', cellType)
        NDcells = [NDcells; (i-300)]; %#ok<AGROW>
    end
end

t = t*1e-3;
xLims = xRange/1000;
xLims2 = xRange/1000; %#ok<*NASGU>
xTicks = xLims(1):(xLims(end)-xLims(1))/4:xLims(end);
yLims = [50 100];
yLimsi = [25 50];
width = 2*15;
%ratio = 38.883/13.042;
ratio = 112.326/13.042;
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
%data = 5;
%data = [5:6 9:12];
%data = 11:12;
%data = 9:10;
%data = 5:6;

cmLimCx = [-63 -54];
cmLimCxi = [-63 -54];
cmLimNRT = [-63 -49]; %[-63 -54]+5;
cmLimTCFO = [-45 -35]; %[-63 -54]+18;
cmLimTCHO = [-50 -35]; %[-63 -54]+18;
for data = data
    if data == 1
        rPlot('Cortical layer 2/3 PY population rastergram', '02', t, xLims, xTicks, Cx23raster, width, ratio, label, margin, disp(1), data)
        populationPlot('Cortical layer 2/3 PY population data', '02', cmLimCx, t, xLims, xTicks, vCx23, Cx23raster, 'grey', width, ratio, label, margin, disp(2), data)
        populationPlot('Cortical layer 2/3 PY population data', '02', cmLimCx, t, xLims, xTicks, vCx23, Cx23raster, 'hot', width, ratio, label, margin, disp(3), data)
        populationPlot('Cortical layer 2/3 PY population data', '02', cmLimCx, t, xLims, xTicks, vCx23, Cx23raster, 'cold', width, ratio, label, margin, disp(4), data)
        populationPlot('Cortical layer 2/3 PY population data', '02', cmLimCx, t, xLims, xTicks, vCx23, Cx23raster, 'full', width, ratio, label, margin, disp(5), data)
    elseif data == 2
        rPlot('Cortical layer 2/3 IN population rastergram', '02i', t, xLims, xTicks, Cx23iraster, width, ratio2, label, margin, disp(1), data)
        populationPlot('Cortical layer 2/3 IN population data', '02i', cmLimCxi, t, xLims, xTicks, vCx23i, Cx23iraster, 'grey', width, ratio2, label, margin, disp(2), data)
        populationPlot('Cortical layer 2/3 IN population data', '02i', cmLimCxi, t, xLims, xTicks, vCx23i, Cx23iraster, 'hot', width, ratio2, label, margin, disp(3), data)
        populationPlot('Cortical layer 2/3 IN population data', '02i', cmLimCxi, t, xLims, xTicks, vCx23i, Cx23iraster, 'cold', width, ratio2, label, margin, disp(4), data)
        populationPlot('Cortical layer 2/3 IN population data', '02i', cmLimCxi, t, xLims, xTicks, vCx23i, Cx23iraster, 'full', width, ratio2, label, margin, disp(5), data)
    elseif data == 3
        rPlot('Cortical layer 4 PY population rastergram', '04', t, xLims, xTicks, Cx4raster, width, ratio, label, margin, disp(1), data)
        populationPlot('Cortical layer 4 PY population data', '04', cmLimCx, t, xLims, xTicks, vCx4, Cx4raster, 'grey', width, ratio, label, margin, disp(2), data)
        populationPlot('Cortical layer 4 PY population data', '04', cmLimCx, t, xLims, xTicks, vCx4, Cx4raster, 'hot', width, ratio, label, margin, disp(3), data)
        populationPlot('Cortical layer 4 PY population data', '04', cmLimCx, t, xLims, xTicks, vCx4, Cx4raster, 'cold', width, ratio, label, margin, disp(4), data)
        populationPlot('Cortical layer 4 PY population data', '04', cmLimCx, t, xLims, xTicks, vCx4, Cx4raster, 'full', width, ratio, label, margin, disp(5), data)
    elseif data == 4
        rPlot('Cortical layer 4 IN population rastergram', '04i', t, xLims, xTicks, Cx4iraster, width, ratio2, label, margin, disp(1), data)
        populationPlot('Cortical layer 4 IN population data', '04i', cmLimCxi, t, xLims, xTicks, vCx4i, Cx4iraster, 'grey', width, ratio2, label, margin, disp(2), data)
        populationPlot('Cortical layer 4 IN population data', '04i', cmLimCxi, t, xLims, xTicks, vCx4i, Cx4iraster, 'hot', width, ratio2, label, margin, disp(3), data)
        populationPlot('Cortical layer 4 IN population data', '04i', cmLimCxi, t, xLims, xTicks, vCx4i, Cx4iraster, 'cold', width, ratio2, label, margin, disp(4), data)
        populationPlot('Cortical layer 4 IN population data', '04i', cmLimCxi, t, xLims, xTicks, vCx4i, Cx4iraster, 'full', width, ratio2, label, margin, disp(5), data)
    elseif data == 5
        rPlot('Cortical layer 5 PY population rastergram', '05', t, xLims, xTicks, Cx5raster, width, ratio, label, margin, disp(1), data)
%         hold on
%         for i = 1:length(NDcells)
%             plot(0.250, 0.5+NDcells(i), '.r', 'MarkerSize', 10)
%         end
%         hold off
        populationPlot('Cortical layer 5 PY population data', '05', cmLimCx, t, xLims, xTicks, vCx5, Cx5raster, 'grey', width, ratio, label, margin, disp(2), data)
        populationPlot('Cortical layer 5 PY population data', '05', cmLimCx, t, xLims, xTicks, vCx5, Cx5raster, 'hot', width, ratio, label, margin, disp(3), data)
        populationPlot('Cortical layer 5 PY population data', '05', cmLimCx, t, xLims, xTicks, vCx5, Cx5raster, 'cold', width, ratio, label, margin, disp(4), data)
        populationPlot('Cortical layer 5 PY population data', '05', cmLimCx, t, xLims, xTicks, vCx5, Cx5raster, 'full', width, ratio, label, margin, disp(5), data)
    elseif data == 6
        rPlot('Cortical layer 5 IN population rastergram', '05i', t, xLims, xTicks, Cx5iraster, width, ratio2, label, margin, disp(1), data)
        populationPlot('Cortical layer 5 IN population data', '05i', cmLimCxi, t, xLims, xTicks, vCx5i, Cx5iraster, 'grey', width, ratio2, label, margin, disp(2), data)
        populationPlot('Cortical layer 5 IN population data', '05i', cmLimCxi, t, xLims, xTicks, vCx5i, Cx5iraster, 'hot', width, ratio2, label, margin, disp(3), data)
        populationPlot('Cortical layer 5 IN population data', '05i', cmLimCxi, t, xLims, xTicks, vCx5i, Cx5iraster, 'cold', width, ratio2, label, margin, disp(4), data)
        populationPlot('Cortical layer 5 IN population data', '05i', cmLimCxi, t, xLims, xTicks, vCx5i, Cx5iraster, 'full', width, ratio2, label, margin, disp(5), data)
    elseif data == 7
        rPlot('Cortical layer 6 PY population rastergram', '06', t, xLims, xTicks, Cx6raster, width, ratio, label, margin, disp(1), data)
        populationPlot('Cortical layer 6 PY population data', '06', cmLimCx, t, xLims, xTicks, vCx6, Cx6raster, 'grey', width, ratio, label, margin, disp(2), data)
        populationPlot('Cortical layer 6 PY population data', '06', cmLimCx, t, xLims, xTicks, vCx6, Cx6raster, 'hot', width, ratio, label, margin, disp(3), data)
        populationPlot('Cortical layer 6 PY population data', '06', cmLimCx, t, xLims, xTicks, vCx6, Cx6raster, 'cold', width, ratio, label, margin, disp(4), data)
        populationPlot('Cortical layer 6 PY population data', '06', cmLimCx, t, xLims, xTicks, vCx6, Cx6raster, 'full', width, ratio, label, margin, disp(5), data)
    elseif data == 8
        rPlot('Cortical layer 6 IN population rastergram', '06i', t, xLims, xTicks, Cx6iraster, width, ratio2, label, margin, disp(1), data)
        populationPlot('Cortical layer 6 IN population data', '06i', cmLimCxi, t, xLims, xTicks, vCx6i, Cx6iraster, 'grey', width, ratio2, label, margin, disp(2), data)
        populationPlot('Cortical layer 6 IN population data', '06i', cmLimCxi, t, xLims, xTicks, vCx6i, Cx6iraster, 'hot', width, ratio2, label, margin, disp(3), data)
        populationPlot('Cortical layer 6 IN population data', '06i', cmLimCxi, t, xLims, xTicks, vCx6i, Cx6iraster, 'cold', width, ratio2, label, margin, disp(4), data)
        populationPlot('Cortical layer 6 IN population data', '06i', cmLimCxi, t, xLims, xTicks, vCx6i, Cx6iraster, 'full', width, ratio2, label, margin, disp(5), data)
    elseif data == 9
        rPlot('Thalamic NRT FO population rastergram', '07_NRT_FO', t, xLims, xTicks, NRTraster, width, ratio2, label, margin, disp(1), data)
        populationPlot('Thalamic NRT FO population data', '07_NRT_FO', cmLimNRT, t, xLims, xTicks, vNRT, NRTraster, 'grey', width, ratio2, label, margin, disp(2), data)
        populationPlot('Thalamic NRT FO population data', '07_NRT_FO', cmLimNRT, t, xLims, xTicks, vNRT, NRTraster, 'hot', width, ratio2, label, margin, disp(3), data)
        populationPlot('Thalamic NRT FO population data', '07_NRT_FO', cmLimNRT, t, xLims, xTicks, vNRT, NRTraster, 'cold', width, ratio2, label, margin, disp(4), data)
        populationPlot('Thalamic NRT FO population data', '07_NRT_FO', cmLimNRT, t, xLims, xTicks, vNRT, NRTraster, 'full', width, ratio2, label, margin, disp(5), data)
    elseif data == 10
        rPlot('Thalamic NRT HO population rastergram', '08_NRT_HO', t, xLims, xTicks, NRT2raster, width, ratio2, label, margin, disp(1), data)
        populationPlot('Thalamic NRT HO population data', '08_NRT_HO', cmLimNRT, t, xLims, xTicks, vNRT2, NRT2raster, 'grey', width, ratio2, label, margin, disp(2), data)
        populationPlot('Thalamic NRT HO population data', '08_NRT_HO', cmLimNRT, t, xLims, xTicks, vNRT2, NRT2raster, 'hot', width, ratio2, label, margin, disp(3), data)
        populationPlot('Thalamic NRT HO population data', '08_NRT_HO', cmLimNRT, t, xLims, xTicks, vNRT2, NRT2raster, 'cold', width, ratio2, label, margin, disp(4), data)
        populationPlot('Thalamic NRT HO population data', '08_NRT_HO', cmLimNRT, t, xLims, xTicks, vNRT2, NRT2raster, 'full', width, ratio2, label, margin, disp(5), data)
    elseif data == 11
        rPlot('Thalamic TC FO population rastergram', '09_TC_FO', t, xLims, xTicks, TCraster, width, ratio, label, margin, disp(1), data)
        populationPlot('Thalamic TC FO population data', '09_TC_FO', cmLimTCFO, t, xLims, xTicks, vTC, TCraster, 'grey', width, ratio, label, margin, disp(2), data)
        populationPlot('Thalamic TC FO population data', '09_TC_FO', cmLimTCFO, t, xLims, xTicks, vTC, TCraster, 'hot', width, ratio, label, margin, disp(3), data)
        populationPlot('Thalamic TC FO population data', '09_TC_FO', cmLimTCFO, t, xLims, xTicks, vTC, TCraster, 'cold', width, ratio, label, margin, disp(4), data)
        populationPlot('Thalamic TC FO population data', '09_TC_FO', cmLimTCFO, t, xLims, xTicks, vTC, TCraster, 'full', width, ratio, label, margin, disp(5), data)
    elseif data == 12
        rPlot('Thalamic TC HO population rastergram', '10_TC_HO', t, xLims, xTicks, TC2raster, width, ratio, label, margin, disp(1), data)
        populationPlot('Thalamic TC HO population data', '10_TC_HO', cmLimTCHO, t, xLims, xTicks, vTC2, TC2raster, 'grey', width, ratio, label, margin, disp(2), data)
        populationPlot('Thalamic TC HO population data', '10_TC_HO', cmLimTCHO, t, xLims, xTicks, vTC2, TC2raster, 'hot', width, ratio, label, margin, disp(3), data)
        populationPlot('Thalamic TC HO population data', '10_TC_HO', cmLimTCHO, t, xLims, xTicks, vTC2, TC2raster, 'cold', width, ratio, label, margin, disp(4), data)
        populationPlot('Thalamic TC HO population data', '10_TC_HO', cmLimTCHO, t, xLims, xTicks, vTC2, TC2raster, 'full', width, ratio, label, margin, disp(5), data)
    end
end



function populationPlot(name, nameShort, cmLim, t, xLims, xTicks, vMat, rMat, type, width, ratio, label, margin, disp, data)
if disp
    f = figProperties(name, 'normalized', [0, .005, .97, .90], 'w', 'on');
    cLim = cmLim;
    populationGraph({}, {}, t, xLims, xTicks, vMat, cLim, type);
%     if data == 1
%         hold on
%         plot([184.47575 184.47575], [0 size(rMat,1)], 'r--', 'Linewidth', 4) % 0.08175
%         hold off
%     elseif data == 2
%         hold on
%         plot([184.51125 184.51125], [0 size(rMat,1)], 'r--', 'Linewidth', 4) % 0.11725
%         hold off
%     elseif data == 3
%         hold on
%         plot([184.49825 184.49825], [0 size(rMat,1)], 'r--', 'Linewidth', 4) % 0.10425
%         hold off
%     elseif data == 4
%         hold on
%         plot([184.504 184.504], [0 size(rMat,1)], 'r--', 'Linewidth', 4) % 0.11
%         hold off
%     elseif data == 5
%         hold on
%         plot([184.43325 184.43325], [0 size(rMat,1)], 'r--', 'Linewidth', 4) % 0.03925
%         hold off
%     elseif data == 6
%         hold on
%         plot([184.469 184.469], [0 size(rMat,1)], 'r--', 'Linewidth', 4) % 0.075
%         hold off
%     elseif data == 7
%         hold on
%         plot([184.4675 184.4675], [0 size(rMat,1)], 'r--', 'Linewidth', 4) % 0.0735
%         hold off
%     elseif data == 8
%         hold on
%         plot([184.47775 184.47775], [0 size(rMat,1)], 'r--', 'Linewidth', 4) % 0.08375
%         hold off
%     elseif data == 9
%         hold on
%         plot([184.45725 184.45725], [0 size(rMat,1)], 'r--', 'Linewidth', 4) % 0.06325
%         hold off
%     elseif data == 10
%         hold on
%         %plot([184.42625 184.42625], [0 size(rMat,1)], 'r--', 'Linewidth', 4)
%         plot([184.45 184.45], [0 size(rMat,1)], 'r--', 'Linewidth', 4) % 0.056
%         hold off
%     elseif data == 11
%         hold on
%         plot([184.49075 184.49075], [0 size(rMat,1)], 'r--', 'Linewidth', 4) % 0.09675
%         hold off
%     elseif data == 12
%         hold on
%         plot([184.394 184.394], [0 size(rMat,1)], 'r--', 'Linewidth', 4) % 0
%         hold off
%     end
    height = width/ratio;
    paperSize = resizeFig(f, gca, width, height, label, margin, 0);
%     exportFig(gcf, [nameShort '_' type '.tif'],'-dtiffnocompression','-r1200', paperSize);
    print(gcf, [nameShort '_' type '.png'], '-dpng', '-r300');
    close(f)
end

function rPlot(name, nameShort, t, xLims, xTicks, rMat, width, ratio, label, margin, disp, data)
if disp
    f = figProperties(name, 'normalized', [0, .005, .97, .90], 'w', 'on');
    rasterPlot({}, {}, t, xLims, xTicks, rMat);
%     if data == 1
%         onset(t, xLims, [1 size(rMat,1)], rMat, 2);
%     elseif data == 2
%         onset(t, xLims, [1 size(rMat,1)], rMat, 2);
%     elseif data == 3
%         onset(t, xLims, [1 size(rMat,1)], rMat, 2);
%     elseif data == 4
%         onset(t, xLims, [1 size(rMat,1)], rMat, 2);
%     elseif data == 5
%         onset(t, xLims, [1 size(rMat,1)], rMat, 2);
%     elseif data == 6
%         onset(t, xLims, [1 size(rMat,1)], rMat, 2);
%     elseif data == 7
%         onset(t, xLims, [1 size(rMat,1)], rMat, 2);
%     elseif data == 8
%         onset(t, xLims, [1 size(rMat,1)], rMat, 2);
%     elseif data == 9
%         hold on
%         plot([184.4572 184.4572], [0 size(rMat,1)], 'r--', 'Linewidth', 4)
%         hold off
%     elseif data == 10
%         hold on
%         %plot([184.42625 184.42625], [0 size(rMat,1)], 'r--', 'Linewidth', 4)
%         plot([184.45 184.45], [0 size(rMat,1)], 'r--', 'Linewidth', 4)
%         hold off
%     elseif data == 11
%         hold on
%         plot([184.49075 184.49075], [0 size(rMat,1)], 'r--', 'Linewidth', 4)
%         hold off
%     elseif data == 12
%         hold on
%         plot([184.394 184.394], [0 size(rMat,1)], 'r--', 'Linewidth', 4)
%         hold off
%     end
    height = width/ratio;
    paperSize = resizeFig(f, gca, width, height, label, margin, 0);
    hold on
        plot([xLims(1) xLims(1)]+0.002,[1 size(rMat,1)],'k','LineWidth',2)
        plot([xLims(1) xLims(2)],[size(rMat,1) size(rMat,1)],'k','LineWidth',2)
        plot([xLims(2) xLims(2)],[size(rMat,1) 1],'k','LineWidth',2)
        plot([xLims(2) xLims(1)],[1 1],'k','LineWidth',2)
    hold off
%     exportFig(gcf, [nameShort '_rastergram.tif'],'-dtiffnocompression','-r1200', paperSize);
    print(gcf, [nameShort '_rastergram.png'], '-dpng', '-r300');
    close(f)
end
