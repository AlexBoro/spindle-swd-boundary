% The script file plots the membrane potential of a Cx cell.

clc
close all
clear all
format longG

for iFile = 0.0000200:0.0000005:0.0000320
    fileName = sprintf('TCdata0.000610_90.0_%1.9f_0.0000.dat', iFile);
    fid = fopen(fileName,'rt');
    A = textscan(fid, '%f', 'HeaderLines', 1);
    fclose(fid);
    A = A{1};
    n = length(A)/2;
    A = reshape(A,n,2)';
    t = A(1,:);
    v = A(2,:);
        
    % Plot membrane potential data:
    figure('Units', 'normalized', 'Position', [0, .01, .48, .89]);
    plot(t*1e-3, v)
    titleStr = sprintf('Membrane Potential Trace - file: %s', fileName);
    set(gcf,'name',titleStr)
    title(titleStr)
    xlabel('Time (s)')
    ylabel('Membrane potential (mV)')
    ylim([-100 50])
    %xlim([0 10])
    %xlim([10 20])
end
