TITLE T-type Ca2+ current I_T

COMMENT
    Model described in [1] and maximal conductance adjusted to 2-10 nA. The
    time constants are adjusted to avoid progression to infinity at more
    negative Vm. This adjustment prevents artifacts of I_T surging when Vm
    is stepped from more positve to more negative Vm.

    References:
    [1] Williams, S.R., Toth, T.I., Turner, J.P., Hughes, S.W., Crunelli, V.
        The window component of the low threshold Ca2+ current produces
        input signal amplification and bistability in cat and rat
        thalamocortical neurones. Journal of Physiology, 505: 689-705, 1997.

    Written by Martynas Dervinis @Cardiff University, 2017.
   
ENDCOMMENT

NEURON {
	SUFFIX it
	USEION ca READ eca WRITE ica
	RANGE gcabar, m_inf, tau_m, shift_m, h_inf, tau_h, shift_h, adj
    RANGE tau_m_min, tau_h_min
}

UNITS {
	(mV) = (millivolt)
	(mA) = (milliamp)
    (mS) = (millisecond)
}

PARAMETER {
	v (mV)
	celsius	= 35 (degC)
    eca = 180 (mV)
	gcabar	= 0.001	(mho/cm2)
    adj = 1
    m_shift = 0 (mV)
    h_shift = 0 (mV)
    tau_m_min = 0 (mS)
    tau_h_min = 0 (mS)
}

STATE {
	m h
}

ASSIGNED {
	ica	(mA/cm2)
	m_inf
	tau_m (ms)
	h_inf
	tau_h (ms)
}

BREAKPOINT {
	SOLVE states METHOD cnexp
	ica = gcabar * m^3 * h * (v - eca)
}

INITIAL {
	gates(v)
	m = m_inf
    h = h_inf
}

DERIVATIVE states {
	gates(v)
    m' = (m_inf - m) / tau_m
	h' = (h_inf - h) / tau_h
}

: Procedures
PROCEDURE gates(v(mV)) {                                                    : computes gating functions and other constants at current v
                                                                            : call once from HOC to initialize inf at resting v
    LOCAL  q10
    TABLE m_inf, h_inf, tau_m, tau_h
        DEPEND celsius FROM -100 TO 100 WITH 200

    UNITSOFF
    q10 = 3^((celsius - 35) / 10)

    tau_m = (tau_m_min + 2.44 + 0.02506 * exp(-0.0984 * (v-m_shift))) / q10
    :if (adj && (v-m_shift) < -80) {
    :    tau_m = (tau_m_min + exp(((v-m_shift)+361.2)/66.6)) / q10
    :}
    if (adj && (v-m_shift) < -60) {
        tau_m = (tau_m_min + exp(((v-m_shift)+223.35)/66.6)) / q10
    }
    :tau_m = ( 0.612 + 1.0 / ( exp(-(v-m_shift+132)/16.7) + exp((v-m_shift+16.8)/18.2) ) ) / q10

    tau_h = (tau_h_min + 7.66 + 0.02868 * exp(-0.1054 * (v-h_shift))) / q10
    if (adj && (v-m_shift) < -80) {
        tau_h = exp(((v-h_shift)+408.8)/66.6) / q10
        :tau_h = exp(((v-h_shift)+413.4)/66.6) / q10
    }

    m_inf = 1 / (1 + exp(-((v-m_shift) + 63) / 7.8))
    h_inf = 1 / (1 + exp(((v-h_shift) + 83.5) / 6.3))
}

UNITSON