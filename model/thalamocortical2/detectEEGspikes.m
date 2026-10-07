function eegSpikes = detectEEGspikes(EEG, dt, type)

showFigs = false;

% Butterworth filter
Rp = 0.5;                                                                   % Passband riple, dB
Rs = 10;                                                                    % Stopband attenuation, dB
NyqFreq = (1000/dt)/2;                                                      % The Nyquist frequency
if strcmpi(type, 'spindles')
    Wp = 20/NyqFreq;                                                        % Passbands, normalised frequency
    Ws = 30/NyqFreq;                                                        % Stopband, normalised frequency
elseif strcmpi(type, 'SWDs')
    Wp = 8/NyqFreq;
    Ws = 12/NyqFreq;
elseif strcmpi(type, 'delta')
    Wp = 5/NyqFreq;
    Ws = 7.5/NyqFreq;
elseif strcmpi(type, 'slow')
    Wp = 2/NyqFreq;
    Ws = 3/NyqFreq;
end
[n, Wn] = buttord(Wp, Ws, Rp, Rs);                                          % n is a filter order
[b, a] = butter(n, Wn, 'low');
EEGfilt = filtfilt(double(b), double(a), EEG);

% descriptive stats
meanEEGfilt = mean(EEGfilt); %#ok<*NASGU>
medianEEG = median(EEG);
medianEEGfilt = median(EEGfilt);
modeEEG = mode(EEG);
modeEEGfilt = mode(EEGfilt);
sdEEG = std(EEG);
sdEEGfilt = std(EEGfilt);

% estimate baseline and its standard deviation
range = [floor(min(EEGfilt)) ceil(max(EEGfilt))];
edges = range(1):0.0001:range(2);
[voltageValues, edges] = histcounts(EEGfilt, edges);
centres = edges(1:end-1) + (edges(2)-edges(1))/2;
[~, iMostCommon] = max(voltageValues);
baseline = centres(iMostCommon);
f = fit(centres.',voltageValues.','gauss1');
gaussFit = f.a1*exp(-((centres-f.b1)./f.c1).^2);
sdBaseline = f.c1;
lowCI95baseline = baseline - norminv(1-0.05/2)*sdBaseline;
lowSD6 = baseline - 6*sdBaseline;
lowCI95eeg = baseline - norminv(1-0.05/2)*sdEEGfilt;
lowSDeeg = baseline - sdEEGfilt;

if showFigs
    figure %#ok<*UNRCH>
    plot(centres, voltageValues)
    hold on
    plot(centres, gaussFit)
    hold off
end

% Estimate the oscilation frequency
maxPowerFrequency = oscFreq(EEGfilt, dt, type);
cycle = (1000/maxPowerFrequency)*1.1;

if showFigs
    figure
    semilogx(f, powerDBfilt)
    hold on
    semilogx(maxPowerFrequency, maxPower, 'r.', 'MarkerSize',10)
    hold off
end

% threshold EEG and find peaks
EEGfiltTh = EEGfilt;
EEGfiltTh(EEGfiltTh >= lowSDeeg) = 0;
EEGfiltThAbs = abs(EEGfiltTh);
[~, pksLocs] = findpeaks(EEGfiltThAbs, 'MinPeakDistance',ceil(cycle/2/dt));
pks = EEGfilt(pksLocs);
t = (dt:dt:numel(EEGfilt)*dt)./1000;
tPks = t(pksLocs);

% plot data
t = (dt:dt:numel(EEGfilt)*dt)./1000;
if showFigs
    figure
    plot(t, EEGfilt)
    hold on
    % plot(ones(1, numel(EEGfilt))*meanEEGfilt);
    % plot(ones(1, numel(EEGfilt))*meanEEGfilt - ones(1, numel(EEGfilt))*sdEEGfilt);
    %plot(ones(1, numel(EEGfilt))*medianEEGfilt);
    % plot(ones(1, numel(EEGfilt))*modeEEGfilt);
    plot(t, ones(1, numel(EEGfilt))*baseline);
    plot(t, ones(1, numel(EEGfilt))*lowCI95baseline);
    plot(t, ones(1, numel(EEGfilt))*lowSD6);
    plot(t, ones(1, numel(EEGfilt))*lowCI95eeg);
    plot(t, ones(1, numel(EEGfilt))*lowSDeeg);
    plot(tPks, pks, 'r.', 'MarkerSize',10)
    hold off
end

% Set the output variable
eegSpikes = zeros(1,numel(EEG));
eegSpikes(pksLocs) = 1;