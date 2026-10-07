TITLE Cortical HH channels for action potential generation (I_Na + I_K(DR))

COMMENT
    The model equations are the same as in [1] and based on data in [2].
    The I_K(DR) here corresponds to I_Ks - a slow K+ current - which is
    likely to be compossed of currents mediated by at least a few voltage-
    activated K+ channels like regular delayed rectifier, D-type current [3],
    and/or possibly other slowly inactivating K+ currents. The shift
    parameters were introduced for the Na+ current in order to allow the
    hyperpolarisation of the voltage-dependence of Na+ current in the axo-
    somatic terminal as reported by [4] and [5].

    References:
    [1] Keren, N., Peled, N., and Korngreen, A. Constraining Compartmental
        Models Using Multiple Voltage Recordings and Genetic Algorithms.
        Journal of Neurophysiology, 94: 3730–3742, 2005.
    [2] Korngreen, A. and Sakmann, B. Voltage-gated K+ channels in layer 5
        neocortical pyramidal neurones from young rats: subtypes and
        gradients. Journal of Neurophysiology, 523: 621–639, 2000.
    [3] Bekkers, J.M. and Delaney, A.J. Modulation of excitability by alpha-
        dendrotoxin-sensitive potassium channels in neocortical pyramidal
        neurons. Neuroscience, 21: 6553–6560, 2001.
    [4] Colbert, C.M. and Pan, E. Ion channel properties underlying axonal
        action potential initiation in pyramidal neurons. Nature
        Neuroscience, 5: 533-538, 2002.
    [5] Kole, M.H.P., Ilschner, S.U., Kampa, B.M., Williams, S.R., Ruben,
        P.C., and Stuart, G. Action potential generation requires a high
        sodium channel density in the axon initial segment. Nature
        Neuroscience, 11: 178-186, 2008.

    Written by Martynas Dervinis @Cardiff University, 2014.

ENDCOMMENT

NEURON {
	SUFFIX hhCx3
	USEION na WRITE ina
	USEION k READ ek WRITE ik
	RANGE ena, ek, ik, gnabar, gkbar, m_inf, m_shift, h_inf, h_shift
    RANGE r_inf, s_inf, tau_m, tau_h, tau_r, tau_s1, tau_s2, q10, amptadj
}

UNITS {
	(mA) = (milliamp)
	(mV) = (millivolt)
}

PARAMETER {
	gnabar  = 0.25 (mho/cm2)
    gkbar   = 0.15 (mho/cm2)
	ena     = 50 (mV)
	ek      = -90 (mV)
    m_shift = 0 (mV)
    h_shift = 0 (mV)
    amptadj = 0                 : Adjust the amplitude depending on the temperature (0, 1)
}

STATE {
	m h r s1 s2
}

ASSIGNED {
    v (mV)
    celsius (degC)
	ina	(mA/cm2)
    ik	(mA/cm2)
	m_inf
	h_inf
    r_inf
    s_inf
    tau_m
    tau_h
    tau_r
    tau_s1
    tau_s2
    q10
}

BREAKPOINT {
    LOCAL q10amp

    q10 = 2.3^((celsius - 21) / 10)
    if (amptadj) {
        q10amp = q10
    } else {
        q10amp = 1
    }
	SOLVE states METHOD cnexp
	ina = q10amp * gnabar * m^3 * h * (v - ena)
    ik  = q10amp * gkbar * r^2 * 0.5 * (s1 + s2) * (v - ek)
}

INITIAL {
    gates(v)
	m  = m_inf
	h  = h_inf
    r  = r_inf
    s1 = s_inf
    s2 = s_inf
}

DERIVATIVE states {
    gates(v)
	m'  = (m_inf - m) / (tau_m / q10)
	h'  = (h_inf - h) / (tau_h / q10)
    r'  = (r_inf - r) / (tau_r / q10)
    s1' = (s_inf - s1) / (tau_s1 / q10)
    s2' = (s_inf - s2) / (tau_s2 / q10)
}

: Procedures & functions
PROCEDURE gates(v(mV)) {                                                    : computes channel gating functions and other constants at current v
                                                                            : call once from HOC to initialize inf at resting v
    LOCAL  alpha, beta
    TABLE m_inf, tau_m, h_inf, tau_h, r_inf, tau_r, s_inf, tau_s1, tau_s2
        DEPEND celsius FROM -120 TO 80 WITH 200

    UNITSOFF

    m_inf  = 1/ (1 + exp(-(v + 38 - m_shift)/10))                           : m system
    tau_m  = 0.058 + 0.114 * exp(-((v + 36 - m_shift)/28)^2)

    h_inf  = 1/ (1 + exp((v + 66 - m_shift)/6))                             : h system
    tau_h  = 0.28 + 16.7 * exp(-((v + 60 - m_shift)/25)^2)

    alpha  = 0.0052 * vtrap(v - 11.1, 13.1)                                 : r system
    beta   = 0.02 * exp(-(v + 1.27)/71) - 0.005
    r_inf  = alpha/(alpha + beta)
    tau_r  = 1/(alpha + beta)

    s_inf  = 1/(1 + exp((v + 58)/11))                                       : s system
    tau_s1 = 360 + (1010 + 23.7*(v + 54)) * exp(-((v + 75)/48)^2)
    tau_s2 = 2350 + 1380 * exp(-0.011 * v) - 210 * exp(-0.03 * v)
}

FUNCTION vtrap(x,y) {                                                       : traps for 0 in denominator of rate eqns.
        if (fabs(x/y) < 1e-6) {
                vtrap = y*(1 - x/y/2)
        }else{
                vtrap = x/(1 - exp(-x/y))
        }
}

UNITSON
