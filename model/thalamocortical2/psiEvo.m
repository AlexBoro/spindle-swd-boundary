cleanUp

load('psiData2.mat');

f10 = figProperties('PSI evolution', 'normalized', [0, .005, .97, .90], 'w', 'on');
hold on


%% Data bars for PSI within areas
gap = 1;

colour = cellColour('Cx23');
barGroupCount = 1;
barCount = 1;
bar(barCount+(barGroupCount-1)*gap, mean(psi2RasterCx23MeanSecond,'omitnan'), 'FaceColor',colour, 'EdgeColor',colour);
barCount = barCount + 1;
bar(barCount+(barGroupCount-1)*gap, mean(psi2RasterCx23MeanThird10,'omitnan'), 'FaceColor',colour, 'EdgeColor',colour);
barCount = barCount + 1;
bar(barCount+(barGroupCount-1)*gap, mean(psi2RasterCx23Mean_SWDs,'omitnan'), 'FaceColor',colour, 'EdgeColor',colour);

colour = cellColour('Cx23i');
barGroupCount = barGroupCount + 1;
barCount = barCount + 1;
bar(barCount+(barGroupCount-1)*gap, mean(psi2RasterCx23iMeanSecond,'omitnan'), 'FaceColor',colour, 'EdgeColor',colour);
barCount = barCount + 1;
bar(barCount+(barGroupCount-1)*gap, mean(psi2RasterCx23iMeanThird10,'omitnan'), 'FaceColor',colour, 'EdgeColor',colour);
barCount = barCount + 1;
bar(barCount+(barGroupCount-1)*gap, mean(psi2RasterCx23iMean_SWDs,'omitnan'), 'FaceColor',colour, 'EdgeColor',colour);

colour = cellColour('Cx4');
barGroupCount = barGroupCount + 1;
barCount = barCount + 1;
bar(barCount+(barGroupCount-1)*gap, mean(psi2RasterCx4MeanSecond,'omitnan'), 'FaceColor',colour, 'EdgeColor',colour);
barCount = barCount + 1;
bar(barCount+(barGroupCount-1)*gap, mean(psi2RasterCx4MeanThird10,'omitnan'), 'FaceColor',colour, 'EdgeColor',colour);
barCount = barCount + 1;
bar(barCount+(barGroupCount-1)*gap, mean(psi2RasterCx4Mean_SWDs,'omitnan'), 'FaceColor',colour, 'EdgeColor',colour);

colour = cellColour('Cx4i');
barGroupCount = barGroupCount + 1;
barCount = barCount + 1;
bar(barCount+(barGroupCount-1)*gap, mean(psi2RasterCx4iMeanSecond,'omitnan'), 'FaceColor',colour, 'EdgeColor',colour);
barCount = barCount + 1;
bar(barCount+(barGroupCount-1)*gap, mean(psi2RasterCx4iMeanThird10,'omitnan'), 'FaceColor',colour, 'EdgeColor',colour);
barCount = barCount + 1;
bar(barCount+(barGroupCount-1)*gap, mean(psi2RasterCx4iMean_SWDs,'omitnan'), 'FaceColor',colour, 'EdgeColor',colour);

colour = cellColour('Cx5');
barGroupCount = barGroupCount + 1;
barCount = barCount + 1;
bar(barCount+(barGroupCount-1)*gap, mean(psi2RasterCx5MeanSecond,'omitnan'), 'FaceColor',colour, 'EdgeColor',colour);
barCount = barCount + 1;
bar(barCount+(barGroupCount-1)*gap, mean(psi2RasterCx5MeanThird10,'omitnan'), 'FaceColor',colour, 'EdgeColor',colour);
barCount = barCount + 1;
bar(barCount+(barGroupCount-1)*gap, mean(psi2RasterCx5Mean_SWDs,'omitnan'), 'FaceColor',colour, 'EdgeColor',colour);

colour = cellColour('Cx5i');
barGroupCount = barGroupCount + 1;
barCount = barCount + 1;
bar(barCount+(barGroupCount-1)*gap, mean(psi2RasterCx5iMeanSecond,'omitnan'), 'FaceColor',colour, 'EdgeColor',colour);
barCount = barCount + 1;
bar(barCount+(barGroupCount-1)*gap, mean(psi2RasterCx5iMeanThird10,'omitnan'), 'FaceColor',colour, 'EdgeColor',colour);
barCount = barCount + 1;
bar(barCount+(barGroupCount-1)*gap, mean(psi2RasterCx5iMean_SWDs,'omitnan'), 'FaceColor',colour, 'EdgeColor',colour);

colour = cellColour('Cx6');
barGroupCount = barGroupCount + 1;
barCount = barCount + 1;
bar(barCount+(barGroupCount-1)*gap, mean(psi2RasterCx6MeanSecond,'omitnan'), 'FaceColor',colour, 'EdgeColor',colour);
barCount = barCount + 1;
bar(barCount+(barGroupCount-1)*gap, mean(psi2RasterCx6MeanThird10,'omitnan'), 'FaceColor',colour, 'EdgeColor',colour);
barCount = barCount + 1;
bar(barCount+(barGroupCount-1)*gap, mean(psi2RasterCx6Mean_SWDs,'omitnan'), 'FaceColor',colour, 'EdgeColor',colour);

colour = cellColour('Cx6i');
barGroupCount = barGroupCount + 1;
barCount = barCount + 1;
bar(barCount+(barGroupCount-1)*gap, mean(psi2RasterCx6iMeanSecond,'omitnan'), 'FaceColor',colour, 'EdgeColor',colour);
barCount = barCount + 1;
bar(barCount+(barGroupCount-1)*gap, mean(psi2RasterCx6iMeanThird10,'omitnan'), 'FaceColor',colour, 'EdgeColor',colour);
barCount = barCount + 1;
bar(barCount+(barGroupCount-1)*gap, mean(psi2RasterCx6iMean_SWDs,'omitnan'), 'FaceColor',colour, 'EdgeColor',colour);

