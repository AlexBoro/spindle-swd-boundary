function [frMeanAligned, frCI95Aligned, tStartAligned, tEndAligned,...
    frMeanAlignedScaled, frCI95AlignedScaled, tStartAlignedScaled, tEndAlignedScaled,...
    frMean, frCI95, frMeanFirst, frCI95First, frMeanSecond, frCI95Second,...
    frMeanThird, frCI95Third, frMeanThird10, frCI95Third10] = frAlign(SWDs, fr, t, meanType)
% [frMeanAligned, frCI95Aligned, tStartAligned, tEndAligned,...
%    frMeanAlignedScaled, frCI95AlignedScaled, tStartAlignedScaled, tEndAlignedScaled,...
%    frMean, frCI95, frMeanFirst, frCI95First, frMeanSecond, frCI95Second, frMeanThird, frCI95Third] = frAlign(SWDs, fr, t)
%
% Function calculates mean firing rate aligned to SWD boundaries for a
% group of cells. It can also be used for any other measure that needs to
% be aligned to SWD boundaries.
% Input: SWDs - a vector marking SWDs;
%        fr - a corresponding matrix of cell firing rates. Rows correspond
%             to individual  in ms.
%        t - time vector.
%        meanType - 'regular' for a regular mean, 'circular' for a
%                   circular mean and 'circularNP' for a circular mean with
%                   non-parametric confidence intervals. The default is
%                   'regular'.
% Output: frMeanAligned - a mean firing rate vector aligned to SWD
%                         boundaries. The duration of the SWD is determined
%                         by the longest SWD. Other SWDs are split in
%                         halves and aligned to the boundaries.
%         frCI95Aligned - corresponding 95% confidence intervals.
%         tStartAligned - a corresponding time vector aligned to the
%                         beginning of the SWD in seconds.
%         tEndAligned - a corresponding time vector aligned to the end of
%                       the SWD in seconds.
%         frMeanAlignedScaled - a mean firing rate vector aligned to SWD
%                               boundaries. The duration of the SWD is
%                               average. All SWDs are linearly scaled and
%                               interpolated to match the average. Other
%                               associated output variables are
%                               frCI95AlignedScaled, tStartAlignedScaled,
%                               and tEndAlignedScaled.
%         frMean - mean firing rate for every SWD.
%         frCI95 - a 95% confidence interval on the mean firing rate.
%         frMeanFirst, frMeanSecond, frMeanThird - mean firing rate for
%                                                  every SWD (first third,
%                                                  second third, and the
%                                                  last third).
%         frCI95First, frCI95Second, frCI95Third - a 95% confidence
%                                                  interval on the mean
%                                                  firing rate (first third,
%                                                  second third, and the
%                                                  last third).
%         frMeanThird, frCI95First10 - Same as the measures above but
%                                      containing either the final third or
%                                      the last 10 seconds whichever is the
%                                      shortest.


%% Set function local parameters
if nargin < 4
    meanType = 'regular';
end

dispData = false;

preSWD = 0; %10000;
postSWD = 0; %10000;

dt = t(2) - t(1);


%% Split appart individual SWDs
tStartLargest = [];
tEndLargest = [];
tStartSplit = {};
tEndSplit = {};
frMeanSplit = {};
frMeanSplitShort = {};
clusters = unique(SWDs, 'stable');
clusters = clusters(clusters > 0);
if isempty(clusters)
    clusters = unique(SWDs, 'stable');
