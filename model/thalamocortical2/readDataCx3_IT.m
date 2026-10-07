% The script file estimates the maximal amplitude and I-V curve of I_T
% in TC cells.

clc
close all
format long
peaks = zeros(1, 29);
amplitudes = peaks;
commandV = (-100:5:40);
diam = 5.644; %[uf]
L = 5.644;    %[uf]
AreaS = pi*(L*1e-4)*(diam*1e-4);
L = 160*5.644;    %[uf]
AreaD = pi*(L*1e-4)*(diam*1e-4);

f1 = figure(1);
f2 = figure(2);
f3 = figure(3);
for iFile = 0:28
    fileName = ['Cx3_0data' num2str(iFile) '.dat'];
    fid = fopen(fileName,'rt');
    A = textscan(fid, '%f', 'HeaderLines', 1);
    fclose(fid);
    A = A{1};
    n = length(A)/50;
    A = reshape(A,n,50)';
    t = A(1,:);
    v = A(2,:);
    CaiS = A(20,:)*1e6;
    CaiD = A(44,:)*1e6;
    ICaS = A(19,:)*1e6*AreaS;
    ICaD = A(43,:)*1e6*AreaD;
    ITmS = A(23,:);
    IThS = A(24,:);
    ITmD = A(47,:);
    IThD = A(48,:);
    
    t2000msec = t;
    t2000msec(t2000msec <= 2000) = 0;
    iT = find(t2000msec, 1);
    [peak, iPeak] = min(ICaD(iT:end-3));
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
    plot(t*1e-3, ICaD)
    plot(t(iPeak)*1e-3, peak, 'r.', 'markerSize', 5)
    title('Membrane Current Trace')
    xlabel('Time (s)')
    ylabel('Membrane current (nA)')
    hold off
    
    figure(f3)
    hold on
    plot(t*1e-3, CaiD)
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