colour = cellColour('TC');
barGroupCount = barGroupCount + 1;
barCount = barCount + 1;
bar(barCount+(barGroupCount-1)*gap, mean(psi2RasterTCMeanSecond,'omitnan'), 'FaceColor',colour, 'EdgeColor',colour);
barCount = barCount + 1;
bar(barCount+(barGroupCount-1)*gap, mean(psi2RasterTCMeanThird10,'omitnan'), 'FaceColor',colour, 'EdgeColor',colour);
barCount = barCount + 1;
bar(barCount+(barGroupCount-1)*gap, mean(psi2RasterTCMean_SWDs,'omitnan'), 'FaceColor',colour, 'EdgeColor',colour);

colour = cellColour('TC2');
barGroupCount = barGroupCount + 1;
barCount = barCount + 1;
bar(barCount+(barGroupCount-1)*gap, mean(psi2RasterTC2MeanSecond,'omitnan'), 'FaceColor',colour, 'EdgeColor',colour);
barCount = barCount + 1;
bar(barCount+(barGroupCount-1)*gap, mean(psi2RasterTC2MeanThird10,'omitnan'), 'FaceColor',colour, 'EdgeColor',colour);
barCount = barCount + 1;
bar(barCount+(barGroupCount-1)*gap, mean(psi2RasterTC2Mean_SWDs,'omitnan'), 'FaceColor',colour, 'EdgeColor',colour);

colour = cellColour('NRT');
barGroupCount = barGroupCount + 1;
barCount = barCount + 1;
bar(barCount+(barGroupCount-1)*gap, mean(psi2RasterNRTMeanSecond,'omitnan'), 'FaceColor',colour, 'EdgeColor',colour);
barCount = barCount + 1;
bar(barCount+(barGroupCount-1)*gap, mean(psi2RasterNRTMeanThird10,'omitnan'), 'FaceColor',colour, 'EdgeColor',colour);
barCount = barCount + 1;
bar(barCount+(barGroupCount-1)*gap, mean(psi2RasterNRTMean_SWDs,'omitnan'), 'FaceColor',colour, 'EdgeColor',colour);

colour = cellColour('NRT2');
barGroupCount = barGroupCount + 1;
barCount = barCount + 1;
bar(barCount+(barGroupCount-1)*gap, mean(psi2RasterNRT2MeanSecond,'omitnan'), 'FaceColor',colour, 'EdgeColor',colour);
barCount = barCount + 1;
bar(barCount+(barGroupCount-1)*gap, mean(psi2RasterNRT2MeanThird10,'omitnan'), 'FaceColor',colour, 'EdgeColor',colour);
barCount = barCount + 1;
bar(barCount+(barGroupCount-1)*gap, mean(psi2RasterNRT2Mean_SWDs,'omitnan'), 'FaceColor',colour, 'EdgeColor',colour);


%% Error bars
gaps1 = 4:4:(barGroupCount-1)*4;
bars = sort([1 1+gaps1 2 2+gaps1 3 3+gaps1]);
data = [mean(psi2RasterCx23MeanSecond,'omitnan') mean(psi2RasterCx23MeanThird10,'omitnan') mean(psi2RasterCx23Mean_SWDs,'omitnan') mean(psi2RasterCx23iMeanSecond,'omitnan') mean(psi2RasterCx23iMeanThird10,'omitnan') mean(psi2RasterCx23iMean_SWDs,'omitnan') mean(psi2RasterCx4MeanSecond,'omitnan') mean(psi2RasterCx4MeanThird10,'omitnan') mean(psi2RasterCx4Mean_SWDs,'omitnan')...
        mean(psi2RasterCx4iMeanSecond,'omitnan') mean(psi2RasterCx4iMeanThird10,'omitnan') mean(psi2RasterCx4iMean_SWDs,'omitnan') mean(psi2RasterCx5MeanSecond,'omitnan') mean(psi2RasterCx5MeanThird10,'omitnan') mean(psi2RasterCx5Mean_SWDs,'omitnan') mean(psi2RasterCx5iMeanSecond,'omitnan') mean(psi2RasterCx5iMeanThird10,'omitnan') mean(psi2RasterCx5iMean_SWDs,'omitnan')...
        mean(psi2RasterCx6MeanSecond,'omitnan') mean(psi2RasterCx6MeanThird10,'omitnan') mean(psi2RasterCx6Mean_SWDs,'omitnan') mean(psi2RasterCx6iMeanSecond,'omitnan') mean(psi2RasterCx6iMeanThird10,'omitnan') mean(psi2RasterCx6iMean_SWDs,'omitnan') mean(psi2RasterTCMeanSecond,'omitnan') mean(psi2RasterTCMeanThird10,'omitnan') mean(psi2RasterTCMean_SWDs,'omitnan')...
        mean(psi2RasterTC2MeanSecond,'omitnan') mean(psi2RasterTC2MeanThird10,'omitnan') mean(psi2RasterTC2Mean_SWDs,'omitnan') mean(psi2RasterNRTMeanSecond,'omitnan') mean(psi2RasterNRTMeanThird10,'omitnan') mean(psi2RasterNRTMean_SWDs,'omitnan') mean(psi2RasterNRT2MeanSecond,'omitnan') mean(psi2RasterNRT2MeanThird10,'omitnan') mean(psi2RasterNRT2Mean_SWDs,'omitnan')];
