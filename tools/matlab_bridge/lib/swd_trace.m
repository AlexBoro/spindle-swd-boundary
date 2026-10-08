function x = swd_trace(dur_s, dt_ms, episodes, spike_hz, amp_sd, noise_sd)
%SWD_TRACE  Synthetic negative spike-and-wave trace on a noisy baseline.
%   Separate file (not a local function) so make_reference.m can also be
%   executed through tools/matlab_bridge, which runs scripts via run()
%   inside a function where local functions are unreliable.
    % Negative spike-and-wave episodes on a noisy baseline. The detector looks
    % for NEGATIVE deflections past 1 and 1.96 SD of the baseline.
    fs = 1000 / dt_ms;
    n  = round(dur_s * fs);
    x  = noise_sd * randn(1, n);
    for e = 1:size(episodes, 1)
        i0 = max(1, round(episodes(e,1) * fs) + 1);
        i1 = min(round(episodes(e,2) * fs), n);
        tt = (i0:i1) / fs;
        wave = 0.4 * amp_sd(e) * sin(2*pi*spike_hz*tt);
        spk  = zeros(1, numel(tt));
        spk(1:round(fs / spike_hz):end) = -amp_sd(e);
        spk  = conv(spk, gausswin(max(3, round(0.004*fs))), 'same');
        x(i0:i1) = x(i0:i1) + wave + spk;
    end
end
