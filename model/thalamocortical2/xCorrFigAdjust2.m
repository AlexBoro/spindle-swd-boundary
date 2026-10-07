function f = xCorrFigAdjust2(f, xLabel, xLim, xTicks, xTickLabels, fileNameExt, colourLeft)

figure(f);
%yLim = ylim;
%yLim = [0 yLim(2)];
%yLim = [0 0.00436];
yLim = [0 0.003];
ylim(yLim);
hold on
plot([0 0], ylim, 'k--', 'LineWidth',1);
hold off
yLabel = '';
%yTicks = ylim;
%yTicks = [yTicks(1) yTicks(1)+(yTicks(2)-yTicks(1))/2 yTicks(2)];
%yTicks = [0 0.002 0.004];
yTicks = [0 0.001 0.002 0.003];
ax1 = axesProperties({}, 1, 'normal', 'off', 'w', 'Arial', 20, 4/3, 2, [0.015 0.015], 'out',...
    'on', 'k', {xLabel}, xLim, xTicks,...
    'on', 'k', {yLabel}, yLim, yTicks);
set(gca, 'ycolor',colourLeft);
ax1.XTickLabel = xTickLabels;
ax1.TickLength = [0.015 0.015];
%ytickformat('%.3f')
ax1.YRuler.Exponent = 0;

label = [2.5 1.2];
margin = [0.5 0.4];
width = 15-label(1)-margin(1)+label(1);
height = ((279-253.375)/(80-34))*15-label(2)-margin(2);
paperSize = resizeFig(gcf, ax1, width, height, label, margin, 0);
savefig(gcf, ['xCorrelations_' fileNameExt '.fig'], 'compact');
%exportFig(gcf, ['xCorrelations_' fileNameExt '.png'],'-dpng','-r300', paperSize);
exportFig(gcf, ['xCorrelations_' fileNameExt '.tif'],'-dtiffnocompression','-r300', paperSize);
end