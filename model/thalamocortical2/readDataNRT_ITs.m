% The script file estimates the maximal amplitude and I-V curve of I_Ts
% in NRT cells.

clc
close all
format long
commandV = (-100:5:40);
peaks = zeros(1, length(commandV));
amplitudes = peaks;
diam = 42; %[uf]
L = 63;    %[uf]
Area = pi*(L*1e-4)*(diam*1e-4);

f1 = figure('Units', 'normalized', 'Position', [0,.01, .48, .89]);
f2 = figure('Units', 'normalized', 'Position', [0,.01, .48, .89]);
f3 = figure('Units', 'normalized', 'Position', [0,.01, .48, .89]);
for iFile = 0:length(commandV)-1
    fileName = ['y10_NRTdata' num2str(iFile) '.dat'];
    [~, data, cellType] = loadFile(fileName, Area, 'NRT');
    
    t2000msec = data.t;
    t2000msec(t2000msec <= 2000) = 0;
    iT = find(t2000msec, 1);
    [peak, iPeak] = min(data.ICa(iT:end-3));
    iPeak = iT-1+iPeak;
    peaks(iFile+1) = peak;
    amplitudes(iFile+1) = abs(peak);
    
    figure(f1)
    hold on
    plot(data.t*1e-3, data.v)
    title('Membrane Potential Trace')
    xlabel('Time (s)')
    ylabel('Membrane potential (mV)')
    hold off
    
    figure(f2)
    hold on
    plot(data.t*1e-3, data.ICa)
    plot(data.t(iPeak)*1e-3, peak, 'r.', 'markerSize', 5)
    title('Membrane Current Trace')
    xlabel('Time (s)')
    ylabel('Membrane current (nA)')
    hold off
    
    figure(f3)
    hold on
    plot(data.t*1e-3, data.Cai)
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
