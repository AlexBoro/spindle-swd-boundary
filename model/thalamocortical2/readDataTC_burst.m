% The script file assesses the intracellular [Ca2+] dynamics in TC cells.

clc
close all
clear all
format long

diam = 60; %[uf]
L = 90;    %[uf]
Area = pi*(L*1e-4)*(diam*1e-4);

f1 = figure('Units', 'normalized', 'Position', [0, .01, .48, .89]);
f2 = figure('Units', 'normalized', 'Position', [0, .01, .48, .89]);
f3 = figure('Units', 'normalized', 'Position', [0, .01, .48, .89]);
f4 = figure('Units', 'normalized', 'Position', [0, .01, .48, .89]);

fileName = 'TC0data0.dat';
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
Ih = A(18,:)*1e6*Area;
Ihm = A(19,:);
IHVA = A(32,:)*1e6*Area;
IHVAm = A(33,:);

t6000msec = t;
t6000msec(t6000msec <= 6000) = 0;
iT = find(t6000msec, 1);
[peak, iPeak] = max(Cai(iT:end-3));
iPeak = iT-1+iPeak;
trough = Cai(end);
amplitude = peak - trough;
fprintf('amplitude = %g nM\n', amplitude);

oneOverE = (peak - trough)/exp(1);
decay = Cai(iPeak:end);
decay(decay > oneOverE+trough) = 0;
iOneOverE = find(decay, 1);
iOneOverE = iPeak-1+iOneOverE;
tauDecay1 = t(iOneOverE) - t(iPeak);
fprintf('tau = %g ms\n', tauDecay1);

figure(f1)
hold on
plot(t*1e-3, v)
title('Membrane Potential Trace')
xlabel('Time (s)')
ylabel('Membrane potential (mV)')
hold off
xlim([5.99 6.4])

figure(f2)
hold on
plot(t*1e-3, ICa)
title('Membrane Current Trace (I_T)')
xlabel('Time (s)')
ylabel('Membrane current (nA)')
hold off

figure(f3)
hold on
plot(t*1e-3, Ih)
title('Membrane Current Trace (I_h)')
xlabel('Time (s)')
ylabel('Membrane current (nA)')
hold off

figure(f4)
hold on
plot(t*1e-3, Cai)
plot(t(1, iPeak)*1e-3, peak, 'r.', 'markerSize', 5)
plot(t(1, iOneOverE)*1e-3, oneOverE + trough, 'r.', 'markerSize', 5)
title('Intracellular [Ca2+]')
xlabel('Time (s)')
ylabel('Concentration (nM)')
hold off
    
% figure(f1)
% ylim([-110 60])
% 
% figure(f2)
% xlim([1.98 2.15])
% ylim([-10 1])
% 
% figure(f3)
% xlim([1.98 2.15])
