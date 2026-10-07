TITLE Na+-activated K+ current I_K[Na] in cortical and NRT cells

COMMENT
    The model equations are the same as in [1].

    References:
    [1] Bischoff, U., Vogel, W., and Safranov, B.V.Na+-activated K+
        channels in small dorsal root ganglion neurones of rat. Journal of
        Physiology, 510.3: 743—754, 1998.

    Written by Martynas Dervinis @Cardiff University, 2017.

ENDCOMMENT

NEURON {
	SUFFIX iknaThCx
	USEION k READ ek WRITE ik
    USEION na READ nai
	RANGE ek, gkbar, w_inf, nai_half, q10
}

UNITS {
	(molar)	= (1/liter)
	(mM)	= (millimolar)
	(mA) 	= (milliamp)
	(mV) 	= (millivolt)
}

PARAMETER {
	gkbar = 0.00133 (mho/cm2)
	ek    = -90     (mV)
    nai	  = 10      (mM)
    nai_half = 38.7   (mM)
    nai_exp = 3.5
}

ASSIGNED {
    v (mV)
    celsius (degC)
	ik	(mA/cm2)
	w_inf
    q10
}

BREAKPOINT {
    q10 = 2.3^((celsius - 37) / 10)
    w_inf = 1/(1 + (nai_half/nai)^nai_exp)
    ik = q10 * gkbar * w_inf * (v - ek)
}
