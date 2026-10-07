% The script file plots the membrane potential population data of thalamic cells.

clc
close all
clear all %#ok<CLALL>
format longG
AreaCx3(1) = area(5.644, 5.644);
AreaCx3(2) = area(5.644, 160*5.644);
AreaTC = area(60, 90);
AreaNRT = area(42, 63);

list = dir('*dat');
iList = 1:600;
cellTypes = cell(length(iList),1);
dt = .25;
xRange = [49000 300000];
iRange = xRange./dt+1;
iRange = iRange(1):iRange(end);
full = 0;
for i = iList
    i %#ok<NOPTS>
    fileName = list(i).name;
    if i <= 600
        [~, data, cellTypes{i}] = loadFile(fileName, AreaCx3, 'Cx3');
    elseif i <= 700
        [~, data, cellTypes{i}] = loadFile(fileName, AreaNRT, 'NRT');
    else
        [~, data, cellTypes{i}] = loadFile(fileName, AreaTC, 'TC');
    end
    
    % Resample:
    if i == iList(1)
        t = data.t(1):dt:data.t(end);
        if ~full
            t = t(iRange);
            data.t = data.t(iRange);
            data.v = data.v(iRange);
        end
        vTC = zeros(100, length(t));
        vNRT = zeros(50, length(t));
        vTC2 = vTC;
        vNRT2 = vNRT;
        vCx23 = vTC;
        vCx23i = zeros(50, length(t));
        vCx4 = vTC;
        Cx4raster = vTC;
        vCx4i = vCx23i;
        Cx4iraster = vCx23i;
        vCx5 = vTC;
        Cx5raster = vTC;
        vCx5i = vCx23i;
        Cx5iraster = vCx23i;
        vCx6 = vTC;
        Cx6raster = vTC;
        vCx6i = vCx23i;
        Cx6iraster = vCx23i;
    end
    [tunique, iunique] = unique(data.t);
    if i >= 1 && i <= 100
        vCx23(i,:) = interp1(tunique,data.v(iunique),t);
    elseif i >= 101 && i <= 150
        vCx23i(i-100,:) = interp1(tunique,data.v(iunique),t);
    elseif i >= 151 && i <= 250
        vCx4(i-150,:) = interp1(tunique,data.v(iunique),t);
    elseif i >= 251 && i <= 300
        vCx4i(i-250,:) = interp1(tunique,data.v(iunique),t);
    elseif i >= 301 && i <= 400
        vCx5(i-300,:) = interp1(tunique,data.v(iunique),t);
    elseif i >= 401 && i <= 450
        vCx5i(i-400,:) = interp1(tunique,data.v(iunique),t);
    elseif i >= 451 && i <= 550
        vCx6(i-450,:) = interp1(tunique,data.v(iunique),t);
    elseif i >= 551 && i <= 600
        vCx6i(i-550,:) = interp1(tunique,data.v(iunique),t);
    elseif i >= 601 && i <= 650
        vNRT(i-600,:) = interp1(tunique,data.v(iunique),t);
    elseif i >= 651 && i <= 700
        vNRT2(i-650,:) = interp1(tunique,data.v(iunique),t);
    elseif i >= 701 && i <= 800
        vTC(i-700,:) = interp1(tunique,data.v(iunique),t);
    elseif i >= 801 && i <= 900
        vTC2(i-800,:) = interp1(tunique,data.v(iunique),t);
    end
end

