% The script file estimates the maximal amplitude and I-V curve of I_Na
% in TC cells.

clc
close all
format long
commandV = (-70:5:40);
peaks = zeros(1, length(commandV));
amplitudes = peaks;
diam = 60; %[uf]
L = 90;    %[uf]
Area = pi*(L*1e-4)*(diam*1e-4);

f1 = figure('Units', 'normalized', 'Position', [0, .01, .48, .89]);
f2 = figure('Units', 'normalized', 'Position', [0, .01, .48, .89]);
for iFile = 0:length(commandV)-1
    fileName = ['TC0data' num2str(iFile) '.dat'];
    fid = fopen(fileName,'rt');
    A = textscan(fid, '%f', 'HeaderLines', 1);
    fclose(fid);
    A = A{1};
    n = length(A)/33;
    A = reshape(A,n,33)';
    t = A(1,:);
    v = A(2,:);
    INa = A(7,:)*1e6*Area;
    INam = A(8,:);
    INah = A(9,:);
    
    t2000msec = t;
    t2000msec(t2000msec <= 2000) = 0;
    iT = find(t2000msec, 1);
    [peak, iPeak] = min(INa(iT:end-3));
    iPeak = iT-1+iPeak;
    peaks(iFile+1) = peak;
    amplitudes(iFile+1) = abs(peak);
    
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
    plot(t(iPeak)*1e-3, peak, 'r.', 'markerSize', 5)
    title('Membrane Current Trace')
    xlabel('Time (s)')
    ylabel('Membrane current (nA)')
    hold off
end
figure(f1)
ylim([-115 50])

figure(f2)
xlim([1.999 2.015])

figure('Units', 'normalized', 'Position', [0, .01, .48, .89]);
absAmps = abs(amplitudes);
plot(commandV, absAmps/(max(absAmps)))
title('I-V Curve (modulus)')
xlabel('Membrane potential (mV)')
ylabel('Membrane current (nA)')

figure('Units', 'normalized', 'Position', [0, .01, .48, .89]);
plot(commandV, amplitudes)
title('I-V Curve')
xlabel('Membrane potential (mV)')
ylabel('Membrane current (nA)')

amplitudes
maxAmp = max(amplitudes)

% vtraub = -65.5;
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
% alphaH = alpha;
% betaH = alpha;
% tau_h = alpha;
% h_inf = alpha;
% alphaH2 = alpha;
% betaH2 = alpha;
% tau_h2 = alpha;
% h_inf2 = alpha;
% for i = 1:length(v)
%     alpha(i) = 0.02 * ((13.1 - v2(i))/(exp((13.1 - v2(i))/4) - 1));
%     beta(i) = 0.0175 * ((v2(i) - 40.1)/(exp((v2(i) - 40.1)/5) - 1));
%     tau_m(i) = 1 / (alpha(i) + beta(i));
%     m_inf(i) = (alpha(i) / (alpha(i) + beta(i)))^3;
%     
%     alpha2(i) = 0.054 * ((13.1 + 18 - v2(i))/(exp((13.1 + 18 - v2(i))/4) - 1));
%     beta2(i) = 0.013 * ((v2(i) - 18 - 40.1)/(exp((v2(i) - 18 - 40.1)/5) - 1));
%     tau_m2(i) = 1 / (alpha2(i) + beta2(i));
%     m_inf2(i) = 1 / (1 + exp((35.7 - v2(i))/5.48));
%     
%     alphaH(i) = 0.128 * exp((17 + 11.5 - v2(i)) / 18);
% 	betaH(i) = 4 / ( 1 + exp((40 + 11.5 - v2(i)) / 5) );
% 	tau_h(i) = 1 / (alphaH(i) + betaH(i));
% 	h_inf(i) = 1 / (1 + exp(-(-4.54 - v2(i))/5.8));
%     
%     alphaH2(i) = (0.128/2) * exp((17 + 11.5 - v2(i)) / 18);
% 	betaH2(i) = (4/2) / ( 1 + exp((40 + 11.5 - v2(i)) / 5) );
% 	tau_h2(i) = (1/2) / (alphaH(i) + betaH(i));
% 	h_inf2(i) = 1 / (1 + exp(-(-4.54 - v2(i))/5.8));
% end
% 
% close all
% plot(v, m_inf)
% hold on
% [~, iHalfAct] = min(abs(m_inf - 0.5));
% halfAct = v(iHalfAct)
% plot(v, m_inf2, '--')
% 
% plot(v, h_inf, 'r');
% hold off
% [~, iHalfInact] = min(abs(h_inf - 0.5));
% halfInact = v(iHalfInact)
% 
% figure
% plot(v, tau_m)
% hold on
% plot(v, tau_m2, '--')
% plot(v, tau_h, 'r')
% plot(v, tau_h2, 'r--')
% hold off
