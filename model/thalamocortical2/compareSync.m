clc
close all
clear all %#ok<CLALL>
format longG


%% Load synchronisation data files
fileListXCorr{1} = '/media/martynas/HD-LCU3/thalamocortical311_SWDs_0.0013/xCorrelationData.mat';
fileListXCorr{2} = '/media/martynas/Seagate Backup Plus Drive/SIB_SWDs/thalamocortical23_pL5/xCorrelationData.mat';
fileListXCorr{3} = '/media/martynas/Seagate Backup Plus Drive/SIB_SWDs/thalamocortical21_pL5_pL6/xCorrelationData.mat';

fileListEEGTS{1} = '/media/martynas/HD-LCU3/thalamocortical311_SWDs_0.0013/eegtsData.mat';
fileListEEGTS{2} = '/media/martynas/Seagate Backup Plus Drive/SIB_SWDs/thalamocortical23_pL5/eegtsData.mat';
fileListEEGTS{3} = '/media/martynas/Seagate Backup Plus Drive/SIB_SWDs/thalamocortical21_pL5_pL6/eegtsData.mat';

assert(numel(fileListXCorr) == numel(fileListEEGTS));

maxVal = 0;
for iFile = 1:numel(fileListXCorr)
   xCorrData{iFile} = load(fileListXCorr{iFile}); %#ok<*SAGROW>
   eegtsData{iFile} = load(fileListEEGTS{iFile});
   maxVal = max([maxVal max(eegtsData{iFile}.eegtsAllmean)]);
end


%% Timing data
timingData = [nan nan;
              10.49 39.01;
              11.21 31.38];


%% Draw the figures
xLim = [-0.5 0.5]; xTicks = [-0.5 -0.25 0 0.25 0.5]; xTickLabels = {'-500'; '-250'; '0'; '250'; '500'};
xLimZoom = [-0.3 0.3]; xTicksZoom = [-0.3 -0.15 0 0.15 0.3]; xTickLabelsZoom = {'-300'; '-150'; '0'; '150'; '300'};
yColourLeft = [0, 0, 0];

[f1, t] = swdFigs_xCorr(xCorrData);
f1 = xCorrFigAdjust2(f1, t, 'Time lag (ms)', xLim, xTicks, xTickLabels, '5_All', yColourLeft);
f1 = xCorrFigAdjust2(f1, t, 'Time lag (ms)', xLimZoom, xTicksZoom, xTickLabelsZoom, '5_All_zoom', yColourLeft);

[f2, t, ax1] = swdFigs_eegts(eegtsData);
gap = 0.3;
yLim = ylim;
%yLim = [yLim(1) maxVal+(maxVal-yLim(1))*0.03];
yLim = [0.062 0.0792];
ylim(yLim);
f2 = xCorrFigAdjust2(f2, t, 'Time lag (ms)', xLim, xTicks, xTickLabels, '6_All', yColourLeft);
f2 = xCorrFigAdjust2(f2, t, 'Time lag (ms)', xLimZoom, xTicksZoom, xTickLabelsZoom, '6_All_zoom', yColourLeft);

displacement = 0.21;
if ~isempty(timingData)
    set(ax1, 'ycolor','none');
    set(ax1, 'XAxisLocation', 'top') % move existing axis to the top
    yLim = ylim;
    yLim = [yLim(1)-gap*(yLim(end)-yLim(1)) maxVal+(maxVal-yLim(1))*0.03];
    ylim(yLim)
    ax2 = axes(t);
    ax2.YAxisLocation = 'right';
    ax2.XAxisLocation = 'bottom';
    ax2.Color = 'none';
    hold(ax2);
    for iFile = 1:size(timingData,1)
        if ~isnan(timingData(iFile,1)) && ~isnan(timingData(iFile,2))
            for iSWD = 1:5
                if iSWD == 1
                    SWDs = [0 timingData(iFile,1)];
                else
                    SWDs = [SWDs; SWDs(end) + timingData(iFile,2) SWDs(end) + timingData(iFile,2) + timingData(iFile,1)]; %#ok<*AGROW>
                end
            end
            %SWDs = SWDs - SWDs(end)/2;
            yLocs = (yLim(1) - iFile*displacement).*ones(size(SWDs));
            plot(ax2, SWDs', yLocs', 'color',matlabColours(iFile), 'LineWidth',6);
        end
    end
    hold off
    xLim = [0 90];
    xTicks = [0 10 45 90];
    xTickLabels = {'0', '10', '45', '90'};
    ylim([yLocs(1) - displacement*(3/4) 10]);
    f2 = xCorrFigAdjust3(f2, t, 'Time (s)', xLim, xTicks, xTickLabels, '6_All_SWDs', 'none');
end



%% Local functions
function [f, t, ax] = xCorrFigs2(dataMean, dataCI95, dt, window, colour, smooth, shape) %#ok<*INUSL>

if smooth
    dataMean = smoothdata(dataMean,'movmedian',10);
end

f = figure;
t = tiledlayout(1,1);
ax = axes(t);
plot(ax, [-fliplr(dt:dt:window*dt) 0 dt:dt:window*dt]./1000, dataMean, shape, 'LineWidth',2, 'Color',colour);
hold on
% pC = ciplot(dataMean+dataCI95(2,:), dataMean+dataCI95(1,:), [-fliplr(dt:dt:window*dt) 0 dt:dt:window*dt]./1000,...
%     colour, 0.3);
% uistack(pC, 'bottom');
hold off
set(ax,'ycolor',colour);
end


function f = xCorrFigsUpdate2(f, ax, dataMean, dataCI95, dt, window, colour, smooth, shape)

