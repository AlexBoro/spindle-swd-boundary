TITLE Mechanism for submembranal Na+ concentration (nai)

COMMENT
    Takes into account:
        - increase of nai due to sodium currents
        - extrusion of sodium with a simple first order equation

    Parameters:
        - depth: depth of the shell beneath the membran (in um). Should be
          no more than the radius of the cell.
        - nainf: equilibrium concentration of sodium (assumes native NEURON
          parameters)
        - taux: time constant of sodium extrusion (500 ms)

    Written by Martynas Dervinis @ Cardiff University, 2013
        (martynas.dervinis@gmail.com).
ENDCOMMENT

NEURON {
	SUFFIX nad
	USEION na READ ina, nai WRITE nai
	RANGE depth, nainf, taux
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
	depth	= 1     (um) 	: depth of shell
	taux	= 7000	(ms) 	: rate of sodium removal (slow)
	nainf	= 10    (mM)
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
	drive_channel =  - 10000 * ina / (FARADAY * depth)
	if (drive_channel <= 0.) { drive_channel = 0. }                         : cannot pump inward
	nai' = drive_channel + (nainf-nai)/taux
}
