function [f, ax] = biPlot(titleStr, data, lineCols, penSz, Vm, xRange, yRange, visibility)
f = multiPlot(titleStr, abs(data), lineCols, penSz, Vm, visibility);
ax = axesProperties({}, 1, 'normal', 'off', 'w', 'Calibri', 30, 4/3, 2, [0.01 0.025], 'out', 'on', 'k', 'V_m (mV)', xRange, [-90 -60 -30], 'on', 'k', '|I| (pA)', yRange, [60 120 180]);