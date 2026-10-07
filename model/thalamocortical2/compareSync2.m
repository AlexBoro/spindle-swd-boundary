% clc
% close all
% clear all %#ok<CLALL>
% format longG
% 
% 
% %% Load synchronisation data files
% fileListXCorr{1} = '/media/martynas/HD-LCU3/thalamocortical311_SWDs_0.0013/xCorrelationData.mat';
% fileListXCorr{2} = '/media/martynas/HD-LCU3/thalamocortical311_SWDs_0.001375/xCorrelationData.mat';
% fileListXCorr{3} = '/media/martynas/Seagate Backup Plus Drive/output_14_globalIndex0_SWDs_tonicTCinhibition_working/xCorrelationData.mat';
% fileListXCorr{4} = '/media/martynas/Seagate Backup Plus Drive/output_10_0.0015/xCorrelationData.mat';
% 
% fileListEEGTS{1} = '/media/martynas/HD-LCU3/thalamocortical311_SWDs_0.0013/eegtsData.mat';
% fileListEEGTS{2} = '/media/martynas/HD-LCU3/thalamocortical311_SWDs_0.001375/eegtsData.mat';
% fileListEEGTS{3} = '/media/martynas/Seagate Backup Plus Drive/output_14_globalIndex0_SWDs_tonicTCinhibition_working/eegtsData.mat';
% fileListEEGTS{4} = '/media/martynas/Seagate Backup Plus Drive/output_10_0.0015/eegtsData.mat';
% 
% assert(numel(fileListXCorr) == numel(fileListEEGTS));
% 
% for iFile = 1:numel(fileListXCorr)
%    xCorrData{iFile} = load(fileListXCorr{iFile}); %#ok<*SAGROW>
%    eegtsData{iFile} = load(fileListEEGTS{iFile});
% end
% 
% 
% %% Timing data
% timingData = [nan nan;
%               7.89 78.19;
%               9.59 39.1;
%               8.94 58.76];


%% Draw the figures
xLim = [-0.5 0.5]; xTicks = [-0.5 -0.25 0 0.25 0.5]; xTickLabels = {'-500'; '-250'; '0'; '250'; '500'};
xLimZoom = [-0.3 0.3]; xTicksZoom = [-0.3 -0.15 0 0.15 0.3]; xTickLabelsZoom = {'-300'; '-150'; '0'; '150'; '300'};
yColourLeft = [0, 0, 0];

f1 = swdFigs_xCorr(xCorrData);
f1 = xCorrFigAdjust2(f1, 'Corr time lag (ms)', xLim, xTicks, xTickLabels, '5_All', yColourLeft);
f1 = xCorrFigAdjust2(f1, 'Corr time lag (ms)', xLimZoom, xTicksZoom, xTickLabelsZoom, '5_All_zoom', yColourLeft);

f2 = swdFigs_eegts(eegtsData);
f2 = xCorrFigAdjust2(f2, 'Corr time lag (ms)', xLim, xTicks, xTickLabels, '6_All', yColourLeft);
f2 = xCorrFigAdjust2(f2, 'Corr time lag (ms)', xLimZoom, xTicksZoom, xTickLabelsZoom, '6_All_zoom', yColourLeft);

if ~isempty(timingData)
    set(gca, 'XAxisLocation', 'top') % move existing axis to the top
    yLim = ylim;
    ylim([yLim(1)-0.05*(yLim(end)-yLim(1)) yLim(end)])
    t = tiledlayout('flow');
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
            SWDs = SWDs - SWDs(end)/2;
            yLocs = (yLim(1) - iFile*0.2).*ones(size(SWDs));
            plot(ax2, SWDs', yLocs', 'color',matlabColours(iFile), 'LineWidth',6);
            xlim([-100 100]);
            ylim([-0.86 10]);
        end
    end
    hold off
end



%% Local functions
function f = xCorrFigs2(dataMean, dataCI95, dt, window, colour, smooth, shape) %#ok<*INUSL>

