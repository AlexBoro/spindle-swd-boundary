% The script file plots the membrane potential traces of single thalamic cells.

clc
close all
clear all %#ok<CLALL>
format longG
AreaTC = area(60, 90);

list = dir('*dat');
iList = 1:length(list);
%iList = 001:1:070;

f1 = figure('Units', 'normalized', 'Position', [0, .01, .98, .89]);
hold on
for i = iList
    
    % Load:
    fileName = list(i).name;
    [~, data, cellType] = loadFile(fileName, AreaTC, 'TC');
    
    % Plot:
    plot(data.t*1e-3, data.ICa)
end
titleStr = sprintf('T-type current Trace - file: %s', fileName);
set(f1,'name',titleStr)
title(titleStr, 'Interpreter', 'none')
xlabel('Time (s)')
%xlim([0 10])
ylabel('Current (mA/cm^2)')
%ylim([-90 50])
hold off
