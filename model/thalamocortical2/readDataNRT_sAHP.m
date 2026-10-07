% The script file plots a voltage trace of a file with the simulation of
% the slow afterhyperpolarisation in NRT.

clc
close all
format long
diam = 42; %[uf]
L = 63;    %[uf]
Area = pi*(L*1e-4)*(diam*1e-4);

fileName = 'NRTdata0.dat';
fid = fopen(fileName,'rt');
A = textscan(fid, '%f', 'HeaderLines', 1);
fclose(fid);
A = A{1};
n = length(A)/36;
A = reshape(A,n,36)';
t = A(1,:);
v = A(2,:);
IKleak = A(5,:);
INaleak = A(6,:);
INa = A(7,:)*1e6*Area;
INam = A(8,:);
INah = A(9,:);
IK = A(10,:)*1e6*Area;
IKn = A(11,:);
Cai = A(12,:)*1e6;
ICa = A(13,:)*1e6*Area;
ICam = A(14,:);
ICah = A(15,:);
Ih = A(16,:)*1e6*Area;
Ihm = A(17,:);
IAHP = A(20,:)*1e6*Area;
IAHPm1 = A(21,:);
IAHPm2 = A(22,:);
ICAN = A(23,:)*1e6*Area;
ICANp1 = A(24,:);
ICANo = A(25,:);
INaPm = A(26,:);
Nai = A(27,:);
IKNan = A(28,:);

t5500msec = t;
t5500msec(t5500msec <= 5500) = 0;
iT = find(t5500msec, 1);
[peak, iPeak] = min(v(iT:end-3));
iPeak = iT-1+iPeak;
tAdj = abs(t - 3000);
[~, i3000] = min(tAdj);
baseline = v(i3000-1);
amplitude = abs(peak - baseline)

oneOverE = amplitude/exp(1);
decay = abs(v(iPeak:end));
decay(decay > oneOverE+abs(baseline)) = 0;
iOneOverE = find(decay, 1);
iOneOverE = iPeak-1+iOneOverE;
decay = t(iOneOverE) - t(iPeak)

%Plot membrane potential data:
f1 = figure('Units', 'normalized', 'Position', [0,.01, .48, .89]);
plot(t*1e-3, v)
hold on
plot(t(iPeak)*1e-3, peak, 'r.', 'markerSize', 5)
plot(t(iOneOverE)*1e-3, v(iOneOverE), 'r.', 'markerSize', 5)
hold off
titleStr = sprintf('Membrane Potential Trace - file: %s, frequency: %2.2f',...
    fileName, f(iStart+imax-1));
set(f1,'name',titleStr)
title(titleStr)
xlabel('Time (s)')
ylabel('Membrane potential (mV)')
ylim([-100 50])

%Plot [Na+]_i data:
f5 = figure('Units', 'normalized', 'Position', [0,.01, .48, .89]);
plot(t*1e-3, Nai)
[~, iNaiPeak] = max(Nai);
naiRT = t(iNaiPeak) - 3000
titleStr = sprintf('[Na+]_i Trace - file: %s, frequency: %2.2f',...
    fileName, f(iStart+imax-1));
set(f5,'name',titleStr)
title(titleStr)
xlabel('Time (s)')
ylabel('Concentration (mM)')

%Plot I_K[Na] data:
f6 = figure('Units', 'normalized', 'Position', [0,.01, .48, .89]);
plot(t*1e-3, IKNan)
titleStr = sprintf('I_K_[_N_a_] Activation Trace - file: %s, frequency: %2.2f',...
    fileName, f(iStart+imax-1));
set(f6,'name',titleStr)
title(titleStr)
xlabel('Time (s)')
ylabel('Proprtion of open channels')
