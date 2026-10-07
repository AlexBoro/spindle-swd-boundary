cleanUp

dataPairs = {{'psiData3.mat','psiData3.mat'}};
margin = 2000;
traces2plot = [21:25]; %[6:8 11:15 21:25];
CIs2plot = [21*2-1:25*2]; %[6*2-1:8*2 11*2-1:15*2 21*2-1:25*2];


for iPair = 1:numel(dataPairs)
    %% Load data
    load(dataPairs{iPair}{1})
    indsOI = tStartAlignedScaled_i >= 0 & tEndAlignedScaled_i <= 0;
    psi2RasterMeanAlignedScaled_i = [psi2RasterCx23toCx23iMeanAlignedScaled_i; psi2RasterCx23toTCMeanAlignedScaled_i; psi2RasterCx23toTC2MeanAlignedScaled_i; psi2RasterCx23toNRTMeanAlignedScaled_i; psi2RasterCx23toNRT2MeanAlignedScaled_i;...
        psi2RasterCx4toCx4iMeanAlignedScaled_i; psi2RasterCx4toTCMeanAlignedScaled_i; psi2RasterCx4toTC2MeanAlignedScaled_i; psi2RasterCx4toNRTMeanAlignedScaled_i; psi2RasterCx4toNRT2MeanAlignedScaled_i;...
        psi2RasterCx5toCx5iMeanAlignedScaled_i; psi2RasterCx5toTCMeanAlignedScaled_i; psi2RasterCx5toTC2MeanAlignedScaled_i; psi2RasterCx5toNRTMeanAlignedScaled_i; psi2RasterCx5toNRT2MeanAlignedScaled_i;...
        psi2RasterCx6toCx6iMeanAlignedScaled_i; psi2RasterCx6toTCMeanAlignedScaled_i; psi2RasterCx6toTC2MeanAlignedScaled_i; psi2RasterCx6toNRTMeanAlignedScaled_i; psi2RasterCx6toNRT2MeanAlignedScaled_i;...
        psi2RasterNRTtoTCMeanAlignedScaled_i; psi2RasterNRTtoTC2MeanAlignedScaled_i; psi2RasterNRT2toTCMeanAlignedScaled_i; psi2RasterNRT2toTC2MeanAlignedScaled_i;...
        psi2RasterNRTtoNRT2MeanAlignedScaled_i; psi2RasterTCtoTC2MeanAlignedScaled_i];
    psi2RasterCI95AlignedScaled_i = [psi2RasterCx23toCx23iCI95AlignedScaled_i; psi2RasterCx23toTCCI95AlignedScaled_i; psi2RasterCx23toTC2CI95AlignedScaled_i; psi2RasterCx23toNRTCI95AlignedScaled_i; psi2RasterCx23toNRT2CI95AlignedScaled_i;...
        psi2RasterCx4toCx4iCI95AlignedScaled_i; psi2RasterCx4toTCCI95AlignedScaled_i; psi2RasterCx4toTC2CI95AlignedScaled_i; psi2RasterCx4toNRTCI95AlignedScaled_i; psi2RasterCx4toNRT2CI95AlignedScaled_i;...
        psi2RasterCx5toCx5iCI95AlignedScaled_i; psi2RasterCx5toTCCI95AlignedScaled_i; psi2RasterCx5toTC2CI95AlignedScaled_i; psi2RasterCx5toNRTCI95AlignedScaled_i; psi2RasterCx5toNRT2CI95AlignedScaled_i;...
        psi2RasterCx6toCx6iCI95AlignedScaled_i; psi2RasterCx6toTCCI95AlignedScaled_i; psi2RasterCx6toTC2CI95AlignedScaled_i; psi2RasterCx6toNRTCI95AlignedScaled_i; psi2RasterCx6toNRT2CI95AlignedScaled_i;...
        psi2RasterNRTtoTCCI95AlignedScaled_i; psi2RasterNRTtoTC2CI95AlignedScaled_i; psi2RasterNRT2toTCCI95AlignedScaled_i; psi2RasterNRT2toTC2CI95AlignedScaled_i;...
        psi2RasterNRTtoNRT2CI95AlignedScaled_i; psi2RasterTCtoTC2CI95AlignedScaled_i];

    dataOI_1 = psi2RasterMeanAlignedScaled_i(:,indsOI);
    dataOICI95_1 = psi2RasterCI95AlignedScaled_i(:,indsOI);
    
    %load(dataPairs{iPair}{2})
    indsOI = tStartAlignedScaled >= 0 & tEndAlignedScaled <= 0;
    psi2RasterMeanAlignedScaled = [psi2RasterCx23toCx23iMeanAlignedScaled; psi2RasterCx23toTCMeanAlignedScaled; psi2RasterCx23toTC2MeanAlignedScaled; psi2RasterCx23toNRTMeanAlignedScaled; psi2RasterCx23toNRT2MeanAlignedScaled;...
        psi2RasterCx4toCx4iMeanAlignedScaled; psi2RasterCx4toTCMeanAlignedScaled; psi2RasterCx4toTC2MeanAlignedScaled; psi2RasterCx4toNRTMeanAlignedScaled; psi2RasterCx4toNRT2MeanAlignedScaled;...
        psi2RasterCx5toCx5iMeanAlignedScaled; psi2RasterCx5toTCMeanAlignedScaled; psi2RasterCx5toTC2MeanAlignedScaled; psi2RasterCx5toNRTMeanAlignedScaled; psi2RasterCx5toNRT2MeanAlignedScaled;...
        psi2RasterCx6toCx6iMeanAlignedScaled; psi2RasterCx6toTCMeanAlignedScaled; psi2RasterCx6toTC2MeanAlignedScaled; psi2RasterCx6toNRTMeanAlignedScaled; psi2RasterCx6toNRT2MeanAlignedScaled;...
        psi2RasterNRTtoTCMeanAlignedScaled; psi2RasterNRTtoTC2MeanAlignedScaled; psi2RasterNRT2toTCMeanAlignedScaled; psi2RasterNRT2toTC2MeanAlignedScaled;...
        psi2RasterNRTtoNRT2MeanAlignedScaled; psi2RasterTCtoTC2MeanAlignedScaled];
    psi2RasterCI95AlignedScaled = [psi2RasterCx23toCx23iCI95AlignedScaled; psi2RasterCx23toTCCI95AlignedScaled; psi2RasterCx23toTC2CI95AlignedScaled; psi2RasterCx23toNRTCI95AlignedScaled; psi2RasterCx23toNRT2CI95AlignedScaled;...
        psi2RasterCx4toCx4iCI95AlignedScaled; psi2RasterCx4toTCCI95AlignedScaled; psi2RasterCx4toTC2CI95AlignedScaled; psi2RasterCx4toNRTCI95AlignedScaled; psi2RasterCx4toNRT2CI95AlignedScaled;...
        psi2RasterCx5toCx5iCI95AlignedScaled; psi2RasterCx5toTCCI95AlignedScaled; psi2RasterCx5toTC2CI95AlignedScaled; psi2RasterCx5toNRTCI95AlignedScaled; psi2RasterCx5toNRT2CI95AlignedScaled;...
        psi2RasterCx6toCx6iCI95AlignedScaled; psi2RasterCx6toTCCI95AlignedScaled; psi2RasterCx6toTC2CI95AlignedScaled; psi2RasterCx6toNRTCI95AlignedScaled; psi2RasterCx6toNRT2CI95AlignedScaled;...
        psi2RasterNRTtoTCCI95AlignedScaled; psi2RasterNRTtoTC2CI95AlignedScaled; psi2RasterNRT2toTCCI95AlignedScaled; psi2RasterNRT2toTC2CI95AlignedScaled;...
        psi2RasterNRTtoNRT2CI95AlignedScaled; psi2RasterTCtoTC2CI95AlignedScaled];
    dataOI_2 = psi2RasterMeanAlignedScaled(:,indsOI);
    dataOICI95_2 = psi2RasterCI95AlignedScaled(:,indsOI);
    
    
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
    
    marginSize = round(margin/dtInterpFinal);
    fullDataWithMargins = [fullData(:,end-marginSize+1:end) fullData fullData(:,1:marginSize)];
    fullDataCI95WithMargins = [fullDataCI95(:,end-marginSize+1:end) fullDataCI95 fullDataCI95(:,1:marginSize)];
    borderIndsWithMargins = [borderInds(end-marginSize+1:end) borderInds borderInds(1:marginSize)];
    swdOnsetWithMargins = [swdOnset(end-marginSize+1:end) swdOnset swdOnset(1:marginSize)];
    t = ((1:size(fullDataWithMargins,2)).*dtInterpFinal)./1000;
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
    colours = [cellColour('Cx23i'); cellColour('Cx23'); cellColour('Cx23'); cellColour('Cx23'); cellColour('Cx23'); cellColour('Cx4i'); cellColour('Cx4');...
        cellColour('Cx4'); cellColour('Cx4'); cellColour('Cx4'); cellColour('Cx5i'); cellColour('Cx5'); cellColour('Cx5'); cellColour('Cx5'); cellColour('Cx5');...
        cellColour('Cx6i'); cellColour('Cx6'); cellColour('Cx6'); cellColour('Cx6'); cellColour('Cx6'); cellColour('NRT'); cellColour('NRT');...
        cellColour('NRT2'); cellColour('NRT2'); cellColour('NRT'); cellColour('TC')];
    lineTypes = {'-','-','--','-.',':','-','-','--','-.',':','-','-','--','-.',':','-','-','--','-.',':','-','--','-','--','-.','-'};
    legendEntries = {'L2/3 PY to L2/3 IN', 'L2/3 PY to TC_F_O', 'L2/3 PY to TC_H_O', 'L2/3 PY to NRT_F_O', 'L2/3 PY to NRT_H_O',...
        'L4 PY to L4 IN', 'L4 PY to TC_F_O', 'L4 PY to TC_H_O', 'L4 PY to NRT_F_O', 'L4 PY to NRT_H_O',...
        'L5 PY to L5 IN', 'L5 PY to TC_F_O', 'L5 PY to TC_H_O', 'L5 PY to NRT_F_O', 'L5 PY to NRT_H_O',...
        'L6 PY to L6 IN', 'L6 PY to TC_F_O', 'L6 PY to TC_H_O', 'L6 PY to NRT_F_O', 'L6 PY to NRT_H_O',...
        'NRT_F_O to TC_F_O', 'NRT_F_O to TC_H_O', 'NRT_H_O to TC_F_O', 'NRT_H_O to TC_H_O', 'NRT_F_O to NRT_H_O', 'TC_F_O to TC_H_O'};
    yLabel = ''; %'PSI';
    fVM = frAlignPlot2(fullDataWithMargins(traces2plot,:), fullDataCI95WithMargins(CIs2plot,:), tOnsetCentred, tBorders,...
        colours(traces2plot,:), lineTypes(traces2plot), yLabel, legendEntries(traces2plot), 'Phase synchronisation index between populations');
    
    xLabel = '';
    %xLim = [tOnsetCentred(1) tOnsetCentred(end)];
    xLim = [-27.91+2 tOnsetCentred(end)];
    xlim(xLim);
    xTicks = xticks;
    yLim = [0.70 0.865]; %ylim;
    yTicks = [0.70 0.78 0.86]; %ylim;
    ax1 = axesProperties({}, 1, 'normal', 'off', 'w', 'Arial', 25, 4/3, 2, [0.003 0.003], 'out',...
        'on', 'k', {xLabel}, xLim, xTicks,...
        'on', 'k', {yLabel}, yLim, yTicks);
    %ax1.YTickLabel = {'-\pi/4','0','\pi/4'};
    legend('off');
    
    
    %% Save figure
    label = [2.3 0.42];
    margin = [0.01 0.35];
    width = 22.5-label(1)-margin(1);
    height = (26.419/78.686)*22.5-label(2)-margin(2);
    paperSize = resizeFig(gcf, ax1, width, height, label, margin, 0);
    savefig(gcf, 'psiBetween_evo.fig', 'compact');
    %exportFig(gcf, 'psiBetween_evo.png','-dpng','-r300', paperSize);
    %exportFig(gcf, 'psiBetween_evo.tif','-dtiffnocompression','-r300', paperSize);
    exportFig(gcf, 'psiBetween_evo.eps','-depsc','-r1200', paperSize);
end