TITLE Ca2+-activated K+ current I_K[Ca] in cortical cells

COMMENT
    The model equations are the same as in [1].

    References:
    [1] Mainen, Z.F. and Sejnowski, T.J. Influence of dendritic structure
        on firing pattern in model neocortical neurons. Nature, 382: 363-
        366, 1996.

    Written by Martynas Dervinis @Cardiff University, 2014.

ENDCOMMENT

NEURON {
	SUFFIX ikcaFull
	USEION k READ ek WRITE ik
    USEION ca READ cai
    USEION caHVA READ caHVAi VALENCE 2
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
	gkbar   = 3E-4 (mho/cm2)
	ek      = -90 (mV)
    cai     = 50e-6 (mM)
    caHVAi	= 50e-6 (mM)
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
    caiFull (mM)
}

BREAKPOINT {
    q10 = 2.3^((celsius - 23) / 10)
    caiFull = cai + caHVAi
	SOLVE states METHOD cnexp
	ik = q10 * gkbar * n * (v - ek)
}

INITIAL {
    caiFull = cai + caHVAi
    gates(caiFull)
	n = n_inf
}

DERIVATIVE states {
    gates(caiFull)
	n' = (n_inf - n) / (tau_n / q10)
}

PROCEDURE gates(caiFull(mM)) {                                              : computes I_K[Ca] gating functions and other constants at current v
                                                                            : call once from HOC to initialize inf at resting v
    LOCAL  alpha, beta

    UNITSOFF

	alpha = 10 * caiFull                                                        : n system
	beta  = 0.02      : used to be beta = 20
	tau_n = 1 / (alpha + beta)
	n_inf = alpha / (alpha + beta)
}

UNITSON
