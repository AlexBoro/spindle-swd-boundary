TITLE Hippocampal HH channels for action potential generation (I_Na + I_K(DR))

COMMENT
    The model was described by [1]. It is built for the purpose of using it
    in thalamocortical (TC) relay cells and neurons of reticular thalamic
    nucleus (NRT). The vtraub parameter corresponds to the threshold of
    action potential generation. This model was originally developed for
    hippocampal pyramidal cells and adapted to TC and NRT cells because the
    description of HH mechanism for these cells does not exist (see [2]).

    References:
    [1] Traub, R.D., Wong, R.K., Miles, R., and Michelson, H. A model of a
        CA3 hippocampal pyramidal neuron incorporating voltage-clamp data
        on intrinsic conductances. Journal of Neurophysiology 66: 635-650,
        1991.
    [2] Parri, H.R., Crunelli, V. Sodium current in rat and cat
        thalamocortical neurons: role of a non-inactivating component in
        tonic and burst firing. The Journal of Neuroscience 18: 854-867,
        1998.

    Written by Martynas Dervinis @Cardiff University, 2013.

ENDCOMMENT

NEURON {
	SUFFIX hhT
	USEION na WRITE ina
	USEION k READ ek WRITE ik
	RANGE enaHH, gnabar, gkbar, vtraubNa, vtraubK, m_inf, h_inf, n_inf
    RANGE tau_m, tau_h, tau_n, m_shift, h_shift, n_shift
}

UNITS {
	(mA) = (milliamp)
	(mV) = (millivolt)
}

PARAMETER {
	gnabar	= 0.00135 (mho/cm2)
	gkbar	= 0.0007 (mho/cm2)
	enaHH	= 55 (mV)
	ek	= -75 (mV)
	vtraubNa = -65.5 (mV)	: see ref. 2
    vtraubK = -65.5 (mV)
    m_shift = 0 (mV)
    h_shift = 0 (mV)
    n_shift = 0 (mV)
}

STATE {
	m h n
}

ASSIGNED {
    v (mV)
    v2 (mV)
    v3 (mV)
    celsius (degC)
	ina	(mA/cm2)
	ik	(mA/cm2)
	m_inf
	h_inf
	n_inf
	tau_m
	tau_h
	tau_n
}

BREAKPOINT {
	SOLVE states METHOD cnexp
	ina = gnabar * m^3 * h * (v - enaHH)
	ik  = gkbar * n^4 * (v - ek)
}

INITIAL {
    v2 = v - vtraubNa       : convert to traub convention
    v3 = v - vtraubK
    gatesNa(v2)
    gatesK(v3)
	m = m_inf
	h = h_inf
	n = n_inf
}

DERIVATIVE states {
	v2 = v - vtraubNa
    v3 = v - vtraubK
    gatesNa(v2)
    gatesK(v3)
	m' = (m_inf - m) / tau_m
	h' = (h_inf - h) / tau_h
	n' = (n_inf - n) / tau_n
}

: Procedures & functions
PROCEDURE gatesNa(v2(mV)) {	: computes I_Na gating functions and other constants at current v
    LOCAL  alpha, beta, q10
    TABLE m_inf, tau_m, h_inf, tau_h
        DEPEND celsius FROM -120 TO 80 WITH 200

    UNITSOFF
    q10 = 3^((celsius - 35) / 10)

	alpha = 0.32 * vtrap(13.1 + m_shift - v2, 4)        : m system
	beta = 0.28 * vtrap(v2 - m_shift - 40.1, 5)
	tau_m = 1 / (alpha + beta) / q10
	m_inf = alpha / (alpha + beta)

	alpha = 0.128 * exp((17 + h_shift - v2) / 18)       : h system
	beta = 4 / ( 1 + exp((40 + h_shift - v2) / 5) )
	tau_h = 1 / (alpha + beta) / q10
	h_inf = alpha / (alpha + beta)
}

PROCEDURE gatesK(v3(mV)) {  : computes I_K(DR) gating functions and other constants at current v
    LOCAL  alpha, beta, q10
    TABLE n_inf, tau_n
        DEPEND celsius FROM -120 TO 80 WITH 200

    UNITSOFF
    q10 = 3^((celsius - 35) / 10)

	alpha = 0.016 * vtrap(35.1 + n_shift - v3, 5)       : n system
	beta = 0.25 * exp((20 + n_shift - v3)/40)
	tau_n = 1 / (alpha + beta) / q10
	n_inf = alpha / (alpha + beta)
}

FUNCTION vtrap(x,y) {	: traps for 0 in denominator of rate eqns
        if (fabs(x/y) < 1e-6) {
                vtrap = y*(1 - x/y/2)
        }else{
                vtrap = x/(exp(x/y) - 1)
        }
}

UNITSON
