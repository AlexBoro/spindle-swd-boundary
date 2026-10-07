function [cohmean, cohCI95, phasemean, phaseCI95] = phaseCohMean(coh, phase) %#ok<*DEFNU>

n = size(coh, 1); % number of cells
F = size(coh, 2); % number of frequencies

% Coherence
cohmean = mean(coh);
cohStd = std(coh, 'omitnan');
cohSEM = cohStd ./ n;
CI95 = zeros(2,F);
cohCI95 = zeros(2,F);
for f = 1:F
    CI95(:,f) = (tinv([0.025 0.975], n-1))';
    cohCI95(:,f) = bsxfun(@times, cohSEM(f), CI95(:,f));
end

%Phase
phasemean = nan(1, F);
phaseCI95 = nan(1, F);
for f = 1:F
    phasemean(f) = circmean(phase(~isnan(phase(:, f)), f));
    phaseCI95(f) = circ_confmean(phase(~isnan(phase(:, f)), f), 0.05);
end
end