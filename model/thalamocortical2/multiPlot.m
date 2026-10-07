function [f, plotObjects] = multiPlot(titleStr, data, lineCols, penSz, Vm, visibility)
f = figProperties(titleStr, 'normalized', [0, .005, .97, .90], 'w', visibility);
plotObjects = gobjects(1,size(data,1));
hold on
for i = 1:size(data,1)
    plotObjects(i) = plot(Vm, data(i,:), 'Color', lineCols(i,:), 'LineWidth', penSz(i));
end
hold off