% pad = 700;
% pCx23 = layerIter(vCx23, pad, dt);
% pCx23i = layerIter(vCx23i, pad, dt);
% pCx4 = layerIter(vCx4, pad, dt);
% pCx4i = layerIter(vCx4i, pad, dt);
% pCx5 = layerIter(vCx5, pad, dt);
% pCx5i = layerIter(vCx5i, pad, dt);
% pCx6 = layerIter(vCx6, pad, dt);
% pCx6i = layerIter(vCx6i, pad, dt);
% peaks = [pCx23; pCx23i; pCx4; pCx4i; pCx5; pCx5i; pCx6; pCx6i];
% 
% crop = 5000/dt;
% iStart = crop;
% delayMat = [];
% tDelayMat = [];
% tStart = [];
% delayVec = NaN(size(peaks,1),1);
% tDelayVec = NaN(size(peaks,1),1);
% up = 860;
% for i = crop:size(peaks,2)
%     newUp = 0;
%     jStart = [];
%     for j = 1:size(peaks,1)
%         if iStart == crop || (iStart > 0 && i-iStart > up/dt)
%             if ((j == 1 || j == 101 || j == 151 || j == 251 || j == 301 || j == 401 || j == 451 || j == 551) && peaks(j,i) == 1 && peaks(j+1,i) == 0)...
%                     || ((j == 100 || j == 150 || j == 250 || j == 300 || j == 400 || j == 450 || j == 550 || j == 600) && peaks(j,i) == 1 && peaks(j-1,i) == 0)...
%                     || ((j > 1 && j < 600) && peaks(j,i) == 1 && peaks(j-1,i) == 0 && peaks(j+1,i) == 0)
%                 newUp = 1;
%                 delayVec(j) = 0;
%                 tDelayVec(j) = i*dt;
%                 iStart = i;
%                 jStart = [jStart j]; %#ok<*AGROW>
%                 if length(jStart) == 1
%                     tStart = [tStart i*dt];
%                 end
%             end
%         elseif ~newUp
%             if peaks(j,i) == 1 && isnan(delayVec(j)) && i-iStart <= (up-0)/dt
%                 delayVec(j) = (i-iStart)*dt;
%                 tDelayVec(j) = i*dt;
%             end
%             if i-iStart == (up-0)/dt && j == size(peaks,1)
%                 delayMat = [delayMat delayVec];
%                 tDelayMat = [tDelayMat tDelayVec];
%                 delayVec = NaN(size(peaks,1),1);
%                 tDelayVec = NaN(size(peaks,1),1);
%             end
%         end
%     end
%     if newUp
%         for j = 1:size(peaks,1)
%             if sum(j == jStart)
%                 continue
%             end
%             jPeaks = peaks(j,i:end);
%             for k = 1:length(jPeaks)
%                 if jPeaks(k) == 0
%                     peaks(j,1:i+k-1) = 0;
%                     break
%                 end
%             end
%         end
%     end
% end

pad = 0;
pCx23 = layerIter(vCx23, pad, dt);
pCx23i = layerIter(vCx23i, pad, dt);
pCx4 = layerIter(vCx4, pad, dt);
pCx4i = layerIter(vCx4i, pad, dt);
pCx5 = layerIter(vCx5, pad, dt);
pCx5i = layerIter(vCx5i, pad, dt);
pCx6 = layerIter(vCx6, pad, dt);
pCx6i = layerIter(vCx6i, pad, dt);
pNRT = layerIter(vNRT, pad, dt);
pNRT2 = layerIter(vNRT2, pad, dt);
pTC = layerIter(vTC, pad, dt);
pTC2 = layerIter(vTC2, pad, dt);
peaks = [pCx23; pCx23i; pCx4; pCx4i; pCx5; pCx5i; pCx6; pCx6i; pNRT; pNRT2; pTC; pTC2];
clear pCx23 pCx23i pCx4 pCx4i pCx5 pCx5i pCx6 pCx6i pNRT pNRT2 pTC pTC2

