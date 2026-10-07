% The script file plots the membrane potential of a Cx cell.

clc
close all
clear all
format longG

list = dir('*dat');
files = [1, 25, 50, 75, 100];
% for i = 1: size(files, 2)
%     fileName = list(files(i)).name;
% for i = 1:size(list, 1)
for i = 401
    fileName = list(i).name;
    fid = fopen(fileName,'rt');
    A = textscan(fid, '%f', 'HeaderLines', 1);
    fclose(fid);
    A = A{1};
    n = length(A)/38;
    A = reshape(A,n,38)';
    t = A(1,:);
    vS = A(2,:);
    iS = A(3,:);
    
    t1000_2000 = t - 1000;
    t1000_2000(t1000_2000 < 0) = 0;
    ind1000 = find(t1000_2000, 1);
    t1000_2000 = t - 2000;
    t1000_2000(t1000_2000 < 0) = 0;
    ind2000 = find(t1000_2000, 1);
    t1000_2000 = t(ind1000:ind2000);
    v1000_2000 = abs(vS(ind1000:ind2000));
    v1000_2000 = v1000_2000 - v1000_2000(1);
    indStart = ind1000 + find(v1000_2000, 1) - 1;
    tStart = t(indStart); % should be >4.2ms
    
    [maxV, indMax] = max(v1000_2000);
    amplitude = maxV %#ok<*NOPTS>
    indMax = ind1000 + indMax - 1;
    tMax = t(indMax);
    i1000_2000RT = v1000_2000 - 0.0025*maxV; % 0.1%
    i1000_2000RT(i1000_2000RT < 0) = 0;
    ind1RT = ind1000 + find(i1000_2000RT, 1) - 1;
    t1RT = t(ind1RT);
    
    latency = t1RT - 1004.2
    RT = tMax - t1RT
    
    
    v1000_2000 = abs(vS(ind1000:ind2000));
    vDecay = abs(vS(indMax:end)) - v1000_2000(1);
    vDecay = vDecay - maxV/exp(1);
    vDecay(vDecay < 0) = 0;
    indE = indMax + find(vDecay, 1, 'last');
    tE = t(indE);
    tauDecay = tE - t(indMax)
    
    % Plot membrane potential data:
    figure('Units', 'normalized', 'Position', [0, .01, .48, .89]);
    plot(t, vS)
    hold on
    plot([t(ind1000), tStart, t1RT, tMax, tE],...
        [vS(ind1000), vS(indStart), vS(ind1RT), vS(indMax), vS(indE)], '.r', 'MarkerSize', 10)
    hold off
    titleStr = sprintf('Membrane Potential Trace - file: %s', fileName);
    set(gcf,'name',titleStr)
    title(titleStr)
    xlabel('Time (s)')
    ylabel('Membrane potential (mV)')
    %ylim([-74 -70.5])
end

% Aim: amplitude of a single IPSP ~2mV (@Vm=-71.5), latency ~47ms (@100Hz),
% RT ~58ms.