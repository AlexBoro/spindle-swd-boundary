TITLE Michaelis-Menten sequestration mechanism for submembranal Ca2+ concentration (cai)

COMMENT
    Takes into account:
        - increase of cai due to calcium currents
        - extrusion of calcium with two instances of Michaelis-Menten
          mechanism for fast and slow sequestration as in [1].

    Parameters:
        - depth: depth of the shell beneath the membrane (in um). Should be
          no more than the radius of the cell.
        - cainf: equilibrium concentration of calcium (TC: 23e-6 mM; NRT:
          39e-6 mM).
        - KT1: The maximum extrusion rate of the first pump.
        - KT2: The maximum extrusion rate of the second pump.
        - Kd1: The intracellular calcium concentration at the half-maximal
               extrusion rate of the first pump.
        - Kd2: The intracellular calcium concentration at the half-maximal
               extrusion rate of the second pump.

    References:
    [1] Cueni, L., Canepari, M., Lujan, R., Emmenegger, Y., Watanabe, M.,
        Bond, C.T., Franken, P., Adelman, J.P., Luthi, A. T-type Ca2+
        channels, SK2 channels and SERCAs gate sleep-related oscillations
        in thalamic dendrites. Nature Neuroscience, 11: 683-692, 2008.

    Written by Martynas Dervinis @ Cardiff University, 2013

ENDCOMMENT

NEURON {
	SUFFIX cap
	USEION ca READ ica, cai WRITE cai
	RANGE depth, cainf, KT1, KT2, Kd1, Kd2
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
	depth	= 1     (um)		: depth of shell
	cainf	= 50e-6 (mM)
    KT1     = 1e-5  (mM/ms)     : max rate 1
    KT2     = 2e-4  (mM/ms)     : max rate 2
    Kd1     = 1e-4  (mM)        : half conc 1
    Kd2     = 2e-3  (mM)        : half conc 2
}

STATE {
	cai	(mM) 
}

INITIAL {
	cai = cainf
}

ASSIGNED {
	ica             (mA/cm2)
	drive_channel	(mM/ms)
    drive_pump1     (mM/ms)
    drive_pump2     (mM/ms)
}
	
BREAKPOINT {
	SOLVE state METHOD derivimplicit
}

DERIVATIVE state {
    drive_channel =  - (10000) * ica / (2 * FARADAY * depth)
    if (drive_channel <= 0) { drive_channel = 0 }	: cannot pump inward
    cai' = drive_channel + drive_pump(cai)
}

FUNCTION drive_pump(cai(mM)) {
    drive_pump1 = -KT1*(cai-cainf) / ((cai-cainf) + Kd1)
    drive_pump2 = -KT2*(cai-cainf) / ((cai-cainf) + Kd2)
    drive_pump = drive_pump1 + drive_pump2
}