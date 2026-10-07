function raster = rastergramInit(v, SWCs)

rasterFull = rastergram(v);

n = max(SWCs);
raster = zeros(size(rasterFull));
for swc = 1:n
    swcOI = zeros(size(SWCs));
    swcOI(SWCs == swc) = 1;
    initSpikeLoc = find(logical(swcOI) & logical(rasterFull), 1);
    raster(initSpikeLoc) = 1;
end