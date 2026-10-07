function h = populationGraph(titleStr, xLabel, x, xLims, xTicks, v, cLim, cm)
h = pcolor(x, 1:size(v,1), v);
h.EdgeColor = 'none';
caxis(cLim)
if strcmp('grey', cm)
    colormap(flipud(gray))
elseif strcmp('full', cm)
    colormap(jet)
elseif strcmp('hot', cm)
    colormap(flipud(hot))
elseif strcmp('cold', cm)
    colormap(parula)
end
colorbar;
% hold on
% spikes = [32.6805 32.9255 33.2015 33.4808 33.739  34.0598 34.362  34.623...
%          34.9835 35.213  35.517  35.8342 36.1035 36.3938 36.6918 36.9878...
%          37.2642 37.5762 37.8665 38.157  38.4938 38.8158 39.1022 39.4328...
%          39.707  40.0542 40.2845 40.6142 40.9352 41.1958 41.53   41.771 ...
%          42.081];
% spikes = [spikes; spikes];%+0.100;
% lines = [zeros(1,size(spikes,2)); ones(1,size(spikes,2))*100];
% plot(spikes,lines,'r','LineWidth',1)
% waves = [32.547  32.7625 33.0178 33.3675 33.535  33.8605 34.1422 34.4718...
%          34.7398 35.0768 35.3872 35.6735 35.9425 36.2588 36.546  36.7635...
%          37.079  37.3952 37.6832 37.985  38.3305 38.5915 38.8712 39.1958...
%          39.4888 39.8035 40.1802 40.418  40.7108 41.0262 41.268  41.6005...
%          41.8508 42.1248];
% waves = [waves; waves];
% lines = [lines [0;100]];
% plot(waves,lines,'g','LineWidth',1)
% hold off
axesProperties(titleStr, 1, 'normal', 'off', 'w', 'Calibri', 20, 1, 2, [0.01 0.025], 'out', 'off', 'k', xLabel, xLims, xTicks, 'off', 'k', 'Cell', [1 size(v,1)], [0 size(v,1)/2 size(v,1)]);