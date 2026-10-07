function h = rasterPlot(titleStr, xLabel, x, xLims, xTicks, raster)
for i = 1:15
    raster = raster+[zeros(size(raster,1),i) raster(:,1:end-i)];
end
h = pcolor(x, 1:size(raster,1), raster);
h.EdgeColor = 'none';
cLim = [0 1e-14];
caxis(cLim)
colormap(flipud(gray))
colorbar;
axesProperties(titleStr, 1, 'normal', 'off', 'w', 'Calibri', 20, 1, 2, [0.01 0.025], 'out', 'off', 'k', xLabel, xLims, xTicks, 'off', 'k', 'Cell', [1 size(raster,1)], [0 size(raster,1)/2 size(raster,1)]);