if smooth
    dataMean = smoothdata(dataMean,'movmedian',10);
end

f = figure;
plot([-fliplr(dt:dt:window*dt) 0 dt:dt:window*dt]./1000, dataMean, shape, 'LineWidth',2, 'Color',colour);
hold on
% pC = ciplot(dataMean+dataCI95(2,:), dataMean+dataCI95(1,:), [-fliplr(dt:dt:window*dt) 0 dt:dt:window*dt]./1000,...
%     colour, 0.3);
% uistack(pC, 'bottom');
hold off
set(gca,'ycolor',colour);
end


function f = xCorrFigsUpdate2(f, dataMean, dataCI95, dt, window, colour, smooth, shape)

if smooth
    dataMean = smoothdata(dataMean,'movmedian',10);
end

figure(f);
hold on
plot([-fliplr(dt:dt:window*dt) 0 dt:dt:window*dt]./1000, dataMean, shape, 'LineWidth',2, 'Color',colour);
% pC = ciplot(dataMean+dataCI95(2,:), dataMean+dataCI95(1,:), [-fliplr(dt:dt:window*dt) 0 dt:dt:window*dt]./1000,...
%     colour, 0.3);
% uistack(pC, 'bottom');
hold off
set(gca,'ycolor',colour);
end


function f = xCorrFigAdjust2(f, xLabel, xLim, xTicks, xTickLabels, fileNameExt, colourLeft)

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
%ytickformat('%.3f')
%ax1.YRuler.Exponent = 0;

label = [3.5 2.85];
margin = [0.8 1.25];
width = 15-label(1)-margin(1);
height = 15/0.94-label(2)-margin(2);
paperSize = resizeFig(gcf, ax1, width, height, label, margin, 0);
savefig(f, ['xCorrelations_' fileNameExt '.fig'],'compact');
%exportFig(f, ['xCorrelations_' fileNameExt '.png'],'-dpng','-r300', paperSize);
%exportFig(f, ['xCorrelations_' fileNameExt '.tif'],'-dtiffnocompression','-r300', paperSize);
exportFig(f, ['xCorrelations_' fileNameExt '.eps'],'-depsc','-r1200', paperSize);
end


function f = swdFigs_xCorr(data)

%colourStep = (255/2)/(numel(data)-1);
%shape = {':', '-.', '--', '-'};
shape = {'-', '-', '-', '-'};
for iFile = 1:numel(data)
    yColourRight = matlabColours(iFile); %(ones(1,3) * (0 + colourStep*(numel(data)-(iFile-1))))./255;
    if iFile == 1
        f = xCorrFigs2(data{iFile}.xCorrAllmean, data{iFile}.xCorrAllCI95,...
            data{iFile}.dt, data{iFile}.window, yColourRight, true, shape{iFile});
    else
        f = xCorrFigsUpdate2(f, data{iFile}.xCorrAllmean, data{iFile}.xCorrAllCI95,...
            data{iFile}.dt, data{iFile}.window, yColourRight, true, shape{iFile});
    end
end
end


function f = swdFigs_eegts(data)

%colourStep = (255/2)/(numel(data)-1);
%shape = {':', '-.', '--', '-'};
shape = {'-', '-', '-', '-'};
for iFile = 1:numel(data)
    yColourRight = matlabColours(iFile); %(ones(1,3) * (0 + colourStep*(numel(data)-(iFile-1))))./255;
    if iFile == 1
        f = xCorrFigs2(data{iFile}.eegtsAllmean, data{iFile}.eegtsAllCI95,...
            data{iFile}.dt, data{iFile}.window, yColourRight, true, shape{iFile});
    else
        f = xCorrFigsUpdate2(f, data{iFile}.eegtsAllmean, data{iFile}.eegtsAllCI95,...
            data{iFile}.dt, data{iFile}.window, yColourRight, true, shape{iFile});
    end
end
end