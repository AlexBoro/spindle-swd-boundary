%cleanUp

load('frData.mat');

f10 = figProperties('events of SWC', 'normalized', [0, .005, .97, .90], 'w', 'on');
hold on


%% Data bars
colour = cellColour('Cx23');
bar(1, brFrCx23mean, 'FaceColor',colour, 'EdgeColor',colour);
bar(2, trFrCx23mean, 'FaceColor',colour, 'EdgeColor',colour);
bar(3, 1-frFrCx23mean, 'FaceColor',colour, 'EdgeColor',colour);

gap = 1;
colour = cellColour('Cx23i');
bar(4+gap, brFrCx23imean, 'FaceColor',colour, 'EdgeColor',colour);
bar(5+gap, trFrCx23imean, 'FaceColor',colour, 'EdgeColor',colour);
bar(6+gap, 1-frFrCx23imean, 'FaceColor',colour, 'EdgeColor',colour);

colour = cellColour('Cx4');
bar(7+2*gap, brFrCx4mean, 'FaceColor',colour, 'EdgeColor',colour);
bar(8+2*gap, trFrCx4mean, 'FaceColor',colour, 'EdgeColor',colour);
bar(9+2*gap, 1-frFrCx4mean, 'FaceColor',colour, 'EdgeColor',colour);

colour = cellColour('Cx4i');
bar(10+3*gap, brFrCx4imean, 'FaceColor',colour, 'EdgeColor',colour);
bar(11+3*gap, trFrCx4imean, 'FaceColor',colour, 'EdgeColor',colour);
bar(12+3*gap, 1-frFrCx4imean, 'FaceColor',colour, 'EdgeColor',colour);

colour = cellColour('Cx5');
bar(13+4*gap, brFrCx5mean, 'FaceColor',colour, 'EdgeColor',colour);
bar(14+4*gap, trFrCx5mean, 'FaceColor',colour, 'EdgeColor',colour);
bar(15+4*gap, 1-frFrCx5mean, 'FaceColor',colour, 'EdgeColor',colour);

colour = cellColour('Cx5i');
bar(16+5*gap, brFrCx5imean, 'FaceColor',colour, 'EdgeColor',colour);
bar(17+5*gap, trFrCx5imean, 'FaceColor',colour, 'EdgeColor',colour);
bar(18+5*gap, 1-frFrCx5imean, 'FaceColor',colour, 'EdgeColor',colour);

colour = cellColour('Cx6');
bar(19+6*gap, brFrCx6mean, 'FaceColor',colour, 'EdgeColor',colour);
bar(20+6*gap, trFrCx6mean, 'FaceColor',colour, 'EdgeColor',colour);
bar(21+6*gap, 1-frFrCx6mean, 'FaceColor',colour, 'EdgeColor',colour);

colour = cellColour('Cx6i');
bar(22+7*gap, brFrCx6imean, 'FaceColor',colour, 'EdgeColor',colour);
bar(23+7*gap, trFrCx6imean, 'FaceColor',colour, 'EdgeColor',colour);
bar(24+7*gap, 1-frFrCx6imean, 'FaceColor',colour, 'EdgeColor',colour);

colour = cellColour('TC');
bar(25+8*gap, brFrTCmean, 'FaceColor',colour, 'EdgeColor',colour);
bar(26+8*gap, trFrTCmean, 'FaceColor',colour, 'EdgeColor',colour);
bar(27+8*gap, 1-frFrTCmean, 'FaceColor',colour, 'EdgeColor',colour);

colour = cellColour('TC2');
bar(28+9*gap, brFrTC2mean, 'FaceColor',colour, 'EdgeColor',colour);
bar(29+9*gap, trFrTC2mean, 'FaceColor',colour, 'EdgeColor',colour);
bar(30+9*gap, 1-frFrTC2mean, 'FaceColor',colour, 'EdgeColor',colour);

colour = cellColour('NRT');
bar(31+10*gap, brFrNRTmean, 'FaceColor',colour, 'EdgeColor',colour);
bar(32+10*gap, trFrNRTmean, 'FaceColor',colour, 'EdgeColor',colour);
bar(33+10*gap, 1-frFrNRTmean, 'FaceColor',colour, 'EdgeColor',colour);

colour = cellColour('NRT2');
bar(34+11*gap, brFrNRT2mean, 'FaceColor',colour, 'EdgeColor',colour);
bar(35+11*gap, trFrNRT2mean, 'FaceColor',colour, 'EdgeColor',colour);
bar(36+11*gap, 1-frFrNRT2mean, 'FaceColor',colour, 'EdgeColor',colour);


%% Error bars
gaps = 4:4:44;
bars = sort([1 1+gaps 2 2+gaps 3 3+gaps]);
data = [brFrCx23mean trFrCx23mean 1-frFrCx23mean brFrCx23imean trFrCx23imean 1-frFrCx23imean brFrCx4mean trFrCx4mean 1-frFrCx4mean...
    brFrCx4imean trFrCx4imean 1-frFrCx4imean brFrCx5mean trFrCx5mean 1-frFrCx5mean brFrCx5imean trFrCx5imean 1-frFrCx5imean...
    brFrCx6mean trFrCx6mean 1-frFrCx6mean brFrCx6imean trFrCx6imean 1-frFrCx6imean brFrTCmean trFrTCmean 1-frFrTCmean...
    brFrTC2mean trFrTC2mean 1-frFrTC2mean brFrNRTmean trFrNRTmean 1-frFrNRTmean brFrNRT2mean trFrNRT2mean 1-frFrNRT2mean];
err = [brFrCx23CI95 trFrCx23CI95 frFrCx23CI95 brFrCx23iCI95 trFrCx23iCI95 frFrCx23iCI95 brFrCx4CI95 trFrCx4CI95 frFrCx4CI95...
    brFrCx4iCI95 trFrCx4iCI95 frFrCx4iCI95 brFrCx5CI95 trFrCx5CI95 frFrCx5CI95 brFrCx5iCI95 trFrCx5iCI95 frFrCx5iCI95...
    brFrCx6CI95 trFrCx6CI95 frFrCx6CI95 brFrCx6iCI95 trFrCx6iCI95 frFrCx6iCI95 brFrTCCI95 trFrTCCI95 frFrTCCI95...
    brFrTC2CI95 trFrTC2CI95 frFrTC2CI95 brFrNRTCI95 trFrNRTCI95 frFrNRTCI95 brFrNRT2CI95 trFrNRT2CI95 frFrNRT2CI95];

er = errorbar(bars,data,err(2,:),err(1,:));
er.Color = [0 0 0];
er.LineStyle = 'none';


%% Graph adjustments
ax1 = axesProperties({}, 1, 'normal', 'off', 'w', 'Arial', 25, 4/3, 2, [0.003 0.003], 'out', 'on', 'k', {}, [],...
    gaps, 'on', 'k', {''}, [0 0.9], [0 0.3 0.6 0.9]);
ax1.XTickLabel = {'','','','','','','','','','','',};

label = [2.05 0.4];
margin = [0.01 0.33];
width = 45-label(1)-margin(1);
height = (22.443/164.506)*45-label(2)-margin(2);
paperSize = resizeFig(gcf, ax1, width, height, label, margin, 0);
%exportFig(gcf, 'fractions.png','-dpng','-r300', paperSize);
%exportFig(gcf, 'fractions'.tif','-dtiffnocompression','-r300', paperSize);
exportFig(gcf, 'fractions.eps','-depsc','-r1200', paperSize);