TITLE Persistent Ca2+ sensitive K+ current (I_K1) of thalamocortical relay cells

COMMENT
    Highly TEA sensitive. The model is outlined by [1]. The maximal current
    should be 13 to 17 times smaller than that of I_K2 as reported in [1].
    Note that the [Ca2+]_i sensitivity is absent in the actual model for
    reasons of simplification.

    References:
    [1] Huguenard, J.R., and Prince, D.A. Slow inactivation of a
        TEA-sensitive K current in acutely isolated rat thalamic relay
        neurons. Jounal of Neurophysiology 66: 1316-1328, 1991.

    Written by Martynas Dervinis @Cardiff University, 2013.

ENDCOMMENT

NEURON {
    SUFFIX ik1
    USEION k READ ek WRITE ik
    RANGE gbar, taum
}

UNITS {
    (S) = (siemens)
    (mV) = (millivolt)
    (mA) = (milliamp)
}

PARAMETER {
    v (mV)
    celsius = 35 (degC)
    ek = -90 (mV)
    gbar = 0.0001 (S/cm2)
    taum = 2.5
}

STATE {
    m
}

ASSIGNED {
    ik (mA/cm2)
    minf
    mtau (ms)
}

BREAKPOINT {
    SOLVE states METHOD cnexp
    ik = gbar*m*(v - ek)
}

INITIAL {
	gates(v)
	m = minf
}

DERIVATIVE states {  
    gates(v)
    m' = (minf - m) / mtau
}

: Procedures
PROCEDURE gates(v(mV)) {	: computes gating functions and other constants at current v
    LOCAL q10
    TABLE minf, mtau DEPEND celsius FROM -120 TO 80 WITH 200

    UNITSOFF
    q10 = 3^((celsius - 22) / 10)

    mtau = taum :(1 / (exp((v - 81 - 7) / 25.6) + exp((v + 132 - 7) / -18)) + 9.9) / q10  : activation system
    minf = 1 / (1 + exp(-(v + 5) / 8.6))
}

UNITSON