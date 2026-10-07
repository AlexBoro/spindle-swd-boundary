TITLE Persistent Na+ current I_Na(P)

COMMENT
    The model was taken from [1]. The time constant was adopted from the
    transient Na+ channel described in [2].

    References:
    [1] Timofeev, I., Bazhenov, G.M., Sejnowski, T.J., and Steriade, M.
        Origin of Slow Cortical Oscillations in Deafferented Cortical Slabs.
        Cerebral Cortex, 10: 1185-1199, 2000.
    [2] Mainen, Z.F. and Sejnowski, T.J. Influence of dendritic structure
        on firing pattern in model neocortical neurons. Nature, 382: 363-
        366, 1996.

    Written by Martynas Dervinis @Cardiff University, 2014.

ENDCOMMENT

NEURON {
	SUFFIX inapCx2
	USEION na WRITE ina
	RANGE ena, gnabar, v_half, stFact, m_inf, tau_m, q10
}

UNITS {
	(mA) = (milliamp)
	(mV) = (millivolt)
    (mS) = (millisecond)
}

PARAMETER {
	gnabar	= 0.65E-4   (mho/cm2)
	ena     = 50        (mV)
    v_half  = -42       (mV)
    stFact = 5
	celsius = 35        (degC)
}

STATE {
	m
}

ASSIGNED {
	ina	(mA/cm2)
	m_inf
	tau_m
    q10
    v_nap
}

BREAKPOINT {
    q10 = 2.3^((celsius - 36) / 10)
	SOLVE states METHOD cnexp
	ina = q10 * gnabar * m * (v - ena)
}

DERIVATIVE states {
    v_nap = v - v_half
	gates(v_nap)
	m' = (m_inf - m) / (tau_m / q10)
}

INITIAL {
    v_nap = v - v_half
	gates(v_nap)
	m = m_inf
}

: Procedures & functions
PROCEDURE gates(v_nap(mV)) {                                                    : computes gating functions and other constants at current v
    LOCAL alpha, beta                                                                        : call once from HOC to initialize inf at resting v
    TABLE m_inf, tau_m DEPEND celsius FROM -120 TO 80 WITH 200

    UNITSOFF

	tau_m = 0.05 :0.2                                                             : activation system
    :alpha = 0.182 * vtrap(v + 25 +13, 9)                                        : m system
	:beta  = 0.124 * vtrap(-(v + 25 +13), 9)
	:tau_m = 1 / (alpha + beta)
	m_inf = 1 / (1 + exp(-(v_nap) / stFact))
}

FUNCTION vtrap(x,y) {                                                       : traps for 0 in denominator of rate eqns.
        if (fabs(x/y) < 1e-6) {
                vtrap = y*(1 - x/y/2)
        }else{
                vtrap = x/(1 - exp(-x/y))
        }
}

UNITSON
