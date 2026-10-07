dataPairs = {{'vmData_1sec_interictal.mat','vmData_1sec.mat'}};
margin = 1000;


for iPair = 1:numel(dataPairs)
    %% Load data
    load(dataPairs{iPair}{1})
    indsOI = tStartAlignedScaled >= 0 & tEndAlignedScaled <= 0;
    dataOI_1 = vmMeanAlignedScaled(:,indsOI);
    dataOICI95_1 = vmCI95AlignedScaled(:,indsOI);
    
    load(dataPairs{iPair}{2})
    indsOI = tStartAlignedScaled >= 0 & tEndAlignedScaled <= 0;
    dataOI_2 = vmMeanAlignedScaled(:,indsOI);
    dataOICI95_2 = vmCI95AlignedScaled(:,indsOI);
    
    
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
    
    
    %% Plot data
    colours = [cellColour('Cx23'); cellColour('Cx23'); cellColour('Cx4'); cellColour('Cx4'); cellColour('Cx5'); cellColour('Cx5');...
        cellColour('Cx6'); cellColour('Cx6'); cellColour('NRT'); cellColour('NRT2'); cellColour('TC'); cellColour('TC2')];
    lineTypes = {'-','--','-','--','-','--','-','--','-','-','-','-'};
    legendEntries = {'L2/3 PY', 'L2/3 IN', 'L4 PY', 'L4 IN', 'L5 PY', 'L5 IN', 'L6 PY', 'L6 IN', 'NRT_F_O', 'NRT_H_O', 'TC_F_O', 'TC_H_O'};
    fVM = frAlignPlot2(fullDataWithMargins, fullDataCI95WithMargins, tOnsetCentred, tBorders, colours, lineTypes, 'V_M (mV)',...
        legendEntries, 'Membrane potential');
    
    
    %% Save figure
    label = [3 2.85];
    margin = [0.8 1.25];
    width = 15-label(1)-margin(1);
    height = (4.0248/4.7357)*15-label(2)-margin(2);
    paperSize = resizeFig(gcf, ax1, width, height, label, margin, 0);
    savefig(gcf, ['xCorrelations_' fileNameExt '.fig'], 'compact');
    %exportFig(gcf, ['xCorrelations_' fileNameExt '.png'],'-dpng','-r300', paperSize);
    %exportFig(gcf, ['xCorrelations_' fileNameExt '.tif'],'-dtiffnocompression','-r300', paperSize);
    exportFig(gcf, ['xCorrelations_' fileNameExt '.eps'],'-depsc','-r1200', paperSize);
end