TITLE Ca2+ activated fast transient potassium (K+) current I_C

COMMENT
    Equations for this current are taken from [1] and [2].
    
    References:
    [1] McCormick, D.A. and Huguenard, J.R. A model of the
        electrophysiological properties of thalamocortical relay neurons.
        Jounal of Neurophysiology 68: 138a-1400, 1992.
    [2] Yamada, W.M., Koch, C., and Adams, P. Multiple channels and calcium
        dynamics. In: Methods in Neuronal Modeling. From Synapses to
        Networks, edited by C. Koch and I. Segev. Cambridge, MA: MIT Press,
        1989, p. 97-133.

    Written by Martynas Dervinis @Cardiff University, 2014.

ENDCOMMENT

NEURON {
    SUFFIX ic
    USEION k READ ek WRITE ik
	USEION ca READ cai
    RANGE gkbar, m_inf, q10, castate
}

UNITS {
	(molar)	= (1/liter)
	(mM)	= (millimolar)
	(mA) 	= (milliamp)
	(mV) 	= (millivolt)
}

PARAMETER {
	ek	= -95	(mV)
	celsius = 35	(degC)
    tau_m = 2.5 (mS)
	gkbar	= 0.0001 (mho/cm2)
}

STATE {
	m
}

ASSIGNED {
	v	(mV)
	cai	(mM)
    q10
    m_inf
    castate
    gc (mho/cm2)
	ik	(mA/cm2)
}

BREAKPOINT {
	SOLVE states METHOD cnexp
    castate = (cai - 0.00005) / 0.0025
    if (castate < 1) {
        gc = gkbar * castate
    } else {
        gc = gkbar
    }
	ik = gc * m * (v - ek)
}

INITIAL {
	gates(v)
	m = m_inf
}

DERIVATIVE states {  
    gates(v)
    m' = (m_inf - m) / (tau_m / q10)
}

: Procedures

PROCEDURE gates(v(mV)) {                                                    : computes gating functions and other constants at current v
                                                                            : call once from HOC to initialize inf at resting v
    TABLE m_inf DEPEND celsius FROM -120 TO 80 WITH 200

    UNITSOFF
    q10 = 3^((celsius - 35) / 10)
                                                       
    m_inf = 1 / (1 + exp(-(v + 30) / 5))                                    : activation system
}

UNITSON