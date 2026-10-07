% dt = .25;
% window = 3*round(1000/dt);
% yColourLeft = [0, 0, 0];
% lineWidth = 3;
% %cycle = (1/swdFrequency);
% %time2plot = (-window:window).*dt./1000; time2plotInds = time2plot >= -cycle & time2plot <= cycle; time2plot = time2plot(time2plotInds);
% time2plot = (-window:window).*dt./1000; time2plotInds = time2plot >= -0.160 & time2plot <= 0.060; time2plot = time2plot(time2plotInds);
% xLimZoomInit = [-0.13 0.03];xTicksZoomInit = [-0.12 -0.08 -0.04 0]; xTickLabelsZoomInit = {'-120'; '-80'; '-40'; '0'};
% 
% pathology1 = load('/media/martynas/HD-LCU3/thalamocortical311_SWDs_0.001375/eegstsData.mat');
% pathology2 = load('/media/martynas/Seagate Backup Plus Drive/output_14_globalIndex0_SWDs_tonicTCinhibition_working/eegstsData.mat');
% pathology3 = load('/media/martynas/Seagate Backup Plus Drive/output_10_0.0015/eegstsData.mat');

% fCx5 = xCorrFigs2(pathology1.eegstsInitCx5mean, pathology1.eegstsInitCx5CI95, dt, window, cellColour('Cx5'), '-', true);
% fCx5 = xCorrFigsUpdate2(fCx5, pathology2.eegstsInitCx5mean, pathology2.eegstsInitCx5CI95, dt, window, cellColour('Cx5'), '-', true);
% fCx5 = xCorrFigsUpdate2(fCx5, pathology3.eegstsInitCx5mean, pathology3.eegstsInitCx5CI95, dt, window, cellColour('Cx5'), '-', true);
% fCx4 = xCorrFigsUpdate2(fCx5, pathology1.eegstsInitCx4mean, pathology1.eegstsInitCx4CI95, dt, window, cellColour('Cx4'), '-', true);
% fCx4 = xCorrFigsUpdate2(fCx4, pathology2.eegstsInitCx4mean, pathology2.eegstsInitCx4CI95, dt, window, cellColour('Cx4'), '-', true);
% fCx4 = xCorrFigsUpdate2(fCx4, pathology3.eegstsInitCx4mean, pathology3.eegstsInitCx4CI95, dt, window, cellColour('Cx4'), '-', true);
% fTC = xCorrFigsUpdate2(fCx4, pathology1.eegstsInitTCmean, pathology1.eegstsInitTCCI95, dt, window, cellColour('TC'), '-', true);
% fTC = xCorrFigsUpdate2(fTC, pathology2.eegstsInitTCmean, pathology2.eegstsInitTCCI95, dt, window, cellColour('TC'), '-', true);
% fTC = xCorrFigsUpdate2(fTC, pathology3.eegstsInitTCmean, pathology3.eegstsInitTCCI95, dt, window, cellColour('TC'), '-', true);
% xCorrFigAdjust2(fTC, 'Time lag (ms)', xLimZoomInit, xTicksZoomInit, xTickLabelsZoomInit, '41_I_Pathologies', yColourLeft);
% 
% cumsumFigI = figure;
% plot(time2plot, cumsum(pathology1.eegstsInitCx5mean(time2plotInds))./sum(pathology1.eegstsInitCx5mean(time2plotInds)), 'color',cellColour('Cx5'), 'LineWidth',lineWidth); hold on
% plot(time2plot, cumsum(pathology2.eegstsInitCx5mean(time2plotInds))./sum(pathology2.eegstsInitCx5mean(time2plotInds)), 'color',cellColour('Cx5'), 'LineWidth',lineWidth);
% plot(time2plot, cumsum(pathology3.eegstsInitCx5mean(time2plotInds))./sum(pathology3.eegstsInitCx5mean(time2plotInds)), 'color',cellColour('Cx5'), 'LineWidth',lineWidth);
% plot(time2plot, cumsum(pathology1.eegstsInitCx4mean(time2plotInds))./sum(pathology1.eegstsInitCx4mean(time2plotInds)), 'color',cellColour('Cx4'), 'LineWidth',lineWidth);
% plot(time2plot, cumsum(pathology2.eegstsInitCx4mean(time2plotInds))./sum(pathology2.eegstsInitCx4mean(time2plotInds)), 'color',cellColour('Cx4'), 'LineWidth',lineWidth);
% plot(time2plot, cumsum(pathology3.eegstsInitCx4mean(time2plotInds))./sum(pathology3.eegstsInitCx4mean(time2plotInds)), 'color',cellColour('Cx4'), 'LineWidth',lineWidth);
% plot(time2plot, cumsum(pathology1.eegstsInitTCmean(time2plotInds))./sum(pathology1.eegstsInitTCmean(time2plotInds)), 'color',cellColour('TC'), 'LineWidth',lineWidth);
% plot(time2plot, cumsum(pathology2.eegstsInitTCmean(time2plotInds))./sum(pathology2.eegstsInitTCmean(time2plotInds)), 'color',cellColour('TC'), 'LineWidth',lineWidth);
% plot(time2plot, cumsum(pathology3.eegstsInitTCmean(time2plotInds))./sum(pathology3.eegstsInitTCmean(time2plotInds)), 'color',cellColour('TC'), 'LineWidth',lineWidth); hold off
% cumsumFigAdjust(cumsumFigI, 'Time lag (ms)', xLimZoomInit, xTicksZoomInit, xTickLabelsZoomInit, '41_I_Pathologies_cumsum', yColourLeft);

