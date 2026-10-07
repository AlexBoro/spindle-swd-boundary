% The script file plots the membrane potential of a Cx cell.

clc
close all
clear all
format longG

list = dir('*dat');
% files = [1, 25, 50, 75, 100];
% for i = 1: size(files, 2)
%     fileName = list(files(i)).name;
% for i = 1:size(list, 1)
for i = 36
    fileName = list(i).name;
    fid = fopen(fileName,'rt');
    A = textscan(fid, '%f', 'HeaderLines', 1);
    fclose(fid);
    A = A{1};
    n = length(A)/34;
    A = reshape(A,n,34)';
    t = A(1,:);
    vS = A(2,:);
    iS = A(3,:);
    K_i = A(11,:);
    
    % Plot membrane potential data:
    figure('Units', 'normalized', 'Position', [0, .01, .48, .89]);
    plot(t*1e-3, vS)
    titleStr = sprintf('Membrane Potential Trace - file: %s', fileName);
    set(gcf,'name',titleStr)
    title(titleStr)
    xlabel('Time (s)')
    ylabel('Membrane potential (mV)')
    %ylim([-100 50])
end
