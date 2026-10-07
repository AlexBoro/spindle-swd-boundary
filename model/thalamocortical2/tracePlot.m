function f = tracePlot(titleStr, t, v, xRange, yRange, lineWidth)
f = figProperties(titleStr, 'normalized', [0, .005, .97, .90], 'w', 'on');
plot(t, v, 'Color', 'k', 'LineWidth', lineWidth)
hold on
markerSize = 5;
dt = t(2)-t(1);
markerPoint = xRange(1) + 1.5*dt;
plot([markerPoint markerPoint], [yRange(1) yRange(2)], 'k.', 'MarkerSize', markerSize)
if ~(yRange(1) > 0)
    plot(markerPoint, 0, 'k.', 'MarkerSize', markerSize)
    if ~(yRange(1) > -50)
        plot(markerPoint, -50, 'k.', 'MarkerSize', markerSize)
        if ~(yRange(1) > -60)
            plot(markerPoint, -60, 'k.', 'MarkerSize', markerSize)
            if ~(yRange(1) > -70)
                plot(markerPoint, -70, 'k.', 'MarkerSize', markerSize)
                if ~(yRange(1) > -80)
                    plot(markerPoint, -80, 'k.', 'MarkerSize', markerSize)
                    if ~(yRange(1) > -90)
                        plot(markerPoint, -90, 'k.', 'MarkerSize', markerSize)
                    end
                end
            end
        end
    end
end
hold off
axesProperties({}, 1, 'normal', 'off', 'w', 'Calibri', 30, 4/3, 0.5, [0 0.025], 'out', 'off', 'k', {}, xRange, [], 'off', 'w', {}, yRange, []);