startCycle = dt+([[50;49.5] [54.5;54.5] [57;56.5] [57.5;57.5] [59;58.5] [59.5;59.2] [61.75;61.75] [63;62.5] [64;64] [65;65] [66.5;66] [68;68] [70.5;70] [71.5;71] [72.5;71.8] [72.8;72.8] [74.3;73.5] [75;74.7] [77;77] [79;78.5]...
    [80;79.8] [81.5;81.5] [83;82] [83.5;83.5] [86;85.2] [86.5;86.1] [87.8;87.2] [88.75;88.25] [90.3;90.3] [92.2;91.5] [93;93] [94.65;94] [97.5;97.5] [98.8;98.8] [101.25;100.5] [101.75;101.75] [103.4;103.4] [104.5;104.5]...
    [107.25;106.75] [110;109.7] [111.5;111] [112.25;112.25] [113.3;113.3] [115;114.7] [117.5;116.75] [119.65;119.5] [122;121.5] [122.9;122.5] [124;123.75] [125;124.75] [126;126] [127;126.8] [128;127.8] [130.5;130.5]...
    [131.8;131.25] [134.6;134] [135.15;135.15] [136.5;135.75] [137.5;137.5] [139.25;138.6] [139.7;139.7] [140.75;140.5] [143.25;143.25] [146.3;146.3] [150.8;150.5] [152.65;152.65] [154.25;153.6] [157.1;156.6] [159.4;159.4]...
    [160.3;160.3] [161.9;161.9] [164;163.25] [164.6;164.3] [166;165.5] [170.7;170.7] [172.25;172.25] [173.8;173.3] [175.2;175.2] [177.8;177.8] [181;180.75] [182.4;182.4] [185.75;185.25] [187.7;187.25] [188.5;188.5]...
    [189.8;189.5] [190.8;190.3] [192;192] [193.5;193] [194.3;194] [196.2;196.2] [197.8;197.8] [198.9;198.9] [201;200.5] [201.8;201.4] [203.3;203.3] [204.8;204.2] [206.5;205.75] [207;207] [208.2;207.7] [209.3;209.3]...
    [211.5;210.25] [212.25;211.75] [213.4;213.4] [217.3;217] [219.1;218.25] [220;219.5] [220.75;220.75] [222.5;222.5] [224.5;224] [226.2;225.7] [227.3;226.8] [228.8;228.2] [230;230] [231;231] [232.1;232.1] [233.5;233.5]...
    [235.8;235.8] [238;237] [238.7;238.2] [240.5;240] [241.5;241] [242.5;241.8] [243.5;243.15] [247.2;247.2] [248.9;248.75] [250.5;250] [251.2;251.2] [253;252.5] [254;253.75] [256.25;255.75] [258.2;257.5] [260.3;259.7]...
    [263.5;263.5] [265;264.75] [266;266.25] [267.8;267.5] [268.75;268.5] [270.8;270.5] [271.75;271.25] [272.75;272.75] [274;274] [276;275.5] [277.4;276.75] [278.7;278.3] [281.2;281.2] [282.25;282.25] [283.5;283.25]...
    [284.75;284.25] [285.5;285.5] [287.2;287.2] [288.5;289] [290.25;290] [291.25;290.75] [292.8;292.2] [293.7;293.7] [295.25;295.25] [299.1;298.5] [299.75;299.25]])*1000-xRange(1);
endCycle = ([startCycle(:,2:end) dt+[300000;300000]-xRange(1)]);
iOnsetMat = NaN(size(peaks,1),size(startCycle,2));
tOnsetMat = iOnsetMat;
delayMat = iOnsetMat;
tStart = zeros(1,size(startCycle,2));
for i = 1:size(startCycle,2)
    startStepPY = ((startCycle(2,i)-startCycle(1,i))/100)/dt;
    iStartPY = zeros(100,1);
    for j = 1:length(iStartPY)
        iStartPY(j) = round(startCycle(1,i)/dt+startStepPY*(j-1));
    end
    startStepIN = ((startCycle(2,i)-startCycle(1,i))/50)/dt;
    iStartIN = zeros(50,1);
    for j = 1:length(iStartIN)
        iStartIN(j) = round(startCycle(1,i)/dt+startStepIN*(j-1));
    end
    iStart = [iStartPY; iStartIN];
    iStart = [iStart; iStart; iStart; iStart; iStartIN; iStartIN; iStartPY; iStartPY]; %#ok<*AGROW>
    endStepPY = ((endCycle(2,i)-endCycle(1,i))/100)/dt;
    iEndPY = zeros(100,1);
    for j = 1:length(iEndPY)
        iEndPY(j) = round(endCycle(1,i)/dt+endStepPY*(j-1));
    end
    endStepIN = ((endCycle(2,i)-endCycle(1,i))/50)/dt;
    iEndIN = zeros(50,1);
    for j = 1:length(iEndIN)
        iEndIN(j) = round(endCycle(1,i)/dt+endStepIN*(j-1));
    end
    iEnd = [iEndPY; iEndIN];
    iEnd = [iEnd; iEnd; iEnd; iEnd; iEndIN; iEndIN; iEndPY; iEndPY];
    peakVec = NaN(size(peaks,1),1);
    dbstop if warning
    for j = iList
        iPeak = iStart(j)+find(peaks(j,iStart(j):iEnd(j)),1)-1;
        if isempty(iPeak)
            iOnsetMat(j,i) = NaN;
            tOnsetMat(j,i) = NaN;
        else
            iOnsetMat(j,i) = iPeak;
            tOnsetMat(j,i) = iPeak*dt;
        end
    end
    onset = min(tOnsetMat(:,i));
    delayMat(:,i) = tOnsetMat(:,i)-onset;
    tStart(i) = onset;
