cleanUp

load('psiData3.mat');

f10 = figProperties('PSI evolution within', 'normalized', [0, .005, .97, .90], 'w', 'on');
hold on


%% Data bars for PSI between areas
gap = 1;

% colour = cellColour('Cx4i');
% barGroupCount = 1;
% barCount = 1;
% bar1 = mean(psi2RasterCx4toCx4iMeanSecond,'omitnan')-mean(psi2RasterCx4toCx4iMeanFirst,'omitnan');
% bar(barCount+(barGroupCount-1)*gap, bar1, 'FaceColor',colour, 'EdgeColor',colour);
% barCount = barCount + 1;
% bar2 = mean(psi2RasterCx4toCx4iMeanThird10,'omitnan')-mean(psi2RasterCx4toCx4iMeanSecond,'omitnan');
% bar(barCount+(barGroupCount-1)*gap, bar2, 'FaceColor',colour, 'EdgeColor',colour);
% barCount = barCount + 1;
% bar3 = mean(psi2RasterCx4toCx4iMean_SWDs,'omitnan')-mean(psi2RasterCx4toCx4iMeanThird10,'omitnan');
% bar(barCount+(barGroupCount-1)*gap, bar3, 'FaceColor',colour, 'EdgeColor',colour);

colour = cellColour('Cx4');
barGroupCount = 1;
barCount = 1;
bar1 = mean(psi2RasterCx4toTCMeanSecond,'omitnan')-mean(psi2RasterCx4toTCMeanFirst,'omitnan');
bar(barCount+(barGroupCount-1)*gap, bar1, 'FaceColor',colour, 'EdgeColor',colour);
barCount = barCount + 1;
bar2 = mean(psi2RasterCx4toTCMeanThird10,'omitnan')-mean(psi2RasterCx4toTCMeanSecond,'omitnan');
bar(barCount+(barGroupCount-1)*gap, bar2, 'FaceColor',colour, 'EdgeColor',colour);
barCount = barCount + 1;
bar3 = mean(psi2RasterCx4toTCMean_SWDs,'omitnan')-mean(psi2RasterCx4toTCMeanThird10,'omitnan');
bar(barCount+(barGroupCount-1)*gap, bar3, 'FaceColor',colour, 'EdgeColor',colour);

colour = cellColour('Cx4');
barGroupCount = barGroupCount + 1;
barCount = barCount + 1;
bar4 = mean(psi2RasterCx4toTC2MeanSecond,'omitnan')-mean(psi2RasterCx4toTC2MeanFirst,'omitnan');
bar(barCount+(barGroupCount-1)*gap, bar4, 'FaceColor',colour, 'EdgeColor',colour);
barCount = barCount + 1;
bar5 = mean(psi2RasterCx4toTC2MeanThird10,'omitnan')-mean(psi2RasterCx4toTC2MeanSecond,'omitnan');
bar(barCount+(barGroupCount-1)*gap, bar5, 'FaceColor',colour, 'EdgeColor',colour);
barCount = barCount + 1;
bar6 = mean(psi2RasterCx4toTC2Mean_SWDs,'omitnan')-mean(psi2RasterCx4toTC2MeanThird10,'omitnan');
bar(barCount+(barGroupCount-1)*gap, bar6, 'FaceColor',colour, 'EdgeColor',colour);

