function t = onset(t, xLim, yLims, data, c)
inds = findRange(t, xLim);
if length(inds) == 1
    inds(2) = length(t);
end
t = t(inds(1):inds(2));
data = data(:,inds(1):inds(2));
for i = 1:length(t)
    [~, ind] = findpeaks(data(yLims(1):yLims(2),i));
    if ~isempty(ind)
        break
    end
end
t = t(i);

hold on
if c == 1
    plot([t t], [0 size(data,1)], 'k--', 'Linewidth', 4)
    %t
elseif c == 2
    plot([t t], [0 size(data,1)], 'r--', 'Linewidth', 4)
    t %#ok<NOPRT>
end
hold off