% The script file plots the membrane potential traces of single thalamic cells.

clc
close all
clear all %#ok<CLALL>
format longG
AreaCx3(1) = area(5.644, 5.644);
AreaCx3(2) = area(5.644, 160*5.644);
AreaTC = area(60, 90);
AreaNRT = area(42, 63);

stringent = 0;
list = dir('*dat');
iList = 1:600;
%iList = 315:5:385;
cellTypes = cell(length(iList),1);
meanUpDurations = zeros(size(iList));
meanDownDurations = meanUpDurations;
for i = iList
    i %#ok<*NOPTS>
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
        dt = 0.1;
        t = data.t(1):dt:data.t(end);
        vTC = zeros(100, length(t));
        vNRT = zeros(50, length(t));
        vCx23 = vTC;
        vCx23i = zeros(50, length(t));
        vCx4 = vTC;
        vCx4i = vCx23i;
        vCx5 = vTC;
        vCx5i = vCx23i;
        vCx6 = vTC;
        vCx6i = vCx23i;
    end
%    if strcmp('RS', cellTypes{i})
%         for j = 2:length(data.t)
%             if data.t(j) <= data.t(j-1)
%                 data.t(j) = data.t(j-1) + 1e-9;
%             end
%         end
        [tunique, iunique] = unique(data.t);
        v = interp1(tunique,data.v(iunique),t);
        if i >= 1 && i <= 100
            vCx23(i,:) = v;
        elseif i >= 101 && i <= 150
            vCx23i(i-100,:) = v;
        elseif i >= 151 && i <= 250
            vCx4(i-150,:) = v;
        elseif i >= 251 && i <= 300
            vCx4i(i-250,:) = v;
        elseif i >= 301 && i <= 400
            vCx5(i-300,:) = v;
        elseif i >= 401 && i <= 450
            vCx5i(i-400,:) = v;
        elseif i >= 451 && i <= 550
            vCx6(i-450,:) = v;
        elseif i >= 551 && i <= 600
            vCx6i(i-550,:) = v;
        elseif i >= 601 && i <= 650
            vNRT(i-600,:) = v;
        elseif i >= 701 && i <= 800
            vTC(i-700,:) = v;
        end
        [meanUpDurations(i), meanDownDurations(i)] = durations(0, 0, 0, .01, t, v, dt, cellTypes{i}, fileName, 5000);
        %[meanUpDurations, meanDownDurations] = durations(0, 1, 1, .01, t, v, dt, cellTypes{i}, fileName, 5000)
        %return
%    end
end

meanUp = mean(meanUpDurations)
meanDown = mean(meanDownDurations)
meanUpL23 = mean(meanUpDurations(1:150));
meanDownL23 = mean(meanDownDurations(1:150));
meanUpL4 = mean(meanUpDurations(151:300));
meanDownL4 = mean(meanDownDurations(151:300));
meanUpL5 = mean(meanUpDurations(301:450));
meanDownL5 = mean(meanDownDurations(301:450));
meanUpL6 = mean(meanUpDurations(451:600));
meanDownL6 = mean(meanDownDurations(451:600));
meanUpL23PY = mean(meanUpDurations(1:100));
meanDownL23PY = mean(meanDownDurations(1:100));
meanUpL23IN = mean(meanUpDurations(101:150));
meanDownL23IN = mean(meanDownDurations(101:150));
meanUpL4PY = mean(meanUpDurations(151:250));
meanDownL4PY = mean(meanDownDurations(151:250));
meanUpL4IN = mean(meanUpDurations(251:300));
meanDownL4IN = mean(meanDownDurations(251:300));
meanUpL5PY = mean(meanUpDurations(301:400));
meanDownL5PY = mean(meanDownDurations(301:400));
meanUpL5IN = mean(meanUpDurations(401:450));
meanDownL5IN = mean(meanDownDurations(401:450));
meanUpL6PY = mean(meanUpDurations(451:550));
meanDownL6PY = mean(meanDownDurations(451:550));
meanUpL6IN = mean(meanUpDurations(551:600));
meanDownL6IN = mean(meanDownDurations(551:600));
MeanUpPY = mean([meanUpL23PY meanUpL4PY meanUpL5PY meanUpL6PY])
MeanUpIN = mean([meanUpL23IN meanUpL4IN meanUpL5IN meanUpL6IN])
MeanDownPY = mean([meanDownL23PY meanDownL4PY meanDownL5PY meanDownL6PY])
MeanDownIN = mean([meanDownL23IN meanDownL4IN meanDownL5IN meanDownL6IN])

