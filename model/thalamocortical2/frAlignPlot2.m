function fH = frAlignPlot2(frMean, frCI95, t, tBorders, colours, lineTypes, yTitle, legendEntries, figTitle)

n = size(frMean, 1);

% Plot all traces
p = {};
pC = {};
fH = figure; hold on
for trace = 1:n
    limit1 = frMean(trace,:)+frCI95(2*(trace-1)+2,:);
    limit2 = frMean(trace,:)+frCI95(2*(trace-1)+1,:);
    limInds = ~isnan(limit1) & ~isnan(limit2);
    if strcmp(legendEntries{trace}, 'NRT_F_O to TC_F_O') || strcmp(legendEntries{trace}, 'NRT_H_O to TC_F_O')
        %p{trace} = plot(t(limInds), frMean(trace,limInds), lineTypes{trace}, 'LineWidth',2, 'Color',[colours(trace,:) 1]);
        p{trace} = plot(t(limInds), frMean(trace,limInds), lineTypes{trace}, 'LineWidth',1, 'Color',[colours(trace,:) 1]); %#ok<*AGROW>
    else
        p{trace} = plot(t(limInds), frMean(trace,limInds), lineTypes{trace}, 'LineWidth',1, 'Color',[colours(trace,:) 1]);
    end
    pC{trace} = ciplot(limit1(limInds), limit2(limInds), t(limInds), colours(trace,:), 0.3);
    uistack(pC{trace}, 'bottom');
end
%p{trace-1}.Color(4) = 0.4;
% p{trace}.Color(4) = 0.4;
% uistack(p{trace-1}, 'bottom');
% uistack(p{trace}, 'bottom');
% uistack(pC{trace-1}, 'bottom');
% uistack(pC{trace}, 'bottom');

% Mark SWD boundaries
for i = 1:numel(tBorders)
    plot([tBorders(i) tBorders(i)], ylim, 'k--', 'LineWidth',1);
    %plot([tBorders(i) tBorders(i)], [-pi/8 pi/8], 'k--', 'LineWidth',1);
end
hold off

xlabel('time (s)')
ylabel(yTitle);
pL = zeros(size(p));
for iP = 1:numel(pL)
    pL(iP) = p{iP};
end
legend(pL,legendEntries, 'Location','Southeast');
title(figTitle);