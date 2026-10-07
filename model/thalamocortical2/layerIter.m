function peaks = layerIter(v, pad, dt)
peaks = peakIter(v);
pad = round(pad/dt);
if pad >= 0
    for i = 1:size(peaks,1)
        for j = 1:size(peaks,2)
            if peaks(i,j) == 1
                for k = 1:pad
                    for l = -5:5
                        if i+l > 0 && i+l < size(peaks,1)
                            if j+k <= size(peaks,2) && peaks(i+l,j+k) ~= 1
                                peaks(i+l,j+k) = 2;
                            end
                        end
                    end
                end
            end
        end
    end
end

function peaks = peakIter(v)
peaks = zeros(size(v));
for i = 1:size(v,1)
    [~, locs] = findpeaks(v(i,:),'MinPeakHeight',-10);
    if ~isempty(locs)
        peaks(i,locs) = 1;
    end
end