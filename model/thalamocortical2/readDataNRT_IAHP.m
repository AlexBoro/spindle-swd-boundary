function readDataNRT_IAHP()

% The function should be used for adjusting parameters of I_AHP in NRT cells.

close all
clear all
clc
format long
diam = 42; %[uf]
L = 63;    %[uf]
Area = pi*(L*1e-4)*(diam*1e-4);
fitdexp = 1;



% The first go:
f1 = figure('Units', 'normalized', 'Position', [0,.01, .48, .89]);
f2 = figure('Units', 'normalized', 'Position', [0,.01, .48, .89]);
f3 = figure('Units', 'normalized', 'Position', [0,.01, .48, .89]);
f4 = figure('Units', 'normalized', 'Position', [0,.01, .48, .89]);
f5 = figure('Units', 'normalized', 'Position', [0,.01, .48, .89]);

fileName = 'NRTdata0.dat';
fid = fopen(fileName,'rt');
A = textscan(fid, '%f', 'HeaderLines', 1);
fclose(fid);
A = A{1};
n = length(A)/36;
A = reshape(A,n,36)';
t = A(1,:);
v = A(2, :);
IVC = A(3, :);
Cai = A(12,:)*1e6;
ICa = A(13,:)*1e6*Area;
IAHP = A(20,:)*1e6*Area;
IAHPm1 = A(21,:);
IAHPm2 = A(22,:);

t5126msec = t;
t5126msec(t5126msec <= 5126) = 0;
iT = find(t5126msec, 1);
[peak, iPeak] = max(IAHP(iT:end));
iPeak = iT-1+iPeak;
trough = 0;
troughFit = IAHP(end);
amplitude = peak - trough;
fprintf('amplitude = %g nA\n', amplitude);

oneOverE = (peak - troughFit)/exp(1);
decay = IAHP(iPeak:end);
decay(decay > oneOverE+troughFit) = 0;
iOneOverE = find(decay, 1);
iOneOverE = iPeak-1+iOneOverE;
tauDecay1 = t(iOneOverE) - t(iPeak);
fprintf('tau = %g ms\n', tauDecay1);

if fitdexp
%     f = fit(t(iPeak:end)' - t(iPeak), IAHP(iPeak:end)' - troughFit, 'exp2');
%     fitOpts = fitoptions('exp2',...
%         'Lower', [(peak - troughFit)*0.827-1e-9 -1      (peak - troughFit)*0.173-1e-9 -1     ],...
%         'Upper', [(peak - troughFit)*0.827+1e-9 -0.0001 (peak - troughFit)*0.173+1e-9 -0.0001]);
%     g = fit(t(iPeak:end)' - t(iPeak), IAHP(iPeak:end)' - troughFit, 'exp2', fitOpts);
    sought = (peak - troughFit)*0.827*exp((-1/30.1)*(t(iPeak+1:end) - t(iPeak+1)))...
        + (peak - troughFit)*0.173*exp((-1/834)*(t(iPeak+1:end) - t(iPeak+1)));
    sought2 = (peak - troughFit)*0.785*exp((-1/32.7)*(t(iPeak+1:end) - t(iPeak+1)))...
        + (peak - troughFit)*0.215*exp((-1/1061)*(t(iPeak+1:end) - t(iPeak+1)));
    sought3 = (peak - troughFit)*0.871*exp((-1/27.4)*(t(iPeak+1:end) - t(iPeak+1)))...
        + (peak - troughFit)*0.129*exp((-1/607)*(t(iPeak+1:end) - t(iPeak+1)));
%     fprintf('tau_1 = %g ms\n', 1/f.b);
%     fprintf('tau_2 = %g ms\n', 1/f.d);
%     fprintf('I_1 = %g nA\n', f.a);
%     fprintf('I_2 = %g nA\n', f.c);
%     fprintf('tau_1.2 = %g ms\n', 1/g.b);
%     fprintf('tau_2.2 = %g ms\n', 1/g.d);
%     fprintf('I_1.2 = %g nA\n', g.a);
%     fprintf('I_2.2 = %g nA\n', g.c);
end

