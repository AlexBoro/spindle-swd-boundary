TITLE Cortical outward rectifier K+ current

COMMENT
    The model equations are the same as in [1].

    References:
    [1] Stern, E.A., Kincaid, A.E., and Wilson, C.J. Spontaneous
        Subthreshold Membrane Potential Fluctuations and Action
        Potential Variability of Rat Corticostriatal and Striatal Neurons
        In Vivo. Journal of Neurophysiology, 77:1697-1715, 1997.

    Written by Martynas Dervinis @Cardiff University, 2014.

ENDCOMMENT

NEURON {
	SUFFIX ior
	USEION k READ ek WRITE ik
	RANGE ek, gkbar, alpha, beta, tau_max, q10
}

UNITS {
	(mA) = (milliamp)
	(mV) = (millivolt)
    (mS) = (millisecond)
}

PARAMETER {
	gkbar   = 0.002 (mho/cm2)
	ek      = -90 (mV)
    tau_max = 5 (mS)
}

STATE {
	n
}

ASSIGNED {
    v (mV)
    celsius (degC)
	ik	(mA/cm2)
	alpha
    beta
    q10
}

BREAKPOINT {
    q10 = 3^((celsius - 37) / 10)
	SOLVE states METHOD cnexp
	ik = q10 * gkbar * n^3 * (v - ek)
}

INITIAL {
    gates(v)
	n = alpha / (alpha + beta)
}

DERIVATIVE states {
    gates(v)
	n' = (-(alpha + beta) * n + alpha) / q10
}

PROCEDURE gates(v(mV)) {                                                    : computes I_AR gating functions and other constants at current v
                                                                            : call once from HOC to initialize inf at resting v
    TABLE alpha, beta
        DEPEND celsius FROM -120 TO 80 WITH 200

    UNITSOFF

	alpha = -10/tau_max * vtrap(v + 40 - 0.049, 0.1)
    beta = 0.17/tau_max * exp(-(v + 40 - 0.011)/0.01)
}

FUNCTION vtrap(x,y) {                                                       : traps for 0 in denominator of rate eqns.
        if (fabs(x/y) < 1e-6) {
                vtrap = y*(1 - x/y/2)
        }else{
                vtrap = x/(1 - exp(-x/y))
        }
}

UNITSON