% colour = cellColour('Cx4');
% barGroupCount = barGroupCount + 1;
% barCount = barCount + 1;
% bar10 = mean(psi2RasterCx4toNRTMeanSecond,'omitnan')-mean(psi2RasterCx4toNRTMeanFirst,'omitnan');
% bar(barCount+(barGroupCount-1)*gap, bar10, 'FaceColor',colour, 'EdgeColor',colour);
% barCount = barCount + 1;
% bar11 = mean(psi2RasterCx4toNRTMeanThird10,'omitnan')-mean(psi2RasterCx4toNRTMeanSecond,'omitnan');
% bar(barCount+(barGroupCount-1)*gap, bar11, 'FaceColor',colour, 'EdgeColor',colour);
% barCount = barCount + 1;
% bar12 = mean(psi2RasterCx4toNRTMean_SWDs,'omitnan')-mean(psi2RasterCx4toNRTMeanThird10,'omitnan');
% bar(barCount+(barGroupCount-1)*gap, bar12, 'FaceColor',colour, 'EdgeColor',colour);
% 
% colour = cellColour('Cx4');
% barGroupCount = barGroupCount + 1;
% barCount = barCount + 1;
% bar13 = mean(psi2RasterCx4toNRT2MeanSecond,'omitnan')-mean(psi2RasterCx4toNRT2MeanFirst,'omitnan');
% bar(barCount+(barGroupCount-1)*gap, bar13, 'FaceColor',colour, 'EdgeColor',colour);
% barCount = barCount + 1;
% bar14 = mean(psi2RasterCx4toNRT2MeanThird10,'omitnan')-mean(psi2RasterCx4toNRT2MeanSecond,'omitnan');
% bar(barCount+(barGroupCount-1)*gap, bar14, 'FaceColor',colour, 'EdgeColor',colour);
% barCount = barCount + 1;
% bar15 = mean(psi2RasterCx4toNRT2Mean_SWDs,'omitnan')-mean(psi2RasterCx4toNRT2MeanThird10,'omitnan');
% bar(barCount+(barGroupCount-1)*gap, bar15, 'FaceColor',colour, 'EdgeColor',colour);

% colour = cellColour('Cx5i');
% barGroupCount = barGroupCount + 1;
% barCount = barCount + 1;
% bar16 = mean(psi2RasterCx5toCx5iMeanSecond,'omitnan')-mean(psi2RasterCx5toCx5iMeanFirst,'omitnan');
% bar(barCount+(barGroupCount-1)*gap, bar16, 'FaceColor',colour, 'EdgeColor',colour);
% barCount = barCount + 1;
% bar17 = mean(psi2RasterCx5toCx5iMeanThird10,'omitnan')-mean(psi2RasterCx5toCx5iMeanSecond,'omitnan');
% bar(barCount+(barGroupCount-1)*gap, bar17, 'FaceColor',colour, 'EdgeColor',colour);
% barCount = barCount + 1;
% bar18 = mean(psi2RasterCx5toCx5iMean_SWDs,'omitnan')-mean(psi2RasterCx5toCx5iMeanThird10,'omitnan');
% bar(barCount+(barGroupCount-1)*gap, bar18, 'FaceColor',colour, 'EdgeColor',colour);

colour = cellColour('Cx5');
barGroupCount = barGroupCount + 1;
barCount = barCount + 1;
bar7 = mean(psi2RasterCx5toTCMeanSecond,'omitnan')-mean(psi2RasterCx5toTCMeanFirst,'omitnan');
bar(barCount+(barGroupCount-1)*gap, bar7, 'FaceColor',colour, 'EdgeColor',colour);
barCount = barCount + 1;
bar8 = mean(psi2RasterCx5toTCMeanThird10,'omitnan')-mean(psi2RasterCx5toTCMeanSecond,'omitnan');
bar(barCount+(barGroupCount-1)*gap, bar8, 'FaceColor',colour, 'EdgeColor',colour);
barCount = barCount + 1;
bar9 = mean(psi2RasterCx5toTCMean_SWDs,'omitnan')-mean(psi2RasterCx5toTCMeanThird10,'omitnan');
bar(barCount+(barGroupCount-1)*gap, bar9, 'FaceColor',colour, 'EdgeColor',colour);

