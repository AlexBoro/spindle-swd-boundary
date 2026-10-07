function ca = axesProperties(titleStr, titleSzMult, titleWeight, boxStr, col, font, fontSz, labelSzMult, width, tickLength, tickDir, xVisible, xCol, xLab, xRange, xTicks, yVisible, yCol, yLab, yRange, yTicks)
ca = gca;
set(ca, 'Box', boxStr);
set(ca, 'Color', col);
set(ca, 'FontName', font);
set(ca, 'FontSize', fontSz);
set(ca, 'LabelFontSizeMultiplier', labelSzMult);
set(ca, 'LineWidth', width);
set(ca, 'TickLength', tickLength);
set(ca, 'TickDir', tickDir);
title(titleStr);
set(ca, 'TitleFontSizeMultiplier', titleSzMult);
set(ca, 'TitleFontWeight', titleWeight);
ca.XRuler.Axle.Visible = xVisible;
set(ca, 'XColor', xCol);
xlabel(xLab);
if ~isempty(xRange)
    xlim(xRange);
end
set(ca, 'XTick', xTicks);
ca.YRuler.Axle.Visible = yVisible;
set(ca, 'YColor', yCol);
ylabel(yLab);
if ~isempty(yRange)
    ylim(yRange);
end
set(ca, 'YTick', yTicks);