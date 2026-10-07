function f = xCorrFigAdjust(f, xLabel, xLim, xTicks, xTickLabels, fileNameExt, colourLeft, colourRight)

figure(f);
yyaxis left
yLabel = '';
yTicks = ylim;
yTicks = [yTicks(1) yTicks(1)+(yTicks(2)-yTicks(1))/2 yTicks(2)];
axesProperties({}, 1, 'normal', 'off', 'w', 'Arial', 25, 4/3, 2, [0.005 0], 'out',...
    'on', 'k', {xLabel}, xLim, xTicks,...
    'on', 'k', {yLabel}, ylim, yTicks);
set(gca, 'ycolor',colourLeft);
%ytickformat('%.3f')
%ax1.YRuler.Exponent = 0;
yyaxis right
yLabel = '';
yTicks = ylim;
yTicks = [yTicks(1) yTicks(1)+(yTicks(2)-yTicks(1))/2 yTicks(2)];
ax1 = axesProperties({}, 1, 'normal', 'off', 'w', 'Arial', 27, 1.23456790111111, 2, [0.015 0.015], 'out',...
    'on', 'k', {xLabel}, xLim, xTicks,...
    'on', 'k', {yLabel}, ylim, yTicks);
set(gca, 'ycolor',colourRight);
ax1.XTickLabel = xTickLabels;
%ytickformat('%.3f')
% ylh = get(gca, 'ylabel');
% ylp = get(ylh, 'Position');
% ext = get(ylh, 'Extent');
% set(ylh, 'Rotation',0, 'Position',ylp+[1 0 0])
%ax1.YAxis(2).Exponent = 0;

label = [3.1 2.95];
margin = [2.65 1.35];
width = 15-label(1)-margin(1);
height = (2.0124/2.3678)*15-label(2)-margin(2);
paperSize = resizeFig(gcf, ax1, width, height, label, margin, 0);
savefig(gcf, ['xCorrelations_' fileNameExt '.fig'], 'compact');
%exportFig(gcf, ['xCorrelations_' fileNameExt '.png'],'-dpng','-r300', paperSize);
exportFig(gcf, ['xCorrelations_' fileNameExt '.tif'],'-dtiffnocompression','-r300', paperSize);
end