TITLE Ca2+ activated non-specific cation current I_CAN

COMMENT
    A Ca2+ activated non-specific cation current I_CAN in TC and NRT cells.

    The model was originally desribed in [1]. However, the parameters k1
    and k2 were adjusted to match experimental data of [1] more closely
    with the current TC model.

    References:
    [1] Hughes, S.W., Cope, D.W., Blethyn, K.L., Crunelli, V. Cellular
        mechanisms of the slow (<1 Hz) oscillation in thalamocortical
        neurons in vitro. Neuron, 33: 947-958, 2002.

    Written by Martynas Dervinis @Cardiff University, 2013.
    
ENDCOMMENT

NEURON {
    SUFFIX ican
    USEION n READ en WRITE in VALENCE 1
	USEION ca READ cai
    RANGE gnbar, o
	GLOBAL k1, k2, k3, k4, nca
}

UNITS {
	(molar)	= (1/liter)
	(mM)	= (millimolar)
	(mA) 	= (milliamp)
	(mV) 	= (millivolt)
	(msM)	= (ms mM)
}

PARAMETER {
	en	= 10            (mV)
	celsius = 35        (degC)
    cai	= 50e-6         (mM)
	gnbar	= 0.00025   (mho/cm2)
	k1 = 1.25e7         (msM)
    k2 = 2e-4           (1/ms)
    k3 = 0.075          (1/ms)
    k4 = 0.00075        (1/ms)
    nca = 4
}

STATE {
	p0	: unbound Ca2+ binding protrein
	p1	: bound Ca2+ binding protrein
	c	: closed state of the I_CAN channel
	o	: open state of the I_CAN channel
}

ASSIGNED {
	v	(mV)
	in	(mA/cm2)
    q10
    kf1 (1/ms)
    kf2 (1/ms)
    kf3 (1/ms)
    kf4 (1/ms)
}

BREAKPOINT {
	SOLVE inkin METHOD sparse
	in = gnbar * o * (v - en)
}

INITIAL {
	p0 = 1
	p1 = 0
	c = 1
	o = 0
    SOLVE inkin STEADYSTATE sparse
}

KINETIC inkin {
    q10 = 3^((celsius - 35 (degC) ) / 10 (degC) )
    rates(q10)
	~ p0      <-> p1	(kf1,kf2)
	~ c + p1  <-> o		(kf3,kf4)
	CONSERVE p0 + p1 = 1
	CONSERVE c + o = 1
}

: Procedures
PROCEDURE rates(q10) {
    kf1 = q10*k1*cai^nca
    kf2 = q10*k2
    kf3 = q10*k3
    kf4 = q10*k4
}
