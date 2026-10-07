function [f, amplitude, amplitudeCons, power, powerCons, powerDB, powerDBcons, PSD, PSDcons, ratio] = spectra(data, dt)

% Parameters:
Fs = 1000/dt;           % Sampling frequency
L = length(data);       % Length of signal
n = 2^nextpow2(L);      % Next power of 2 from length of the data
f = Fs*(0:(n/2))/n;     % Frequency range

% Fourier transform:
Y2 = fft(data,n)/Fs;    % see Parseval's theorem for the scaling factor Fs
Y = Y2(1:n/2+1);
% df = Fs/n;
% B = sum( abs(data).^2 )*(1/Fs) - sum( abs(fft(data, n)/Fs).^2 )*df

% Amplitude spectrum:
P1 = abs(Y);
P1(2:end-1) = 2*P1(2:end-1);
amplitude = P1/2;
amplitudeCons = P1;

% Power spectrum:
P1 = (abs(Y)).^2;
P1(2:end-1) = 2*P1(2:end-1);
power = P1/2;
powerCons = P1;
powerDB = 10*log10(power);
powerDBcons = 10*log10(powerCons);

% Power spectral density:
PSD = 10*log10(power/(0.5*Fs*L));
PSDcons = 10*log10(powerCons/(0.5*Fs*L));

% <4 Hz / >4 Hz ratio:
f2 = f-4;
f2(f2<0) = 0;
i = find(f2,1);
ratio = sum(powerCons(1:i))/sum(powerCons(i+1:end));





% figure('Units', 'normalized', 'Position', [0, .01, .98, .89]);
% plot(f,amplitudeCons,'k');
% hold on
% plot(f,powerCons)
% plot(f,powerDBcons,'g')
% plot(f,PSDcons,'r')
% hold off
% legend('amplitudeCons','powerCons','powerDBcons','PSDcons')