meanUpL23RS = [];
meanUpL23EF = [];
meanUpL23IB = [];
meanUpL4RS = [];
meanUpL4IB = [];
meanUpL5RS = [];
meanUpL5EF = [];
meanUpL5IB = [];
meanUpL5RIB = [];
meanUpL5SIB = [];
meanUpL5ND = [];
meanUpL6RS = [];
meanUpL6EF = [];
meanUpL6IB = [];
meanUpRS = [];
meanUpEF = [];
meanUpIB = [];
meanUpRIB = [];
meanUpSIB = [];
meanUpND = [];
for i = iList
    if i >= 1 && i <= 100
        if strcmp('RS', cellTypes{i})
            meanUpL23RS = [meanUpL23RS; meanUpDurations(i)]; %#ok<*AGROW>
            meanUpRS = [meanUpRS; meanUpDurations(i)];
        elseif strcmp('EF', cellTypes{i})
            meanUpL23EF = [meanUpL23EF; meanUpDurations(i)];
            meanUpEF = [meanUpEF; meanUpDurations(i)];
        elseif strcmp('IB', cellTypes{i})
            meanUpL23IB = [meanUpL23IB; meanUpDurations(i)];
            meanUpIB = [meanUpIB; meanUpDurations(i)];
        end
    elseif i >= 151 && i <= 250
        if strcmp('RS', cellTypes{i})
            meanUpL4RS = [meanUpL4RS; meanUpDurations(i)];
            meanUpRS = [meanUpRS; meanUpDurations(i)];
        elseif strcmp('IB', cellTypes{i})
            meanUpL4IB = [meanUpL4IB; meanUpDurations(i)];
            meanUpIB = [meanUpIB; meanUpDurations(i)];
        end
    elseif i >= 301 && i <= 400
        if strcmp('RS', cellTypes{i})
            meanUpL5RS = [meanUpL5RS; meanUpDurations(i)];
            meanUpRS = [meanUpRS; meanUpDurations(i)];
        elseif strcmp('EF', cellTypes{i})
            meanUpL5EF = [meanUpL5EF; meanUpDurations(i)];
            meanUpEF = [meanUpEF; meanUpDurations(i)];
        elseif strcmp('IB', cellTypes{i})
            meanUpL5IB = [meanUpL5IB; meanUpDurations(i)];
            meanUpIB = [meanUpIB; meanUpDurations(i)];
        elseif strcmp('RIB', cellTypes{i})
            meanUpL5RIB = [meanUpL5RIB; meanUpDurations(i)];
            meanUpRIB = [meanUpRIB; meanUpDurations(i)];
        elseif strcmp('SIB', cellTypes{i})
            meanUpL5SIB = [meanUpL5SIB; meanUpDurations(i)];
            meanUpSIB = [meanUpSIB; meanUpDurations(i)];
        elseif strcmp('ND', cellTypes{i})
            meanUpL5ND = [meanUpL5ND; meanUpDurations(i)];
            meanUpND = [meanUpND; meanUpDurations(i)];
        end
    elseif i >= 451 && i <= 550
        if strcmp('RS', cellTypes{i})
            meanUpL6RS = [meanUpL6RS; meanUpDurations(i)];
            meanUpRS = [meanUpRS; meanUpDurations(i)];
        elseif strcmp('EF', cellTypes{i})
            meanUpL6EF = [meanUpL6EF; meanUpDurations(i)];
            meanUpEF = [meanUpEF; meanUpDurations(i)];
        elseif strcmp('IB', cellTypes{i})
            meanUpL6IB = [meanUpL6IB; meanUpDurations(i)];
            meanUpIB = [meanUpIB; meanUpDurations(i)];
        end
    end
end
meanUpL23RS = mean(meanUpL23RS);
meanUpL23EF = mean(meanUpL23EF);
meanUpL23IB = mean(meanUpL23IB);
meanUpL4RS = mean(meanUpL4RS);
meanUpL4IB = mean(meanUpL4IB);
meanUpL5RS = mean(meanUpL5RS);
meanUpL5EF = mean(meanUpL5EF);
meanUpL5IB = mean(meanUpL5IB);
meanUpL5RIB = mean(meanUpL5RIB);
meanUpL5SIB = mean(meanUpL5SIB);
meanUpL5ND = mean(meanUpL5ND);
meanUpL6RS = mean(meanUpL6RS);
meanUpL6EF = mean(meanUpL6EF);
meanUpL6IB = mean(meanUpL6IB);
meanUpRS = mean(meanUpRS)
meanUpEF = mean(meanUpEF)
meanUpIB = mean(meanUpIB)
meanUpRIB = mean(meanUpRIB)
meanUpSIB = mean(meanUpSIB)
meanUpND = mean(meanUpND)

