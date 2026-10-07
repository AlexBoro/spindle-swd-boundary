% Script to preload spiking data

nCores = 1;

nPY = 100;
nIN = 50;
nTC = 100;
nNRT = 50;
iList = 001:900;
list = dir('*dat');

AreaCx3(1) = area(5.644, 5.644);
AreaCx3(2) = area(5.644, 160*5.644);
AreaTC = area(60, 90);
AreaNRT = area(42, 63);

dt = .25;
dtInterpInit = 10*dt;
xRange = [015000 1200000]+dt;
iRange = xRange./dt;
iRange = round(iRange(1):iRange(end));

[~, data1] = loadFile(list(1).name, AreaCx3, 'Cx3');
t = data1.t(iRange);
tInterpInit = t(1):dtInterpInit:t(end);

rasterAll = zeros(numel(iList), length(tInterpInit));

%parpool(nCores);
%parfor l = iList
for l = iList
    disp(['Loading file: ' num2str(l)])
    fileName = list(l).name;
    if l <= 4*(nPY+nIN)
        [~, data, cellType] = loadFile(fileName, AreaCx3, 'Cx3');
    elseif l <= 4*(nPY+nIN)+2*nNRT
        [~, data, cellType] = loadFile(fileName, AreaNRT, 'NRT');
    elseif l <= 4*(nPY+nIN)+2*nNRT+2*nTC
        [~, data, cellType] = loadFile(fileName, AreaTC, 'TC');
    end
    rasterAll(l,:) = interplAPs(t, rastergram(data.v(iRange)), tInterpInit);
end

save('spikingMat.mat', 'rasterAll', '-v7.3');