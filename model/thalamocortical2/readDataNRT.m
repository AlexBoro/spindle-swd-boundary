% The script file plots voltage traces of multiple files depending on I_h
% parameters.

clc
close all
clear all %#ok<CLALL>
format long
Area = area(42, 63);

multiPlot = 0;

f1 = figure('Units', 'normalized', 'Position', [0, .01, .98, .89]);
% for iFile = 0.0000111:0.0000001:0.0000120
%     fileName = sprintf('0.000100_NRT0data0.0000100_ 95_%1.7f_0.0000.dat', iFile);
% for iFile = 0.0020:0.0001:0.0020
%     fileName = sprintf('0.000000_NRT0data0.0000100_ 75_0.0000223_%1.4f.dat', iFile);
list = dir('*dat');
for i = 1:14
    fileName = list(i).name;
    [~, NRT] = loadFile(fileName, Area, 'NRT');

    %Plot membrane potential data:
    figure(f1)
    hold on
    plot(NRT.t*1e-3, NRT.v)
    hold off
%     f2 = figure('Units', 'normalized', 'Position', [0, .01, .98, .89]);
%     if multiPlot
%         subplot(2,1,1) %#ok<*UNRCH>
%     end
%     plot(NRT.t*1e-3, NRT.v)
%     titleStr = sprintf('Membrane Potential Trace - file: %s', fileName);
%     set(f2,'name',titleStr)
%     title(titleStr)
%     xlabel('Time (s)')
%     xlim([9.5 11.5])
%     ylabel('Membrane potential (mV)')
%     ylim([-100 30])
% 
%     if multiPlot
%         subplot(2,1,2)
%         plot(NRT.t*1e-3, NRT.IKNap)
%         %plot(NRT.t*1e-3, NRT.Nai)
%         titleStr = sprintf('I_{K[Na]} Activation State - file: %s', fileName);
%         title(titleStr)
%         xlabel('Time (s)')
%         ylabel('Activation state')
%         %ylim([0 1.01])
%     end
end

figure(f1)
set(f1,'name','Membrane Potential Trace')
title('Membrane Potential Trace')
xlabel('Time (s)')
xlim([9.5 11.5])
ylabel('Membrane potential (mV)')
ylim([-100 30])