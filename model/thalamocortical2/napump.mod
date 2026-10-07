TITLE Na+ pump

COMMENT
    Takes into account:
        - increase of nai due to sodium currents
        - extrusion of sodium using a pump. The mathematical description of
          the pump was taken from [1].

    Parameters:
        - depth: depth of the shell beneath the membran (in um). Should be
          no more than the radius of the cell.
        - nainf: equilibrium concentration of sodium (assumes native NEURON
          parameters)
        - R_pump: the maximal extrusion rate (mM/ms)
        - K_m: concentration at which the pump is half-activated (mM)

    Written by Martynas Dervinis @ Cardiff University, 2014
ENDCOMMENT

NEURON {
	SUFFIX nap
	USEION na READ ina, nai WRITE nai
	RANGE depth, nainf, R_pump, K_m
}

UNITS {
	(molar) = (1/liter)
	(mM)	= (millimolar)
	(um)	= (micron)
	(mA)	= (milliamp)
	(msM)	= (ms mM)
}

CONSTANT {
	FARADAY = 96489	(coul) 
}

PARAMETER {
	depth	= 1      (um) 	: depth of shell
	nainf	= 10     (mM)
    R_pump  = -0.018 (mM/ms)
    K_m     = 15     (mM)
}

STATE {
	nai	(mM) 
}

INITIAL {
	nai = nainf
}

ASSIGNED {
	ina             (mA/cm2)
	drive_channel	(mM/ms)
}
	
BREAKPOINT {
	SOLVE state METHOD derivimplicit
}

DERIVATIVE state {
    LOCAL pump

	drive_channel =  - 10000 * ina / (FARADAY * depth)
	if (drive_channel <= 0.) { drive_channel = 0. }                         : cannot pump inward
    pump = R_pump*(nai^3/(nai^3 + K_m^3) - nainf^3/(nainf^3 + K_m^3))
	nai' = drive_channel + pump
}
