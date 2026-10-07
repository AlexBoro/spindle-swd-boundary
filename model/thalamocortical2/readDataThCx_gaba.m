% The script file plots the membrane potential of a Cx cell.

clc
close all
clear all
format longG

multiDisp = 0;
if multiDisp
    denom = 40;
else
    denom = 2; %#ok<*UNRCH>
end

i = 627;
list = dir('*dat');
fileName = list(i).name;
fid = fopen(fileName,'rt');
A = textscan(fid, '%f', 'HeaderLines', 1);
fclose(fid);
A = A{1};

n = length(A)/denom;
A = reshape(A,n,denom)';
shift = 20000;
t = A(1,:) - shift;
v = -A(2,:);

t5000_6990 = t - 5000;
t5000_6990(t5000_6990 < 0) = 0;
ind5000 = find(t5000_6990, 1);
t5000_6990 = t - 6990;
t5000_6990(t5000_6990 < 0) = 0;
ind6990 = find(t5000_6990, 1);
t5000_6990 = t(ind5000:ind6990);
v5000_6990 = v(ind5000:ind6990);
v5000_6990 = v5000_6990 - min(v5000_6990);
indStart = ind5000 + find(v5000_6990, 1) - 1;
tStart = t(indStart);

[maxV, indMax] = max(v5000_6990);
amplitude = maxV %#ok<NOPTS>
indMax = ind5000 + indMax - 1;
tMax = t(indMax);
v5000_6990RT = v5000_6990 - 0.1*maxV; 
v5000_6990RT(v5000_6990RT < 0) = 0;
ind10RT = ind5000 + find(v5000_6990RT, 1) - 1;
t10RT = t(ind10RT);

v5000_6990RT = v5000_6990 - 0.9*maxV;
v5000_6990RT(v5000_6990RT < 0) = 0;
ind90RT = ind5000 + find(v5000_6990RT, 1) - 1;
t90RT = t(ind90RT);
RT10_90 = t90RT - t10RT %#ok<NOPTS>

v5000_6990RT = v5000_6990 - 0.2*maxV; 
v5000_6990RT(v5000_6990RT < 0) = 0;
ind20RT = ind5000 + find(v5000_6990RT, 1) - 1;
t20RT = t(ind20RT);
v5000_6990RT = v5000_6990 - 0.8*maxV;
v5000_6990RT(v5000_6990RT < 0) = 0;
ind80RT = ind5000 + find(v5000_6990RT, 1) - 1;
t80RT = t(ind80RT);
RT20_80 = t80RT - t20RT %#ok<NOPTS>

v5000_6990RT = v5000_6990 - 0.01*maxV; 
v5000_6990RT(v5000_6990RT < 0) = 0;
indLat = ind5000 + find(v5000_6990RT, 1) - 1;
tLat = t(indLat);
RT = tMax - tLat %#ok<NOPTS>
latency = tLat - 5003.6 %#ok<NOPTS>

vDecay = v(indMax:end);
vDecay = vDecay - vDecay(end);
vDecay = vDecay - maxV/exp(1);
vDecay(vDecay < 0) = 0;
indE = indMax + find(vDecay, 1, 'last');
tE = t(indE);
tauDecay = tE - t(indMax) %#ok<NOPTS>

% Plot membrane current data:
figure('Units', 'normalized', 'Position', [0, .01, .48, .89]);
if multiDisp
    v = -v;
    subplot(3,1,1) %#ok<*UNRCH>
    hold on
    plot((t+shift)*1e-3, v)
    plot([tStart+shift tLat+shift t10RT+shift t90RT+shift tMax+shift tE+shift]*1e-3, [v(indStart)...
        v(indLat) v(ind10RT) v(ind90RT) v(indMax) v(indE)], '.r', 'MarkerSize', 10)
    hold off
    titleStr = sprintf('Membrane Potential Trace - file: %s', fileName);
    set(gcf,'name',titleStr)
    title(titleStr)
    xlabel('Time (s)')
    ylabel('Membrane potential (mV)')
    ylim([min(v(ind5000:ind6990))-0.5 max(v(ind5000:ind6990))+0.5])
    xlim([24.9 25.9])

    iGABAb = A(38,:);
    subplot(3,1,2)
    hold on
    plot((t+shift)*1e-3, iGABAb)
    titleStr = sprintf('GABAb current');
    title(titleStr)
    xlabel('Time (s)')
    ylabel('Current (nA)')
    hold off
    xlim([24.9 25.9])

    iGABAb_Gn = A(40,:).^8 ./ (A(40,:).^8 + 17.83);
    iGABAb_R = A(39,:);
    subplot(3,1,3)
    hold on
    plot((t+shift)*1e-3, A(40,:), 'k')
    plot((t+shift)*1e-3, A(40,:).^8, 'k')
    plot((t+shift)*1e-3, iGABAb_Gn)
    plot((t+shift)*1e-3, iGABAb_R, 'r')
    titleStr = sprintf('GABAb activation level');
    title(titleStr)
    xlabel('Time (s)')
    ylabel('Proportion of open GABAb channels')
    hold off
    xlim([24.9 25.9])
else
    v = -v;
    plot((t+shift)*1e-3, v)
    hold on
    plot([tStart+shift tLat+shift t10RT+shift t90RT+shift tMax+shift tE+shift]*1e-3, [v(indStart)...
        v(indLat) v(ind10RT) v(ind90RT) v(indMax) v(indE)], '.r', 'MarkerSize', 10)
    hold off
    titleStr = sprintf('Membrane Potential Trace - file: %s', fileName);
    set(gcf,'name',titleStr)
    title(titleStr)
    xlabel('Time (s)')
    ylabel('Membrane potential (mV)')
    ylim([min(v(ind5000:ind6990))-0.5 max(v(ind5000:ind6990))+0.5])
    xlim([24.9 25.9])
end

a = [0:0.1:10];
iGABAb_Gn = a.^4 ./ (a.^4 + 5);
%plot(a, iGABAb_Gn)