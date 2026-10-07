function fH = frAlignPlot(frMean, frCI95, tStart, tEnd, colours, lineTypes, yTitle, legendEntries, figTitle)

n = size(frMean, 1);

% Plot all traces
p = zeros(1,n);
fH = figure; hold on
for trace = 1:n
    p(trace) = plot(tStart, frMean(trace,:), lineTypes{trace}, 'LineWidth',1, 'Color',colours(trace,:));
    pC = ciplot(frMean(trace,:)+frCI95(2*(trace-1)+2,:), frMean(trace,:)+frCI95(2*(trace-1)+1,:), tStart, colours(trace,:), 0.3);
    uistack(pC, 'bottom');
end

% Mark SWD boundaries
plot([0 0], ylim, 'k--', 'LineWidth',1);
iEnd = find(tEnd == 0);
plot([tStart(iEnd) tStart(iEnd)], ylim, 'k--', 'LineWidth',1);
hold off

xlabel('time (s)')
ylabel(yTitle);
legend(p,legendEntries, 'Location','Southeast');
title(figTitle);