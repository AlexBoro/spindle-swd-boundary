% The script file plots the membrane potential of a Cx cell.

clc
close all
clear all
format longG

cell = 'TC';
multiDisp = 1;
if multiDisp
    if strcmp(cell, 'TC')
        denom = 46;
    else
        denom = 36;
    end
else
    denom = 2;
end

if strcmp(cell, 'TC')
    i = 701;
else
    i = 601;
end
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
v = A(2,:);

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

RT = tMax - tStart %#ok<NOPTS>
latency = tMax - 1000 %#ok<NOPTS>

vDecay = v(indMax:end);
vDecay = vDecay - vDecay(end);
vDecay = vDecay - maxV/exp(1);
vDecay(vDecay < 0) = 0;
indE = indMax + find(vDecay, 1, 'last') - 1;
tE = t(indE);
tauDecay = tE - t(indMax) %#ok<NOPTS>

% Plot membrane current data:
figure('Units', 'normalized', 'Position', [0, .01, .48, .89]);
if multiDisp
    subplot(3,1,1) %#ok<*UNRCH>
    hold on
    plot((t+shift)*1e-3, v)
    %plot([tStart+shift t10RT+shift t90RT+shift tMax+shift tE+shift]*1e-3, [v(indStart) v(ind10RT)...
    %    v(ind90RT) v(indMax) v(indE)], '.r', 'MarkerSize', 10)
    hold off
    titleStr = sprintf('Membrane Potential Trace - file: %s', fileName);
    set(gcf,'name',titleStr)
    title(titleStr)
    xlabel('Time (s)')
    ylabel('Membrane potential (mV)')
    %ylim([min(v(ind5000:ind6990))-0.5 max(v(ind5000:ind6990))+0.5])
    %xlim([24.9 25.9])

    if strcmp(cell, 'TC')
        imGluR1a = A(41,:).^4; %A(39,:);
    else
        imGluR1a = A(32,:);
    end
    subplot(3,1,2)
    hold on
    plot((t+shift)*1e-3, imGluR1a)
    titleStr = sprintf('K^+ leak current');
    title(titleStr)
    xlabel('Time (s)')
    ylabel('Current (nA)')
    hold off

    if strcmp(cell, 'TC')
        imGluR1a_Gn = A(41,:).^4 ./ (A(41,:).^4 + 0.0001);
        imGluR1a_R = A(40,:);
    else
        imGluR1a_Gn = A(34,:).^4 ./ (A(34,:).^4 + 0.0001);
        imGluR1a_R = A(33,:);
    end
    subplot(3,1,3)
    hold on
    plot((t+shift)*1e-3, imGluR1a_Gn)
    plot((t+shift)*1e-3, imGluR1a_R, 'r')
    titleStr = sprintf('mGluR1a activation level');
    title(titleStr)
    xlabel('Time (s)')
    ylabel('Proportion of closed K^+ leak channels')
    hold off
else
    plot((t+shift)*1e-3, v)
    hold on
    plot([tStart+shift t10RT+shift t90RT+shift tMax+shift tE+shift]*1e-3, [v(indStart) v(ind10RT)...
        v(ind90RT) v(indMax) v(indE)], '.r', 'MarkerSize', 10)
    hold off
    titleStr = sprintf('Membrane Potential Trace - file: %s', fileName);
    set(gcf,'name',titleStr)
    title(titleStr)
    xlabel('Time (s)')
    ylabel('Membrane potential (mV)')
    ylim([min(v(ind5000:ind6990))-0.5 max(v(ind5000:ind6990))+0.5])
    %xlim([24.9 25.9])
end
