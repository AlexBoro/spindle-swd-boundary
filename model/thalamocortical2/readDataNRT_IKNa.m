% The script file estimates the maximal amplitude and I-V curve of I_K[Na]
% in NRT cells.

clc
close all
format long
commandV = (-60:5:120);
peaks = zeros(1, length(commandV));
amplitudes = peaks;
diam = 42; %[uf]
L = 63;    %[uf]
Area = pi*(L*1e-4)*(diam*1e-4);

f1 = figure('Units', 'normalized', 'Position', [0,.01, .48, .89]);
f2 = figure('Units', 'normalized', 'Position', [0,.01, .48, .89]);
f3 = figure('Units', 'normalized', 'Position', [0,.01, .48, .89]);
for iFile = 0:length(commandV)-1
    fileName = ['NRT0data' num2str(iFile) '.dat'];
    fid = fopen(fileName,'rt');
    A = textscan(fid, '%f', 'HeaderLines', 1);
    fclose(fid);
    A = A{1};
    n = length(A)/26;
    A = reshape(A,n,26)';
    t = A(1,:);
    v = A(2,:);
    IK = A(10,:)*1e6*Area;
    Nai = A(25,:);
    IKNan = A(26,:);
    
    t5000msec = t;
    t5000msec(t5000msec <= 5000) = 0;
    iT = find(t5000msec, 1);
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
    
    figure(f3)
    hold on
    plot(t*1e-3, Nai)
    title('Intracellular [Na+]')
    xlabel('Time (s)')
    ylabel('Concentration (mM)')
    hold off
end
figure(f1)
ylim([-110 130])

figure(f2)
%xlim([1.98 2.15])
%ylim([-10 1])

figure(f3)
%xlim([1.98 3])

figure('Units', 'normalized', 'Position', [0,.01, .48, .89]);
absAmps = abs(amplitudes);
plot(commandV, absAmps/(max(absAmps)))
title('I-V Curve (modulus)')
xlabel('Membrane potential (mV)')
ylabel('Membrane current (nA)')

figure('Units', 'normalized', 'Position', [0,.01, .48, .89]);
plot(commandV, amplitudes)
title('I-V Curve')
xlabel('Membrane potential (mV)')
ylabel('Membrane current (nA)')

amplitudes
maxAmp = max(amplitudes)
