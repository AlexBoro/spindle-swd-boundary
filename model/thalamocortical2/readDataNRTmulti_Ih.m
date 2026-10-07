% The script file plots voltage traces of multiple files depending on I_h
% parameters.

clc
close all
clear all %#ok<CLSCR>
format long
Area = area(42, 63);

%for iFile = 0.0000224:0.0000001:0.0000224
for iFile = 0.0000090:0.0000001:0.0000100
   fileName = sprintf('0.000100_NRT0data0.0000100_ 95_%1.7f_0.0000.dat', iFile);
% for iFile = 0.0000:0.0001:0.0010
%     fileName = sprintf('0.000000_NRT0data0.0000100_ 75_0.0000223_%1.4f.dat', iFile);
    [~, NRT] = loadFile(fileName, Area, 'NRT');
    
    % Resample:
    dt = 0.25;
    tt = NRT.t(1):0.25:NRT.t(end);
    [tunique, iunique] = unique(NRT.t);
    vv = interp1(tunique,NRT.v(iunique),tt);
    
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
    pf = 0.6/f(end);
    iStart = round(pf*length(f));
    [~, imax] = max(amplitude(iStart:end));
    power = (amplitude.^2*length(f)^2)./(sum(f.^2)*f);
    
    %Plot membrane potential data:
    f1 = figure('Units', 'normalized', 'Position', [0, .01, .98, .89]);
    plot(NRT.t*1e-3, NRT.v)
    titleStr = sprintf('Membrane Potential Trace - file: %s, frequency: %2.2f',...
        fileName, f(iStart+imax-1));
    set(f1,'name',titleStr)
    title(titleStr)
    xlabel('Time (s)')
    ylabel('Membrane potential (mV)')
    ylim([-90 40])
end