err = [psi2RasterCx23CI95Second psi2RasterCx23CI95Third10 psi2RasterCx23CI95_SWDs psi2RasterCx23iCI95Second psi2RasterCx23iCI95Third10 psi2RasterCx23iCI95_SWDs psi2RasterCx4CI95Second psi2RasterCx4CI95Third10 psi2RasterCx4CI95_SWDs...
       psi2RasterCx4iCI95Second psi2RasterCx4iCI95Third10 psi2RasterCx4iCI95_SWDs psi2RasterCx5CI95Second psi2RasterCx5CI95Third10 psi2RasterCx5CI95_SWDs psi2RasterCx5iCI95Second psi2RasterCx5iCI95Third10 psi2RasterCx5iCI95_SWDs...
       psi2RasterCx6CI95Second psi2RasterCx6CI95Third10 psi2RasterCx6CI95_SWDs psi2RasterCx6iCI95Second psi2RasterCx6iCI95Third10 psi2RasterCx6iCI95_SWDs psi2RasterTCCI95Second psi2RasterTCCI95Third10 psi2RasterTCCI95_SWDs...
       psi2RasterTC2CI95Second psi2RasterTC2CI95Third10 psi2RasterTC2CI95_SWDs psi2RasterNRTCI95Second psi2RasterNRTCI95Third10 psi2RasterNRTCI95_SWDs psi2RasterNRT2CI95Second psi2RasterNRT2CI95Third10 psi2RasterNRT2CI95_SWDs];

er = errorbar(bars,data,err(2,:),err(1,:));
er.Color = [0 0 0];
er.LineStyle = 'none';


%% Data bars for PSI between areas
load('psiData3.mat');

colour = cellColour('Cx23i');
barGroupCount2 = barGroupCount + 1;
barCount2 = barCount + 1;
bar(barCount2+(barGroupCount2-1)*gap, mean(psi2RasterCx23toCx23iMeanSecond,'omitnan'), 'FaceColor',colour, 'EdgeColor',colour);
barCount2 = barCount2 + 1;
bar(barCount2+(barGroupCount2-1)*gap, mean(psi2RasterCx23toCx23iMeanThird10,'omitnan'), 'FaceColor',colour, 'EdgeColor',colour);
barCount2 = barCount2 + 1;
bar(barCount2+(barGroupCount2-1)*gap, mean(psi2RasterCx23toCx23iMean_SWDs,'omitnan'), 'FaceColor',colour, 'EdgeColor',colour);

colour = cellColour('Cx23');
barGroupCount2 = barGroupCount2 + 1;
barCount2 = barCount2 + 1;
bar(barCount2+(barGroupCount2-1)*gap, mean(psi2RasterCx23toTCMeanSecond,'omitnan'), 'FaceColor',colour, 'EdgeColor',colour);
barCount2 = barCount2 + 1;
bar(barCount2+(barGroupCount2-1)*gap, mean(psi2RasterCx23toTCMeanThird10,'omitnan'), 'FaceColor',colour, 'EdgeColor',colour);
barCount2 = barCount2 + 1;
bar(barCount2+(barGroupCount2-1)*gap, mean(psi2RasterCx23toTCMean_SWDs,'omitnan'), 'FaceColor',colour, 'EdgeColor',colour);

colour = cellColour('Cx23');
barGroupCount2 = barGroupCount2 + 1;
barCount2 = barCount2 + 1;
bar(barCount2+(barGroupCount2-1)*gap, mean(psi2RasterCx23toTC2MeanSecond,'omitnan'), 'FaceColor',colour, 'EdgeColor',colour);
barCount2 = barCount2 + 1;
bar(barCount2+(barGroupCount2-1)*gap, mean(psi2RasterCx23toTC2MeanThird10,'omitnan'), 'FaceColor',colour, 'EdgeColor',colour);
barCount2 = barCount2 + 1;
bar(barCount2+(barGroupCount2-1)*gap, mean(psi2RasterCx23toTC2Mean_SWDs,'omitnan'), 'FaceColor',colour, 'EdgeColor',colour);

colour = cellColour('Cx23');
barGroupCount2 = barGroupCount2 + 1;
barCount2 = barCount2 + 1;
bar(barCount2+(barGroupCount2-1)*gap, mean(psi2RasterCx23toNRTMeanSecond,'omitnan'), 'FaceColor',colour, 'EdgeColor',colour);
barCount2 = barCount2 + 1;
bar(barCount2+(barGroupCount2-1)*gap, mean(psi2RasterCx23toNRTMeanThird10,'omitnan'), 'FaceColor',colour, 'EdgeColor',colour);
barCount2 = barCount2 + 1;
bar(barCount2+(barGroupCount2-1)*gap, mean(psi2RasterCx23toNRTMean_SWDs,'omitnan'), 'FaceColor',colour, 'EdgeColor',colour);

colour = cellColour('Cx23');
barGroupCount2 = barGroupCount2 + 1;
barCount2 = barCount2 + 1;
bar(barCount2+(barGroupCount2-1)*gap, mean(psi2RasterCx23toNRT2MeanSecond,'omitnan'), 'FaceColor',colour, 'EdgeColor',colour);
barCount2 = barCount2 + 1;
bar(barCount2+(barGroupCount2-1)*gap, mean(psi2RasterCx23toNRT2MeanThird10,'omitnan'), 'FaceColor',colour, 'EdgeColor',colour);
barCount2 = barCount2 + 1;
bar(barCount2+(barGroupCount2-1)*gap, mean(psi2RasterCx23toNRT2Mean_SWDs,'omitnan'), 'FaceColor',colour, 'EdgeColor',colour);