end

meanDelays = mean(delayMat,2,'omitnan');
delayL23 = mean(meanDelays(1:150),'omitnan');
delayL4 = mean(meanDelays(151:300),'omitnan');
delayL5 = mean(meanDelays(301:450),'omitnan');
delayL6 = mean(meanDelays(451:600),'omitnan');
delayL23PY = mean(meanDelays(1:100),'omitnan');
delayL23IN = mean(meanDelays(101:150),'omitnan');
delayL4PY = mean(meanDelays(151:250),'omitnan');
delayL4IN = mean(meanDelays(251:300),'omitnan');
delayL5PY = mean(meanDelays(301:400),'omitnan');
delayL5IN = mean(meanDelays(401:450),'omitnan');
delayL6PY = mean(meanDelays(451:550),'omitnan');
delayL6IN = mean(meanDelays(551:600),'omitnan');
delayNRT = mean(meanDelays(601:650),'omitnan');
delayNRT2 = mean(meanDelays(651:700),'omitnan');
delayTC = mean(meanDelays(701:800),'omitnan');
delayTC2 = mean(meanDelays(801:900),'omitnan');
delayL23RS = [];
delayL23EF = [];
delayL23IB = [];
delayL4RS = [];
delayL4IB = [];
delayL5RS = [];
delayL5EF = [];
delayL5IB = [];
delayL5RIB = [];
delayL5SIB = [];
delayL5ND = [];
delayL6RS = [];
delayL6EF = [];
delayL6IB = [];
delayL6SIB = [];
for i = iList
    if i >= 1 && i <= 100
        if strcmp('RS', cellTypes{i})
            delayL23RS = [delayL23RS; meanDelays(i)];
        elseif strcmp('EF', cellTypes{i})
            delayL23EF = [delayL23EF; meanDelays(i)];
        elseif strcmp('IB', cellTypes{i})
            delayL23IB = [delayL23IB; meanDelays(i)];
        end
    elseif i >= 151 && i <= 250
        if strcmp('RS', cellTypes{i})
            delayL4RS = [delayL4RS; meanDelays(i)];
        elseif strcmp('IB', cellTypes{i})
            delayL4IB = [delayL4IB; meanDelays(i)];
        end
    elseif i >= 301 && i <= 400
        if strcmp('RS', cellTypes{i})
            delayL5RS = [delayL5RS; meanDelays(i)];
        elseif strcmp('EF', cellTypes{i})
            delayL5EF = [delayL5EF; meanDelays(i)];
        elseif strcmp('IB', cellTypes{i})
            delayL5IB = [delayL5IB; meanDelays(i)];
        elseif strcmp('RIB', cellTypes{i})
            delayL5RIB = [delayL5RIB; meanDelays(i)];
        elseif strcmp('SIB', cellTypes{i})
            delayL5SIB = [delayL5SIB; meanDelays(i)];
        elseif strcmp('ND', cellTypes{i})
            delayL5ND = [delayL5ND; meanDelays(i)];
        end
    elseif i >= 451 && i <= 550
        if strcmp('RS', cellTypes{i})
            delayL6RS = [delayL6RS; meanDelays(i)];
        elseif strcmp('EF', cellTypes{i})
            delayL6EF = [delayL6EF; meanDelays(i)];
        elseif strcmp('IB', cellTypes{i})
            delayL6IB = [delayL6IB; meanDelays(i)];
        elseif strcmp('SIB', cellTypes{i})
            delayL6SIB = [delayL6SIB; meanDelays(i)];
        end
    end