end
nClusters = numel(clusters);
durationAverage = 0;
for cell = 1:size(fr,1)
    for cl = 1:nClusters
        entry = (cell-1)*nClusters + cl;
        clOI = find(SWDs == clusters(cl));
        frMeanSplitShort{entry} = fr(cell,clOI);
        duration = numel(clOI);
        durationAverage = durationAverage + duration;
        tStart = t(clOI(1));
        tEnd = t(clOI(end));
        clOI = clOI(1) - preSWD/dt : clOI(end) + postSWD/dt;
        if clOI(1) < 1
            clOI = 1:clOI(end);
        end
        if clOI(end) > numel(SWDs)
            clOI = clOI(1):numel(SWDs);
        end
        
        SWDtemp = SWDs(clOI);
        iStart = find(SWDtemp > 0 & SWDtemp < clusters(cl), 1, 'last') + 1;
        if ~isempty(iStart)
            clOI = clOI(iStart):clOI(end);
        end
        iEnd = find(SWDtemp > clusters(cl), 1, 'first') - 1;
        if ~isempty(iEnd)
            clOI = clOI(1):clOI(iEnd);
        end
        
        tStartSplit{entry} = t(clOI) - tStart; %#ok<*AGROW>
        tEndSplit{entry} = t(clOI) - tEnd;
        if numel(clOI) > numel(tStartLargest)
            tStartLargest = tStartSplit{entry};
            tEndLargest = tEndSplit{entry};
        end
        frMeanSplit{entry} = fr(cell,clOI);
    end
end
durationAverage = round(durationAverage/entry);
duration10sec = round(5000/dt);
durationFinal10sec = max([1 durationAverage - duration10sec + 1]);

clear clOI tStart tEnd SWDtemp SWDs frMean t


%% Average SWDs
iStart = find(tStartLargest == 0);
iEnd = find(tEndLargest == 0);
iStartAverage = preSWD/dt + 1;
iEndAverage = preSWD/dt + durationAverage - 1; %#ok<*NASGU>
frMeanAligned = NaN(size(fr,1)*nClusters,numel(tStartLargest));
tStartAligned = NaN(size(fr,1)*nClusters,numel(tStartLargest));
tEndAligned = NaN(size(fr,1)*nClusters,numel(tStartLargest));
nTotal = (preSWD/dt)+durationAverage+(postSWD/dt);
frMeanAlignedScaled = NaN(size(fr,1)*nClusters, nTotal);
tInterp = (1:durationAverage)./durationAverage;
tStartAlignedScaled = ((1:nTotal)*dt)./1000 - preSWD/1000;
tEndAlignedScaled = ((1:nTotal)*dt)./1000 - (iEndAverage*dt)/1000;
frMean = NaN(size(fr,1)*nClusters, 1);
frCI95 = NaN(size(fr,1)*nClusters, 1);
frMeanFirst = NaN(size(fr,1)*nClusters, 1);
frCI95First = NaN(size(fr,1)*nClusters, 1);
frMeanSecond = NaN(size(fr,1)*nClusters, 1);
frCI95Second = NaN(size(fr,1)*nClusters, 1);
frMeanThird = NaN(size(fr,1)*nClusters, 1);
frCI95Third = NaN(size(fr,1)*nClusters, 1);
frMeanThird10 = NaN(size(fr,1)*nClusters, 1);
frCI95Third10 = NaN(size(fr,1)*nClusters, 1);
for cell = 1:size(fr,1)
    for cl = 1:nClusters
        entry = (cell-1)*nClusters + cl;
        iStartCl = find(tStartSplit{entry} == 0);
        iEndCl = find(tEndSplit{entry} == 0);
        duration = iEndCl - iStartCl + 1;
        iMidCl = iStartCl + ceil((duration)/2) - 1;
        iHalf1 = iStart - iStartCl + 1 : iStart - iStartCl + iMidCl;
        iHalf2 = iEnd - (iEndCl - iMidCl) + 1 : iEnd - (iEndCl - iMidCl) + (numel(frMeanSplit{entry}) - iMidCl);
        frMeanAligned(entry, iHalf1) = frMeanSplit{entry}(1:iMidCl);
        frMeanAligned(entry, iHalf2) = frMeanSplit{entry}(iMidCl+1:end);
        tStartAligned(entry, iHalf1) = tStartSplit{entry}(1:iMidCl);
        tStartAligned(entry, iHalf2) = tStartSplit{entry}(iMidCl+1:end);
        tEndAligned(entry, iHalf1) = tEndSplit{entry}(1:iMidCl);
        tEndAligned(entry, iHalf2) = tEndSplit{entry}(iMidCl+1:end);
        
        t = (1:duration)./duration;
        frScaled = interp1(t, frMeanSplitShort{entry}, tInterp, 'linear', 'extrap');
        frMeanAlignedScaled(entry,:) = [frMeanAligned(entry,1:iStartAverage-1) frScaled frMeanAligned(entry, end - postSWD/dt + 1 : end)];
        
        if strcmp(meanType, 'regular')
            frMean(entry,:) = mean(frScaled, 'omitnan');
            frMeanFirst(entry,:) = mean(frScaled(round(numel(frScaled)/6)+1:round(numel(frScaled)/3)), 'omitnan');
            frMeanSecond(entry,:) = mean(frScaled(round(numel(frScaled)/3)+1:round(2*numel(frScaled)/3)), 'omitnan');
            frMeanThird(entry,:) = mean(frScaled(round(2*numel(frScaled)/3)+1:end), 'omitnan');
            frMeanThird10(entry,:) = mean(frScaled(max([durationFinal10sec round(2*numel(frScaled)/3)+1]):end), 'omitnan');
        elseif strcmp(meanType, 'circular') || strcmp(meanType, 'circularNP')
            frMean(entry,:) = circmean(frScaled);
            frMeanFirst(entry,:) = circmean(frScaled(round(numel(frScaled)/6)+1:round(numel(frScaled)/3)));
            frMeanSecond(entry,:) = circmean(frScaled(round(numel(frScaled)/3)+1:round(2*numel(frScaled)/3)));
            frMeanThird(entry,:) = circmean(frScaled(round(2*numel(frScaled)/3)+1:end));
            frMeanThird10(entry,:) = circmean(frScaled(max([durationFinal10sec round(2*numel(frScaled)/3)+1]):end));
        end
    end