colour = cellColour('Cx4i');
barGroupCount2 = barGroupCount2 + 1;
barCount2 = barCount2 + 1;
bar(barCount2+(barGroupCount2-1)*gap, mean(psi2RasterCx4toCx4iMeanSecond,'omitnan'), 'FaceColor',colour, 'EdgeColor',colour);
barCount2 = barCount2 + 1;
bar(barCount2+(barGroupCount2-1)*gap, mean(psi2RasterCx4toCx4iMeanThird10,'omitnan'), 'FaceColor',colour, 'EdgeColor',colour);
barCount2 = barCount2 + 1;
bar(barCount2+(barGroupCount2-1)*gap, mean(psi2RasterCx4toCx4iMean_SWDs,'omitnan'), 'FaceColor',colour, 'EdgeColor',colour);

colour = cellColour('Cx4');
barGroupCount2 = barGroupCount2 + 1;
barCount2 = barCount2 + 1;
bar(barCount2+(barGroupCount2-1)*gap, mean(psi2RasterCx4toTCMeanSecond,'omitnan'), 'FaceColor',colour, 'EdgeColor',colour);
barCount2 = barCount2 + 1;
bar(barCount2+(barGroupCount2-1)*gap, mean(psi2RasterCx4toTCMeanThird10,'omitnan'), 'FaceColor',colour, 'EdgeColor',colour);
barCount2 = barCount2 + 1;
bar(barCount2+(barGroupCount2-1)*gap, mean(psi2RasterCx4toTCMean_SWDs,'omitnan'), 'FaceColor',colour, 'EdgeColor',colour);

colour = cellColour('Cx4');
barGroupCount2 = barGroupCount2 + 1;
barCount2 = barCount2 + 1;
bar(barCount2+(barGroupCount2-1)*gap, mean(psi2RasterCx4toTC2MeanSecond,'omitnan'), 'FaceColor',colour, 'EdgeColor',colour);
barCount2 = barCount2 + 1;
bar(barCount2+(barGroupCount2-1)*gap, mean(psi2RasterCx4toTC2MeanThird10,'omitnan'), 'FaceColor',colour, 'EdgeColor',colour);
barCount2 = barCount2 + 1;
bar(barCount2+(barGroupCount2-1)*gap, mean(psi2RasterCx4toTC2Mean_SWDs,'omitnan'), 'FaceColor',colour, 'EdgeColor',colour);

colour = cellColour('Cx4');
barGroupCount2 = barGroupCount2 + 1;
barCount2 = barCount2 + 1;
bar(barCount2+(barGroupCount2-1)*gap, mean(psi2RasterCx4toNRTMeanSecond,'omitnan'), 'FaceColor',colour, 'EdgeColor',colour);
barCount2 = barCount2 + 1;
bar(barCount2+(barGroupCount2-1)*gap, mean(psi2RasterCx4toNRTMeanThird10,'omitnan'), 'FaceColor',colour, 'EdgeColor',colour);
barCount2 = barCount2 + 1;
bar(barCount2+(barGroupCount2-1)*gap, mean(psi2RasterCx4toNRTMean_SWDs,'omitnan'), 'FaceColor',colour, 'EdgeColor',colour);

colour = cellColour('Cx4');
barGroupCount2 = barGroupCount2 + 1;
barCount2 = barCount2 + 1;
bar(barCount2+(barGroupCount2-1)*gap, mean(psi2RasterCx4toNRT2MeanSecond,'omitnan'), 'FaceColor',colour, 'EdgeColor',colour);
barCount2 = barCount2 + 1;
bar(barCount2+(barGroupCount2-1)*gap, mean(psi2RasterCx4toNRT2MeanThird10,'omitnan'), 'FaceColor',colour, 'EdgeColor',colour);
barCount2 = barCount2 + 1;
bar(barCount2+(barGroupCount2-1)*gap, mean(psi2RasterCx4toNRT2Mean_SWDs,'omitnan'), 'FaceColor',colour, 'EdgeColor',colour);

colour = cellColour('Cx5i');
barGroupCount2 = barGroupCount2 + 1;
barCount2 = barCount2 + 1;
bar(barCount2+(barGroupCount2-1)*gap, mean(psi2RasterCx5toCx5iMeanSecond,'omitnan'), 'FaceColor',colour, 'EdgeColor',colour);
barCount2 = barCount2 + 1;
bar(barCount2+(barGroupCount2-1)*gap, mean(psi2RasterCx5toCx5iMeanThird10,'omitnan'), 'FaceColor',colour, 'EdgeColor',colour);
barCount2 = barCount2 + 1;
bar(barCount2+(barGroupCount2-1)*gap, mean(psi2RasterCx5toCx5iMean_SWDs,'omitnan'), 'FaceColor',colour, 'EdgeColor',colour);

colour = cellColour('Cx5');
barGroupCount2 = barGroupCount2 + 1;
barCount2 = barCount2 + 1;
bar(barCount2+(barGroupCount2-1)*gap, mean(psi2RasterCx5toTCMeanSecond,'omitnan'), 'FaceColor',colour, 'EdgeColor',colour);
barCount2 = barCount2 + 1;
bar(barCount2+(barGroupCount2-1)*gap, mean(psi2RasterCx5toTCMeanThird10,'omitnan'), 'FaceColor',colour, 'EdgeColor',colour);
barCount2 = barCount2 + 1;
bar(barCount2+(barGroupCount2-1)*gap, mean(psi2RasterCx5toTCMean_SWDs,'omitnan'), 'FaceColor',colour, 'EdgeColor',colour);

