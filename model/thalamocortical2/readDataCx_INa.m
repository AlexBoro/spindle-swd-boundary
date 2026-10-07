% The script file plots fast I_Na of a Cx cell.

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
INaS = A(5,:)*1e6*Area;
INamS = A(6,:);
INahS = A(7,:);

%Plot membrane potential data:
f1 = figure('Units', 'normalized', 'Position', [0, .01, .48, .89]);
plot(t*1e-3, vS)
titleStr = sprintf('Membrane Potential Trace - file: %s', fileName);
set(f1,'name',titleStr)
title(titleStr)
xlabel('Time (s)')
ylabel('Membrane potential (mV)')
ylim([-100 50])
    
%Plot I_Na at the soma:
f2 = figure('Units', 'normalized', 'Position', [0, .01, .48, .89]);
plot(t*1e-3, INaS)
titleStr = sprintf('I_N_a at the soma - file: %s', fileName);
set(f2,'name',titleStr)
title(titleStr)
xlabel('Time (s)')
ylabel('Membrane current (nA)')

%Plot the activation state of the fast I_Na at the soma:
f3 = figure('Units', 'normalized', 'Position', [0, .01, .48, .89]);
plot(t*1e-3, INamS.^3)
titleStr = sprintf('Activation state (m^3) of the fast I_N_a at the soma - file: %s', fileName);
set(f3,'name',titleStr)
title(titleStr)
xlabel('Time (s)')
ylabel('Proportion of the channels in the activation state')

%Plot the inactivation state of the fast I_Na at the soma:
f4 = figure('Units', 'normalized', 'Position', [0, .01, .48, .89]);
plot(t*1e-3, 1 - INahS)
titleStr = sprintf('Inctivation state (1-h) of the fast I_N_a at the soma - file: %s', fileName);
set(f4,'name',titleStr)
title(titleStr)
xlabel('Time (s)')
ylabel('Proportion of the channels in the inactivation state')

%Plot the proportion of the open channels of the fast I_Na at the soma:
f5 = figure('Units', 'normalized', 'Position', [0, .01, .48, .89]);
plot(t*1e-3, INamS.^3.*(1 - INahS))
titleStr = sprintf('Proportion of open channels of the fast I_N_a at the soma - file: %s', fileName);
set(f5,'name',titleStr)
title(titleStr)
xlabel('Time (s)')
ylabel('Proportion of open channels')