end
delayL23RS = mean(delayL23RS,'omitnan');
delayL23EF = mean(delayL23EF,'omitnan');
delayL23IB = mean(delayL23IB,'omitnan');
delayL4RS = mean(delayL4RS,'omitnan');
delayL4IB = mean(delayL4IB,'omitnan');
delayL5RS = mean(delayL5RS,'omitnan');
delayL5EF = mean(delayL5EF,'omitnan');
delayL5IB = mean(delayL5IB,'omitnan');
delayL5RIB = mean(delayL5RIB,'omitnan');
delayL5SIB = mean(delayL5SIB,'omitnan');
delayL5ND = mean(delayL5ND,'omitnan');
delayL6RS = mean(delayL6RS,'omitnan');
delayL6EF = mean(delayL6EF,'omitnan');
delayL6IB = mean(delayL6IB,'omitnan');
delayL6SIB = mean(delayL6SIB,'omitnan');

f1 = figProperties('Average Up-state onset delays for different cortical cell types', 'normalized', [0, .005, .97, .90], 'w', 'on');
bar(1:6, [delayL5ND delayL5EF delayL5RS delayL5IB delayL5RIB delayL5IN], 'g');
hold on
bar((7:10)+1, [delayL6EF delayL6IB delayL6RS delayL6IN], 'b');
bar((11:14)+2, [delayL23EF delayL23RS delayL23IN delayL23IB], 'm');
bar((15:17)+3, [delayL4RS delayL4IN delayL4IB], 'r');
bar(19+5, delayL5, 'g');
%bar(19+5, (delayL5*150-10*delayL5ND)/140, 'g');
%bar(19+5, (delayL5*150-10*delayL5ND+150*delayL6)/290, 'g');
bar(20+5, delayL6, 'b');
bar(21+5, (delayL5+delayL6)/2, 'FaceColor',[95,158,160]/255);
bar(22+5, delayL23, 'm');
bar(23+5, delayL4, 'r');
%bar(24+5, delayNRT, 'c');
%bar(25+5, delayNRT2, 'y');
%bar(26+5, delayTC, 'b');
%bar(27+5, delayTC2, 'b');
hold off

ax1= axesProperties({}, 1, 'normal', 'off', 'w', 'Calibri', 30, 4/3, 3, [0.01 0], 'out', 'on', 'k', {}, [], [1:6 (7:10)+1 (11:14)+2 (15:17)+3 19+5 20+5 21+5 22+5 23+5 24+5 25+5 26+5], 'on', 'k', {'Latency (ms)'}, [140 400], [140 270 400]);
ax1.XTickLabel = {'L5 ND','L5 IB','L5 EF','L5 RS','L5 RIB','L5 IN','L6 EF','L6 IB','L6 RS','L6 IN','L2/3 EF','L2/3 RS','L2/3 IN','L2/3 IB','L4 RS','L4 IN','L4 IB','L5','L6','L5/6','L2/3','L4','NRT FO','NRT HO','TC FO','TC HO'};
ax1.XTickLabelRotation = 90;
% hText = text([1:6 (7:9)+1 (10:13)+2 (14:16)+3 18+5 19+5 20+5 21+5],...
%     [delayL5ND delayL5IB delayL5EF delayL5RS delayL5IN delayL5RIB delayL6EF delayL6RS delayL6IN delayL23EF delayL23RS delayL23IN delayL23IB delayL4RS delayL4IN delayL4IB delayL5 delayL6 delayL23 delayL4],...
%     {num2str(delayL5ND), num2str(delayL5IB), num2str(delayL5EF), num2str(delayL5RS), num2str(delayL5IN), num2str(delayL5RIB), num2str(delayL6EF), num2str(delayL6RS), num2str(delayL6IN), num2str(delayL23EF)...
%     num2str(delayL23RS), num2str(delayL23IN), num2str(delayL23IB), num2str(delayL4RS), num2str(delayL4IN), num2str(delayL4IB), num2str(delayL5), num2str(delayL6), num2str(delayL23), num2str(delayL4)});
% set(hText, 'VerticalAlignment','bottom', 'HorizontalAlignment','center', 'FontSize',30, 'Color','k');
paperSize = resizeFig(f1, ax1, 3*15, 7.5, [3.65 3.95], [-2.4 0.3], 0);
% paperSize = resizeFig(f1, ax1, 3*15, 7.5, [3.65 0.6], [-2.4 0.3], 0);
exportFig(f1, ['onset_delays' '.tif'],'-dtiffnocompression','-r300', paperSize);