colour = cellColour('Cx5');
barGroupCount2 = barGroupCount2 + 1;
barCount2 = barCount2 + 1;
bar(barCount2+(barGroupCount2-1)*gap, mean(psi2RasterCx5toTC2MeanSecond,'omitnan'), 'FaceColor',colour, 'EdgeColor',colour);
barCount2 = barCount2 + 1;
bar(barCount2+(barGroupCount2-1)*gap, mean(psi2RasterCx5toTC2MeanThird10,'omitnan'), 'FaceColor',colour, 'EdgeColor',colour);
barCount2 = barCount2 + 1;
bar(barCount2+(barGroupCount2-1)*gap, mean(psi2RasterCx5toTC2Mean_SWDs,'omitnan'), 'FaceColor',colour, 'EdgeColor',colour);

colour = cellColour('Cx5');
barGroupCount2 = barGroupCount2 + 1;
barCount2 = barCount2 + 1;
bar(barCount2+(barGroupCount2-1)*gap, mean(psi2RasterCx5toNRTMeanSecond,'omitnan'), 'FaceColor',colour, 'EdgeColor',colour);
barCount2 = barCount2 + 1;
bar(barCount2+(barGroupCount2-1)*gap, mean(psi2RasterCx5toNRTMeanThird10,'omitnan'), 'FaceColor',colour, 'EdgeColor',colour);
barCount2 = barCount2 + 1;
bar(barCount2+(barGroupCount2-1)*gap, mean(psi2RasterCx5toNRTMean_SWDs,'omitnan'), 'FaceColor',colour, 'EdgeColor',colour);

colour = cellColour('Cx5');
barGroupCount2 = barGroupCount2 + 1;
barCount2 = barCount2 + 1;
bar(barCount2+(barGroupCount2-1)*gap, mean(psi2RasterCx5toNRT2MeanSecond,'omitnan'), 'FaceColor',colour, 'EdgeColor',colour);
barCount2 = barCount2 + 1;
bar(barCount2+(barGroupCount2-1)*gap, mean(psi2RasterCx5toNRT2MeanThird10,'omitnan'), 'FaceColor',colour, 'EdgeColor',colour);
barCount2 = barCount2 + 1;
bar(barCount2+(barGroupCount2-1)*gap, mean(psi2RasterCx5toNRT2Mean_SWDs,'omitnan'), 'FaceColor',colour, 'EdgeColor',colour);

colour = cellColour('Cx6i');
barGroupCount2 = barGroupCount2 + 1;
barCount2 = barCount2 + 1;
bar(barCount2+(barGroupCount2-1)*gap, mean(psi2RasterCx6toCx6iMeanSecond,'omitnan'), 'FaceColor',colour, 'EdgeColor',colour);
barCount2 = barCount2 + 1;
bar(barCount2+(barGroupCount2-1)*gap, mean(psi2RasterCx6toCx6iMeanThird10,'omitnan'), 'FaceColor',colour, 'EdgeColor',colour);
barCount2 = barCount2 + 1;
bar(barCount2+(barGroupCount2-1)*gap, mean(psi2RasterCx6toCx6iMean_SWDs,'omitnan'), 'FaceColor',colour, 'EdgeColor',colour);

colour = cellColour('Cx6');
barGroupCount2 = barGroupCount2 + 1;
barCount2 = barCount2 + 1;
bar(barCount2+(barGroupCount2-1)*gap, mean(psi2RasterCx6toTCMeanSecond,'omitnan'), 'FaceColor',colour, 'EdgeColor',colour);
barCount2 = barCount2 + 1;
bar(barCount2+(barGroupCount2-1)*gap, mean(psi2RasterCx6toTCMeanThird10,'omitnan'), 'FaceColor',colour, 'EdgeColor',colour);
barCount2 = barCount2 + 1;
bar(barCount2+(barGroupCount2-1)*gap, mean(psi2RasterCx6toTCMean_SWDs,'omitnan'), 'FaceColor',colour, 'EdgeColor',colour);

colour = cellColour('Cx6');
barGroupCount2 = barGroupCount2 + 1;
barCount2 = barCount2 + 1;
bar(barCount2+(barGroupCount2-1)*gap, mean(psi2RasterCx6toTC2MeanSecond,'omitnan'), 'FaceColor',colour, 'EdgeColor',colour);
barCount2 = barCount2 + 1;
bar(barCount2+(barGroupCount2-1)*gap, mean(psi2RasterCx6toTC2MeanThird10,'omitnan'), 'FaceColor',colour, 'EdgeColor',colour);
barCount2 = barCount2 + 1;
bar(barCount2+(barGroupCount2-1)*gap, mean(psi2RasterCx6toTC2Mean_SWDs,'omitnan'), 'FaceColor',colour, 'EdgeColor',colour);

colour = cellColour('Cx6');
barGroupCount2 = barGroupCount2 + 1;
barCount2 = barCount2 + 1;
bar(barCount2+(barGroupCount2-1)*gap, mean(psi2RasterCx6toNRTMeanSecond,'omitnan'), 'FaceColor',colour, 'EdgeColor',colour);
barCount2 = barCount2 + 1;
bar(barCount2+(barGroupCount2-1)*gap, mean(psi2RasterCx6toNRTMeanThird10,'omitnan'), 'FaceColor',colour, 'EdgeColor',colour);
barCount2 = barCount2 + 1;
bar(barCount2+(barGroupCount2-1)*gap, mean(psi2RasterCx6toNRTMean_SWDs,'omitnan'), 'FaceColor',colour, 'EdgeColor',colour);

