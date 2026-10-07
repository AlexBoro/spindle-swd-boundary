TITLE Persistent Na+ current I_Na(P) in TC cells

COMMENT
    The model was described by [1]. The activation time constant is the
    same as for the fast transient Na+ current of action potentials
    described in [2] but hyperpolarised.

    References:
    [1] Parri, H.R., Crunelli, V. Sodium current in rat and cat
        thalamocortical neurons: role of a non-inactivating component in
        tonic and burst firing. The Journal of Neuroscience 18: 854-867,
        1998.
    [2] Traub, R.D., Wong, R. K., Miles, R., and Michelson, H. A model of a
        CA3 hippocampal pyramidal neuron incorporating voltage-clamp data
        on intrinsic conductances. Journal of Neurophysiology 66: 635-650,
        1991.

    Written by Martynas Dervinis @Cardiff University, 2013.

ENDCOMMENT

NEURON {
	SUFFIX inap
	USEION na WRITE ina
	RANGE enaINaP, gnabar, m_inf, tau_m, shift, delay
}

UNITS {
	(mA) = (milliamp)
	(mV) = (millivolt)
    (mS) = (millisecond)
}

PARAMETER {
	gnabar	= 0.0000085 (mho/cm2)
	enaINaP	= 30        (mV)
	celsius = 35        (degC)
    shift = 0           (mV)
    delay = 0           (mS)
}

STATE {
	m
}

ASSIGNED {
	ina	(mA/cm2)
	m_inf
	tau_m
}

BREAKPOINT {
	SOLVE states METHOD cnexp
	ina = gnabar * m * (v - enaINaP)
}

DERIVATIVE states {
	gates(v)
	m' = (m_inf - m) / tau_m
}

INITIAL {
    gates(v)
	m = m_inf
}

: Procedures & functions
PROCEDURE gates(v(mV)) {	: computes gating functions and other constants at current v
    LOCAL  q10, alpha, beta
    TABLE m_inf, tau_m DEPEND celsius FROM -120 TO 80 WITH 200

    UNITSOFF
    q10 = 3^((celsius - 35) / 10)
	
	alpha = 0.32 * vtrap(-66.58 + shift - v, 4)     : activation system
	beta = 0.28 * vtrap(39.58 + v - shift, 5)
	tau_m = (delay + 1 / (alpha + beta)) / q10
	m_inf = 1 / (1 + exp(-(v + 53.87 - shift) / 8.57))
}

FUNCTION vtrap(x,y) {   : traps for 0 in denominator of rate eqns.
        if (fabs(x/y) < 1e-6) {
                vtrap = y*(1 - x/y/2)
        }else{
                vtrap = x/(exp(x/y) - 1)
        }
}

UNITSON
