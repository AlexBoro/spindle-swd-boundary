function Ri = estRi(V, I, Area)

peak = V(end);
baseline = V(120);
amplitude = abs(peak - baseline);

peak = I(end);
baseline = I(120);
I = abs(peak - baseline)*Area*1e6;

Ri = amplitude/0.001;