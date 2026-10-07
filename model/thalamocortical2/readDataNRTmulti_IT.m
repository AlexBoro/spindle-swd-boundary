% The script file plots voltage traces of multiple files depending on I_T
% parameters.

clc
close all
format long
diam = 42; %[uf]
L = 63;    %[uf]
Area = pi*(L*1e-4)*(diam*1e-4);

for iFile = 0.0000150:0.0000001:0.0000150
    fileName = sprintf('NRT0data0.000690_0_0_7.4_5.00_%1.7f.dat', iFile);
    fid = fopen(fileName,'rt');
    A = textscan(fid, '%f', 'HeaderLines', 1);
    fclose(fid);
    A = A{1};
    n = length(A)/26;
    A = reshape(A,n,26)';
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
    ICAN = A(21,:)*1e6*Area;
    ICANp1 = A(22,:);
    ICANo = A(23,:);
    INaPm = A(24,:);
    Nai = A(25,:);
    IKNan = A(26,:);
    
    % Resample:
    dt = 0.25;
    tt = t(1):0.25:t(end);
    [tunique, iunique] = unique(t);
    vv = interp1(tunique,v(iunique),tt);
    
    % Estimate the oscillation frequency:
    iStart = 3000/dt +1;
    ttShort = tt(iStart:end);
    vvShort = vv(iStart:end);
    L = length(vvShort);
    NFFT = 2^nextpow2(L); % Next power of 2 from length of y
    Y = fftshift(fft(vvShort,NFFT))/L;
    Fs = 1000/dt;
    f = Fs/2*linspace(0,1,NFFT/2+1);
    amplitude = fliplr(2*abs(Y(1:NFFT/2+1)));
    pf = 0.4/f(end);
    iStart = round(pf*length(f));
    [~, imax] = max(amplitude(iStart:end));
    power = (amplitude.^2*length(f)^2)./(sum(f.^2)*f);
    
    %Plot membrane potential data:
    f1 = figure('Units', 'normalized', 'Position', [0,.01, .48, .89]);
    plot(t*1e-3, v)
    titleStr = sprintf('Membrane Potential Trace - file: %s, frequency: %2.2f',...
        fileName, f(iStart+imax-1));
    set(f1,'name',titleStr)
    title(titleStr)
    xlabel('Time (s)')
    ylabel('Membrane potential (mV)')
    ylim([-100 50])
    
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
% 
    %Plot [Na+]_i data:
    f5 = figure('Units', 'normalized', 'Position', [0,.01, .48, .89]);
    plot(t*1e-3, Nai)
    titleStr = sprintf('[Na+]_i Trace - file: %s, frequency: %2.2f',...
        fileName, f(iStart+imax-1));
    set(f5,'name',titleStr)
    title(titleStr)
    xlabel('Time (s)')
    ylabel('Concentration (mM)')
    
    %Plot I_K[Na] data:
    f6 = figure('Units', 'normalized', 'Position', [0,.01, .48, .89]);
    plot(t*1e-3, IKNan)
    titleStr = sprintf('I_K_[_N_a_] Activation Trace - file: %s, frequency: %2.2f',...
        fileName, f(iStart+imax-1));
    set(f6,'name',titleStr)
    title(titleStr)
    xlabel('Time (s)')
    ylabel('Proprtion of open channels')
end
