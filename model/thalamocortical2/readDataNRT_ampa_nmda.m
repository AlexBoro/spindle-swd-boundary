% The script file assesses the intracellular [Ca2+] dynamics in NRT cells.

%clc
close all
clear all
format long

diam = 42; %[uf]
L = 63;    %[uf]
Area = pi*(L*1e-4)*(diam*1e-4);



f1 = figure('Units', 'normalized', 'Position', [0, .01, .48, .89]);

fileName = '0_NRT0data0.dat';
fid = fopen(fileName,'rt');
A = textscan(fid, '%f', 'HeaderLines', 1);
fclose(fid);
A = A{1};
n = length(A)/27;
A = reshape(A,n,27)';
t = A(1,:);
IVC = A(3,:);

t5000msec = t;
t5000msec(t5000msec <= 5000) = 0;
iT = find(t5000msec, 1);
[peak, iPeak] = min(IVC(iT:end-3));
iPeak = iT-1+iPeak;
trough = IVC(iT);
amplitude = peak - trough;
fprintf('IPSC amplitude = %g nA\n', amplitude);
fprintf('Rise time = %g ms\n', t(iPeak) - 5006.88);

oneOverE = abs(peak - trough)/exp(1);
decay = abs(IVC(iPeak:end) - trough);
decay(decay > oneOverE+abs(trough)) = 0;
iOneOverE = find(decay, 1);
iOneOverE = iPeak-1+iOneOverE;
tauDecay1 = t(iOneOverE) - t(iPeak);
fprintf('tau = %g ms\n', tauDecay1);

figure(f1)
hold on
plot(t*1e-3, IVC)
plot(t(iPeak)*1e-3, peak, 'r.', 'markerSize', 5)
plot(t(iOneOverE)*1e-3, trough - oneOverE, 'r.', 'markerSize', 5)
title('Membrane Current Trace')
xlabel('Time (s)')
ylabel('Membrane current (nA)')
hold off
xlim([4.9 5.5])



f2 = figure('Units', 'normalized', 'Position', [0, .01, .48, .89]);

fileName = '0_NRT1data1.dat';
fid = fopen(fileName,'rt');
A = textscan(fid, '%f', 'HeaderLines', 1);
fclose(fid);
A = A{1};
n = length(A)/27;
A = reshape(A,n,27)';
t = A(1,:);
v = A(2,:);

t5000msec = t;
t5000msec(t5000msec <= 5000) = 0;
iT = find(t5000msec, 1);
[peak, iPeak] = max(v(iT:end-3));
iPeak = iT-1+iPeak;
trough = v(iT);
amplitude = peak - trough;
fprintf('IPSP amplitude = %g mV\n', amplitude);
fprintf('Rise time = %g ms\n', t(iPeak) - 5006.88);

per10 = (peak - trough)*0.1;
per90 = (peak - trough)*0.9;
rise10 = v(iT:iPeak);
rise90 = v(iT:iPeak);
rise10(rise10 > trough+per10) = 0;
rise90(rise90 > trough+per90) = 0;
iRise10 = find(rise10, 1, 'last');
iRise90 = find(rise90, 1, 'last');
RT = t(iT+iRise90-1) - t(iT+iRise10-1);
fprintf('10-90%% Rise time = %g ms\n', RT);

oneOverE = (peak - trough)/exp(1);
decay = v(iPeak:end);
decay(decay > oneOverE+trough) = 0;
iOneOverE = find(decay, 1);
iOneOverE = iPeak-1+iOneOverE;
tauDecay1 = t(iOneOverE) - t(iPeak);
fprintf('tau = %g ms\n\n', tauDecay1);

figure(f2)
hold on
plot(t*1e-3, v)
plot(t(iPeak)*1e-3, peak, 'r.', 'markerSize', 5)
plot(t(iOneOverE)*1e-3, oneOverE + trough, 'r.', 'markerSize', 5)
title('Membrane Potential Trace')
xlabel('Time (s)')
ylabel('Membrane potential (mV)')

sought = 1.1*(peak - trough)*0.48*exp((-1/6.1)*(t(iPeak+1:end) - t(iPeak+1)))...
        + 1.1*(peak - trough)*0.52*exp((-1/23.5)*(t(iPeak+1:end) - t(iPeak+1)));
plot(t(iPeak+1:end)*1E-3, sought + trough, 'g')
hold off
xlim([4.9 5.5])

intArea = v(iT:end-3) - trough;
intArea(intArea < 0) = 0;
trapz(intArea)