colour = cellColour('Cx5');
barGroupCount = barGroupCount + 1;
barCount = barCount + 1;
bar10 = mean(psi2RasterCx5toTC2MeanSecond,'omitnan')-mean(psi2RasterCx5toTC2MeanFirst,'omitnan');
bar(barCount+(barGroupCount-1)*gap, bar10, 'FaceColor',colour, 'EdgeColor',colour);
barCount = barCount + 1;
bar11 = mean(psi2RasterCx5toTC2MeanThird10,'omitnan')-mean(psi2RasterCx5toTC2MeanSecond,'omitnan');
bar(barCount+(barGroupCount-1)*gap, bar11, 'FaceColor',colour, 'EdgeColor',colour);
barCount = barCount + 1;
bar12 = mean(psi2RasterCx5toTC2Mean_SWDs,'omitnan')-mean(psi2RasterCx5toTC2MeanThird10,'omitnan');
bar(barCount+(barGroupCount-1)*gap, bar12, 'FaceColor',colour, 'EdgeColor',colour);

colour = cellColour('Cx5');
barGroupCount = barGroupCount + 1;
barCount = barCount + 1;
bar13 = mean(psi2RasterCx5toNRTMeanSecond,'omitnan')-mean(psi2RasterCx5toNRTMeanFirst,'omitnan');
bar(barCount+(barGroupCount-1)*gap, bar13, 'FaceColor',colour, 'EdgeColor',colour);
barCount = barCount + 1;
bar14 = mean(psi2RasterCx5toNRTMeanThird10,'omitnan')-mean(psi2RasterCx5toNRTMeanSecond,'omitnan');
bar(barCount+(barGroupCount-1)*gap, bar14, 'FaceColor',colour, 'EdgeColor',colour);
barCount = barCount + 1;
bar15 = mean(psi2RasterCx5toNRTMean_SWDs,'omitnan')-mean(psi2RasterCx5toNRTMeanThird10,'omitnan');
bar(barCount+(barGroupCount-1)*gap, bar15, 'FaceColor',colour, 'EdgeColor',colour);

colour = cellColour('Cx5');
barGroupCount = barGroupCount + 1;
barCount = barCount + 1;
bar16 = mean(psi2RasterCx5toNRT2MeanSecond,'omitnan')-mean(psi2RasterCx5toNRT2MeanFirst,'omitnan');
bar(barCount+(barGroupCount-1)*gap, bar16, 'FaceColor',colour, 'EdgeColor',colour);
barCount = barCount + 1;
bar17 = mean(psi2RasterCx5toNRT2MeanThird10,'omitnan')-mean(psi2RasterCx5toNRT2MeanSecond,'omitnan');
bar(barCount+(barGroupCount-1)*gap, bar17, 'FaceColor',colour, 'EdgeColor',colour);
barCount = barCount + 1;
bar18 = mean(psi2RasterCx5toNRT2Mean_SWDs,'omitnan')-mean(psi2RasterCx5toNRT2MeanThird10,'omitnan');
bar(barCount+(barGroupCount-1)*gap, bar18, 'FaceColor',colour, 'EdgeColor',colour);

colour = cellColour('NRT');
barGroupCount = barGroupCount + 1;
barCount = barCount + 1;
bar19 = mean(psi2RasterNRTtoTCMeanSecond,'omitnan')-mean(psi2RasterNRTtoTCMeanFirst,'omitnan');
bar(barCount+(barGroupCount-1)*gap, bar19, 'FaceColor',colour, 'EdgeColor',colour);
barCount = barCount + 1;
bar20 = mean(psi2RasterNRTtoTCMeanThird10,'omitnan')-mean(psi2RasterNRTtoTCMeanSecond,'omitnan');
bar(barCount+(barGroupCount-1)*gap, bar20, 'FaceColor',colour, 'EdgeColor',colour);
barCount = barCount + 1;
bar21 = mean(psi2RasterNRTtoTCMean_SWDs,'omitnan')-mean(psi2RasterNRTtoTCMeanThird10,'omitnan');
bar(barCount+(barGroupCount-1)*gap, bar21, 'FaceColor',colour, 'EdgeColor',colour);