[~, iPeakIT] = min(ICa(iT:end));
iPeakIT = iT-1+iPeakIT;
betweenPeaks = t(iPeak) - t(iPeakIT);
fprintf('Peak latency relatively to the peak of I_T = %g ms\n', betweenPeaks);

[~, iPeakCai] = max(Cai(iT:end));
iPeakCai = iT-1+iPeakCai;
betweenCai = t(iPeak) - t(iPeakCai);
fprintf('Peak latency relatively to the peak of [Ca2+]_i = %g ms\n', betweenCai);

figure(f1)
hold on
plot(t*1e-3, v)
title('Membrane Potential Trace')
xlabel('Time (s)')
ylabel('Membrane potential (mV)')
hold off
%ylim([-105 -55])

figure(f2)
hold on
plot(t*1E-3, IAHP)
plot([t(iPeak)*1E-3 t(iOneOverE)*1E-3], [peak oneOverE + troughFit], 'r.', 'markerSize', 5)
if fitdexp
    plot(t(iPeak+1:end)*1E-3, sought + troughFit, 'g')
    plot(t(iPeak+1:end)*1E-3, sought2 + troughFit, 'r')
    plot(t(iPeak+1:end)*1E-3, sought3 + troughFit, 'r')
end
title('I_A_H_P Trace')
xlabel('Time (s)')
ylabel('Membrane current (nA)')
hold off

figure(f3)
hold on
plot(t*1E-3, ICa)
title('I_T Trace')
xlabel('Time (s)')
ylabel('Membrane current (nA)')
hold off

[peak, iPeak] = max(Cai(iT:end));
iPeak = iT-1+iPeak;
troughFit = Cai(end);
amplitude = peak - troughFit;
fprintf('[Ca2+]_i amplitude = %g nM\n', amplitude);

oneOverE = (peak - troughFit)/exp(1);
decay = IAHP(iPeak:end);
decay(decay > oneOverE+troughFit) = 0;
iOneOverE = find(decay, 1);
iOneOverE = iPeak-1+iOneOverE;
tauDecay1 = t(iOneOverE) - t(iPeak);
fprintf('[Ca2+]_i tau = %g ms\n\n', tauDecay1);

figure(f4)
hold on
plot(t*1E-3, Cai)
title('Intracellular [Ca2+]')
xlabel('Time (s)')
ylabel('Concentration (nM)')
hold off

figure(f5)
hold on
plot(t*1E-3, IAHPm1)
plot(t*1E-3, IAHPm2, 'r')
title('I_A_H_P Activation Components')
xlabel('Time (s)')
ylabel('Concentration (nM)')
legend('m_1', 'm_2')
hold off



