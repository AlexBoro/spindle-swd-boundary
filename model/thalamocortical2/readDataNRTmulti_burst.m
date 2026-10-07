% The script file plots voltage traces of multiple files depending on I_h
% parameters.

clc
close all
clear all
format long
injCurrent = 0.03: -0.001 :-0.15;
diam = 42; %[uf]
L = 63;    %[uf]
Area = pi*(L*1e-4)*(diam*1e-4);

for iFile = 000:010
%for iFile = 151:200
    fileName = sprintf('0.00160_NRT0data%g.dat', iFile);
    fid = fopen(fileName,'rt');
    A = textscan(fid, '%f', 'HeaderLines', 1);
    fclose(fid);
    A = A{1};
    n = length(A)/27;
    A = reshape(A,n,27)';
    t = A(1,:);
    v = A(2,:);
    IKleak = A(5,:);
    INaleak = A(6,:);
    INa = A(7,:)*1e6*Area;
    INam = A(8,:);
    INah = A(9,:);
    IK = A(10,:)*1e6*Area;
    IKn = A(11,:);
    Cai = A(12,:)*1e6;
    ICa = A(13,:)*1e6*Area;
    ICam = A(14,:);
    ICah = A(15,:);
    Ih = A(16,:)*1e6*Area;
    Ihm = A(17,:);
    IAHP = A(18,:)*1e6*Area;
    IAHPm1 = A(19,:);
    IAHPm2 = A(20,:);
    
    % Resample:
    dt = 0.25;
    tt = t(1):0.25:t(end);
    [tunique, iunique] = unique(t);
    vv = interp1(tunique,v(iunique),tt);
    
    % Estimate the oscillation frequency:
    iStart = 10000/dt +1;
    iEnd = 10500/dt;
    ttShort = tt(iStart:iEnd);
    vvShort = vv(iStart:iEnd);
    L = length(vvShort);
    NFFT = 2^nextpow2(L); % Next power of 2 from length of y
    Y = fftshift(fft(vvShort,NFFT))/L;
    Fs = 1000/dt;
    f = Fs/2*linspace(0,1,NFFT/2+1);
    amplitude = fliplr(2*abs(Y(1:NFFT/2+1)));
    pf = 3/f(end);
    iStart = round(pf*length(f));
    [~, imax] = max(amplitude(iStart:end));
    power = (amplitude.^2*length(f)^2)./(sum(f.^2)*f);
    
    %Plot membrane potential data:
    f1 = figure('Units', 'normalized', 'Position', [0, .01, .48, .89]);
    plot(t*1e-3, v)
    titleStr = sprintf('Membrane Potential Trace - file: %s, frequency: %2.2f, resting V_M: %2.2f, dc: %1.3f',...
        fileName, f(iStart+imax-1), v(end), injCurrent(iFile+1));
    set(f1,'name',titleStr)
    title(titleStr)
    xlabel('Time (s)')
    ylabel('Membrane potential (mV)')
    xlim([9.9 12])
    
%     f2 = figure('Units', 'normalized', 'Position', [0,.01, .48, .89]);
%     plot(tt*1e-3, vv)
%     titleStr = sprintf('Membrane Potential Trace (resampled) - file: %s, frequency: %2.2f',...
%         fileName, f(iStart+imax-1));
%     set(f2,'name',titleStr)
%     title(titleStr)
%     xlabel('Time (s)')
%     ylabel('Membrane potential (mV)')
%     ylim([-110 60])
%     
%     % Plot single-sided amplitude spectrum:
%     f3 = figure('Units', 'normalized', 'Position', [0,.01, .48, .89]);
%     plot(f,amplitude)
%     titleStr = sprintf('Amplitude Spectrum - file: %s, frequency: %2.2f',...
%         fileName, f(iStart+imax-1));
%     set(f3,'name',titleStr)
%     title(titleStr)
%     xlabel('Frequency (Hz)')
%     ylabel('|Y(f)|')
%     xlim([0 25])
%     ylim([0 15])
%     
%     % Plot single-sided power spectrum:
%     f4 = figure('Units', 'normalized', 'Position', [0,.01, .48, .89]);
%     loglog(f, power);
%     titleStr = sprintf('Power Spectrum on logarithmic axes - file: %s, frequency: %2.2f',...
%         fileName, f(iStart+imax-1));
%     set(f4,'name',titleStr)
%     title(titleStr)
%     xlabel('Frequency (Hz)')
%     ylabel('Power')
end