colour = cellColour('NRT');
barGroupCount = barGroupCount + 1;
barCount = barCount + 1;
bar22 = mean(psi2RasterNRTtoTC2MeanSecond,'omitnan')-mean(psi2RasterNRTtoTC2MeanFirst,'omitnan');
bar(barCount+(barGroupCount-1)*gap, bar22, 'FaceColor',colour, 'EdgeColor',colour);
barCount = barCount + 1;
bar23 = mean(psi2RasterNRTtoTC2MeanThird10,'omitnan')-mean(psi2RasterNRTtoTC2MeanSecond,'omitnan');
bar(barCount+(barGroupCount-1)*gap, bar23, 'FaceColor',colour, 'EdgeColor',colour);
barCount = barCount + 1;
bar24 = mean(psi2RasterNRTtoTC2Mean_SWDs,'omitnan')-mean(psi2RasterNRTtoTC2MeanThird10,'omitnan');
bar(barCount+(barGroupCount-1)*gap, bar24, 'FaceColor',colour, 'EdgeColor',colour);

colour = cellColour('NRT2');
barGroupCount = barGroupCount + 1;
barCount = barCount + 1;
bar25 = mean(psi2RasterNRT2toTCMeanSecond,'omitnan')-mean(psi2RasterNRT2toTCMeanFirst,'omitnan');
bar(barCount+(barGroupCount-1)*gap, bar25, 'FaceColor',colour, 'EdgeColor',colour);
barCount = barCount + 1;
bar26 = mean(psi2RasterNRT2toTCMeanThird10,'omitnan')-mean(psi2RasterNRT2toTCMeanSecond,'omitnan');
bar(barCount+(barGroupCount-1)*gap, bar26, 'FaceColor',colour, 'EdgeColor',colour);
barCount = barCount + 1;
bar27 = mean(psi2RasterNRT2toTCMean_SWDs,'omitnan')-mean(psi2RasterNRT2toTCMeanThird10,'omitnan');
bar(barCount+(barGroupCount-1)*gap, bar27, 'FaceColor',colour, 'EdgeColor',colour);

colour = cellColour('NRT2');
barGroupCount = barGroupCount + 1;
barCount = barCount + 1;
bar28 = mean(psi2RasterNRT2toTC2MeanSecond,'omitnan')-mean(psi2RasterNRT2toTC2MeanFirst,'omitnan');
bar(barCount+(barGroupCount-1)*gap, bar28, 'FaceColor',colour, 'EdgeColor',colour);
barCount = barCount + 1;
bar29 = mean(psi2RasterNRT2toTC2MeanThird10,'omitnan')-mean(psi2RasterNRT2toTC2MeanSecond,'omitnan');
bar(barCount+(barGroupCount-1)*gap, bar29, 'FaceColor',colour, 'EdgeColor',colour);
barCount = barCount + 1;
bar30 = mean(psi2RasterNRT2toTC2Mean_SWDs,'omitnan')-mean(psi2RasterNRT2toTC2MeanThird10,'omitnan');
bar(barCount+(barGroupCount-1)*gap, bar30, 'FaceColor',colour, 'EdgeColor',colour);

colour = cellColour('NRT');
barGroupCount = barGroupCount + 1;
barCount = barCount + 1;
bar31 = mean(psi2RasterNRTtoNRT2MeanSecond,'omitnan')-mean(psi2RasterNRTtoNRT2MeanFirst,'omitnan');
bar(barCount+(barGroupCount-1)*gap, bar31, 'FaceColor',colour, 'EdgeColor',colour);
barCount = barCount + 1;
bar32 = mean(psi2RasterNRTtoNRT2MeanThird10,'omitnan')-mean(psi2RasterNRTtoNRT2MeanSecond,'omitnan');
bar(barCount+(barGroupCount-1)*gap, bar32, 'FaceColor',colour, 'EdgeColor',colour);
barCount = barCount + 1;
bar33 = mean(psi2RasterNRTtoNRT2Mean_SWDs,'omitnan')-mean(psi2RasterNRTtoNRT2MeanThird10,'omitnan');
bar(barCount+(barGroupCount-1)*gap, bar33, 'FaceColor',colour, 'EdgeColor',colour);

