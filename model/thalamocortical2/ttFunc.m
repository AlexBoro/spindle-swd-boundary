function timing = ttFunc(raster,binCentres)
timing = zeros(size(binCentres));
for i = 1:size(raster,1)
    timing = timing + hist(raster(i,:),binCentres);
end
timing = timing(2:end-1);