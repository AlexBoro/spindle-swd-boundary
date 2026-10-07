TITLE Anomalous rectifier current I_h in cortical neurons

COMMENT
    Anomalous rectifier or hyperpolarisation activated (Na+/K+) current I_h
    outlined in [1]

    References:
    [1] Keren, N., Peled, N., and Korngreen, A. Constraining Compartmental
        Models Using Multiple Voltage Recordings and Genetic Algorithms.
        Journal of Neurophysiology, 94: 3730–3742, 2005.

    Written by Martynas Dervinis @ Cardiff University, 2014.

ENDCOMMENT

NEURON {
	SUFFIX iarCx3
	USEION h READ eh WRITE ih VALENCE 1
    RANGE ghbar, halfAct
}

UNITS {
	(mA) 	= (milliamp)
	(mV) 	= (millivolt)
}

PARAMETER {
	eh      = -30	 (mV)
	celsius = 37	 (degC)
	ghbar	= 0.0015 (mho/cm2)
    halfAct = -91
}

STATE {
	m
}

ASSIGNED {
	v	  (mV)
	ih    (mA/cm2)
	m_inf
    tau_m (ms)
	phi
}

BREAKPOINT {
	SOLVE states METHOD cnexp
	ih = phi * ghbar * m * (v - eh)
}

DERIVATIVE states {
	gates(v)
	m' = (m_inf - m) / (tau_m / phi)
}

INITIAL {
    phi = 3.5 ^ ((celsius-22 (degC) )/10 (degC) )
	gates(v)
	m = m_inf
}

UNITSOFF
PROCEDURE gates(v(mV)) {
    m_inf = 1 / (1 + exp((v-halfAct)/6))
	tau_m = 1/(0.0004 * exp(-0.025*v) + 0.088*exp(0.062*v))	
}
UNITSON
