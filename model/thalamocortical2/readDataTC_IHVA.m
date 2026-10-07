% The script file estimates the maximal amplitude and I-V curve of I_HVA
% in TC cells.

clc
close all
clear all
format long
commandV = (-50:5:50);
peaks = zeros(1, length(commandV));
amplitudes = peaks;
diam = 60; %[uf]
L = 90;    %[uf]
Area = pi*(L*1e-4)*(diam*1e-4);

f1 = figure('Units', 'normalized', 'Position', [0, .01, .48, .89]);
f2 = figure('Units', 'normalized', 'Position', [0, .01, .48, .89]);
f3 = figure('Units', 'normalized', 'Position', [0, .01, .48, .89]);
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
    Cai = A(12,:)*1e6;
    ICa = A(13,:)*1e6*Area;
    ICam = A(14,:);
    ICah = A(15,:);
    ICam2 = A(16,:);
    ICah2 = A(17,:);
    IHVA = A(32,:)*1e6*Area;
    IHVAm = A(33,:);
    
    t2000msec = t;
    t2000msec(t2000msec <= 2000) = 0;
    iT = find(t2000msec, 1);
    [peak, iPeak] = min(IHVA(iT:end-3));
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
    plot(t*1e-3, IHVA)
    plot(t(iPeak)*1e-3, peak, 'r.', 'markerSize', 5)
    title('Membrane Current Trace')
    xlabel('Time (s)')
    ylabel('Membrane current (nA)')
    hold off
    
    figure(f3)
    hold on
    plot(t*1e-3, Cai)
    title('Intracellular [Ca2+]')
    xlabel('Time (s)')
    ylabel('Concentration (nM)')
    hold off
end
figure(f1)
ylim([-60 60])

figure(f2)
xlim([1.98 2.15])
ylim([-10 1])

figure(f3)
xlim([1.98 3])

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
