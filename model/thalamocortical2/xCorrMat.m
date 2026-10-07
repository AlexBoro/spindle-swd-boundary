function xCorrMean = xCorrMat(data2corr)

nUnits = size(data2corr,1);
combos = nchoosek(1:nUnits,2);

xCorrs = zeros(1,2*size(data2corr,2)-1);
for combo = 1:size(combos,1)
    disp(['xCorr progress: ' num2str(combo) '/' num2str(size(combos,1))]);
    xCorrs = xCorrs + xcorr(data2corr(combos(combo,1),:), data2corr(combos(combo,2),:));
end

xCorrMean = xCorrs./combo;