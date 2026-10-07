TITLE Cortical HH channels for action potential generation (I_Na + I_K(DR))

COMMENT
    The model equations are the same as in [1].

    References:
    [1] Mainen, Z.F. and Sejnowski, T.J. Influence of dendritic structure
        on firing pattern in model neocortical neurons. Nature, 382: 363-
        366, 1996.

    Written by Martynas Dervinis @Cardiff University, 2014.

ENDCOMMENT

NEURON {
	SUFFIX hhCx
	USEION na WRITE ina
	USEION k READ ek WRITE ik
	RANGE ena, ek, gnabar, gkbar, m_inf, h_inf, n_inf, tau_m, tau_h, tau_n, q10, shift
}

UNITS {
	(mA) = (milliamp)
	(mV) = (millivolt)
}

PARAMETER {
	gnabar	= 30E-4 (mho/cm2)
	gkbar	= 1.5E-4 (mho/cm2)
	ena     = 50 (mV)
	ek      = -90 (mV)
    shift   = 0 (mV)
}

STATE {
	m h n
}

ASSIGNED {
    v (mV)
    celsius (degC)
	ina	(mA/cm2)
	ik	(mA/cm2)
	m_inf
	h_inf
	n_inf
	tau_m
	tau_h
	tau_n
    q10
}

BREAKPOINT {
    q10 = 2.3^((celsius - 23) / 10)
	SOLVE states METHOD cnexp
	ina = q10*gnabar * m^3 * h * (v - ena)
	ik  = q10*gkbar * n * (v - ek)
}

INITIAL {
    gatesNa(v-shift)
    gatesK(v-shift)
	m = m_inf
	h = h_inf
	n = n_inf
}

DERIVATIVE states {
    gatesNa(v-shift)
    gatesK(v-shift)
	m' = (m_inf - m) / (tau_m / q10)
	h' = (h_inf - h) / (tau_h / q10)
	n' = (n_inf - n) / (tau_n / q10)
}

: Procedures & functions
PROCEDURE gatesNa(v(mV)) {                                                  : computes I_Na gating functions and other constants at current v
                                                                            : call once from HOC to initialize inf at resting v
    LOCAL  alpha, beta
    TABLE m_inf, tau_m, h_inf, tau_h
        DEPEND celsius FROM -120 TO 80 WITH 200

    UNITSOFF
    q10 = 2.3^((celsius - 23) / 10)

	alpha = 0.182 * vtrap(v + 25, 9)                                        : m system
	beta  = 0.124 * vtrap(-(v + 25), 9)
	tau_m = 1 / (alpha + beta)
	m_inf = alpha / (alpha + beta)

	alpha = 0.024 * vtrap(v + 40, 5)                                        : h system
	beta  = 0.0091 * vtrap(-(v + 65), 5)
	tau_h = 1 / (alpha + beta)
    h_inf = 1/(1 + exp((v + 55)/6.2))
}

PROCEDURE gatesK(v(mV)) {                                                   : computes I_K(DR) gating functions and other constants at current v
                                                                            : call once from HOC to initialize inf at resting v
    LOCAL  alpha, beta
    TABLE n_inf, tau_n
        DEPEND celsius FROM -120 TO 80 WITH 200

    UNITSOFF
    q10 = 2.3^((celsius - 23) / 10)

	alpha = 0.02 * vtrap(v - 25, 9)                                         : n system
	beta = 0.002 * vtrap(-(v - 25), 9)
	tau_n = 1 / (alpha + beta)
	n_inf = alpha / (alpha + beta)
}

FUNCTION vtrap(x,y) {                                                       : traps for 0 in denominator of rate eqns.
        if (fabs(x/y) < 1e-6) {
                vtrap = y*(1 - x/y/2)
        }else{
                vtrap = x/(1 - exp(-x/y))
        }
}

UNITSON
