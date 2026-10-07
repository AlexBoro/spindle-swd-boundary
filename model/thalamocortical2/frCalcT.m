function [vecFR, vecTR, vecBR, vecBR2, tSlide] = frCalcT(raster, t, slide, window, ISI)
% [vecFR, vecTR, vecBR, tSlide] = frCalcT(raster, t, slide, window, ISI)
%
% Function calculates cell firing rates: total, tonic, and bursting.
% Input: raster - cell spiking vector.
%        t - a corresponding time vector.
%        slide - averaging window step size in ms.
%        window - averaging window sample size.
%        ISI - the maximum interval between two consecutive spikes for them
%              to be considered as part of the same burst.
% Output: vecFR - total firing rate vector.
%         vecTR - tonic firing rate vector.
%         vecBR - burst firing rate vector.
%         vecBR2 - burst firing rate vector in terms of APs per burst.
%         tSlide - a corresponding time vector.

dt = t(2)-t(1);

slideSize = slide/dt;
nSlides = floor((t(end)-t(1)+dt)/slide);
vecFR = zeros(1,nSlides);
vecBR = vecFR;
vecBR2 = vecFR;
vecTR = vecFR;
tSlide = vecFR;
for i = 1:nSlides
    iStart = (i-1)*slideSize+1;
    iEnd = iStart-1+window;
    if iEnd <= length(t)
        rasterROI = raster(iStart:iEnd);
        FR = sum(rasterROI)/(window/(1000/dt));
        tROI = t(iStart:iEnd);
        tROI = tROI(logical(rasterROI));
        BR = 0;
        BR2 = 0;
        burstCount = 0;
        TR = 0;
        if length(tROI) > 1
            for j = 2:length(tROI)
                if tROI(j)-tROI(j-1) <= ISI
                    BR2 = BR2 + 1;
                    if (j < length(tROI) && tROI(j+1)-tROI(j) > ISI) || j == length(tROI)
                        BR = BR + 1;
                        BR2 = BR2 + 1;
                        burstCount = burstCount + 1;
                    end
                else
                    if j == length(tROI)
                        TR = TR + 2;
                    else
                        TR = TR + 1;
                    end
                end
            end
        end
    end
    vecFR(i) = FR;
    vecBR(i) = BR;
    if burstCount == 0
        vecBR2(i) = NaN;
    else
        vecBR2(i) = BR2/burstCount;
    end
    vecTR(i) = TR;
    tSlide(i) = t(iStart)+slide/2;
end
vecFR = vecFR./(window/(1000/dt));
vecBR = vecBR./(window/(1000/dt));
vecTR = vecTR./(window/(1000/dt));