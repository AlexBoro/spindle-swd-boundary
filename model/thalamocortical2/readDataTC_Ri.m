% The script file estimates apparent input resistance of a TC cell using
% multiple current steps.

clc
close all
format long
commandI = abs(-0.00:-0.001:-0.1);
peaks = zeros(1, length(commandI));
amplitudes = peaks;
Ri = peaks;
diam = 60; %[uf]
L = 90;    %[uf]
Area = pi*(L*1e-4)*(diam*1e-4);

f1 = figure('Units', 'normalized', 'Position', [.00, .01, .32, .89]);
f2 = figure('Units', 'normalized', 'Position', [.33, .01, .32, .89]);
f3 = figure('Units', 'normalized', 'Position', [.66, .01, .32, .89]);
for iFile = 0:length(commandI)-1
    fileName = ['TC0data' num2str(iFile) '.dat'];
    fid = fopen(fileName,'rt');
    A = textscan(fid, '%f', 'HeaderLines', 1);
    fclose(fid);
    A = A{1};
    n = length(A)/33;
    A = reshape(A,n,33)';
    t = A(1,:);
    v = A(2,:);
    IVC = A(3, :);
    
    t20000msec = t;
    t20000msec(t20000msec <= 20000) = 0;
    iT = find(t20000msec, 1);
    base = v(iT);
    step = v(end);
    amplitudes(iFile+1) = abs(step-base);
    Ri(iFile+1) = amplitudes(iFile+1)/commandI(iFile+1);
    
    figure(f1)
    hold on
    plot(t*1e-3, v)
    title('Membrane Potential Trace')
    xlabel('Time (s)')
    ylabel('Membrane potential (mV)')
    hold off
    
    figure(f2)
    hold on
    plot(commandI(iFile+1), amplitudes(iFile+1), '.', 'markerSize', 5)
    title('Injected Current vs. Membrane Potential Change')
    xlabel('Injected current (nA)')
    ylabel('Membrane potential (mV)')
    hold off
    
    figure(f3)
    hold on
    plot(commandI(iFile+1), Ri(iFile+1), '.', 'markerSize', 5)
    title('R_i Estimates')
    xlabel('Injected current (nA)')
    ylabel('R_i (MOhms)')
    hold off
end
