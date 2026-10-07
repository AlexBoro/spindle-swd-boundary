TITLE Fast transient potasium current (I_A) of thalamocortical relay cells

COMMENT
    The model is outlined in [1]. The specific conductances were estimated
    by matching the voltage clamp currents of the model thalamocortical
    (TC) relay cell with those observed experimentally by [2].

    References:
    [1] Huguenard, J.R., and McCormick, D.A. Simulation of the currents
        involved in rhythmic oscillations in thalamic relay neurons. Jounal
        of Neurophysiology 68: 1373-1383, 1992.
    [2] Huguenard, J.R., Coulter, D.A, and Prince, D.A. A fast transient
        potassium current in thalamic relay neurons: kinetics of activation
        and inactivation. Jounal of Neurophysiology 66: 1304-1315, 1991.

    Written by Martynas Dervinis @Cardiff University, 2013.

ENDCOMMENT

NEURON {
    SUFFIX ia
    USEION k READ ek WRITE ik
    RANGE gbar1, gbar2, g1, g2
}

UNITS {
    (S) = (siemens)
    (mV) = (millivolt)
    (mA) = (milliamp)
}

PARAMETER {
    v (mV)
    celsius  = 35 (degC)
    ek = -90 (mV)
    gbar1 = 1.9e-4 (S/cm2)	: the total g was in the range [11.2, 50 (nS)] with 30.6 being the mid-point. 
                            : So it needs to be adjusted accordingly.
    gbar2 = 1.26e-4 (S/cm2) : the total g was in the range [7.5, 33 (nS)] with 20.25 being the mid-point.
}                           : The ratio of the two conductances is 30.6:20.25 or 1.51:1

STATE {
    m1 m2 h1 h2
}

ASSIGNED {
    g1 (S/cm2)
    g2 (S/cm2)
    ik (mA/cm2)
    minf1
    minf2
    hinf
    mtau (ms)
    htau1 (ms)
    htau2 (ms)
}

BREAKPOINT {
    SOLVE states METHOD cnexp
    g1 = gbar1*m1^4*h1
    g2 = gbar2*m2^4*h2
    ik = (g1 + g2)*(v - ek)
}

INITIAL {
	gates(v)
	m1 = minf1
    m2 = minf2
	h1 = hinf
    h2 = hinf
}

DERIVATIVE states {  
    gates(v)
    m1' = (minf1 - m1) / mtau
    m2' = (minf2 - m2) / mtau
    h1' = (hinf - h1) / htau1
    h2' = (hinf - h2) / htau2
}

: Procedures
PROCEDURE gates(v(mV)) {	: computes gating functions and other constants at current v
    LOCAL  q10
    TABLE minf1, minf2, hinf, mtau, htau1, htau2
        DEPEND celsius FROM -120 TO 80 WITH 200

    UNITSOFF
    q10 = 3^((celsius - 23) / 10)

    mtau = (1 / (exp((v + 35.8) / 19.7) + exp((v + 79.7) / -12.7)) + 0.37) / q10 : activation system
    minf1 = 1 / (1 + exp(-(v + 60) / 8.5))
    minf2 = 1 / (1 + exp(-(v + 36) / 20))

    if (v < -63) {                                                          : inactivation system
        htau1 = (1 / (exp((v + 46) / 5) + exp((v + 238) / -37.5))) / q10
    } else {
        htau1 = 19 / q10
    }
    if (v < -73) {
        htau2 = htau1
    } else {
        htau2 = 60 / q10
    }
    hinf = 1 / (1 + exp((v + 78) / 6))
}

UNITSON