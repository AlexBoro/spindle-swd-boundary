% The script file plots the membrane potential traces of single thalamic cells.

clc
close all
clear all %#ok<CLALL>
format long
save = 1;

lineWidth = 2;
width = 2.8*15;
height = (2.8/5.95)*15;
label = [4.3 0.45];
margin = [0 0.3];
xRange = [62.2 63.3];
xRangeZoom = [62.575 63.075];
yRange = [-75 0];
fontSize = 30;

IB = 1;
if IB
    file = 'y10_Cx3data_5_0328_IB.dat';
    Area(1) = area(5.644, 5.644);
    Area(2) = area(5.644, 165*5.644);
else
    file = 'y10_Cx3data_5_0329_RS.dat';
    Area(1) = area(5.644, 5.644);
    Area(2) = area(5.644, 160*5.644);
end
[~, Cx3] = loadFile(file, Area, 'Cx3');
inds = findRange(Cx3.t*1e-3, xRange+[0.01 0]);
inds = inds(1):inds(2);
indsZoom = findRange(Cx3.t*1e-3, xRangeZoom+[((xRangeZoom(2)-xRangeZoom(1))/(xRange(2)-xRange(1)))*0.01 0]);
indsZoom = indsZoom(1):indsZoom(2);

figProperties('Membrane Potential Trace', 'normalized', [0, .005, .97, .90], 'w', 'on');
plot(Cx3.t(inds)*1e-3, Cx3.v(inds), 'k', 'LineWidth', 3)
% hold on
% plot([xRangeZoom(1) xRangeZoom(1)], [-71 -67]-4, 'r', 'LineWidth', 3)
% plot([xRangeZoom(2) xRangeZoom(2)], [-71 -67]-4, 'r', 'LineWidth', 3)
% plot([xRangeZoom(1) xRangeZoom(2)], [-71 -71]-4, 'r', 'LineWidth', 3)
% hold off
axesProperties({}, 1, 'normal', 'off', 'w', 'Calibri', fontSize, 4/3, 3, [0.01 0.025], 'out', 'off', 'w', {}, xRange, [], 'on', 'k', 'V_m (mV)', yRange, yRange);
paperSize = resizeFig(gcf, gca, width, height, label, margin, 0);
name = file;
exportFig(gcf, [name(1:end-4) '_Vm.tif'],'-dtiffnocompression','-r300', paperSize);



if IB
    ri = 10.236223;
else
    ri = 9.9260347;
end
vCompS = (Cx3.v - Cx3.vD);
iCompS = vCompS/ri;
iMembS = Cx3.IleakS + Cx3.INaleakS + Cx3.INaS + Cx3.IKS;
iNaleakSe = Cx3.INaleakS;
iNaleakSe(iNaleakSe > 0) = 0;
iNaleakSi = Cx3.INaleakS;
iNaleakSi(iNaleakSe < 0) = 0;
iMembSe = iNaleakSe + Cx3.INaS;
iMembSi = iNaleakSi + Cx3.IleakS + Cx3.IKS;
iSynS = Cx3.IGABAaS + Cx3.IGABAbS;
iSynSe = zeros(size(iSynS));
iSynSi = iSynS;
iSe = iMembSe + iSynSe;
iSi = iMembSi + iSynSi;
iTotalS = iCompS + iMembS + iSynS;

