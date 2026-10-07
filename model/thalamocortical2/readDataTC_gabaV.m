% The script file assesses the intracellular [Ca2+] dynamics in NRT cells.

clc
close all
clear all
format long

diam = 60; %[uf]
L = 90;    %[uf]
Area = pi*(L*1e-4)*(diam*1e-4);

f1 = figure('Units', 'normalized', 'Position', [0, .01, .48, .89]);

fileName = 'TCdata_1_0600_TC.dat';
%fileName = 'NRTdata_1_0700_WA.dat';
fid = fopen(fileName,'rt');
A = textscan(fid, '%f', 'HeaderLines', 1);
fclose(fid);
A = A{1};
n = length(A)/2;
A = reshape(A,n,2)';
t = A(1,:);
v = A(2,:);

t5000msec = t;
t5000msec(t5000msec <= 5000) = 0;
iT = find(t5000msec, 1);
[peak, iPeak] = min(v(iT:end-3));
iPeak = iT-1+iPeak;
trough = v(iT);
amplitude = peak - trough;
fprintf('IPSP amplitude = %g mV\n', amplitude);
fprintf('Rise time = %g ms\n', t(iPeak) - 5003.79);

oneOverE = abs(peak - trough)/exp(1);
decay = abs(v(iPeak:end));
decay(decay > oneOverE+abs(trough)) = 0;
iOneOverE = find(decay, 1);
iOneOverE = iPeak-1+iOneOverE;
tauDecay1 = t(iOneOverE) - t(iPeak);
fprintf('tau = %g ms\n', tauDecay1);

figure(f1)
hold on
plot(t*1e-3, v)
plot(t(iPeak)*1e-3, peak, 'r.', 'markerSize', 5)
plot(t(iOneOverE)*1e-3, trough - oneOverE, 'r.', 'markerSize', 5)
title('Membrane Current Trace')
xlabel('Time (s)')
ylabel('Membrane current (nA)')
hold off
%xlim([4.9 5.5])