fCx4 = xCorrFigs2(pathology1.eegstsInitCx4mean, pathology1.eegstsInitCx4CI95, dt, window, cellColour('Cx4'), '-', true);
fCx4 = xCorrFigsUpdate2(fCx4, pathology2.eegstsInitCx4mean, pathology2.eegstsInitCx4CI95, dt, window, [208 170 145]./255, '-.', true);
fCx4 = xCorrFigsUpdate2(fCx4, pathology3.eegstsInitCx4mean, pathology3.eegstsInitCx4CI95, dt, window, cellColour('Cx4'), ':', true);
fTC = xCorrFigsUpdate2(fCx4, pathology1.eegstsInitTCmean, pathology1.eegstsInitTCCI95, dt, window, cellColour('TC'), '-', true);
fTC = xCorrFigsUpdate2(fTC, pathology2.eegstsInitTCmean, pathology2.eegstsInitTCCI95, dt, window, [145 206 208]./255, '-.', true);
fTC = xCorrFigsUpdate2(fTC, pathology3.eegstsInitTCmean, pathology3.eegstsInitTCCI95, dt, window, cellColour('TC'), ':', true);
xCorrFigAdjust2(fTC, 'Time lag (ms)', xLimZoomInit, xTicksZoomInit, xTickLabelsZoomInit, '41_I_Pathologies', yColourLeft);

cumsumFigI = figure;
plot(time2plot, cumsum(pathology1.eegstsInitCx4mean(time2plotInds))./sum(pathology1.eegstsInitCx4mean(time2plotInds)), '-', 'color',cellColour('Cx4'), 'LineWidth',lineWidth); hold on
plot(time2plot, cumsum(pathology2.eegstsInitCx4mean(time2plotInds))./sum(pathology2.eegstsInitCx4mean(time2plotInds)), '-.', 'color',[208 170 145]./255, 'LineWidth',lineWidth);
plot(time2plot, cumsum(pathology3.eegstsInitCx4mean(time2plotInds))./sum(pathology3.eegstsInitCx4mean(time2plotInds)), ':', 'color',cellColour('Cx4'), 'LineWidth',lineWidth);
plot(time2plot, cumsum(pathology1.eegstsInitTCmean(time2plotInds))./sum(pathology1.eegstsInitTCmean(time2plotInds)), '-', 'color',cellColour('TC'), 'LineWidth',lineWidth);
plot(time2plot, cumsum(pathology2.eegstsInitTCmean(time2plotInds))./sum(pathology2.eegstsInitTCmean(time2plotInds)), '-.', 'color',[145 206 208]./255, 'LineWidth',lineWidth);
plot(time2plot, cumsum(pathology3.eegstsInitTCmean(time2plotInds))./sum(pathology3.eegstsInitTCmean(time2plotInds)), ':', 'color',cellColour('TC'), 'LineWidth',lineWidth); hold off
%legend('L4 1','L4 2','L4 3','TC_{FO} 1','TC_{FO} 2','TC_{FO} 3')
cumsumFigAdjust(cumsumFigI, 'Time lag (ms)', xLimZoomInit, xTicksZoomInit, xTickLabelsZoomInit, '41_I_Pathologies_cumsum', yColourLeft);