% The second go:
% f6 = figure('Units', 'normalized', 'Position', [0, .01, .48, .89]);
% f7 = figure('Units', 'normalized', 'Position', [0, .01, .48, .89]);
% 
% fileName = 'NRT1data0.dat';
% fid = fopen(fileName,'rt');
% A = textscan(fid, '%f', 'HeaderLines', 1);
% fclose(fid);
% A = A{1};
% n = length(A)/8;
% A = reshape(A,n,8)';
% IVC_2 = A(3, :);
% 
% IAHP = IVC - IVC_2;
% 
% t5126msec = t;
% t5126msec(t5126msec <= 5126) = 0;
% iT = find(t5126msec, 1);
% [peak, iPeak] = max(IAHP(iT:end));
% iPeak = iT-1+iPeak;
% trough = 0;
% troughFit = IAHP(end);
% amplitude = peak - trough;
% fprintf('amplitude = %g nA\n', amplitude);
% 
% oneOverE = (peak - troughFit)/exp(1);
% decay = IAHP(iPeak:end);
% decay(decay > oneOverE+troughFit) = 0;
% iOneOverE = find(decay, 1);
% iOneOverE = iPeak-1+iOneOverE;
% tauDecay1 = t(iOneOverE) - t(iPeak);
% fprintf('tau = %g ms\n', tauDecay1);
% 
% if fitdexp
% %     f = fit(t(iPeak:end)' - t(iPeak), IAHP(iPeak:end)' - troughFit, 'exp2');
% %     fitOpts = fitoptions('exp2',...
% %         'Lower', [(peak - troughFit)*0.827-1e-9 -1      (peak - troughFit)*0.173-1e-9 -1     ],...
% %         'Upper', [(peak - troughFit)*0.827+1e-9 -0.0001 (peak - troughFit)*0.173+1e-9 -0.0001]);
% %     g = fit(t(iPeak:end)' - t(iPeak), IAHP(iPeak:end)' - troughFit, 'exp2', fitOpts);
%     sought = (peak - troughFit)*0.827*exp((-1/30.1)*(t(iPeak+1:end) - t(iPeak+1)))...
%         + (peak - troughFit)*0.173*exp((-1/834)*(t(iPeak+1:end) - t(iPeak+1)));
%     sought2 = (peak - troughFit)*0.785*exp((-1/32.7)*(t(iPeak+1:end) - t(iPeak+1)))...
%         + (peak - troughFit)*0.215*exp((-1/1061)*(t(iPeak+1:end) - t(iPeak+1)));
%     sought3 = (peak - troughFit)*0.871*exp((-1/27.4)*(t(iPeak+1:end) - t(iPeak+1)))...
%         + (peak - troughFit)*0.129*exp((-1/607)*(t(iPeak+1:end) - t(iPeak+1)));
% %     fprintf('tau_1 = %g ms\n', 1/f.b);
% %     fprintf('tau_2 = %g ms\n', 1/f.d);
% %     fprintf('I_1 = %g nA\n', f.a);
% %     fprintf('I_2 = %g nA\n', f.c);
% %     fprintf('tau_1.2 = %g ms\n', 1/g.b);
% %     fprintf('tau_2.2 = %g ms\n', 1/g.d);
% %     fprintf('I_1.2 = %g nA\n', g.a);
% %     fprintf('I_2.2 = %g nA\n', g.c);
% end
% 
% betweenPeaks = t(iPeak) - t(iPeakIT);
% fprintf('Peak latency relatively to the peak of I_T = %g ms\n', betweenPeaks);
% 
% betweenCai = t(iPeak) - t(iPeakCai);
% fprintf('Peak latency relatively to the peak of [Ca2+]_i = %g ms\n', betweenCai);
% 
% figure(f6)
% hold on
% plot(t*1E-3, IAHP)
% plot([t(iPeak)*1E-3 t(iOneOverE)*1E-3], [peak oneOverE + troughFit], 'r.', 'markerSize', 5)
% if fitdexp
%     plot(t(iPeak+1:end)*1E-3, sought + troughFit, 'g')
%     plot(t(iPeak+1:end)*1E-3, sought2 + troughFit, 'r')
%     plot(t(iPeak+1:end)*1E-3, sought3 + troughFit, 'r')
% end
% title('I_A_H_P Trace Based on Voltage Clamp Current Subtraction')
% xlabel('Time (s)')
% ylabel('Membrane current (nA)')
% hold off
% xlim([5.126 8])
% 
% figure(f7)
% hold on
% plot(t*1E-3, IVC, 'lineWidth', 2)
% plot(t*1E-3, IVC_2)
% plot(t*1E-3, IAHP, 'r')
% title('Voltage Clamp Current Traces')
% xlabel('Time (s)')
% ylabel('Membrane current (nA)')
% legend('Control', 'No I_A_H_P', 'Difference')
% hold off
% xlim([5.1 5.5])
% ylim([-0.2 0.2])