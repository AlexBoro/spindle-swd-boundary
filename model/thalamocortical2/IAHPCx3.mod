TITLE [Ca2+]-activated small conductance (SK) K+ current in NRT cells

COMMENT
    [Ca2+]-activated small conductance (SK) K+ current or slow
    afterhyperpolarisation current (I_AHP) in NRT cells

    The model is based on [1] which estimated the steady state activation
    curve of the SK1 and SK2 channels (both channels are expressed in NRT)
    and on [2] which identified fast and slow components of I_AHP in NRT
    cells and measured their decay time constants. The I_AHP model
    described here is non-specific and assumes two populations of distinct
    SK apamine-sensitive channels in NRT cells with distinct dynamics. The
    I_AHP model was calibrated to approximate the experimental data in [2].

    The model is expressed in terms of Hill equation.

    Written by Martynas Dervinis @ Cardiff University, 2013
        martynas.dervinis@gmail.com

    References:
    [1] Xia, X.-M., Fakler, B., Rivard, A., Wayman, G., Johnson-Pais, T.,
        Keen, J.E., Ishii, T., Hirschberg, B., Bond, C.T., Lutsenko, S.,
        Maylie, J., Adelman, J. P. Mechanism of calcium gating in small-
        conductance calcium-activated potassium channels. Nature, 396: 503-
        507, 1998.
    [2] Cueni, L., Canepari, M., Lujan, R., Emmenegger, Y., Watanabe, M.,
        Bond, C.T., Franken, P., Adelman, J. P., Luthi, A. T-type Ca2+
        channels, SK2 channels and SERCAs gate sleep-related oscillations
        in thalamic dendrites. Nature Neuroscience, 11: 683-692, 2008.

ENDCOMMENT

NEURON {
	SUFFIX iahpCx3
	USEION kb READ ekb WRITE ikb VALENCE 1
	USEION ca READ cai
    RANGE gkbar1, gkbar2, m1_inf, m2_inf, tau_m1_min, tau_m2_min, beta1, beta2, cac1, cac2, power, cainf
}


UNITS {
	(mA) = (milliamp)
	(mV) = (millivolt)
	(molar) = (1/liter)
	(mM) = (millimolar)
}


PARAMETER {
	v                   (mV)
	celsius	= 35        (degC)
	ekb     = -90       (mV)
	cai 	= 50e-6     (mM)        : initial [Ca2+]i
    cainf   = 0         (mM)
	gkbar1	= .01       (mho/cm2)
    gkbar2	= .001      (mho/cm2)
    cac1    = 0.00032   (mM)        : [Ca2+] at half activation of m1
    cac2    = 0.00032   (mM)        : [Ca2+] at half activation of m2
	power   = 5.3                   : Hill coefficient
    beta1   = 0.05      (1/ms)      : Disociation rate for the first receptor population
    beta2   = 0.0012    (1/ms)      : Disociation rate for the second receptor population
    tau_m1_min = 1      (ms)        : minimal activation time constant for m1
    tau_m2_min = 1      (ms)        : minimal activation time constant for m2
}


STATE {
	m1 m2
}

ASSIGNED {
	ikb     (mA/cm2)
	m1_inf
    m2_inf
    tau_m1
    tau_m2
	phi
}

BREAKPOINT { 
	SOLVE states METHOD cnexp
	ikb = (gkbar1 * m1 + gkbar2 * m2) * (v - ekb)
}

DERIVATIVE states { 
	activation(v, cai)
	m1' = (m1_inf - m1) / tau_m1
    m2' = (m2_inf - m2) / tau_m2
}

UNITSOFF
INITIAL {
    phi = 3 ^ ((celsius-34.25)/10)
	activation(v, cai)
	m1 = m1_inf
    m2 = m2_inf
}

PROCEDURE activation(v(mV), cai(mM)) {
    LOCAL caInc
    
    caInc = cai - cainf
    if (caInc < 0) {
    	caInc = 0
    }
	m1_inf = 1 / ((cac1 / caInc)^power + 1)
    m2_inf = 1 / ((cac2 / caInc)^power + 1)
    :tau_m1 = ((1/beta1) / ((caInc / cac1)^power + 1) / phi) + tau_m1_min
    :tau_m2 = ((1/beta2) / ((caInc / cac2)^power + 1) / phi) + tau_m2_min
    tau_m1 = tau_m1_min
    tau_m2 = tau_m2_min
}
UNITSON