colour = cellColour('Cx6');
barGroupCount2 = barGroupCount2 + 1;
barCount2 = barCount2 + 1;
bar(barCount2+(barGroupCount2-1)*gap, mean(psi2RasterCx6toNRT2MeanSecond,'omitnan'), 'FaceColor',colour, 'EdgeColor',colour);
barCount2 = barCount2 + 1;
bar(barCount2+(barGroupCount2-1)*gap, mean(psi2RasterCx6toNRT2MeanThird10,'omitnan'), 'FaceColor',colour, 'EdgeColor',colour);
barCount2 = barCount2 + 1;
bar(barCount2+(barGroupCount2-1)*gap, mean(psi2RasterCx6toNRT2Mean_SWDs,'omitnan'), 'FaceColor',colour, 'EdgeColor',colour);

colour = cellColour('NRT');
barGroupCount2 = barGroupCount2 + 1;
barCount2 = barCount2 + 1;
bar(barCount2+(barGroupCount2-1)*gap, mean(psi2RasterNRTtoTCMeanSecond,'omitnan'), 'FaceColor',colour, 'EdgeColor',colour);
barCount2 = barCount2 + 1;
bar(barCount2+(barGroupCount2-1)*gap, mean(psi2RasterNRTtoTCMeanThird10,'omitnan'), 'FaceColor',colour, 'EdgeColor',colour);
barCount2 = barCount2 + 1;
bar(barCount2+(barGroupCount2-1)*gap, mean(psi2RasterNRTtoTCMean_SWDs,'omitnan'), 'FaceColor',colour, 'EdgeColor',colour);

colour = cellColour('NRT');
barGroupCount2 = barGroupCount2 + 1;
barCount2 = barCount2 + 1;
bar(barCount2+(barGroupCount2-1)*gap, mean(psi2RasterNRTtoTC2MeanSecond,'omitnan'), 'FaceColor',colour, 'EdgeColor',colour);
barCount2 = barCount2 + 1;
bar(barCount2+(barGroupCount2-1)*gap, mean(psi2RasterNRTtoTC2MeanThird10,'omitnan'), 'FaceColor',colour, 'EdgeColor',colour);
barCount2 = barCount2 + 1;
bar(barCount2+(barGroupCount2-1)*gap, mean(psi2RasterNRTtoTC2Mean_SWDs,'omitnan'), 'FaceColor',colour, 'EdgeColor',colour);

colour = cellColour('NRT2');
barGroupCount2 = barGroupCount2 + 1;
barCount2 = barCount2 + 1;
bar(barCount2+(barGroupCount2-1)*gap, mean(psi2RasterNRT2toTCMeanSecond,'omitnan'), 'FaceColor',colour, 'EdgeColor',colour);
barCount2 = barCount2 + 1;
bar(barCount2+(barGroupCount2-1)*gap, mean(psi2RasterNRT2toTCMeanThird10,'omitnan'), 'FaceColor',colour, 'EdgeColor',colour);
barCount2 = barCount2 + 1;
bar(barCount2+(barGroupCount2-1)*gap, mean(psi2RasterNRT2toTCMean_SWDs,'omitnan'), 'FaceColor',colour, 'EdgeColor',colour);

colour = cellColour('NRT2');
barGroupCount2 = barGroupCount2 + 1;
barCount2 = barCount2 + 1;
bar(barCount2+(barGroupCount2-1)*gap, mean(psi2RasterNRT2toTC2MeanSecond,'omitnan'), 'FaceColor',colour, 'EdgeColor',colour);
barCount2 = barCount2 + 1;
bar(barCount2+(barGroupCount2-1)*gap, mean(psi2RasterNRT2toTC2MeanThird10,'omitnan'), 'FaceColor',colour, 'EdgeColor',colour);
barCount2 = barCount2 + 1;
bar(barCount2+(barGroupCount2-1)*gap, mean(psi2RasterNRT2toTC2Mean_SWDs,'omitnan'), 'FaceColor',colour, 'EdgeColor',colour);

colour = cellColour('NRT');
barGroupCount2 = barGroupCount2 + 1;
barCount2 = barCount2 + 1;
bar(barCount2+(barGroupCount2-1)*gap, mean(psi2RasterNRTtoNRT2MeanSecond,'omitnan'), 'FaceColor',colour, 'EdgeColor',colour);
barCount2 = barCount2 + 1;
bar(barCount2+(barGroupCount2-1)*gap, mean(psi2RasterNRTtoNRT2MeanThird10,'omitnan'), 'FaceColor',colour, 'EdgeColor',colour);
barCount2 = barCount2 + 1;
bar(barCount2+(barGroupCount2-1)*gap, mean(psi2RasterNRTtoNRT2Mean_SWDs,'omitnan'), 'FaceColor',colour, 'EdgeColor',colour);

colour = cellColour('TC');
barGroupCount2 = barGroupCount2 + 1;
barCount2 = barCount2 + 1;
bar(barCount2+(barGroupCount2-1)*gap, mean(psi2RasterTCtoTC2MeanSecond,'omitnan'), 'FaceColor',colour, 'EdgeColor',colour);
barCount2 = barCount2 + 1;
bar(barCount2+(barGroupCount2-1)*gap, mean(psi2RasterTCtoTC2MeanThird10,'omitnan'), 'FaceColor',colour, 'EdgeColor',colour);
barCount2 = barCount2 + 1;
bar(barCount2+(barGroupCount2-1)*gap, mean(psi2RasterTCtoTC2Mean_SWDs,'omitnan'), 'FaceColor',colour, 'EdgeColor',colour);


