% The script file estimates the maximal amplitude and I-V curve of I_A,
% I_K1, and I_K2 currents in TC cells.

clc
close all
format long
commandV = (-100:5:40);
peaks = zeros(1, length(commandV));
amplitudes = peaks;
diam = 60; %[uf]
L = 90;    %[uf]
Area = pi*(L*1e-4)*(diam*1e-4);

f1 = figure('Units', 'normalized', 'Position', [0,.01, .48, .89]);
f2 = figure('Units', 'normalized', 'Position', [0,.01, .48, .89]);
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
    IK = A(10,:)*1e6*Area;
    IAm1 = A(24,:);
    IAm2 = A(25,:);
    IAh1 = A(26,:);
    IAh2 = A(27,:);
    IK1m = A(28,:);
    IK2m = A(29,:);
    IK2h1 = A(30,:);
    IK2h2 = A(31,:);
    
    t3000msec = t;
    t3000msec(t3000msec <= 3000) = 0;
    iT = find(t3000msec, 1);
    [peak, iPeak] = max(IK(iT:end-3));
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
    plot(t*1e-3, IK)
    plot(t(iPeak)*1e-3, peak, 'r.', 'markerSize', 5)
    title('Membrane Current Trace')
    xlabel('Time (s)')
    ylabel('Membrane current (nA)')
    hold off
end
figure(f1)
ylim([-110 50])

figure(f2)
xlim([2.98 3.1])
ylim([-1 10])

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
