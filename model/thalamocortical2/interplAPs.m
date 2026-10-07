function rasterInterp = interplAPs(t, raster, tInterp)
% Function interpolates spiking vector. Inputs and output of the function
% is similar to Matlab's native interpl function.

dt = t(2) - t(1);
dtInterp = tInterp(2) - tInterp(1);
scaleFactor = dtInterp/dt;
spikeInds = find(raster);
spikeIndsInterp = round(spikeInds/scaleFactor);
spikeIndsInterp(spikeIndsInterp == 0) = 1;
assert(numel(spikeIndsInterp) == numel(unique(spikeIndsInterp)));
rasterInterp = zeros(size(tInterp));
rasterInterp(spikeIndsInterp) = 1;
end