meanDownL23RS = [];
meanDownL23EF = [];
meanDownL23IB = [];
meanDownL4RS = [];
meanDownL4IB = [];
meanDownL5RS = [];
meanDownL5EF = [];
meanDownL5IB = [];
meanDownL5RIB = [];
meanDownL5SIB = [];
meanDownL5ND = [];
meanDownL6RS = [];
meanDownL6EF = [];
meanDownL6IB = [];
meanDownRS = [];
meanDownEF = [];
meanDownIB = [];
meanDownRIB = [];
meanDownSIB = [];
meanDownND = [];
for i = iList
    if i >= 1 && i <= 100
        if strcmp('RS', cellTypes{i})
            meanDownL23RS = [meanDownL23RS; meanDownDurations(i)];
            meanDownRS = [meanDownRS; meanDownDurations(i)];
        elseif strcmp('EF', cellTypes{i})
            meanDownL23EF = [meanDownL23EF; meanDownDurations(i)];
            meanDownEF = [meanDownEF; meanDownDurations(i)];
        elseif strcmp('IB', cellTypes{i})
            meanDownL23IB = [meanDownL23IB; meanDownDurations(i)];
            meanDownIB = [meanDownIB; meanDownDurations(i)];
        end
    elseif i >= 151 && i <= 250
        if strcmp('RS', cellTypes{i})
            meanDownL4RS = [meanDownL4RS; meanDownDurations(i)];
            meanDownRS = [meanDownRS; meanDownDurations(i)];
        elseif strcmp('IB', cellTypes{i})
            meanDownL4IB = [meanDownL4IB; meanDownDurations(i)];
            meanDownIB = [meanDownIB; meanDownDurations(i)];
        end
    elseif i >= 301 && i <= 400
        if strcmp('RS', cellTypes{i})
            meanDownL5RS = [meanDownL5RS; meanDownDurations(i)];
            meanDownRS = [meanDownRS; meanDownDurations(i)];
        elseif strcmp('EF', cellTypes{i})
            meanDownL5EF = [meanDownL5EF; meanDownDurations(i)];
            meanDownEF = [meanDownEF; meanDownDurations(i)];
        elseif strcmp('IB', cellTypes{i})
            meanDownL5IB = [meanDownL5IB; meanDownDurations(i)];
            meanDownIB = [meanDownIB; meanDownDurations(i)];
        elseif strcmp('RIB', cellTypes{i})
            meanDownL5RIB = [meanDownL5RIB; meanDownDurations(i)];
            meanDownRIB = [meanDownRIB; meanDownDurations(i)];
        elseif strcmp('SIB', cellTypes{i})
            meanDownL5SIB = [meanDownL5SIB; meanDownDurations(i)];
            meanDownSIB = [meanDownSIB; meanDownDurations(i)];
        elseif strcmp('ND', cellTypes{i})
            meanDownL5ND = [meanDownL5ND; meanDownDurations(i)];
            meanDownND = [meanDownND; meanDownDurations(i)];
        end
    elseif i >= 451 && i <= 550
        if strcmp('RS', cellTypes{i})
            meanDownL6RS = [meanDownL6RS; meanDownDurations(i)];
            meanDownRS = [meanDownRS; meanDownDurations(i)];
        elseif strcmp('EF', cellTypes{i})
            meanDownL6EF = [meanDownL6EF; meanDownDurations(i)];
            meanDownEF = [meanDownEF; meanDownDurations(i)];
        elseif strcmp('IB', cellTypes{i})
            meanDownL6IB = [meanDownL6IB; meanDownDurations(i)];
            meanDownIB = [meanDownIB; meanDownDurations(i)];
        end
    end
end
meanDownL23RS = mean(meanDownL23RS);
meanDownL23EF = mean(meanDownL23EF);
meanDownL23IB = mean(meanDownL23IB);
meanDownL4RS = mean(meanDownL4RS);
meanDownL4IB = mean(meanDownL4IB);
meanDownL5RS = mean(meanDownL5RS);
meanDownL5EF = mean(meanDownL5EF);
meanDownL5IB = mean(meanDownL5IB);
meanDownL5RIB = mean(meanDownL5RIB);
meanDownL5SIB = mean(meanDownL5SIB);
meanDownL5ND = mean(meanDownL5ND);
meanDownL6RS = mean(meanDownL6RS);
meanDownL6EF = mean(meanDownL6EF);
meanDownL6IB = mean(meanDownL6IB);
meanDownRS = mean(meanDownRS);
meanDownEF = mean(meanDownEF);
meanDownIB = mean(meanDownIB);
meanDownRIB = mean(meanDownRIB);
meanDownSIB = mean(meanDownSIB);
meanDownND = mean(meanDownND);

format longG
data = [meanUp meanDown meanUpL23 meanDownL23 meanUpL4 meanDownL4 meanUpL5 meanDownL5 meanUpL6 meanDownL6 meanUpL23PY meanDownL23PY meanUpL23IN meanDownL23IN meanUpL4PY meanDownL4PY meanUpL4IN meanDownL4IN meanUpL5PY...
    meanDownL5PY meanUpL5IN meanDownL5IN meanUpL6PY meanDownL6PY meanUpL6IN meanDownL6IN MeanUpPY MeanUpIN meanUpL23RS meanUpL23EF meanUpL23IB meanUpL4RS meanUpL4IB meanUpL5RS meanUpL5EF meanUpL5IB meanUpL5RIB meanUpL5SIB...
    meanUpL5ND meanUpL6RS meanUpL6EF meanUpL6IB meanUpRS meanUpEF meanUpIB meanUpRIB meanUpSIB meanUpND MeanDownPY MeanDownIN meanDownL23RS meanDownL23EF meanDownL23IB meanDownL4RS meanDownL4IB meanDownL5RS meanDownL5EF...
    meanDownL5IB meanDownL5RIB meanDownL5SIB meanDownL5ND meanDownL6RS meanDownL6EF meanDownL6IB meanDownRS meanDownEF meanDownIB meanDownRIB meanDownSIB meanDownND];
save up_state_parameters1.dat data -ascii -double
