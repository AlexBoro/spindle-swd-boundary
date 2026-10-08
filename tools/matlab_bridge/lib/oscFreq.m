function [oscillationFrequency, maxPower, f, powerDBfilt] = oscFreq(EEG, dt, type)
% f = oscFreq(EEG)
%
% Funtion extimates oscillation frequency of the EEG signal.
% Input: EEG vector.
%        dt - a sampling rate.
%        type - type of the signal (i.e., 'spindles', 'SWDs', 'delta',
%               'slow').
% Output: oscillationFrequency - oscillation frequency.

[f, ~, ~, ~, ~, ~, powerDBfilt] = spectra(EEG-mean(EEG), dt);
if strcmpi(type, 'spindles')
    fMin = 6; fMax = 16;
elseif strcmpi(type, 'SWDs_human')
    fMin = 3; fMax = 6;
elseif strcmpi(type, 'SWDs_rodent')
    fMin = 6; fMax = 9;
elseif strcmpi(type, 'delta')
    fMin = 1; fMax = 5;
elseif strcmpi(type, 'slow')
    fMin = 0; fMax = 1;
end
powerDBfiltTh = powerDBfilt(f >= fMin & f <= fMax);
FOI = f(f >= fMin & f <= fMax);
[maxPower, iMaxPowerFrequency] = max(powerDBfiltTh);
oscillationFrequency = FOI(iMaxPowerFrequency);