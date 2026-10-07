% The script file plots the membrane potential of a Cx cell.

clc
close all
clear all
format longG

fileName = 'HAHAHA.dat';
fid = fopen(fileName,'rt');
A = textscan(fid, '%f', 'HeaderLines', 1);
fclose(fid);
A = A{1};
n = length(A)/1;
A = reshape(A,n,1)';
values = A(1,:);
[N,X] = hist(A,30);

% Plot membrane potential data:
figure('Units', 'normalized', 'Position', [0, .01, .48, .89]);
plot(X, N)
titleStr = sprintf('NEURON gaussian random number generator - file: %s', fileName);
set(gcf,'name',titleStr)
title(titleStr)
xlabel('Values')
ylabel('Count')