function f = eegtsFigs(f, dataMean, dataCI95, dt, window, colour, smooth)

if smooth
    dataMean = smoothdata(dataMean,'movmedian',10);
end
figure(f);
yyaxis right
hold on
ciplot(dataMean+dataCI95(2,:), dataMean+dataCI95(1,:), [-fliplr(dt:dt:window*dt) 0 dt:dt:window*dt]./1000,...
    colour, 0.3);
plot([-fliplr(dt:dt:window*dt) 0 dt:dt:window*dt]./1000, dataMean, '-', 'LineWidth',1, 'Color',colour);
plot([0 0], ylim, 'k--', 'LineWidth',1);
hold off
set(gca,'ycolor',colour);
end