end

[frMeanAligned, frCI95Aligned] = datamean(frMeanAligned, meanType);
tStartAligned = tStartLargest./1000;
tEndAligned = tEndLargest./1000;
[frMeanAlignedScaled, frCI95AlignedScaled] = datamean(frMeanAlignedScaled, meanType);
%frMeanAlignedScaled(isnan(frMeanAlignedScaled)) = 0;
frCI95AlignedScaled(1,isnan(frMeanAlignedScaled)) = NaN;
frCI95AlignedScaled(2,isnan(frMeanAlignedScaled)) = NaN;
[~, frCI95] = datamean(frMean, meanType);
[~, frCI95First] = datamean(frMeanFirst, meanType);
[~, frCI95Second] = datamean(frMeanSecond, meanType);
[~, frCI95Third] = datamean(frMeanThird, meanType);
[~, frCI95Third10] = datamean(frMeanThird10, meanType);


%% Plot the data
if dispData
    figure; plot(tStartLargest./1000, frMeanAligned, '-', 'LineWidth',1, 'Color','b'); %#ok<*UNRCH>
    hold on
    pC = ciplot(frMeanAligned+frCI95Aligned(2,:), frMeanAligned+frCI95Aligned(1,:), tStartLargest./1000, 'b', 0.3);
    uistack(pC, 'bottom');
    plot([0 0], ylim, 'k--', 'LineWidth',1);
    plot([tStartLargest(iEnd) tStartLargest(iEnd)]./1000, ylim, 'k--', 'LineWidth',1);
    hold off
    
    figure; plot(tStartAlignedScaled, frMeanAlignedScaled, '-', 'LineWidth',1, 'Color','b');
    hold on
    pC = ciplot(frMeanAlignedScaled+frCI95AlignedScaled(2,:), frMeanAlignedScaled+frCI95AlignedScaled(1,:), tStartAlignedScaled, 'b', 0.3);
    uistack(pC, 'bottom');
    plot([0 0], ylim, 'k--', 'LineWidth',1);
    plot([tStartAlignedScaled(iEndAverage) tStartAlignedScaled(iEndAverage)], ylim, 'k--', 'LineWidth',1);
    hold off
end