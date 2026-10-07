% The script file estimates the maximal amplitude and I-V curve of I_T
% in TC cells.

clc
close all
format long
peaks = zeros(1, 29);
amplitudes = peaks;
commandV = (-100:5:40);
diam = 60; %[uf]
L = 90;    %[uf]
Area = pi*(L*1e-4)*(diam*1e-4);

f1 = figure(1);
f2 = figure(2);
f3 = figure(3);
for iFile = 0:28
    fileName = ['y10_TCdata' num2str(iFile) '.dat'];
    fid = fopen(fileName,'rt');
    A = textscan(fid, '%f', 'HeaderLines', 1);
    fclose(fid);
    A = A{1};
    n = length(A)/46;
    A = reshape(A,n,46)';
    t = A(1,:);
    v = A(2,:);
    Cai = A(12,:)*1e6;
    ICa = A(13,:)*1e6*Area;
    ICam = A(14,:);
    ICah = A(15,:);
    
    t2000msec = t;
    t2000msec(t2000msec <= 2000) = 0;
    iT = find(t2000msec, 1);
    [peak, iPeak] = min(ICa(iT:end-3));
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
    plot(t*1e-3, ICa)
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
ylim([-110 60])

figure(f2)
xlim([1.98 2.15])
ylim([-10 1])

figure(f3)
xlim([1.98 3])

figure
absAmps = abs(amplitudes);
plot(commandV, absAmps/(max(absAmps)))
title('I-V Curve (modulus)')
xlabel('Membrane potential (mV)')
ylabel('Membrane current (nA)')

figure
plot(commandV, amplitudes)
title('I-V Curve')
xlabel('Membrane potential (mV)')
ylabel('Membrane current (nA)')

amplitudes
maxAmp = max(amplitudes)