vCompD = (Cx3.vD - Cx3.v);
iCompD = vCompS/ri;
iMembD = Cx3.IleakD + Cx3.INaleakD + Cx3.INaD + Cx3.IKD + Cx3.ICaD + Cx3.IhD;
iNaleakDe = Cx3.INaleakD;
iNaleakDe(iNaleakDe > 0) = 0;
iNaleakDi = Cx3.INaleakD;
iNaleakDi(iNaleakDe < 0) = 0;
ihDe = Cx3.IhD;
ihDe(ihDe > 0) = 0;
ihDi = Cx3.IhD;
ihDi(ihDe < 0) = 0;
iMembDe = iNaleakDe + Cx3.INaD + Cx3.ICaD + ihDe;
iMembDi = Cx3.IleakD + iNaleakDi + Cx3.IKD + ihDi;
iSynD = Cx3.IAMPAD + Cx3.INMDAD;
iAMPADe = Cx3.IAMPAD;
iAMPADe(iAMPADe > 0) = 0;
iAMPADi = Cx3.IAMPAD;
iAMPADi(iAMPADi < 0) = 0;
iNMDADe = Cx3.INMDAD;
iNMDADe(iNMDADe > 0) = 0;
iNMDADi = Cx3.INMDAD;
iNMDADi(iNMDADi < 0) = 0;
iSynDe = iAMPADe + iNMDADe;
iSynDi = iAMPADi + iNMDADi;
iDe = iMembDe + iSynDe;
iDi = iMembDi + iSynDi;
iTotalD = iCompD + iMembD + iSynD;
synFraction = iSynD./(iMembD + iSynD);
eSynSoma = synFraction.*iCompS;

iMembE = iMembSe + iMembDe;
iMembI = iMembSi + iMembDi;
iE = iSe + iDe;
iI = iSi + iDi;

figProperties('Net Somatic Current Trace', 'normalized', [0, .005, .97, .90], 'w', 'on');
plot(Cx3.t(inds)*1e-3, iTotalS(inds), 'k', 'LineWidth', 3)
axesProperties({}, 1, 'normal', 'off', 'w', 'Calibri', fontSize, 4/3, 3, [0.01 0.025], 'out', 'off', 'w', {}, xRange, [], 'on', 'k', 'I (nA)', [-2.3 0.2], [-2.3 0]);
paperSize = resizeFig(gcf, gca, width, height, label, margin, 0); %#ok<*NASGU>
name = file;
if save
    exportFig(gcf, [name(1:end-4) '_I.tif'],'-dtiffnocompression','-r300', paperSize); %#ok<*UNRCH>
end

% figProperties('Net Depolarising and Hyperpolarising Currents', 'normalized', [0, .005, .97, .90], 'w', 'on');
% plot(Cx3.t(inds)*1e-3, iE(inds), 'g', 'LineWidth', 2)
% hold on
% plot(Cx3.t(inds)*1e-3, iI(inds), 'r', 'LineWidth', 2)
% hold off
% axesProperties({}, 1, 'normal', 'off', 'w', 'Calibri', fontSize, 4/3, 2, [0.01 0.025], 'out', 'off', 'w', {}, xRange, [], 'on', 'k', 'I (nA)', [-28 24], [-28 0 24]);
% paperSize = resizeFig(gcf, gca, width, height, label, margin, 0);
legStr = {'Depolarising';'Hyperpolarising'};
legFont = 30;
% legProperties(legStr, 'off', legFont, 3, 'NorthWest');
% if save
%     exportFig(gcf, [name(1:end-4) '_I_d_h.tif'],'-dtiffnocompression','-r300', paperSize);
% end

% figProperties('Net Depolarising and Hyperpolarising Currents', 'normalized', [0, .005, .97, .90], 'w', 'on');
% plot(Cx3.t(inds)*1e-3, iE(inds), 'g', 'LineWidth', 2)
% hold on
% plot(Cx3.t(inds)*1e-3, iI(inds), 'r', 'LineWidth', 2)
% plot([Cx3.t(1)*1e-3 Cx3.t(end)*1e-3], [0 0], 'k', 'LineWidth', 1)
% hold off
% axesProperties({}, 1, 'normal', 'off', 'w', 'Calibri', fontSize, 4/3, 2, [0.01 0.025], 'out', 'off', 'w', {}, [19.5304 20.4], [], 'on', 'k', 'I (nA)', [-0.26 0.26], [-0.26 0 0.26]);
% paperSize = resizeFig(gcf, gca, width, height, label, margin, 0);
% if save
%     exportFig(gcf, [name(1:end-4) '_I_d_h_zoom.tif'],'-dtiffnocompression','-r300', paperSize);
% end

