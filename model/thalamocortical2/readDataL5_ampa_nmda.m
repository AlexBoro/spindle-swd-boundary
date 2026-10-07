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
for i = 2
    fileName = list(i).name;
    fid = fopen(fileName,'rt');
    A = textscan(fid, '%f', 'HeaderLines', 1);
    fclose(fid);
    A = A{1};
    n = length(A)/3;
    A = reshape(A,n,3)';
    t = A(1,:);
    vS = A(2,:);
    iS = A(3,:);
    
    t1000_2990 = t - 1000;
    t1000_2990(t1000_2990 < 0) = 0;
    ind1000 = find(t1000_2990, 1);
    t1000_2990 = t - 2990;
    t1000_2990(t1000_2990 < 0) = 0;
    ind2990 = find(t1000_2990, 1);
    t1000_2990 = t(ind1000:ind2990);
    i1000_2990 = -iS(ind1000:ind2990);
    i1000_2990 = i1000_2990 - min(i1000_2990);
    indStart = ind1000 + find(i1000_2990, 1) - 1;
    tStart = t(indStart);
    
    [maxI, indMax] = max(i1000_2990);
    amplitude = 1000*maxI %#ok<NOPTS>
    indMax = ind1000 + indMax - 1;
    tMax = t(indMax);
    i1000_2990RT = i1000_2990 - 0.1*maxI; 
    i1000_2990RT(i1000_2990RT < 0) = 0;
    ind10RT = ind1000 + find(i1000_2990RT, 1) - 1;
    t10RT = t(ind10RT);
    
    i1000_2990RT = i1000_2990 - 0.9*maxI;
    i1000_2990RT(i1000_2990RT < 0) = 0;
    ind90RT = ind1000 + find(i1000_2990RT, 1) - 1;
    t90RT = t(ind90RT);
    RT10_90 = t90RT - t10RT %#ok<NOPTS>
    
    i1000_2990RT = i1000_2990 - 0.2*maxI; 
    i1000_2990RT(i1000_2990RT < 0) = 0;
    ind20RT = ind1000 + find(i1000_2990RT, 1) - 1;
    t20RT = t(ind20RT);
    i1000_2990RT = i1000_2990 - 0.8*maxI;
    i1000_2990RT(i1000_2990RT < 0) = 0;
    ind80RT = ind1000 + find(i1000_2990RT, 1) - 1;
    t80RT = t(ind80RT);
    RT20_80 = t80RT - t20RT %#ok<NOPTS>
    
    RT = tMax - tStart %#ok<NOPTS>
    latency = tMax - 1000 %#ok<NOPTS>
    
    iDecay = -iS(indMax:end);
    iDecay = iDecay - iDecay(end);
    iDecay = iDecay - maxI/exp(1);
    iDecay(iDecay < 0) = 0;
    indE = indMax + find(iDecay, 1, 'last') - 1;
    tE = t(indE);
    tauDecay = tE - t(indMax) %#ok<NOPTS>
    
    % Plot membrane potential data:
    figure('Units', 'normalized', 'Position', [0, .01, .48, .89]);
    plot(t*1e-3, vS)
    titleStr = sprintf('Membrane Potential Trace - file: %s', fileName);
    set(gcf,'name',titleStr)
    title(titleStr)
    xlabel('Time (s)')
    ylabel('Membrane potential (mV)')
    ylim([-100 50])
    
    % Plot membrane current data:
    figure('Units', 'normalized', 'Position', [0, .01, .48, .89]);
    plot(t*1e-3, iS)
    hold on
    plot([tStart t10RT t90RT tMax tE]*1e-3, [iS(indStart) iS(ind10RT)...
        iS(ind90RT) iS(indMax) iS(indE)], '.r', 'MarkerSize', 10)
    hold off
    titleStr = sprintf('Membrane Current Trace - file: %s', fileName);
    set(gcf,'name',titleStr)
    title(titleStr)
    xlabel('Time (s)')
    ylabel('Membrane current (nA)')
    xlim([1 2])
end
