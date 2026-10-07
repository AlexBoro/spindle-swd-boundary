TITLE Ca2+-activated K+ current I_K[Ca] in cortical cells

COMMENT
    The model equations are the same as in [1].

    References:
    [1] Timofeev, I., Bazhenov, G.M., Sejnowski, T.J., and Steriade, M.
        Origin of Slow Cortical Oscillations in Deafferented Cortical Slabs.
        Cerebral Cortex, 10: 1185-1199, 2000.

    Written by Martynas Dervinis @Cardiff University, 2014.

ENDCOMMENT

NEURON {
	SUFFIX ikcaCx2
	USEION k READ ek WRITE ik
    USEION ca READ cai
	RANGE ek, gkbar, n_inf, tau_n, q10
}

UNITS {
	(molar)	= (1/liter)
	(mM)	= (millimolar)
	(mA) 	= (milliamp)
	(mV) 	= (millivolt)
	(msM)	= (ms mM)
}

PARAMETER {
	gkbar = 3E-4 (mho/cm2)
	ek    = -90 (mV)
    cai	  = 240e-6 (mM)
}

STATE {
	n
}

ASSIGNED {
    v (mV)
    celsius (degC)
	ik	(mA/cm2)
	n_inf
	tau_n
    q10
}

BREAKPOINT {
    q10 = 2.3^((celsius - 23) / 10)
	SOLVE states METHOD cnexp
	ik = q10 * gkbar * n * (v - ek)
}

INITIAL {
    gates(cai)
	n = n_inf
}

DERIVATIVE states {
    gates(cai)
	n' = (n_inf - n) / (tau_n / q10)
}

PROCEDURE gates(cai(mM)) {                                                  : computes I_K[Ca] gating functions and other constants at current v
                                                                            : call once from HOC to initialize inf at resting v
    LOCAL  alpha, beta

    UNITSOFF

	alpha = 1000*cai                                                             : n system
	beta  = 2000
	tau_n = 1 / (alpha + beta)
	n_inf = alpha / (alpha + beta)
}

UNITSON
