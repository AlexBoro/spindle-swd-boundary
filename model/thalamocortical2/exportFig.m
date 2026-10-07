function exportFig(f, titleStr, format, dpi, paperSize)
set(f, 'Units', 'centimeters');
set(f, 'PaperUnits', 'centimeters');
set(f, 'PaperSize', paperSize)
set(f, 'PaperPosition', [0, 0, paperSize(1), paperSize(2)])

print(f, titleStr, format, dpi);
set(f, 'Units', 'normalized');