figProperties('Intrinsic Membrane Currents', 'normalized', [0, .005, .97, .90], 'w', 'on');
plot(Cx3.t(inds)*1e-3, iMembE(inds), 'g', 'LineWidth', 3)
hold on
plot(Cx3.t(inds)*1e-3, iMembI(inds), 'r', 'LineWidth', 3)
plot([xRangeZoom(1) xRangeZoom(1)], [-29 -25], 'k', 'LineWidth', 3)
plot([xRangeZoom(2) xRangeZoom(2)], [-29 -25], 'k', 'LineWidth', 3)
plot([xRangeZoom(1) xRangeZoom(2)], [-29 -29], 'k', 'LineWidth', 3)
hold off
axesProperties({}, 1, 'normal', 'off', 'w', 'Calibri', fontSize, 4/3, 3, [0.01 0.025], 'out', 'off', 'w', {}, xRange, [], 'on', 'k', 'I (nA)', [-29 23], [-29 0 23]);
paperSize = resizeFig(gcf, gca, width, height, label, margin, 0);
legProperties(legStr, 'off', legFont, 3, 'SouthWest');
if save
    exportFig(gcf, [name(1:end-4) '_I_d_h_intrinsic.tif'],'-dtiffnocompression','-r300', paperSize);
end

figProperties('Intrinsic Membrane Currents', 'normalized', [0, .005, .97, .90], 'w', 'on');
plot(Cx3.t(indsZoom)*1e-3, iE(indsZoom), 'g', 'LineWidth', 3)
hold on
plot(Cx3.t(indsZoom)*1e-3, iI(indsZoom), 'r', 'LineWidth', 3)
plot([Cx3.t(1)*1e-3 Cx3.t(end)*1e-3], [0 0], 'k', 'LineWidth', 1)
hold off
axesProperties({}, 1, 'normal', 'off', 'w', 'Calibri', fontSize, 4/3, 3, [0.01 0.025], 'out', 'off', 'w', {}, xRangeZoom, [], 'on', 'k', 'I (nA)', [-0.5 0.5], [-0.5 0 0.5]);
paperSize = resizeFig(gcf, gca, width, height, label, margin, 0);
if save
    exportFig(gcf, [name(1:end-4) '_I_d_h_intrinsic_zoom.tif'],'-dtiffnocompression','-r300', paperSize);
end

figProperties('Synaptic Currents', 'normalized', [0, .005, .97, .90], 'w', 'on');
plot(Cx3.t(inds)*1e-3, iSynD(inds), 'g', 'LineWidth', 3)
hold on
plot(Cx3.t(inds)*1e-3, iSynS(inds), 'r', 'LineWidth', 3)
hold off
axesProperties({}, 1, 'normal', 'off', 'w', 'Calibri', fontSize, 4/3, 3, [0.01 0.025], 'out', 'off', 'w', {}, xRange, [], 'on', 'k', 'I (nA)', [-0.5 1], [-0.5 0 1]);
paperSize = resizeFig(gcf, gca, width, height, label, margin, 0);
legStr = {'Excitatory';'Inhibitory'};
legProperties(legStr, 'off', legFont, 3, 'NorthWest');
if save
    exportFig(gcf, [name(1:end-4) '_I_e_i.tif'],'-dtiffnocompression','-r300', paperSize);
end

figProperties('Synaptic Currents Decomposed', 'normalized', [0, .005, .97, .90], 'w', 'on');
plot(Cx3.t(inds)*1e-3, Cx3.IAMPAD(inds), 'g', 'LineWidth', 2)
hold on
plot(Cx3.t(inds)*1e-3, Cx3.INMDAD(inds), 'b', 'LineWidth', 2)
plot(Cx3.t(inds)*1e-3, Cx3.IGABAaS(inds), 'r', 'LineWidth', 2)
plot(Cx3.t(inds)*1e-3, Cx3.IGABAbS(inds), 'm', 'LineWidth', 2)
hold off
axesProperties({}, 1, 'normal', 'off', 'w', 'Calibri', fontSize, 4/3, 2, [0.01 0.025], 'out', 'off', 'w', {}, xRange, [], 'on', 'k', 'I (nA)', [-1 1.5], [-1 0 1.5]);
paperSize = resizeFig(gcf, gca, width, 2*height, label, margin, 0);
legStr = {'AMPA';'NMDA';'GABAa';'GABAb'};
legProperties(legStr, 'off', legFont, 3, 'NorthWest');
if save
    exportFig(gcf, [name(1:end-4) '_I_syn.tif'],'-dtiffnocompression','-r300', paperSize);
