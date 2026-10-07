function f = xCorrFigs(dataMean, dataCI95, dt, window, colour)

f = figure;
yyaxis left
plot([-fliplr(dt:dt:window*dt) 0 dt:dt:window*dt]./1000, dataMean, '-', 'LineWidth',1, 'Color',colour);
hold on
pC = ciplot(dataMean+dataCI95(2,:), dataMean+dataCI95(1,:), [-fliplr(dt:dt:window*dt) 0 dt:dt:window*dt]./1000,...
    colour, 0.3);
uistack(pC, 'bottom');
plot([0 0], ylim, 'k--', 'LineWidth',1);
hold off
set(gca,'ycolor',colour);
end