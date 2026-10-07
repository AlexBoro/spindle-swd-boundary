% Membrane potential ploting function

clc
close all
%clear all
format long
Area = area(42, 63);

lineWidth = 2;
width = 3*15;
height = 15;
label = [0 0];
margin = [0 0];

shift = 1.66;
xRange(1,1:2) = [125 185] +shift;
xRange(2,1:2) = [159.6333749649393 162.7278548184433] +shift;
xRange(3,1:2) = [161.2 162] +shift;

yRange(1,1:2) = [-83 30];
yRange(2,1:2) = [-83 30];
yRange(3,1:2) = [-83 30];

widths(1) = width;
widths(2) = width*(4.15/10.7);
widths(3) = width*(3.25/10.7);

[~, NRT] = loadFile('0.000100_NRT0data0.0000100_ 95_0.0000092_0.0010.dat', Area, 'NRT');
for i = 1:1
    tracePlot('0.000100_NRT0data0.0000100_ 95_0.0000092_0.0010.dat', NRT.t*1e-3, NRT.v, xRange(i,:), yRange(i,:), lineWidth);
    paperSize = resizeFig(gcf, gca, widths(i), height, label, margin, 0);
    name = num2str(i);
    exportFig(gcf, [name '.tif'],'-dtiffnocompression','-r300', paperSize);
end


lineWidth = 2;
height = 1.5*15;
label = [3.65 0.45];
gap = 1;

f4 = figProperties('Trace #1', 'normalized', [0, .005, .97, .90], 'w', 'on');
subplot(4,1,1)
inds = findRange(NRT.t*1e-3, [xRange(2,1)+0.1 xRange(2,2)]);
plot(NRT.t(inds(1):inds(2))*1e-3, NRT.v(inds(1):inds(2)), 'Color', 'k', 'LineWidth', lineWidth)
axesProperties({}, 1, 'normal', 'off', 'w', 'Calibri', 30, 1, 2, [0.01 0.025], 'out', 'off', 'w', {}, xRange(2,:), [], 'off', 'w', {}, yRange(2,:), []);
axesHandles(1) = gca;

subplot(4,1,2)
FARADAY = 96485.309;
R = 8.3144621;
cao = 1.5;
carev = ((1e3) * (R*(37+273.15))/(2*FARADAY)) * log(cao./(NRT.Cai*1e-6));
ITs = 1e6*Area*0.00069 * (NRT.ICam.^2).*NRT.ICah.*(NRT.v-carev);
plot(NRT.t(inds(1):inds(2))*1e-3, ITs(inds(1):inds(2)), 'k', 'LineWidth', lineWidth)
axesProperties({}, 1, 'normal', 'off', 'w', 'Calibri', 30, 1, 2, [0.01 0.025], 'out', 'off', 'w', {}, xRange(2,:), [], 'on', 'k', 'I_{Ts} (nA)', [-1.2 0], [-1.2 0]);
axesHandles(2) = gca;

subplot(4,1,3)
plot(NRT.t(inds(1):inds(2))*1e-3, NRT.IAHP(inds(1):inds(2))*1e3, 'k', 'LineWidth', lineWidth)
axesProperties({}, 1, 'normal', 'off', 'w', 'Calibri', 30, 1, 2, [0.01 0.025], 'out', 'off', 'w', {}, xRange(2,:), [], 'on', 'k', 'I_{AHP} (pA)', [0 220], [0 220]);
axesHandles(3) = gca;

subplot(4,1,4)
plot(NRT.t(inds(1):inds(2))*1e-3, NRT.ICAN(inds(1):inds(2))*1e3, 'k', 'LineWidth', lineWidth)
axesProperties({}, 1, 'normal', 'off', 'w', 'Calibri', 30, 1, 2, [0.01 0.025], 'out', 'off', 'w', {}, xRange(2,:), [], 'on', 'k', 'I_{CAN} (pA)', [-30 0], [-30 0]);
axesHandles(4) = gca;

paperSize = resizeFig(f4, axesHandles, widths(2), height, label, margin, gap);
exportFig(f4, ['2' '.tif'],'-dtiffnocompression','-r300', paperSize);



label = [0 0.45];

f5 = figProperties('Trace #1', 'normalized', [0, .005, .97, .90], 'w', 'on');
subplot(4,1,1)
inds = findRange(NRT.t*1e-3, [xRange(3,1) xRange(3,2)]);
plot(NRT.t(inds(1):inds(2))*1e-3, NRT.v(inds(1):inds(2)), 'Color', 'k', 'LineWidth', lineWidth)
axesProperties({}, 1, 'normal', 'off', 'w', 'Calibri', 30, 1, 2, [0.01 0.025], 'out', 'off', 'w', {}, xRange(3,:), [], 'off', 'w', {}, yRange(3,:), []);
axesHandles(1) = gca;

subplot(4,1,2)
plot(NRT.t(inds(1):inds(2))*1e-3, ITs(inds(1):inds(2)), 'k', 'LineWidth', lineWidth)
axesProperties({}, 1, 'normal', 'off', 'w', 'Calibri', 30, 1, 2, [0.01 0.025], 'out', 'off', 'w', {}, xRange(3,:), [], 'off', 'w', {}, [-1.2 0], [-1.2 0]);
axesHandles(2) = gca;

subplot(4,1,3)
plot(NRT.t(inds(1):inds(2))*1e-3, NRT.IAHP(inds(1):inds(2))*1e3, 'k', 'LineWidth', lineWidth)
axesProperties({}, 1, 'normal', 'off', 'w', 'Calibri', 30, 1, 2, [0.01 0.025], 'out', 'off', 'w', {}, xRange(3,:), [], 'off', 'w', {}, [0 220], [0 220]);
axesHandles(3) = gca;

subplot(4,1,4)
plot(NRT.t(inds(1):inds(2))*1e-3, NRT.ICAN(inds(1):inds(2))*1e3, 'k', 'LineWidth', lineWidth)
axesProperties({}, 1, 'normal', 'off', 'w', 'Calibri', 30, 1, 2, [0.01 0.025], 'out', 'off', 'w', {}, xRange(3,:), [], 'off', 'w', {}, [-30 0], [-30 0]);
axesHandles(4) = gca;

paperSize = resizeFig(f5, axesHandles, widths(3), height, label, margin, gap);
exportFig(f5, ['3' '.tif'],'-dtiffnocompression','-r300', paperSize);
