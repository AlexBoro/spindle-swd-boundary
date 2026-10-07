TITLE Slow Ca2+-dependent non-specific cation current

COMMENT
    Model based on a first order kinetic scheme:
        <closed> + n cai <-> <open>	(alpha,beta)
    
    Following this model, the activation fct will be half-activated at a
    concentration of cai = (beta/alpha)^(1/n) = cac (parameter). The mod
    file is here written for the case n = 2 (2 binding sites). With a few
    changes this is based on ref [1].

    The model also has Vm-dependence based on refs [2-3].

    The current also has an inactivation variable. It allows the
    implementation of the intrinsic slow (<1 Hz) oscillation in thalamic
    cells based on I_Twindow and I_CAN. Absence of this property dampens
    the oscillation because the current is too strong at the onset of the
    down-state.

    This current has the following properties:
        - inward current (non specific for cations Na+, K+, Ca2+, ...)
        - activated by intracellular calcium
        - inactivated by intracellular calcium
        - voltage dependent
        - minimal value for the time constant of Ca2+-dependence
        - fast voltage-dependent activation kinetics

    References:
    [1] Destexhe, A., Contreras, A., Sejnowski, T.J., Steriade, M. A model
        of spindle rhythmicity in the isolated thalamic reticular nucleus.
        The journal of neurophysiology, 72: 803-818, 1994.
    [2] Kolaj, M., Zhang, L., Renaud, L.P. Novel coupling between TRPC-like
        and KNa channels modulates low threshold spike-induced
        afterpotentials in rat thalamic midline neurons. Neuropharmacology,
        86: 88-96, 2014.
    [3] Zhang, L., Kolaj, M., Renaud, L.P. Endocannabinoid 2-AG and
        intracellular cannabinoid receptors modulate a low-threshold
        calcium spike-induced slow depolarizing afterpotential in rat
        thalamic paraventricular nucleus neurons. 322: 308-319, 2016.

    Written by Martynas Dervinis @Cardiff University, 2017.

ENDCOMMENT

NEURON {
	SUFFIX icanmNRT
	USEION n READ en WRITE in VALENCE 1
	USEION ca READ cai
    RANGE gbar, mCa_inf, tau_mCa, beta, cac, taumin, inact, tau_hCa, n
    RANGE mVm_inf, tau_mVm
}


UNITS {
	(mA) = (milliamp)
	(mV) = (millivolt)
	(molar) = (1/liter)
	(mM) = (millimolar)
    (mS) = (millisecond)
}


PARAMETER {
	v                   (mV)
	celsius	= 37        (degC)
	en      = 10        (mV)		: reversal potential
	cai 	= 50e-6     (mM)		: initial [Ca]i
	gbar	= 0.00025   (mho/cm2)
    n       = 2                     : number of Ca2+ binding sites per gating variable
	beta	= 0.0001    (1/ms)		: backward rate constant
	cac     = 0.00025   (mM)		: middle point of activation fct
	taumin	= 0.1       (ms)		: minimal value of time constant
    tau_hCa = 1000      (ms)        : Ca2+-dependent inactivation time constant
    inact   = 1
: Slow rise and medium decay times:   n = 2, beta = 0.0001, cac = 0.00025
: Medium rise and slow decay times:   n = 4, beta = 0.0001, cac = 0.00025
: Medium rise and medium decay times: n = 4, beta = 0.0002, cac = 0.00025 (n = 2, beta = 0.0005, cac = 0.00025)
: Fast rise and fast decay times:     n = 4, beta = 0.0005, cac = 0.00025
}


STATE {
	mCa
    hCa
    :mVm
}

ASSIGNED {
	in      (mA/cm2)
	mCa_inf
	tau_mCa	(ms)
    hCa_inf
    mVm_inf
    tau_mVm
    q10
}

BREAKPOINT { 
	SOLVE states METHOD cnexp
	:in = gbar * mCa^2*mVm * (v - en)
    in = gbar * mCa^2 * hCa * (v - en)
}

DERIVATIVE states { 
	evaluate_fct(cai)
    mCa' = (mCa_inf - mCa) / tau_mCa
    inactivation(cai)
    hCa' = (hCa_inf - hCa) / tau_hCa
    :gates(v)
    :mVm' = (mVm_inf - mVm) / tau_mVm
}

INITIAL {
	q10 = 3.0 ^ ((celsius-22.0)/10)
	evaluate_fct(cai)
	mCa = mCa_inf
    inactivation(cai)
	hCa = hCa_inf
    :gates(v)
	:mVm = mVm_inf
}

UNITSOFF
PROCEDURE evaluate_fct(cai(mM)) {  LOCAL alpha2
	alpha2 = beta * (cai/cac)^n                 : sensitivity
	tau_mCa = 1 / (alpha2 + beta) / q10         : time constant
	mCa_inf = alpha2 / (alpha2 + beta)
    if(tau_mCa < taumin) { tau_mCa = taumin }   : min value of time cst
}

PROCEDURE gates(v(mV)) {	: computes gating functions and other constants at current v
    LOCAL  q10Vm, alphaV, betaV
    TABLE mVm_inf, tau_mVm DEPEND celsius FROM -120 TO 80 WITH 200

    q10Vm = 3.0 ^ ((celsius-22.0)/10)

	alphaV = 0.32 * vtrap(-66.58 - 3.5 - v, 4)     : activation system
	betaV = 0.28 * vtrap(39.58 + v + 3.5, 5)
	tau_mVm = (1 / (alphaV + betaV)) / q10Vm
	mVm_inf = 1 / (1 + exp(-(v + 53.87 + 3.5) / 3))
    : mVm_inf = 1 / (1 + exp(-(v + 53.87 + 3.5) / 1.5))
}

FUNCTION vtrap(x,y) {   : traps for 0 in denominator of rate eqns.
        if (fabs(x/y) < 1e-6) {
                vtrap = y*(1 - x/y/2)
        }else{
                vtrap = x/(exp(x/y) - 1)
        }
}

PROCEDURE inactivation(cai(mM)) {
    if (inact) {
        hCa_inf = 1/(1 + (cai/0.0002)^5)
    } else {
        hCa_inf = 1
    }
}

UNITSON