%% Error bars
gaps2 = 4:4:(barGroupCount2-barGroupCount-1)*4;
bars = sort(barGroupCount*4+[1 1+gaps2 2 2+gaps2 3 3+gaps2]);
data = [mean(psi2RasterCx23toCx23iMeanSecond,'omitnan') mean(psi2RasterCx23toCx23iMeanThird10,'omitnan') mean(psi2RasterCx23toCx23iMean_SWDs,'omitnan')...
        mean(psi2RasterCx23toTCMeanSecond,'omitnan') mean(psi2RasterCx23toTCMeanThird10,'omitnan') mean(psi2RasterCx23toTCMean_SWDs,'omitnan')...
        mean(psi2RasterCx23toTC2MeanSecond,'omitnan') mean(psi2RasterCx23toTC2MeanThird10,'omitnan') mean(psi2RasterCx23toTC2Mean_SWDs,'omitnan')...
        mean(psi2RasterCx23toNRTMeanSecond,'omitnan') mean(psi2RasterCx23toNRTMeanThird10,'omitnan') mean(psi2RasterCx23toNRTMean_SWDs,'omitnan')...
        mean(psi2RasterCx23toNRT2MeanSecond,'omitnan') mean(psi2RasterCx23toNRT2MeanThird10,'omitnan') mean(psi2RasterCx23toNRT2Mean_SWDs,'omitnan')...
        mean(psi2RasterCx4toCx4iMeanSecond,'omitnan') mean(psi2RasterCx4toCx4iMeanThird10,'omitnan') mean(psi2RasterCx4toCx4iMean_SWDs,'omitnan')...
        mean(psi2RasterCx4toTCMeanSecond,'omitnan') mean(psi2RasterCx4toTCMeanThird10,'omitnan') mean(psi2RasterCx4toTCMean_SWDs,'omitnan')...
        mean(psi2RasterCx4toTC2MeanSecond,'omitnan') mean(psi2RasterCx4toTC2MeanThird10,'omitnan') mean(psi2RasterCx4toTC2Mean_SWDs,'omitnan')...
        mean(psi2RasterCx4toNRTMeanSecond,'omitnan') mean(psi2RasterCx4toNRTMeanThird10,'omitnan') mean(psi2RasterCx4toNRTMean_SWDs,'omitnan')...
        mean(psi2RasterCx4toNRT2MeanSecond,'omitnan') mean(psi2RasterCx4toNRT2MeanThird10,'omitnan') mean(psi2RasterCx4toNRT2Mean_SWDs,'omitnan')...
        mean(psi2RasterCx5toCx5iMeanSecond,'omitnan') mean(psi2RasterCx5toCx5iMeanThird10,'omitnan') mean(psi2RasterCx5toCx5iMean_SWDs,'omitnan')...
        mean(psi2RasterCx5toTCMeanSecond,'omitnan') mean(psi2RasterCx5toTCMeanThird10,'omitnan') mean(psi2RasterCx5toTCMean_SWDs,'omitnan')...
        mean(psi2RasterCx5toTC2MeanSecond,'omitnan') mean(psi2RasterCx5toTC2MeanThird10,'omitnan') mean(psi2RasterCx5toTC2Mean_SWDs,'omitnan')...
        mean(psi2RasterCx5toNRTMeanSecond,'omitnan') mean(psi2RasterCx5toNRTMeanThird10,'omitnan') mean(psi2RasterCx5toNRTMean_SWDs,'omitnan')...
        mean(psi2RasterCx5toNRT2MeanSecond,'omitnan') mean(psi2RasterCx5toNRT2MeanThird10,'omitnan') mean(psi2RasterCx5toNRT2Mean_SWDs,'omitnan')...
        mean(psi2RasterCx6toCx6iMeanSecond,'omitnan') mean(psi2RasterCx6toCx6iMeanThird10,'omitnan') mean(psi2RasterCx6toCx6iMean_SWDs,'omitnan')...
        mean(psi2RasterCx6toTCMeanSecond,'omitnan') mean(psi2RasterCx6toTCMeanThird10,'omitnan') mean(psi2RasterCx6toTCMean_SWDs,'omitnan')...
        mean(psi2RasterCx6toTC2MeanSecond,'omitnan') mean(psi2RasterCx6toTC2MeanThird10,'omitnan') mean(psi2RasterCx6toTC2Mean_SWDs,'omitnan')...
        mean(psi2RasterCx6toNRTMeanSecond,'omitnan') mean(psi2RasterCx6toNRTMeanThird10,'omitnan') mean(psi2RasterCx6toNRTMean_SWDs,'omitnan')...
        mean(psi2RasterCx6toNRT2MeanSecond,'omitnan') mean(psi2RasterCx6toNRT2MeanThird10,'omitnan') mean(psi2RasterCx6toNRT2Mean_SWDs,'omitnan')...
        mean(psi2RasterNRTtoTCMeanSecond,'omitnan') mean(psi2RasterNRTtoTCMeanThird10,'omitnan') mean(psi2RasterNRTtoTCMean_SWDs,'omitnan')...
        mean(psi2RasterNRTtoTC2MeanSecond,'omitnan') mean(psi2RasterNRTtoTC2MeanThird10,'omitnan') mean(psi2RasterNRTtoTC2Mean_SWDs,'omitnan')...
        mean(psi2RasterNRT2toTCMeanSecond,'omitnan') mean(psi2RasterNRT2toTCMeanThird10,'omitnan') mean(psi2RasterNRT2toTCMean_SWDs,'omitnan')...
        mean(psi2RasterNRT2toTC2MeanSecond,'omitnan') mean(psi2RasterNRT2toTC2MeanThird10,'omitnan') mean(psi2RasterNRT2toTC2Mean_SWDs,'omitnan')...
        mean(psi2RasterNRTtoNRT2MeanSecond,'omitnan') mean(psi2RasterNRTtoNRT2MeanThird10,'omitnan') mean(psi2RasterNRTtoNRT2Mean_SWDs,'omitnan')...
        mean(psi2RasterTCtoTC2MeanSecond,'omitnan') mean(psi2RasterTCtoTC2MeanThird10,'omitnan') mean(psi2RasterTCtoTC2Mean_SWDs,'omitnan')];
