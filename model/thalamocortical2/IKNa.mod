TITLE Na+ activated K+ current I_K[Na]

COMMENT
    The model of the current was taken from [1]. The intracellular [Na+]
    steady state binding curve was repalaced with the one that more closely
    resembles experimental data obtained in the mammalian nervous system.

    References:
    [1] Dale, N.  A large, sustained Na(+)- and voltage-dependent K+
        current in spinal neurons of the frog embryo. Journal of physiology,
        462: 349-372.

    Written by Martynas Dervinis @Cardiff University, 2013.
    
ENDCOMMENT

NEURON {
    SUFFIX ikna
    USEION k READ ek WRITE ik
	USEION na READ nai
    RANGE gkbar, shift_p, shift_n, inactRate, vDep, naDep, inact, p
}

UNITS {
	(molar)	= (1/liter)
	(mM)	= (millimolar)
	(mA) 	= (milliamp)
	(mV) 	= (millivolt)
}

PARAMETER {
	ek	= -90        (mV)
	celsius = 35	 (degC)
    nai = 10         (mM)
	gkbar	= 0.0001 (mho/cm2)
    shift_p = 0      (mM)
    shift_n = 0      (mV)
    inactRate = 12
    vDep = 1
    naDep = 1
    inact = 1
}

STATE {
	n
}

ASSIGNED {
	v       (mV)
	ik      (mA/cm2)
    p
    n_inf
    tau_n
    hres_inf
}

BREAKPOINT {
    bind(nai)
	SOLVE states METHOD cnexp
    inactgates(nai, v)
	ik = gkbar * p * n^4 * hres_inf * (v - ek)
}

DERIVATIVE states {
	actgates(v)
	n' = (n_inf - n) / tau_n
}

INITIAL {
    bind(nai)
    inactgates(nai, v)
    n = n_inf
}

: Procedures
UNITSOFF
PROCEDURE bind(nai(mM)) {
    if (naDep) {
        :p = (nai / (7.3 + shift_p))^4.6 / (1 + (nai / (7.3 + shift_p))^4.6)
        p = 1/(1 + ((50 + shift_p)/nai)^2.5)
    } else {
        p = 1
    }
}

PROCEDURE actgates(v(mV)) {                                                 : computes gating functions and other constants at current v
                                                                            : call once from HOC to initialize inf at resting v
    LOCAL  q10, alpha, beta
    TABLE n_inf, tau_n DEPEND celsius FROM -120 TO 80 WITH 200

    q10 = 3^((celsius - 22) / 10)

    :alpha = (-0.0033*(v - shift_n + 30)) / vtrap(1 - exp((v - shift_n + 30) / -3.6))
    alpha = (0.0033*(v - shift_n + 30)) / vtrap(1 - exp((v - shift_n + 30) / -3.6))
    beta = 0.52 / vtrap(1 + exp((v - shift_n - 18) / 7))
    if (vDep) {
        n_inf = alpha / (alpha + beta)
    } else {
        n_inf = 1
    }
    tau_n = (1 / (alpha + beta)) / q10
}

PROCEDURE inactgates(nai(mM), v(mV)) {
    if (inact) {
        hres_inf = 1 / (1 + 6.33 * nai * exp((v - 41) / inactRate))         : inactivation system
    } else {
        hres_inf = 1
    }
}

FUNCTION vtrap(x) {                                                         : traps for 0 in denominator of rate eqns.
        if (fabs(x) < 1e-6) {
                vtrap = 1e-6
        } else {
                vtrap = x
        }
}
UNITSON
