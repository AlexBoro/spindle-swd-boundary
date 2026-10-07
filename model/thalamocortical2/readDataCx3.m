% The script file plots voltage traces of multiple files depending on I_h
% parameters.

clc
close all
clear all %#ok<CLALL>
format long
Area(1) = area(5.644, 5.644);
Area(2) = area(5.644, 160*5.644);

multiPlot = 1;

list = dir('*dat');
for i = 70:70
%for i = 91:110
    fileName = list(i).name;
    [~, Cx3] = loadFile(fileName, Area, 'Cx3');

    % Resample:
    dt = 0.1;
    tt = Cx3.t(1):dt:Cx3.t(end);
    [tunique, iunique] = unique(Cx3.t);
    vv = interp1(tunique,Cx3.v(iunique),tt);
    
    % Estimate the oscillation frequency:
    iStart = 1000/dt +1;
    iEnd = 1800/dt +1;
    ttShort = tt(iStart:iEnd);
    vvShort = vv(iStart:iEnd);
    L = length(vvShort);
    NFFT = 2^nextpow2(L); % Next power of 2 from length of y
    Y = fftshift(fft(vvShort,NFFT))/L;
    Fs = 1000/dt;
    f = Fs/2*linspace(0,1,NFFT/2+1);
    amplitude = fliplr(2*abs(Y(1:NFFT/2+1)));
    if i >= 181 && i <= 230
        pf = 1.9/f(end);
    elseif i >= 161 && i <= 180
        pf = 1.5/f(end);
    elseif i >= 111 && i <= 160
        pf = 0.9/f(end);
    elseif i >= 71 && i <= 80
        pf = 3/f(end);
    else
        pf = 0.8/f(end);
    end
    iStart = round(pf*length(f));
    [~, imax] = max(amplitude(iStart:end));
    power = (amplitude.^2*length(f)^2)./(sum(f.^2)*f);
    
    % Plot membrane potential data:
    f1 = figure('Units', 'normalized', 'Position', [0, .01, .98, .89]);
    if multiPlot
        subplot(2,1,1) %#ok<*UNRCH>
    end
    plot(Cx3.t*1e-3, Cx3.v, 'k', 'LineWidth', 1)
    titleStr = sprintf('Membrane Potential Trace - file: %s, frequency: %2.2f', fileName, f(iStart+imax-1));
    set(f1,'name',titleStr)
    title(titleStr)
    xlabel('Time (s)')
    %xlim([0.95 1.55])
    ylabel('Membrane potential (mV)')
    %ylim([-71 46])
    
    if multiPlot
        subplot(2,1,2)
        plot(Cx3.t*1e-3, Cx3.CaiD)
        titleStr = sprintf('Ca_i - file: %s', fileName);
        title(titleStr)
        xlabel('Time (s)')
        ylabel('Ca_i (nM)')
        %ylim([0 1.01])
    end
    
%     % Plot single-sided amplitude spectrum:
%     f2 = figure('Units', 'normalized', 'Position', [0,.01, .48, .89]);
%     plot(f,amplitude)
%     titleStr = sprintf('Amplitude Spectrum - file: %s, frequency: %2.2f',...
%         fileName, f(iStart+imax-1));
%     set(f2,'name',titleStr)
%     title(titleStr)
%     xlabel('Frequency (Hz)')
%     ylabel('|Y(f)|')
%     xlim([0 25])
%     ylim([0 15])
%     
%     % Plot single-sided power spectrum:
%     f3 = figure('Units', 'normalized', 'Position', [0,.01, .48, .89]);
%     loglog(f, power);
%     titleStr = sprintf('Power Spectrum on logarithmic axes - file: %s, frequency: %2.2f',...
%         fileName, f(iStart+imax-1));
%     set(f3,'name',titleStr)
%     title(titleStr)
%     xlabel('Frequency (Hz)')
%     ylabel('Power')
end
