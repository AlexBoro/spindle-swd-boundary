function [meanUpDurations, meanDownDurations, upStates, upLocs] = durations(stringent, draw, draw2, binSize, t, v, dt, cellType, fileName, startTime)

if draw
    f1 = figure('Units', 'normalized', 'Position', [0, .01, .98, .89]);
    plot(t*1e-3, v)
    titleStr = sprintf('Membrane Potential Trace - file: %s', fileName);
    set(f1,'name',titleStr)
    title(titleStr, 'Interpreter', 'none')
    xlabel('Time (s)')
    %xlim([9.5 11.5])
    ylabel('Membrane potential (mV)')
    ylim([-90 45])
end

vStart = startTime/dt + 2;
histRange = [-90 50];
binCentres = (histRange(1):binSize:histRange(2));
histo = hist(v(vStart:end), binCentres);
[~, iPeak1] = max(histo);
peak1 = binCentres(iPeak1);
% if binSize < 0.3
%     iStart = iPeak1+floor(0.3/binSize);
% else
%     iStart = iPeak1+1;
% end
% [~,locs,widths,proms] = findpeaks(histo(iStart:end), 'NPeaks', 5);
% score = 5:-1:1;
% [~, widths] = sort(widths, 'descend');
% [~, proms] = sort(proms, 'descend');
% relevance = score;
% relevance(widths) = relevance(widths) + score;
% relevance(proms) = relevance(proms) + score;
% if strcmp('EF', cellType)
%     peak2 = peak1 + 2;
%     through = (peak1+peak2)/2;
% elseif strcmp('ND', cellType)
%     peak2 = -59.33;
%     iPeak2 = ceil((peak2-binCentres(1))/binSize+1);
%     [~, iThrough] = max(-histo(iPeak1:iPeak2));
%     iThrough = iPeak1+iThrough-1;
%     through = binCentres(iThrough);
% else
%     [~, iPeak2] = max(relevance);
%     iPeak2 = iStart + locs(iPeak2) - 1;
%     peak2 = binCentres(iPeak2);
%     [~, iThrough] = max(-histo(iPeak1:iPeak2));
%     iThrough = iPeak1+iThrough-1;
%     through = binCentres(iThrough);
% end
%iStart = iPeak1+floor(5/binSize);
iStart = iPeak1+floor(2/binSize);
[~, iPeak2] = max(histo(iStart:end));
iPeak2 = iStart + iPeak2 - 1;
peak2 = binCentres(iPeak2);
[~, iThrough] = max(-histo(iPeak1:iPeak2));
iThrough = iPeak1+iThrough-1;
through = binCentres(iThrough);
threshold = through;
binEdges = binCentres-binSize/2;
if draw2
    f2 = figure('Units', 'normalized', 'Position', [0, .01, .98, .89]);
    h = histogram(v(vStart:end), binEdges, 'Normalization', 'count');
    titleStr = sprintf('Membrane Potential Trace - file: %s', fileName);
    set(f2,'name',titleStr)
    title(titleStr, 'Interpreter', 'none')
    hold on
    yRange = ylim;
    plot([peak1 peak1],[yRange(1) yRange(2)])
    plot([peak2 peak2],[yRange(1) yRange(2)])
    plot([threshold threshold],[yRange(1) yRange(2)], 'r')
    hold off
    xlim([-75 -45])
%     bar(binCentres, histo/max(histo), 'FaceColor', [1/255 0 129/255])
%     xlim([-75 -45])
%     ylim([0 1.2])
%     ax2= axesProperties({}, 1, 'normal', 'off', 'w', 'Calibri', 30, 4/3, 1, [0.01 0], 'out', 'on', 'k', {'Membrane potential (mV)'}, [], -70:10:-50, 'on', 'k', {'Normalised events'}, [0 1.2], 0:0.2:1.2);
%     ax2.YTickLabel = {'0.0','0.2','0.4','0.6','0.8','1.0','1.2'};
%     paperSize = resizeFig(f2, ax2, 15, 0.761*15, [3.1 3.05], [0.65 0.3], 0);
%     exportFig(f2, ['bistability' '.tif'],'-dtiffnocompression','-r300', paperSize);
    figure(f2)
    hold on
    plot(t*1e-3, ones(1,length(t))*threshold, 'k--')
    hold off
end