% colour = cellColour('TC');
% barGroupCount = barGroupCount + 1;
% barCount = barCount + 1;
% bar28 = mean(psi2RasterTCtoTC2MeanSecond,'omitnan')-mean(psi2RasterTCtoTC2MeanFirst,'omitnan');
% bar(barCount+(barGroupCount-1)*gap, bar28, 'FaceColor',colour, 'EdgeColor',colour);
% barCount = barCount + 1;
% bar29 = mean(psi2RasterTCtoTC2MeanThird10,'omitnan')-mean(psi2RasterTCtoTC2MeanSecond,'omitnan');
% bar(barCount+(barGroupCount-1)*gap, bar29, 'FaceColor',colour, 'EdgeColor',colour);
% barCount = barCount + 1;
% bar30 = mean(psi2RasterTCtoTC2Mean_SWDs,'omitnan')-mean(psi2RasterTCtoTC2MeanThird10,'omitnan');
% bar(barCount+(barGroupCount-1)*gap, bar30, 'FaceColor',colour, 'EdgeColor',colour);


%% Error bars
gaps1 = 4:4:(barGroupCount-1)*4;
bars = sort([1 1+gaps1 2 2+gaps1 3 3+gaps1]);
% data = [bar1 bar2 bar3 bar4 bar5 bar6 bar7 bar8 bar9 bar10 bar11 bar12 bar13 bar14 bar15 bar16...
%         bar17 bar18 bar19 bar20 bar21 bar22 bar23 bar24 bar25 bar26 bar27 bar28 bar29 bar30 bar31 bar32...
%         bar33 bar34 bar35 bar36 bar37 bar38 bar39 bar40 bar41 bar42 bar43 bar44 bar45 bar46 bar47 bar48];
% err = [psi2RasterCx4toCx4iCI95Second psi2RasterCx4toCx4iCI95Third10 psi2RasterCx4toCx4iCI95_SWDs...
%        psi2RasterCx4toTCCI95Second psi2RasterCx4toTCCI95Third10 psi2RasterCx4toTCCI95_SWDs...
%        psi2RasterCx4toTC2CI95Second psi2RasterCx4toTC2CI95Third10 psi2RasterCx4toTC2CI95_SWDs...
%        psi2RasterCx4toNRTCI95Second psi2RasterCx4toNRTCI95Third10 psi2RasterCx4toNRTCI95_SWDs...
%        psi2RasterCx4toNRT2CI95Second psi2RasterCx4toNRT2CI95Third10 psi2RasterCx4toNRT2CI95_SWDs...
%        psi2RasterCx5toCx5iCI95Second psi2RasterCx5toCx5iCI95Third10 psi2RasterCx5toCx5iCI95_SWDs...
%        psi2RasterCx5toTCCI95Second psi2RasterCx5toTCCI95Third10 psi2RasterCx5toTCCI95_SWDs...
%        psi2RasterCx5toTC2CI95Second psi2RasterCx5toTC2CI95Third10 psi2RasterCx5toTC2CI95_SWDs...
%        psi2RasterCx5toNRTCI95Second psi2RasterCx5toNRTCI95Third10 psi2RasterCx5toNRTCI95_SWDs...
%        psi2RasterCx5toNRT2CI95Second psi2RasterCx5toNRT2CI95Third10 psi2RasterCx5toNRT2CI95_SWDs...
%        psi2RasterNRTtoTCCI95Second psi2RasterNRTtoTCCI95Third10 psi2RasterNRTtoTCCI95_SWDs...
%        psi2RasterNRTtoTC2CI95Second psi2RasterNRTtoTC2CI95Third10 psi2RasterNRTtoTC2CI95_SWDs...
%        psi2RasterNRT2toTCCI95Second psi2RasterNRT2toTCCI95Third10 psi2RasterNRT2toTCCI95_SWDs...
%        psi2RasterNRT2toTC2CI95Second psi2RasterNRT2toTC2CI95Third10 psi2RasterNRT2toTC2CI95_SWDs...
%        psi2RasterNRTtoNRT2CI95Second psi2RasterNRTtoNRT2CI95Third10 psi2RasterNRTtoNRT2CI95_SWDs...
%        psi2RasterTCtoTC2CI95Second psi2RasterTCtoTC2CI95Third10 psi2RasterTCtoTC2CI95_SWDs];
data = [bar1 bar2 bar3 bar4 bar5 bar6 bar7 bar8 bar9 bar10 bar11 bar12 bar13 bar14 bar15 bar16...
        bar17 bar18 bar19 bar20 bar21 bar22 bar23 bar24 bar25 bar26 bar27 bar28 bar29 bar30 bar31 bar32 bar33];
