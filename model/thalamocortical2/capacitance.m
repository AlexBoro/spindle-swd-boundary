function Cm = capacitance(Area, cm)
%   Calculates the membrane capacitance of a neuron given its specific
%   membrane capacitance (cm in uf/cm2) and total membrane area (in cm2).
%   The membrane area is expressed in pF.

Cm = Area*cm*1e6;

end

