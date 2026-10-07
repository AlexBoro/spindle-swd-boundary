% The script file plots the membrane potential of a Cx cell.

clc
close all
clear all
format long
diam = 5.644; %[um]
L = 5.644;    %[um]
Area = pi*(L*1e-4)*(diam*1e-4); %[cm^2]

list = dir('*dat');
% files = [1, 25, 50, 75, 100];
% for i = 1: size(files, 2)
%     fileName = list(files(i)).name;
for i = 1:2
%for i = 41:61
    fileName = list(i).name;
    fid = fopen(fileName,'rt');
    A = textscan(fid, '%f', 'HeaderLines', 1);
    fclose(fid);
    A = A{1};
    n = length(A)/40;
    A = reshape(A,n,40)';
    t = A(1,:);
    vS = A(2,:); %*1e6;
    
    % Resample:
    dt = 0.25;
    tt = t(1):0.25:t(end);
    [tunique, iunique] = unique(t);
    vv = interp1(tunique,vS(iunique),tt);
    
    % Estimate the oscillation frequency:
    iStart = 1250/dt +1;
    iEnd = 4000/dt;
    ttShort = tt(iStart:iEnd);
    vvShort = vv(iStart:iEnd);
    L = length(vvShort);
    NFFT = 2^nextpow2(L); % Next power of 2 from length of y
    Y = fftshift(fft(vvShort,NFFT))/L;
    Fs = 1000/dt;
    f = Fs/2*linspace(0,1,NFFT/2+1);
    amplitude = fliplr(2*abs(Y(1:NFFT/2+1)));
    pf = 5/f(end);
    iStart = round(pf*length(f)) +1;
    [~, imax] = max(amplitude(iStart:end));
    power = (amplitude.^2*length(f)^2)./(sum(f.^2)*f);
    
    %Plot membrane potential data:
    if i==1
        figure('Units', 'normalized', 'Position', [0, .01, .48, .89]);
        plot(t*1e-3, vS)
        hold on
        titleStr = sprintf('Membrane Potential Trace');
        set(gcf,'name',titleStr)
        title(titleStr)
        xlabel('Time (s)')
        ylabel('Membrane potential (mV)')
    else
        plot(t*1e-3, vS, 'r')
        hold off
    end
end