if smooth
    dataMean = smoothdata(dataMean,'movmedian',10);
end

figure(f);
hold on
plot(ax, [-fliplr(dt:dt:window*dt) 0 dt:dt:window*dt]./1000, dataMean, shape, 'LineWidth',2, 'Color',colour);
% pC = ciplot(dataMean+dataCI95(2,:), dataMean+dataCI95(1,:), [-fliplr(dt:dt:window*dt) 0 dt:dt:window*dt]./1000,...
%     colour, 0.3);
% uistack(pC, 'bottom');
hold off
set(gca,'ycolor',colour);
end


function f = xCorrFigAdjust2(f, t, xLabel, xLim, xTicks, xTickLabels, fileNameExt, colourLeft)

figure(f);
hold on
plot([0 0], ylim, 'k--', 'LineWidth',1);
hold off
yLabel = '';
yTicks = ylim;
yTicks = [yTicks(1) yTicks(1)+(yTicks(2)-yTicks(1))/2 yTicks(2)];
ax1 = axesProperties({}, 1, 'normal', 'off', 'w', 'Arial', 25, 4/3, 2, [0.015 0.015], 'out',...
    'on', 'k', {xLabel}, xLim, xTicks,...
    'on', 'k', {yLabel}, ylim, yTicks);
set(ax1, 'ycolor',colourLeft);
ax1.XTickLabel = xTickLabels;
ax1.TickLength = [0.015 0.015];
xtickangle(0);
%ytickformat('%.3f')
%ax1.YRuler.Exponent = 0;

label = [3.5 2.85];
margin = [0.75 1.25];
width = 15-label(1)-margin(1);
height = 15*0.75-label(2)-margin(2);
paperSize = resizeFig(gcf, t, width, height, label, margin, 0);
savefig(f, ['xCorrelations_' fileNameExt '.fig'],'compact');
%exportFig(f, ['xCorrelations_' fileNameExt '.png'],'-dpng','-r300', paperSize);
%exportFig(f, ['xCorrelations_' fileNameExt '.tif'],'-dtiffnocompression','-r300', paperSize);
exportFig(f, ['xCorrelations_' fileNameExt '.eps'],'-depsc','-r1200', paperSize);
end


function [f, t, ax] = swdFigs_xCorr(data)

%colourStep = (255/2)/(numel(data)-1);
%shape = {':', '-.', '--', '-'};
shape = {'-', '-', '-', '-'};
for iFile = 1:numel(data)
    yColourRight = matlabColours(iFile); %(ones(1,3) * (0 + colourStep*(numel(data)-(iFile-1))))./255;
    if iFile == 1
        [f, t, ax] = xCorrFigs2(data{iFile}.xCorrAllmean, data{iFile}.xCorrAllCI95,...
            data{iFile}.dt, data{iFile}.window, yColourRight, true, shape{iFile});
    else
        f = xCorrFigsUpdate2(f, ax, data{iFile}.xCorrAllmean, data{iFile}.xCorrAllCI95,...
            data{iFile}.dt, data{iFile}.window, yColourRight, true, shape{iFile});
    end
end
end


function [f, t, ax] = swdFigs_eegts(data)

%colourStep = (255/2)/(numel(data)-1);
%shape = {':', '-.', '--', '-'};
shape = {'-', '-', '-', '-'};
for iFile = 1:numel(data)
    yColourRight = matlabColours(iFile); %(ones(1,3) * (0 + colourStep*(numel(data)-(iFile-1))))./255;
    if iFile == 1
        [f, t, ax] = xCorrFigs2(data{iFile}.eegtsAllmean, data{iFile}.eegtsAllCI95,...
            data{iFile}.dt, data{iFile}.window, yColourRight, true, shape{iFile});
    else
        f = xCorrFigsUpdate2(f, ax, data{iFile}.eegtsAllmean, data{iFile}.eegtsAllCI95,...
            data{iFile}.dt, data{iFile}.window, yColourRight, true, shape{iFile});
    end
end
end


function f = xCorrFigAdjust3(f, t, xLabel, xLim, xTicks, xTickLabels, fileNameExt, colourLeft)

figure(f);
yLabel = '';
yTicks = ylim;
yTicks = [yTicks(1) yTicks(1)+(yTicks(2)-yTicks(1))/2 yTicks(2)];
ax1 = axesProperties({}, 1, 'normal', 'off', 'none', 'Arial', 25, 4/3, 2, [0.015 0.015], 'out',...
    'on', 'k', {xLabel}, xLim, xTicks,...
    'on', 'k', {yLabel}, ylim, yTicks);
set(ax1, 'ycolor',colourLeft);
ax1.XTickLabel = xTickLabels;
ax1.TickLength = [0.015 0.015];
xtickangle(0);
%ytickformat('%.3f')
%ax1.YRuler.Exponent = 0;

label = [3.5 2.85];
%label = [3.5 1.35];
margin = [0.8 1.3];
width = 15/0.9777-label(1)-margin(1);
height = 15-label(2)-margin(2);
paperSize = resizeFig(gcf, t, width, height, label, margin, 0);
savefig(f, ['xCorrelations_' fileNameExt '.fig'],'compact');
%exportFig(f, ['xCorrelations_' fileNameExt '.png'],'-dpng','-r300', paperSize);
%exportFig(f, ['xCorrelations_' fileNameExt '.tif'],'-dtiffnocompression','-r300', paperSize);
exportFig(f, ['xCorrelations_' fileNameExt '.eps'],'-depsc','-r1200', paperSize);
end