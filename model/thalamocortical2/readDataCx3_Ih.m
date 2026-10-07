% The script file estimates the maximal amplitude and I-V curve of I_T
% in TC cells.

clc
close all
format long
peaks = zeros(1, 29);
amplitudes = peaks;
commandV = (-100:5:40);
diam = 5.644; %[uf]
L = 5.644;    %[uf]
AreaS = pi*(L*1e-4)*(diam*1e-4);
L = 160*5.644;    %[uf]
AreaD = pi*(L*1e-4)*(diam*1e-4);

for iFile = 0.0000060:0.0000001:0.0000100
    fileName = ['Cx3data0.0000002_' num2str(iFile, '%1.7f') '.dat'];
    fid = fopen(fileName,'rt');
    A = textscan(fid, '%f', 'HeaderLines', 1);
    fclose(fid);
    A = A{1};
    n = length(A)/50;
    A = reshape(A,n,50)';
    t = A(1,:);
    v = A(2,:);
    %v = A(44,:)*1e6;
    CaiS = A(20,:)*1e6;
    CaiD = A(44,:)*1e6;
    ICaS = A(19,:)*1e6*AreaS;
    ICaD = A(43,:)*1e6*AreaD;
    ITmS = A(23,:);
    IThS = A(24,:);
    ITmD = A(47,:);
    IThD = A(48,:);
    
    % Resample:
    dt = 0.25;
    tt = t(1):0.25:t(end);
    [tunique, iunique] = unique(t);
    vv = interp1(tunique,v(iunique),tt);
    
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
    pf = 0.2/f(end);
    iStart = round(pf*length(f)) +1;
    [~, imax] = max(amplitude(iStart:end));
    power = (amplitude.^2*length(f)^2)./(sum(f.^2)*f);
    
    %Plot membrane potential data:
    figure('Units', 'normalized', 'Position', [0, .01, .48, .89]);
    plot(t*1e-3, v)
    titleStr = sprintf('Membrane Potential Trace - file: %s, frequency: %2.2f',...
        fileName, f(iStart+imax-1));
    set(gcf,'name',titleStr)
    title(titleStr)
    xlabel('Time (s)')
    ylabel('Membrane potential (mV)')
    %ylim([-100 50])
    
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
%     xlim([0 50])
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
