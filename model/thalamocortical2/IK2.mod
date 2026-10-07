TITLE Slowly inactivating K+ current (I_K2) of thalamocortical relay cells

COMMENT
    Low TEA sensitive. The model is outlined by [1]. The specific
    conductances were estimated by matching the voltage clamp currents of
    the model thalamocortical (TC) relay cell with those observed
    experimentally by [2].

    References:
    [1] Huguenard, J.R., and McCormick, D.A. Simulation of the currents
        involved in rhythmic oscillations in thalamic relay neurons. Jounal
        of Neurophysiology 68: 1373-1383, 1992.
    [2] Huguenard, J.R., and Prince, D.A. Slow inactivation of a
        TEA-sensitive K current in acutely isolated rat thalamic relay
        neurons. Jounal of Neurophysiology 66: 1316-1328, 1991.

    Written by Martynas Dervinis @Cardiff University, 2013.

ENDCOMMENT

NEURON {
    SUFFIX ik2
    USEION k READ ek WRITE ik
    RANGE gbar, g1, g2, fact1, fact2
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
    fact1 = 0.6
    fact2 = 0.4
}

STATE {
    m h1 h2
}

ASSIGNED {
    g1 (S/cm2)
    g2 (S/cm2)
    ik (mA/cm2)
    minf
    hinf
    mtau (ms)
    htau1 (ms)
    htau2 (ms)
}

BREAKPOINT {
    SOLVE states METHOD cnexp
    g1 = fact1*gbar*m*h1
    g2 = fact2*gbar*m*h2
    ik = (g1 + g2)*(v - ek)
}

INITIAL {
	gates(v)
	m = minf
	h1 = hinf
    h2 = hinf
}

DERIVATIVE states {  
    gates(v)
    m' = (minf - m) / mtau
    h1' = (hinf - h1) / htau1
    h2' = (hinf - h2) / htau2
}

: Procedures
PROCEDURE gates(v(mV)) {	: computes gating functions and other constants at current v
    LOCAL q10
    TABLE minf, hinf, mtau, htau1, htau2
        DEPEND celsius FROM -120 TO 80 WITH 200

    UNITSOFF
    q10 = 3^((celsius - 22) / 10)

    mtau = (1 / (exp((v - 81) / 25.6) + exp((v + 132) / -18)) + 9.9) / q10  : activation system
    minf = (1 / (1 + exp(-(v + 43) / 17)))^4

    htau1 = (1 / (exp((v - 1329) / 200) + exp((v + 130) / -7.1)) + 120) / q10 : inactivation system
    if (v < -70) {
        htau2 = htau1
    } else {
        htau2 = 8900 / q10
    }
    hinf = 1 / (1 + exp((v + 58) / 10.6))
}

UNITSON