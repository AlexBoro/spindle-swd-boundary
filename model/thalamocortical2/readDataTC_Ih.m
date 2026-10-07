% The script file estimates the maximal amplitude and I-V curve of I_h
% in TC cells.

clc
close all
format long
peaks = zeros(1, 15);
amplitudes = peaks;
commandV = (-110:5:-40);
diam = 60; %[uf]
L = 90;    %[uf]
Area = pi*(L*1e-4)*(diam*1e-4);

f1 = figure(1);
f2 = figure(2);
for iFile = 0:14
    fileName = ['TC0data' num2str(iFile) '.dat'];
    fid = fopen(fileName,'rt');
    A = textscan(fid, '%f', 'HeaderLines', 1);
    fclose(fid);
    A = A{1};
    n = length(A)/33;
    A = reshape(A,n,33)';
    t = A(1,:);
    v = A(2,:);
    Ih = A(18,:)*1e6*Area;
    Ihm = A(19,:);
    
    t10000msec = t;
    t10000msec(t10000msec <= 10000) = 0;
    iT = find(t10000msec, 1);
    if commandV(iFile+1) <= -65
        [peak, iPeak] = min(Ih(iT:end-3));
    else
        [peak, iPeak] = max(Ih(iT:end-3));
    end
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
    plot(t*1e-3, Ih)
    plot(t(iPeak)*1e-3, peak, 'r.', 'markerSize', 5)
    title('Membrane Current Trace')
    xlabel('Time (s)')
    ylabel('Membrane current (nA)')
    hold off
end
figure(f1)
ylim([-120 -30])

figure(f2)
xlim([4.98 15])

figure
absAmps = abs(amplitudes);
plot(commandV, amplitudes/(max(amplitudes)))
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

% cm = 0.88; %[uf/cm2]
% Cm = Area*cm*1e6 %[uf]