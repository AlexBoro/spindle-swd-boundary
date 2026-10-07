TITLE High threshold calcium current in cortical cells

COMMENT
    The model equations are the same as in [1].

    References:
    [1] Mainen, Z.F. and Sejnowski, T.J. Influence of dendritic structure
        on firing pattern in model neocortical neurons. Nature, 382: 363-
        366, 1996.

    Written by Martynas Dervinis @Cardiff University, 2014.

ENDCOMMENT

NEURON {
	SUFFIX ihvaCxFull
	USEION caHVA WRITE icaHVA VALENCE 2
	RANGE eca, gcabar, m_inf, h_inf, tau_m, tau_h, shift, q10
}

UNITS {
	(mA) = (milliamp)
	(mV) = (millivolt)
}

PARAMETER {
	gcabar = 0.3E-4 (mho/cm2)
	eca    = 140 (mV)
    shift  = 0 (mV)
}

STATE {
	m h
}

ASSIGNED {
    v (mV)
    celsius (degC)
	icaHVA	(mA/cm2)
	m_inf
	h_inf
	tau_m
	tau_h
    q10
}

BREAKPOINT {
    q10 = 2.3^((celsius - 23) / 10)
	SOLVE states METHOD cnexp
	icaHVA = q10 * gcabar * m^2 * h * (v - eca)
}

INITIAL {
    gates(v)
	m = m_inf
	h = h_inf
}

DERIVATIVE states {
    gates(v)
	m' = (m_inf - m) / (tau_m / q10)
	h' = (h_inf - h) / (tau_h / q10)
}

: Procedures & functions
PROCEDURE gates(v(mV)) {                                                    : computes I_HVA gating functions and other constants at current v
                                                                            : call once from HOC to initialize inf at resting v
    LOCAL  alpha, beta
    TABLE m_inf, tau_m, h_inf, tau_h
        DEPEND celsius FROM -120 TO 80 WITH 200

    UNITSOFF

	alpha = 0.055 * vtrap(v + 27 - shift, 3.8)                              : m system
	beta  = 0.94 * exp(-(v + 75 - shift)/17)
	tau_m = 1 / (alpha + beta)
	m_inf = alpha / (alpha + beta)

	alpha = 4.57E-4 * exp(-(v + 13 - shift)/50)                             : h system
	beta  = 0.0065/ (1 + exp(-(v + 15 - shift)/28))
	tau_h = 1 / (alpha + beta)
	h_inf = alpha / (alpha + beta)
}

FUNCTION vtrap(x,y) {                                                       : traps for 0 in denominator of rate eqns.
        if (fabs(x/y) < 1e-6) {
                vtrap = y*(1 - x/y/2)
        }else{
                vtrap = x/(1 - exp(-x/y))
        }
}

UNITSON
