TITLE Cortical slow non-inactivating muscarine-sensitive K+ current I_M

COMMENT
    The model equations are the same as in [1] and is adaptation of [2].

    References:
    [1] Mainen, Z.F. and Sejnowski, T.J. Influence of dendritic structure
        on firing pattern in model neocortical neurons. Nature, 382: 363-
        366, 1996.
    [2] Yamada, W.M., Koch, C., and Adams, P.R. Multiple channels and
        calcium dynamics. In Methods in Neuronal Modeling, ed. Segev, I.
        and Koch, C., pp. 97-133. MIT Press, MA, USA, 1989.

    Written by Martynas Dervinis @Cardiff University, 2014.

ENDCOMMENT

NEURON {
	SUFFIX im
	USEION k READ ek WRITE ik
	RANGE ek, gkbar, n_inf, tau_n, q10
}

UNITS {
	(mA) = (milliamp)
	(mV) = (millivolt)
}

PARAMETER {
	gkbar = 0.1E-4 (mho/cm2)
	ek    = -90 (mV)
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
    gates(v)
	n = n_inf
}

DERIVATIVE states {
    gates(v)
	n' = (n_inf - n) / (tau_n / q10)
}

PROCEDURE gates(v(mV)) {                                                    : computes I_M gating functions and other constants at current v
                                                                            : call once from HOC to initialize inf at resting v
    LOCAL  alpha, beta
    TABLE n_inf, tau_n
        DEPEND celsius FROM -120 TO 80 WITH 200

    UNITSOFF

	alpha = 1E-4 * vtrap(v + 30, 9)                                         : n system
	beta  = 1E-4 * vtrap(-(v + 30), 9)
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