end



enarev = 60;
ekrev  = -90;
ecarev = 140;
I_A = 1e6*Area(2) * 0.00148 * (Cx3.IAaD.^4) .* Cx3.IAbD .* (Cx3.vD - ekrev);
I_M = 1e6*Area(2) * 0.00001 * Cx3.IMnD .* (Cx3.vD - ekrev);
q10 = 2.3^((37 - 23) / 10);
I_KCa = 1e6*Area(2) * q10 * 0.000001 * Cx3.IKCanD .* (Cx3.vD - ekrev);
q10 = 2.3^((37 - 37) / 10);
w_inf = 1./(1 + (38.7./Cx3.NaiS).^3.5);
ikS = 1e6*Area(1) * q10 * 0.00007 * w_inf .* (Cx3.v - ekrev);
w_inf = 1./(1 + (38.7./Cx3.NaiD).^3.5);
ikD = 1e6*Area(2) * q10 * 0.00007 * w_inf .* (Cx3.vD - ekrev);
I_KNa = ikS + ikD;
q10 = 2.3^((37 - 23) / 10);
if IB
    I_HVA = 1e6*Area(2) * q10 * 0.00001 * (Cx3.IHVAmD.^2) .* Cx3.IHVAhD .* (Cx3.vD - ecarev);
else
    I_HVA = 1e6*Area(2) * q10 * 0.000001 * (Cx3.IHVAmD.^2) .* Cx3.IHVAhD .* (Cx3.vD - ecarev);
end
I_T = Cx3.ICaD - I_HVA;
I_h = Cx3.IhD;
q10 = 2.3^((37 - 36) / 10);
I_NaPS = 1e6*Area(1) * q10 * 0.000077 * Cx3.INaPmS .* (Cx3.v - enarev);
I_NaPD = 1e6*Area(2) * q10 * 0.000077 * Cx3.INaPmD .* (Cx3.vD - enarev);
I_NaP = I_NaPS + I_NaPD;
q10 = 2.3^((37 - 23) / 10);
I_NaS = 1e6*Area(1) * q10 * 3 * (Cx3.INamS.^3) .* Cx3.INahS .* (Cx3.v - enarev);
I_NaD = 1e6*Area(2) * q10 * 0.0015 * (Cx3.INamD.^3) .* Cx3.INahD .* (Cx3.vD - enarev);
I_Na = I_NaS + I_NaD;
I_K = 1e6*Area(1) * q10 * 0.216 * Cx3.IKnS .* (Cx3.v - ekrev);

% Resample and integrate:
inds2 = findRange(Cx3.t*1e-3, xRangeZoom);
inds2 = inds2(1):inds2(2);

dt = 0.1;
t = Cx3.t(inds2(1)):dt:Cx3.t(inds2(end));
[tunique, iunique] = unique(Cx3.t(inds2));
iTotalS = iTotalS(inds2);
iTotalS = interp1(tunique,iTotalS(iunique),t);
iTotalS_sum = trapz(iTotalS)*dt %#ok<*NOPTS>

iE = iE(inds2);
iE = interp1(tunique,iE(iunique),t);
iE_sum = trapz(iE)*dt
iI = iI(inds2);
iI = interp1(tunique,iI(iunique),t);
iI_sum = trapz(iI)*dt

iMembE = iMembE(inds2);
iMembE = interp1(tunique,iMembE(iunique),t);
iMembE_sum = trapz(iMembE)*dt
iMembI = iMembI(inds2);
iMembI = interp1(tunique,iMembI(iunique),t);
iMembI_sum = trapz(iMembI)*dt

iSynD = iSynD(inds2);
iSynD = interp1(tunique,iSynD(iunique),t);
iSynD_sum = trapz(iSynD)*dt
iSynS = iSynS(inds2);
iSynS = interp1(tunique,iSynS(iunique),t);
iSynS_sum = trapz(iSynS)*dt

