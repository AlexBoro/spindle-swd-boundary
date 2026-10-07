cleanUp

dataPairs = {{'psiData.mat','psiData.mat'}};
margin = 2000;


for iPair = 1:numel(dataPairs)
    %% Load data
    load(dataPairs{iPair}{1})
    indsOI = tStartAlignedScaled_i >= 0 & tEndAlignedScaled_i <= 0;
    dataOI_1 = psiRasterMeanAlignedScaled_i(:,indsOI);
    dataOICI95_1 = psiRasterCI95AlignedScaled_i(:,indsOI);
    
    %load(dataPairs{iPair}{2})
    indsOI = tStartAlignedScaled >= 0 & tEndAlignedScaled <= 0;
    dataOI_2 = psiRasterMeanAlignedScaled(:,indsOI);
    dataOICI95_2 = psiRasterCI95AlignedScaled(:,indsOI);
    
    
    %% Concatenate data
    fullData = [mean([dataOI_1(:,1) dataOI_2(:,end)],2) dataOI_1(:,2:end-1)...
        mean([dataOI_1(:,end) dataOI_2(:,1)],2) dataOI_2(:,2:end-1)];
    fullDataCI95 = [mean([dataOICI95_1(:,1) dataOICI95_2(:,end)],2) dataOICI95_1(:,2:end-1)...
        mean([dataOICI95_1(:,end) dataOICI95_2(:,1)],2) dataOICI95_2(:,2:end-1)];
    borderInds = zeros(1,size(fullData,2));
    borderInds(1) = 1;
    borderInds(size(dataOI_1,2)) = 1;
    swdOnset = zeros(1,size(fullData,2));
    swdOnset(size(dataOI_1,2)) = 1;
    
    marginSize = round(margin/dtInterp);
    fullDataWithMargins = [fullData(:,end-marginSize+1:end) fullData fullData(:,1:marginSize)];
    fullDataCI95WithMargins = [fullDataCI95(:,end-marginSize+1:end) fullDataCI95 fullDataCI95(:,1:marginSize)];
    borderIndsWithMargins = [borderInds(end-marginSize+1:end) borderInds borderInds(1:marginSize)];
    swdOnsetWithMargins = [swdOnset(end-marginSize+1:end) swdOnset swdOnset(1:marginSize)];
    t = ((1:size(fullDataWithMargins,2)).*dtInterp)./1000;
    tOnsetCentred = t - t(logical(swdOnsetWithMargins));
    tBorders = tOnsetCentred(logical(borderIndsWithMargins));
    
    
    %% Smooth transitions
    dt = t(2)-t(1);
    for iBorder = 1:numel(tBorders)
        inds = round((tBorders(iBorder)-0.5+t(logical(swdOnsetWithMargins)))/dt:...
            (tBorders(iBorder)+0.5+t(logical(swdOnsetWithMargins)))/dt);
        fullDataWithMargins(:,inds) = movmean(fullDataWithMargins(:,inds),15,2, 'Endpoints','shrink');
        fullDataCI95WithMargins(:,inds) = movmean(fullDataCI95WithMargins(:,inds),15,2, 'Endpoints','shrink');
    end
    
    
    %% Plot data
    colours = [cellColour('Cx23'); cellColour('Cx23i'); cellColour('Cx4'); cellColour('Cx4i'); cellColour('Cx5'); cellColour('Cx5i');...
        cellColour('Cx6'); cellColour('Cx6i'); cellColour('NRT'); cellColour('NRT2'); cellColour('TC'); cellColour('TC2')];
    lineTypes = {'-','-','-','-','-','-','-','-','-','-','-','-'};
    legendEntries = {'L2/3 PY', 'L2/3 IN', 'L4 PY', 'L4 IN', 'L5 PY', 'L5 IN', 'L6 PY', 'L6 IN', 'NRT_F_O', 'NRT_H_O', 'TC_F_O', 'TC_H_O'};
    yLabel = ''; %'PSI';
    fVM = frAlignPlot2(fullDataWithMargins, fullDataCI95WithMargins, tOnsetCentred, tBorders, colours, lineTypes, yLabel,...
        legendEntries, 'Phase synchronisation index relative to the EEG');
    
    xLabel = '';
    %xLim = [tOnsetCentred(1) tOnsetCentred(end)];
    xLim = [-27.91+2 tOnsetCentred(end)];
    xlim(xLim);
    xTicks = xticks;
    yLim = ylim;
    yTicks = [0.2 0.5 0.8];
    ax1 = axesProperties({}, 1, 'normal', 'off', 'w', 'Arial', 25, 4/3, 2, [0.003 0.003], 'out',...
        'on', 'k', {xLabel}, xLim, xTicks,...
        'on', 'k', {yLabel}, yLim, yTicks);
    %ax1.YTickLabel = {'-\pi/4','0','\pi/4'};
    legend('off');
    
    
    %% Save figure
    label = [2.3 0.4];
    margin = [0.01 0.33];
    width = 22.5-label(1)-margin(1);
    height = (28/77)*22.5-label(2)-margin(2);
    paperSize = resizeFig(gcf, ax1, width, height, label, margin, 0);
    savefig(gcf, 'psiEEG_evo.fig', 'compact');
    %exportFig(gcf, 'psiEEG_evo.png','-dpng','-r300', paperSize);
    %exportFig(gcf, 'psiEEG_evo.tif','-dtiffnocompression','-r300', paperSize);
    exportFig(gcf, 'psiEEG_evo.eps','-depsc','-r1200', paperSize);
end