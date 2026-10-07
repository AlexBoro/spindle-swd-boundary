function [v, raster, histo, iHisto, histo_spike, histo_spike_init, vecFR, vecBR, vecTR, tSlide, vecBR2, vecTR2, vecSR2] = tFunc(t,v,tSpikes,tSpikesInit,histo,binCentres,histo_spike,slide,window,ISI,spikeVic,spikes)
raster = rastergram(v);
raster2 = raster;
raster2(raster2==0) = -999;
raster3 = raster;
raster3(raster3==1) = tSpikes(logical(raster3));
iHisto = hist(raster2+raster3-1,binCentres);
histo = histo + iHisto;

raster_spike1 = tSpikes(logical(raster));
raster_spike2 = tSpikesInit(logical(raster));
if ~isempty(raster_spike1)
    raster_spike3 = [];
    for i = 2:length(raster_spike1)
        if raster_spike2(i) ~= raster_spike2(i-1)
            raster_spike3 = [raster_spike3 raster_spike1(i)]; %#ok<AGROW>
        end
    end
end
histo_spike_init = hist(raster_spike3,binCentres);
histo_spike = histo_spike + histo_spike_init;

dt = t(2)-t(1);
slideSize = slide/dt;
windowSize = window/dt;
nSlides = floor(t(end)/slide);
vecFR = zeros(1,nSlides);
vecBR = vecFR;
vecTR = vecFR;
tSlide = vecFR;
for i = 1:nSlides
    iStart = (i-1)*slideSize+1;
    iEnd = iStart-1+windowSize;
    if iEnd <= length(t)
        rasterROI = raster(iStart:iEnd);
        FR = sum(rasterROI)/(window/1000);
        tROI = t(iStart:iEnd);
        tROI = tROI(logical(rasterROI));
        BR = 0;
        TR = 0;
        if length(tROI) > 1
            for j = 2:length(tROI)
                if tROI(j)-tROI(j-1) <= ISI
                    if (j < length(tROI) && tROI(j+1)-tROI(j) > ISI) || j == length(tROI)
                        BR = BR + 1;
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
    vecTR(i) = TR;
    tSlide(i) = t(iStart)+slide/2;
end

spikeVic = (-spikeVic:dt:spikeVic)/dt;
vecBR2 = zeros(size(spikes));
vecTR2 = vecBR2;
vecSR2 = vecBR2;
for i = 1:length(spikes)
    spikeVicATM = spikes(i)+spikeVic;
    rasterROI = raster(spikeVicATM);
    tROI = t(spikeVicATM);
    tROI = tROI(logical(rasterROI));
    if length(tROI) > 1
        for j = 2:length(tROI)
            if tROI(j)-tROI(j-1) <= ISI
                vecBR2(i) = 1;
                vecTR2(i) = 0;
                break
            else
                vecTR2(i) = 1;
            end
        end
    elseif length(tROI) == 1
        vecTR2(i) = 1;
    else
        vecSR2(i) = 1;
    end
end