I_A_interp = I_A(inds2);
I_A_interp = interp1(tunique,I_A_interp(iunique),t);
I_A_sum = trapz(I_A_interp)*dt
I_M_interp = I_M(inds2);
I_M_interp = interp1(tunique,I_M_interp(iunique),t);
I_M_sum = trapz(I_M_interp)*dt
I_KCa_interp = I_KCa(inds2);
I_KCa_interp = interp1(tunique,I_KCa_interp(iunique),t);
I_KCa_sum = trapz(I_KCa_interp)*dt
I_KNa_interp = I_KNa(inds2);
I_KNa_interp = interp1(tunique,I_KNa_interp(iunique),t);
I_KNa_sum = trapz(I_KNa_interp)*dt
I_HVA_interp = I_HVA(inds2);
I_HVA_interp = interp1(tunique,I_HVA_interp(iunique),t);
I_HVA_sum = trapz(I_HVA_interp)*dt
I_T_interp = I_T(inds2);
I_T_interp = interp1(tunique,I_T_interp(iunique),t);
I_T_sum = trapz(I_T_interp)*dt
I_h_interp = I_h(inds2);
I_h_interp = interp1(tunique,I_h_interp(iunique),t);
I_h_sum = trapz(I_h_interp)*dt
I_NaP_interp = I_NaP(inds2);
I_NaP_interp = interp1(tunique,I_NaP_interp(iunique),t);
I_NaP_sum = trapz(I_NaP_interp)*dt
I_Na_interp = I_Na(inds2);
I_Na_interp = interp1(tunique,I_Na_interp(iunique),t);
I_Na_sum = trapz(I_Na_interp)*dt
I_K_interp = I_K(inds2);
I_K_interp = interp1(tunique,I_K_interp(iunique),t);
I_K_sum = trapz(I_K_interp)*dt

figProperties('Concrete Currents', 'normalized', [0, .005, .97, .90], 'w', 'on');
plot(Cx3.t(inds)*1e-3, I_NaP(inds), 'g', 'LineWidth', 3)
hold on
plot(Cx3.t(inds)*1e-3, I_A(inds), 'r', 'LineWidth', 3)
hold off
axesProperties({}, 1, 'normal', 'off', 'w', 'Calibri', fontSize, 4/3, 3, [0.01 0.025], 'out', 'off', 'w', {}, xRange, [], 'on', 'k', 'I (nA)', [-1.2 1.9], [-1.2 0 1.9]);
paperSize = resizeFig(gcf, gca, width, height, label, margin, 0);
legStr = {'I_{Na(P)}';'I_A'};
legProperties(legStr, 'off', legFont, 3, 'NorthWest');
if save
    exportFig(gcf, [name(1:end-4) '_I_concrete.tif'],'-dtiffnocompression','-r300', paperSize);
end

figProperties('Concrete Currents', 'normalized', [0, .005, .97, .90], 'w', 'on');
p(1) = plot(Cx3.t(indsZoom)*1e-3, I_NaP(indsZoom), 'g', 'LineWidth', 3);
hold on
p(2) = plot(Cx3.t(indsZoom)*1e-3, I_A(indsZoom), 'r', 'LineWidth', 3);
plot([Cx3.t(1)*1e-3 Cx3.t(end)*1e-3], [0 0], 'k', 'LineWidth', 1)
hold off
axesProperties({}, 1, 'normal', 'off', 'w', 'Calibri', fontSize, 4/3, 3, [0.01 0.025], 'out', 'off', 'w', {}, xRangeZoom, [], 'on', 'k', 'I (nA)', [-0.1 0.1], [-0.1 0 0.1]);
paperSize = resizeFig(gcf, gca, width, height, label, margin, 0);
order = [1 2];
l = legend(p(order),legStr(order), 'Box', 'off', 'FontSize', legFont, 'LineWidth', lineWidth, 'Location', 'SouthWest');
position = get(l, 'Position');
position(2) = position(2) - 0.1;
set(l, 'Position', position);
if save
    exportFig(gcf, [name(1:end-4) '_I_concrete_zoom.tif'],'-dtiffnocompression','-r300', paperSize);