searching = 1;
upStates = v(vStart:end);
upStates(upStates >= threshold) = 1;
upStates(upStates < threshold) = 0;
downStates = abs(upStates-1);
if stringent
    window = round(10000/dt); %#ok<*UNRCH>
    searchStart = 1;
    searchWindow = searchStart:min([searchStart+window-1, length(upStates)]);
    upSearch = upStates(searchWindow);
    minDuration = 40;
    minFraction = 0.90;
    while searching
        downSearch = downStates(searchWindow);
        startUp = find(upSearch,1);
        if isempty(startUp)
            if length(upStates)-searchStart <= minDuration/dt
                searching = 0;
            else
                searchStart = searchWindow(end)+1;
                searchWindow = searchStart:min([searchStart+window-1, length(upStates)]);
                upSearch = upStates(searchWindow);
            end
        else
            endDown = find(downSearch,1,'last');
            if isempty(endDown)
                if searchWindow(end) == length(upStates)
                    searching = 0;
                else
                    searchWindow = searchStart:min([searchWindow(end)+window, length(upStates)]);
                    upSearch = upStates(searchWindow);
                end
            else
                searchWindow = searchStart:searchStart+endDown-1;
                upSearch = upStates(searchWindow);
                endUp = find(upSearch,1,'last');
                searchWindow = searchStart:searchStart+endUp-1;
                upSearch = upStates(searchWindow);
                up = upSearch(startUp:end);
                iUp = searchStart+startUp-1:searchWindow(end);
                fractionUp = sum(up)/length(up);
                if fractionUp > minFraction
                    if length(up) >= round(minDuration/dt)
                        upStates(iUp) = 1;
                    else
                        upStates(iUp) = 0;
                    end
                    searchStart = searchStart+endDown-1;
                    searchWindow = searchStart:min([searchStart+window-1, length(upStates)]);
                    upSearch = upStates(searchWindow);
                elseif length(up) < round(minDuration/dt)
                    upStates(iUp) = 0;
                    searchStart = searchStart+endDown-1;
                    searchWindow = searchStart:min([searchStart+window-1, length(upStates)]);
                    upSearch = upStates(searchWindow);
                end
            end
        end
    end
elseif ~strcmp('EF', cellType)
    minDuration = 20;
    currentPoint = find(downStates,1);
    if ~isempty(currentPoint)
        while searching
            startUp = currentPoint+find(upStates(currentPoint:end),1)-1;
            if isempty(startUp)
                searching = 0;
            else
                endUp = startUp+find(downStates(startUp:end),1)-2;
                if isempty(endUp)
                    searching = 0;
                else
                    if endUp-startUp < round(minDuration/dt)
                        upStates(startUp:endUp) = 0;
                    end
                    currentPoint = endUp+1;
                end
            end
        end
    end
end
downStates = abs(upStates-1);
searching = 1;
if stringent
    minDuration = 40;
else
    minDuration = 100;
end
currentPoint = find(upStates,1);
if ~isempty(currentPoint)
    while searching
        startDown = currentPoint+find(downStates(currentPoint:end),1)-1;
        if isempty(startDown)
            searching = 0;
        else
            endDown = startDown+find(upStates(startDown:end),1)-2;
            if isempty(endDown)
                searching = 0;
            else
                if endDown-startDown < round(minDuration/dt)
                    upStates(startDown:endDown) = 1;
                end
                currentPoint = endDown+1;
            end
        end
    end
end
downStates = abs(upStates-1);
searching = 1;
if ~stringent && ~strcmp('ND', cellType)
    minDuration = 50;
    currentPoint = find(downStates,1);
    if ~isempty(currentPoint)
        while searching
            startUp = currentPoint+find(upStates(currentPoint:end),1)-1;
            if isempty(startUp)
                searching = 0;
            else
                endUp = startUp+find(downStates(startUp:end),1)-2;
                if isempty(endUp)
                    searching = 0;
                else
                    if endUp-startUp < round(minDuration/dt)
                        upStates(startUp:endUp) = 0;
                    end
                    currentPoint = endUp+1;
                end
            end
        end
    end
end
upStates = [zeros(1,vStart-1) upStates];
downStates = abs(upStates-1);
if draw
    figure(f1)
    hold on
    plot(t*1e-3, -85+upStates*(threshold+85), 'r')
    hold off
end

[~, upLocs] = findpeaks(upStates);
[~, downLocs] = findpeaks(downStates);
meanUpDurations = (sum(upStates(upLocs(1):downLocs(end)))/length(upLocs))*dt;
meanDownDurations = (sum(downStates(upLocs(1):upLocs(end)))/(length(upLocs)-1))*dt;

