% The script file estimates the maximal amplitude and I-V curve of I_NaP
% in TC cells.

clc
close all
format long
peaks = zeros(1, 21);
commandV = (-100:5:0);
diam = 60; %[uf]
L = 90;    %[uf]
AreaTC = pi*(L*1e-4)*(diam*1e-4);

f1 = figure(1);
f2 = figure(2);
for iFile = 0:20
    fileName = ['y10_TCdata' num2str(iFile) '.dat'];
    [~, data, cellType] = loadFile(fileName, AreaTC, 'TC');
    t = data.t;
    v = data.v;
    INa = data.INa;
    INaPm = data.INaPm;
    
    peak = INa(end);
    peaks(iFile+1) = peak;
    
    figure(f1)
    hold on
    plot(t*1e-3, v)
    title('Membrane Potential Trace')
    xlabel('Time (s)')
    ylabel('Membrane potential (mV)')
    hold off
    
    figure(f2)
    hold on
    plot(t*1e-3, INa)
    plot(t(end)*1e-3, peak, 'r.', 'markerSize', 5)
    title('Membrane Current Trace')
    xlabel('Time (s)')
    ylabel('Membrane current (nA)')
    hold off
end
figure(f1)
ylim([-130 10])

figure(f2)
xlim([2.98 4])

figure
absAmps = abs(peaks);
plot(commandV, absAmps/(max(absAmps)))
title('I-V Curve (modulus)')
xlabel('Membrane potential (mV)')
ylabel('Membrane current (nA)')

figure
plot(commandV, peaks)
title('I-V Curve')
xlabel('Membrane potential (mV)')
ylabel('Membrane current (nA)')

peaks
maxAmp = min(peaks)

% vtraub = -45;
% v = -100:0.001:40;
% v2 = v - vtraub;
% alpha = zeros(1, length(v));
% beta = alpha;
% tau_m = alpha;
% m_inf = alpha;
% alpha2 = alpha;
% beta2 = alpha;
% tau_m2 = alpha;
% m_inf2 = alpha;
% for i = 1:length(v)
%     alpha(i) = 0.32 * ((13.1 - v2(i))/(exp((13.1 - v2(i))/4) - 1));
%     beta(i) = 0.28 * ((v2(i) - 40.1)/(exp((v2(i) - 40.1)/5) - 1));
%     tau_m(i) = 1 / (alpha(i) + beta(i));
%     m_inf(i) = alpha(i) / (alpha(i) + beta(i));
%     
%     alpha2(i) = 0.32 * ((-66.58 - v(i))/(exp((-66.58 - v(i))/4) - 1));
%     beta2(i) = 0.28 * ((39.58 + v(i))/(exp((39.58 + v(i))/5) - 1));
%     tau_m2(i) = 1 / (alpha2(i) + beta2(i));
%     m_inf2(i) = alpha2(i) / (alpha2(i) + beta2(i));
% end
% 
% plot(v, m_inf)
% hold on
% [~, iHalfAct] = min(abs(m_inf - 0.5));
% halfAct = v(iHalfAct)
% 
% plot(v, m_inf2, 'r')
% hold off
% [~, iHalfAct2] = min(abs(m_inf2 - 0.5));
% halfAct2 = v(iHalfAct2)