err = [psi2RasterCx23toCx23iCI95Second psi2RasterCx23toCx23iCI95Third10 psi2RasterCx23toCx23iCI95_SWDs...
       psi2RasterCx23toTCCI95Second psi2RasterCx23toTCCI95Third10 psi2RasterCx23toTCCI95_SWDs...
       psi2RasterCx23toTC2CI95Second psi2RasterCx23toTC2CI95Third10 psi2RasterCx23toTC2CI95_SWDs...
       psi2RasterCx23toNRTCI95Second psi2RasterCx23toNRTCI95Third10 psi2RasterCx23toNRTCI95_SWDs...
       psi2RasterCx23toNRT2CI95Second psi2RasterCx23toNRT2CI95Third10 psi2RasterCx23toNRT2CI95_SWDs...
       psi2RasterCx4toCx4iCI95Second psi2RasterCx4toCx4iCI95Third10 psi2RasterCx4toCx4iCI95_SWDs...
       psi2RasterCx4toTCCI95Second psi2RasterCx4toTCCI95Third10 psi2RasterCx4toTCCI95_SWDs...
       psi2RasterCx4toTC2CI95Second psi2RasterCx4toTC2CI95Third10 psi2RasterCx4toTC2CI95_SWDs...
       psi2RasterCx4toNRTCI95Second psi2RasterCx4toNRTCI95Third10 psi2RasterCx4toNRTCI95_SWDs...
       psi2RasterCx4toNRT2CI95Second psi2RasterCx4toNRT2CI95Third10 psi2RasterCx4toNRT2CI95_SWDs...
       psi2RasterCx5toCx5iCI95Second psi2RasterCx5toCx5iCI95Third10 psi2RasterCx5toCx5iCI95_SWDs...
       psi2RasterCx5toTCCI95Second psi2RasterCx5toTCCI95Third10 psi2RasterCx5toTCCI95_SWDs...
       psi2RasterCx5toTC2CI95Second psi2RasterCx5toTC2CI95Third10 psi2RasterCx5toTC2CI95_SWDs...
       psi2RasterCx5toNRTCI95Second psi2RasterCx5toNRTCI95Third10 psi2RasterCx5toNRTCI95_SWDs...
       psi2RasterCx5toNRT2CI95Second psi2RasterCx5toNRT2CI95Third10 psi2RasterCx5toNRT2CI95_SWDs...
       psi2RasterCx6toCx6iCI95Second psi2RasterCx6toCx6iCI95Third10 psi2RasterCx6toCx6iCI95_SWDs...
       psi2RasterCx6toTCCI95Second psi2RasterCx6toTCCI95Third10 psi2RasterCx6toTCCI95_SWDs...
       psi2RasterCx6toTC2CI95Second psi2RasterCx6toTC2CI95Third10 psi2RasterCx6toTC2CI95_SWDs...
       psi2RasterCx6toNRTCI95Second psi2RasterCx6toNRTCI95Third10 psi2RasterCx6toNRTCI95_SWDs...
       psi2RasterCx6toNRT2CI95Second psi2RasterCx6toNRT2CI95Third10 psi2RasterCx6toNRT2CI95_SWDs...
       psi2RasterNRTtoTCCI95Second psi2RasterNRTtoTCCI95Third10 psi2RasterNRTtoTCCI95_SWDs...
       psi2RasterNRTtoTC2CI95Second psi2RasterNRTtoTC2CI95Third10 psi2RasterNRTtoTC2CI95_SWDs...
       psi2RasterNRT2toTCCI95Second psi2RasterNRT2toTCCI95Third10 psi2RasterNRT2toTCCI95_SWDs...
       psi2RasterNRT2toTC2CI95Second psi2RasterNRT2toTC2CI95Third10 psi2RasterNRT2toTC2CI95_SWDs...
       psi2RasterNRTtoNRT2CI95Second psi2RasterNRTtoNRT2CI95Third10 psi2RasterNRTtoNRT2CI95_SWDs...
       psi2RasterTCtoTC2CI95Second psi2RasterTCtoTC2CI95Third10 psi2RasterTCtoTC2CI95_SWDs];

er = errorbar(bars,data,err(2,:),err(1,:));
er.Color = [0 0 0];
er.LineStyle = 'none';


%% Graph adjustments
ax1 = axesProperties({}, 1, 'normal', 'off', 'w', 'Arial', 25, 4/3, 2, [0.003 0.003], 'out', 'on', 'k', {}, [],...
    [gaps1 gaps1(end)+gaps2 gaps1(end)+gaps2(end)+4], 'on', 'k', {''}, [0.71 0.96], [0.72 0.80 0.88 0.96]);
ax1.XTickLabel = {'','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','',''};

label = [2.4 0.4];
margin = [0.01 0.33];
width = 45-label(1)-margin(1);
height = (30/161)*45-label(2)-margin(2);
paperSize = resizeFig(gcf, ax1, width, height, label, margin, 0);
savefig(gcf, 'psiEvo.fig', 'compact');
%exportFig(gcf, 'psiEvo.png','-dpng','-r300', paperSize);
%exportFig(gcf, 'psiEvo'.tif','-dtiffnocompression','-r300', paperSize);
exportFig(gcf, 'psiEvo.eps','-depsc','-r1200', paperSize);