end

figProperties('Ca^{2+} currents', 'normalized', [0, .005, .97, .90], 'w', 'on');
plot(Cx3.t(indsZoom)*1e-3, I_T(indsZoom), 'Color', [255 216 1]/255, 'LineWidth', 3)
hold on
plot(Cx3.t(indsZoom)*1e-3, I_HVA(indsZoom), 'Color', [192 64 0]/255, 'LineWidth', 3)
hold off
axesProperties({}, 1, 'normal', 'off', 'w', 'Calibri', fontSize, 4/3, 3, [0.01 0.025], 'out', 'off', 'w', {}, xRangeZoom, [], 'on', 'k', 'I (nA)', [-0.012 0], [-0.012 0]);
paperSize = resizeFig(gcf, gca, width, height, label, margin, 0);
legStr = {'I_T';'I_{HVA}'};
legProperties(legStr, 'off', legFont, 3, 'SouthWest');
if save
    exportFig(gcf, [name(1:end-4) '_I_Ca2+_currents_zoom.tif'],'-dtiffnocompression','-r300', paperSize);
end

figProperties('Terminating currents', 'normalized', [0, .005, .97, .90], 'w', 'on');
p(1) = plot(Cx3.t(indsZoom)*1e-3, I_KCa(indsZoom), 'b', 'LineWidth', 3);
hold on
p(2) = plot(Cx3.t(indsZoom)*1e-3, I_KNa(indsZoom), 'r', 'LineWidth', 3);
p(3) = plot(Cx3.t(indsZoom)*1e-3, I_M(indsZoom), 'm', 'LineWidth', 3);
hold off
axesProperties({}, 1, 'normal', 'off', 'w', 'Calibri', fontSize, 4/3, 3, [0.01 0.025], 'out', 'off', 'w', {}, xRangeZoom, [], 'on', 'k', 'I (nA)', [0 0.01], [0 0.01]);
paperSize = resizeFig(gcf, gca, width, height, label, margin, 0);
legStr = {'I_{K[Ca]}';'I_{K[Na]}';'I_M'};
order = [1 2 3];
l = legend(p(order),legStr(order), 'Box', 'off', 'FontSize', legFont, 'LineWidth', lineWidth, 'Location', 'NorthWest');
position = get(l, 'Position');
position(2) = position(2) + 0.1;
set(l, 'Position', position);
if save
    exportFig(gcf, [name(1:end-4) '_I_terminating2_zoom.tif'],'-dtiffnocompression','-r300', paperSize);
end



f1 = figProperties('Transferred Charge', 'normalized', [0, .005, .97, .90], 'w', 'on');
bar(1, abs(iSynD_sum), 'g');
hold on
bar(2, abs(iSynS_sum), 'r');
bar(4, abs(iMembE_sum),  'g');
bar(5, abs(iMembI_sum),  'r');
bar(7, abs(I_NaP_sum),  'b');
bar(9, abs(I_A_sum),  'm');
% bar(10, abs(I_KCa_sum),  'b');
% bar(11, abs(I_KNa_sum),  'r');
% bar(12, abs(I_M_sum),  'm');
% bar(13, abs(I_T_sum),  'FaceColor',[255 216 1]/255);
% bar(14, abs(I_HVA_sum),  'FaceColor',[192 64 0]/255);
hold off

ax1= axesProperties({}, 1, 'normal', 'off', 'w', 'Calibri', fontSize, 4/3, 3, [0.01 0.025], 'out', 'on', 'k', {}, [], [1.5 4.5 7 9], 'on', 'k', {'|Q| (pC)'}, [0 400], [0 200 400]);
ax1.XTickLabel = {'Synaptic', 'Intrinsic', 'I_{Na(P)}', 'I_A'};
ax1.XTickLabelRotation = 0;
paperSize = resizeFig(f1, ax1, 2.8*15, 2*(2.8/11.5585087)*15, [3.65 2.2], [0 0.3], 0);
if save
    exportFig(f1, [name(1:end-4) '_Q.tif'],'-dtiffnocompression','-r300', paperSize);
end
