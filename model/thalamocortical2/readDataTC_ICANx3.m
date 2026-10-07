% The script file estimates the maximal amplitude and I-V curve of I_CAN
% in TC cells.

clc
close all
format long
commandV = (-120:5:20);
peaks = zeros(1, length(commandV));
amplitudes = peaks;
steady = peaks;
decays = peaks;
diam = 60; %[uf]
L = 90;    %[uf]
Area = pi*(L*1e-4)*(diam*1e-4);

f1 = figure('Units', 'normalized', 'Position', [0,.01, .48, .89]);
f2 = figure('Units', 'normalized', 'Position', [0,.01, .48, .89]);
f3 = figure('Units', 'normalized', 'Position', [0,.01, .48, .89]);
f4 = figure('Units', 'normalized', 'Position', [0,.01, .48, .89]);
f5 = figure('Units', 'normalized', 'Position', [0,.01, .48, .89]);
f6 = figure('Units', 'normalized', 'Position', [0,.01, .48, .89]);
f7 = figure('Units', 'normalized', 'Position', [0,.01, .48, .89]);
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
    IVC = A(3, :);
    Cai = A(12,:)*1e6;
    ICa = A(13,:)*1e6*Area;
    ICAN = A(20,:)*1e6*Area;
    ICANp1 = A(21,:);
    ICANo = A(22,:);
    
    t4080msec = t;
    t4080msec(t4080msec <= 4080) = 0;
    iT = find(t4080msec, 1);
    if commandV(iFile+1) <= 10
        [peak, iPeak] = min(ICAN(iT:end-3));
    else
        [peak, iPeak] = max(ICAN(iT:end-3));
    end
    iPeak = iT-1+iPeak;
    peaks(iFile+1) = peak;
    trough = ICAN(end);
    steady(iFile+1) = trough;
    amplitude = peak - trough;
    amplitudes(iFile+1) = amplitude;
    
    oneOverE = abs(amplitude)/exp(1);
    decay = abs(ICAN(iPeak:end));
    decay(decay > oneOverE+abs(trough)) = 0;
    iOneOverE = find(decay, 1);
    iOneOverE = iPeak-1+iOneOverE;
    decays(iFile+1) = t(iOneOverE) - t(iPeak);
    
    figure(f1)
    hold on
    plot(t*1e-3, v)
    title('Membrane Potential Trace')
    xlabel('Time (s)')
    ylabel('Membrane potential (mV)')
    hold off
    
    figure(f2)
    hold on
    plot(t*1e-3, ICAN)
    plot(t(1, iPeak)*1e-3, peak, 'r.', 'markerSize', 5)
    title('Membrane Current Trace (I_C_A_N)')
    xlabel('Time (s)')
    ylabel('Membrane current (nA)')
    hold off
    
    figure(f3)
    hold on
    plot(t*1e-3, ICa)
    title('Membrane Current Trace (I_T)')
    xlabel('Time (s)')
    ylabel('Membrane current (nA)')
    hold off
    
    figure(f4)
    hold on
    plot(t*1e-3, IVC)
    title('Membrane Current Trace')
    xlabel('Time (s)')
    ylabel('Membrane current (nA)')
    hold off
    
    figure(f5)
    hold on
    plot(t*1e-3, ICANp1)
    title('Proportion of Ca2+-bound messenger protein')
    xlabel('Time (s)')
    ylabel('Proportion')
    hold off
    
    figure(f6)
    hold on
    plot(t*1e-3, ICANo)
    title('Proportion of open I_C_A_N channels')
    xlabel('Time (s)')
    ylabel('Proportion')
    hold off
    
    figure(f7)
    hold on
    plot(t*1e-3, Cai)
    title('Intracellular [Ca2+]')
    xlabel('Time (s)')
    ylabel('Concentration (nM)')
    hold off
end
figure(f1)
ylim([-130 30])

figure(f2)
xlim([2.98 9])

figure(f3)
xlim([2.98 9])

figure(f4)
xlim([2.98 9])
ylim([-2 1])

figure(f5)
xlim([2.98 9])

figure(f6)
xlim([2.98 9])

p = polyfit(commandV, amplitudes, 1);
fit = p(1)*commandV + p(2);
reversal = -p(2)/p(1);

figure('Units', 'normalized', 'Position', [0,.01, .48, .89]);
plot(commandV, amplitudes, '.', 'markerSize', 5)
hold on
plot(commandV, fit)
title('I-V Curve')
xlabel('Membrane potential (mV)')
ylabel('Membrane current (nA)')
hold off

figure('Units', 'normalized', 'Position', [0,.01, .48, .89]);
plot(commandV, steady)
title('Steady State')
xlabel('Membrane potential (mV)')
ylabel('Membrane current (nA)')

amplitudes
amp60 = amplitudes(13)
reversal
decays
meanDecay = mean(decays(1:end-3))