% The script file plots I_K[Ca] of a Cx cell.

clc
close all
clear all
format long
diam = 5.7; %[um]
L = 5.7;    %[um]
Area = pi*(L*1e-4)*(diam*1e-4); %[cm^2]

fileName = sprintf('Cx0data0.dat');
fid = fopen(fileName,'rt');
A = textscan(fid, '%f', 'HeaderLines', 1);
fclose(fid);
A = A{1};
n = length(A)/22;
A = reshape(A,n,22)';
t = A(1,:);
vS = A(2,:);
Cai = A(18,:)*1e6;
ICa = A(19,:)*1e6*Area;
IKCan = A(22,:);

%Plot soma membrane potential data:
f1 = figure('Units', 'normalized', 'Position', [0, .01, .48, .89]);
plot(t*1e-3, vS)
titleStr = sprintf('Membrane Potential Trace - file: %s', fileName);
set(f1,'name',titleStr)
title(titleStr)
xlabel('Time (s)')
ylabel('Membrane potential (mV)')
%ylim([-100 50])
    
%Plot the I_Ca @ dend:
f2 = figure('Units', 'normalized', 'Position', [0, .01, .48, .89]);
plot(t*1e-3, ICa)
titleStr = sprintf('I_C_a at the dendrite - file: %s', fileName);
set(f2,'name',titleStr)
title(titleStr)
xlabel('Time (s)')
ylabel('Membrane current (nA)')

%Plot the intracellular Ca2+ @ dend:
f3 = figure('Units', 'normalized', 'Position', [0, .01, .48, .89]);
plot(t*1e-3, Cai)
titleStr = sprintf('[Ca^2^+]_i at the dendrite - file: %s', fileName);
set(f3,'name',titleStr)
title(titleStr)
xlabel('Time (s)')
ylabel('Concentration [mM]')

%Plot the iactivation state of the fast I_K[Ca] @ dend:
f4 = figure('Units', 'normalized', 'Position', [0, .01, .48, .89]);
plot(t*1e-3, IKCan)
titleStr = sprintf('Activation state (n) of the I_K_[_C_a_] at the dendrite - file: %s', fileName);
set(f4,'name',titleStr)
title(titleStr)
xlabel('Time (s)')
ylabel('Proportion of channels in the activation state')

%Plot the proportion of the open channels of the fast I_Na at the soma:
f5 = figure('Units', 'normalized', 'Position', [0, .01, .48, .89]);
plot(t*1e-3, IKCan)
titleStr = sprintf('Proportion of open I_K_[_C_a_] channels at the dendrite - file: %s', fileName);
set(f5,'name',titleStr)
title(titleStr)
xlabel('Time (s)')
ylabel('Proportion of open channels')

% I_K[Ca] model:
q10 = 2.3^((35 - 23) / 10);
Cai = 0:.1:1000;
alpha = 0.01 * Cai;
beta  = 0.02;
tau_n = 1 ./ (alpha + beta) / q10;
n_inf = alpha ./ (alpha + beta);

f6 = figure('Units', 'normalized', 'Position', [0, .01, .48, .89]);
plot(Cai, tau_n)
titleStr = sprintf('I_K_[_C_a_] activation time constant - file: %s', fileName);
set(f6,'name',titleStr)
title(titleStr)
xlabel('Concentration [mM]')
ylabel('Time (ms)')

f7 = figure('Units', 'normalized', 'Position', [0, .01, .48, .89]);
plot(Cai, n_inf)
titleStr = sprintf('I_K_[_C_a_] steady state activation curve - file: %s', fileName);
set(f6,'name',titleStr)
title(titleStr)
xlabel('Concentration [mM]')
ylabel('Proportion of channels in the activation state')
