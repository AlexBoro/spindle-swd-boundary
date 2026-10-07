TITLE Cortical fast A-type K+ current I_A

COMMENT
    The model equations are the same as in [1].

    References:
    [1] Golomb, D. and Amitai, Y. Propagating Neuronal Discharges in
        Neocortical Slices: Computational and Experimental Study. Journal
        of Neurophysiology, 78: 1199-1211, 1997.

    Written by Martynas Dervinis @Cardiff University, 2014.

ENDCOMMENT

NEURON {
	SUFFIX iaCx3
	USEION k READ ek WRITE ik
	RANGE ek, gkbar, m_inf, h_inf, tau_h, q10
}

UNITS {
	(mA) = (milliamp)
	(mV) = (millivolt)
    (mS) = (millisecond)
}

PARAMETER {
	gkbar = 0.001 (mho/cm2)
	ek    = -90 (mV)
    tau_h = 15 (mS)
}

STATE {
	h
}

ASSIGNED {
    v (mV)
    celsius (degC)
	ik	(mA/cm2)
	m_inf
    h_inf
    q10
}

BREAKPOINT {
    q10 = 4^((celsius - 37) / 10)
	SOLVE states METHOD cnexp
	ik = q10 * gkbar * m_inf^3 * h * (v - ek)
}

INITIAL {
    gates(v)
	h = h_inf
}

DERIVATIVE states {
    gates(v)
	h' = (h_inf - h) / (tau_h / q10)
}

PROCEDURE gates(v(mV)) {                                                    : computes I_A gating functions and other constants at current v
                                                                            : call once from HOC to initialize inf at resting v
    TABLE m_inf, h_inf
        DEPEND celsius FROM -120 TO 80 WITH 200

    UNITSOFF

	m_inf = 1/(1 + exp(-(v + 50)/20))
    h_inf = 1/(1 + exp((v + 80)/6))
}

UNITSON
