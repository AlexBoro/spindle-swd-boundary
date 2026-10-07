function f = xCorrFigsUpdate2(f, dataMean, dataCI95, dt, window, colour, lineType, smooth)

if smooth
    dataMean = smoothdata(dataMean,'movmedian',10);
end

figure(f);
hold on
plot([-fliplr(dt:dt:window*dt) 0 dt:dt:window*dt]./1000, dataMean, lineType, 'LineWidth',1, 'Color',colour);
pC = ciplot(dataMean+dataCI95(2,:), dataMean+dataCI95(1,:), [-fliplr(dt:dt:window*dt) 0 dt:dt:window*dt]./1000,...
    colour, 0.3);
uistack(pC, 'bottom');
hold off
set(gca,'ycolor',colour);
end