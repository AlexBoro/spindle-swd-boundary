TITLE Cortical fast K+ channels also known as I_A channels

COMMENT
    The model equations are the same as in [1] and based on data in [2].

    References:
    [1] Keren, N., Peled, N., and Korngreen, A. Constraining Compartmental
        Models Using Multiple Voltage Recordings and Genetic Algorithms.
        Journal of Neurophysiology, 94: 3730–3742, 2005.
    [2] Korngreen, A. and Sakmann, B. Voltage-gated K+ channels in layer 5
        neocortical pyramidal neurones from young rats: subtypes and
        gradients. Journal of Neurophysiology, 523: 621–639, 2000.

    Written by Martynas Dervinis @Cardiff University, 2014.

ENDCOMMENT

NEURON {
	SUFFIX ikf
	USEION k READ ek WRITE ik
	RANGE ek, ik, gkbar, a_inf, b_inf, tau_a, tau_b, q10, amptadj
}

UNITS {
	(mA) = (milliamp)
	(mV) = (millivolt)
}

PARAMETER {
	gkbar   = 0.1 (mho/cm2)
	ek      = -90 (mV)
    amptadj = 0                 : Adjust the amplitude depending on the temperature (0, 1)
}

STATE {
	a b
}

ASSIGNED {
    v (mV)
    celsius (degC)
	ik	(mA/cm2)
	a_inf
    b_inf
    tau_a
    tau_b
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
	ik = q10amp * gkbar * a^4 * b * (v - ek)
}

INITIAL {
    gates(v)
	a  = a_inf
    b  = b_inf
}

DERIVATIVE states {
    gates(v)
	a'  = (a_inf - a) / (tau_a / q10)
    b'  = (b_inf - b) / (tau_b / q10)
}

: Procedures & functions
PROCEDURE gates(v(mV)) {                                                    : computes channel gating functions and other constants at current v
                                                                            : call once from HOC to initialize inf at resting v
    TABLE a_inf, tau_a, b_inf, tau_b
        DEPEND celsius FROM -120 TO 80 WITH 200

    UNITSOFF

    a_inf  = 1/ (1 + exp(-(v + 47)/29))                                     : a system
    tau_a  = 0.34 + 0.92 * exp(-((v + 71)/59)^2)

    b_inf  = 1/ (1 + exp((v + 66)/10))                                      : b system
    tau_b  = 8 + 49 * exp(-((v + 73)/23)^2)
}

UNITSON
