function raster = rastergram(data)
data(data < 0) = 0;
[~, locs] = findpeaks(data);
raster = zeros(1,length(data));
raster(locs) = 1;