% The script file plots voltage traces of multiple files depending on I_h
% parameters.

clc
close all
clear all
format long
diam = 60; %[uf]
L = 90;    %[uf]
Area = pi*(L*1e-4)*(diam*1e-4);

multiDisp = 0;

% for iFile = 0.020: .010 :0.200
%     fileName = sprintf('TCdata106_0.0000000_%1.3f.dat', iFile);
for iFile = 0.0000:0.0010:0.0100
    fileName = sprintf('TCdata0.000120_93.0_0.000019200_%1.4f.dat', iFile);
% for iFile = 0.0000190:0.00000005:0.0000210
%     fileName = sprintf('TCdata0.000120_93.0_%1.9f_0.0000.dat', iFile);
    fid = fopen(fileName,'rt');
    A = textscan(fid, '%f', 'HeaderLines', 1);
    fclose(fid);
    A = A{1};
    if multiDisp
        n = length(A)/46; %#ok<*UNRCH>
        A = reshape(A,n,46)';
        IVC = A(3,:);
        I = A(4,:);
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
        Iho1 = A(17,:);
        Iho2 = A(18,:);
        Ihp1 = A(19,:);
        IAHP = A(20,:);
        IAHPm1 = A(21,:);
        IAHPm2 = A(22,:);
        ICAN = A(23,:)*1e6*Area;
        ICANp1 = A(24,:);
        ICANo = A(25,:);
        INaPm = A(26,:);
        IAm1 = A(27,:);
        IAm2 = A(28,:);
        IAh1 = A(29,:);
        IAh2 = A(30,:);
        IK1m = A(31,:);
        IK2m = A(32,:);
        IK2h1 = A(33,:);
        IK2h2 = A(34,:);
        IHVA = A(35,:)*1e6*Area;
        IHVAm = A(36,:);
        IAMPA = A(37,:);
        INMDA = A(38,:);
        ImGluR1a = A(39,:);
        ImGluR1aR = A(40,:);
        ImGluR1aG = A(41,:);
        IGABAa = A(42,:);
        IGABAb = A(43,:);
        IeGABAa = A(44,:);
        IeGABAa_R = A(45,:);
        IeGABAa_G = A(46,:);
    else
        n = length(A)/2;
        A = reshape(A,n,2)';
    end
        t = A(1,:);
        v = A(2,:);
    
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
    pf = 0.3/f(end);
    iStart = round(pf*length(f));
    [~, imax] = max(amplitude(iStart:end));
    power = (amplitude.^2*length(f)^2)./(sum(f.^2)*f);
    
    %Plot membrane potential data:
    f1 = figure('Units', 'normalized', 'Position', [0, .01, .98, .89]);
    plot(t*1e-3, v, 'k', 'LineWidth', 1)
    %plot(t*1e-3, v, 'k')
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
end

% xlim([90 101]);
% ylim([-81 0]);
% set(gca, 'box', 'off')
% set(gca, 'YTick', -60);
% %set(gca, 'YTickMode', 'auto');
% set(gca, 'XColor', 'k');
% set(gca, 'YColor', 'k');
% set(gcf,'PaperUnits', 'normalized');
% papersize = get(gcf, 'PaperSize');
% myfiguresize = [0, 0, 2.65, 1];
% set(gcf,'PaperPosition', myfiguresize);
% %titleStr = sprintf('Membrane Potential Trace - file %s',fileName(1:end-4));
% titleStr = sprintf('Membrane Potential Trace - file %s',fileName(1:end-4));
% saveas(gcf, [titleStr '.fig'], 'fig');
% print([titleStr '.tif'],'-dtiffnocompression','-r300');