err = [psi2RasterCx4toTCCI95Second psi2RasterCx4toTCCI95Third10 psi2RasterCx4toTCCI95_SWDs...
       psi2RasterCx4toTC2CI95Second psi2RasterCx4toTC2CI95Third10 psi2RasterCx4toTC2CI95_SWDs...
       psi2RasterCx5toTCCI95Second psi2RasterCx5toTCCI95Third10 psi2RasterCx5toTCCI95_SWDs...
       psi2RasterCx5toTC2CI95Second psi2RasterCx5toTC2CI95Third10 psi2RasterCx5toTC2CI95_SWDs...
       psi2RasterCx5toNRTCI95Second psi2RasterCx5toNRTCI95Third10 psi2RasterCx5toNRTCI95_SWDs...
       psi2RasterCx5toNRT2CI95Second psi2RasterCx5toNRT2CI95Third10 psi2RasterCx5toNRT2CI95_SWDs...
       psi2RasterNRTtoTCCI95Second psi2RasterNRTtoTCCI95Third10 psi2RasterNRTtoTCCI95_SWDs...
       psi2RasterNRTtoTC2CI95Second psi2RasterNRTtoTC2CI95Third10 psi2RasterNRTtoTC2CI95_SWDs...
       psi2RasterNRT2toTCCI95Second psi2RasterNRT2toTCCI95Third10 psi2RasterNRT2toTCCI95_SWDs...
       psi2RasterNRT2toTC2CI95Second psi2RasterNRT2toTC2CI95Third10 psi2RasterNRT2toTC2CI95_SWDs...
       psi2RasterNRTtoNRT2CI95Second psi2RasterNRTtoNRT2CI95Third10 psi2RasterNRTtoNRT2CI95_SWDs];

er = errorbar(bars,data,err(2,:),err(1,:));
er.Color = [0 0 0];
er.LineStyle = 'none';
hold off


%% Graph adjustments
yLim = ylim;
ax1 = axesProperties({}, 1, 'normal', 'off', 'w', 'Arial', 50, 4/3, 2, [0.003 0.003], 'out', 'on', 'k', {}, [],...
    [gaps1 gaps1(end)+4], 'on', 'k', {''}, [-0.04 0.042], [-0.04 -0.02 0 0.02 0.04]);
ax1.XTickLabel = {'','','','','','','','',''};

label = [5 0.7];
margin = [0.01 0.7];
width = 45-label(1)-margin(1);
height = (25.625/77.296)*45-label(2)-margin(2);
paperSize = resizeFig(gcf, ax1, width, height, label, margin, 0);
savefig(gcf, 'psiEvoBetween.fig', 'compact');
%exportFig(gcf, 'psiEvo.png','-dpng','-r300', paperSize);
%exportFig(gcf, 'psiEvo'.tif','-dtiffnocompression','-r300', paperSize);
exportFig(gcf, 'psiEvoBetween.eps','-depsc','-r1200', paperSize);