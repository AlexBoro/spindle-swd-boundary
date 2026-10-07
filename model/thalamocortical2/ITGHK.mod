TITLE Low voltage-activated T-type Ca2+ current in thalamocortical cells

COMMENT
    Ca2+ current responsible for low threshold spikes (LTS)
 
    The model is based on [1] and its implementation is taken from [2]. The
    kinetics is described by Goldman-Hodgkin-Katz equations, using an m2h
    format, according to the voltage-clamp data (whole cell patch clamp) of
    [3]. The temperature dependence is taken from [4]. In addition, the
    model is extended to include an adjusted activation time constant
    required in case when the window current is increased in order to
    reduce the subthreshold oscillations.
 
    The model includes:
        - mshift parameter for shifting voltage dependcies related to the
          activation of the system
        - hshift parameter for shifting voltage dependcies related to the
          inactivation of the system
        - SDfactor parameter for adjusting the tau_m constant
    
    References:
    [1] Huguenard, J.R., and McCormick, D.A. Simulation of the currents
        involved in rhythmic oscillations in thalamic relay neurons. Jounal
        of Neurophysiology, 68: 1373-1383, 1992.
    [2] Destexhe, A., Neubig, M., Ulrich, D., and Huguenard, J.R. Dendritic
        low-threshold calcium currents in thalamic relay cells. Journal of
        Neuroscience, 18: 3574-3588, 1998.
    [3] Huguenard, J.R., and Prince, D.A. A Novel T-type Current Underlies
        Prolonged Ca2+-dependent Burst Firing in GABAergic Neurons of Rat
        Thalamic Reticular Nucleus. Journal of Neuroscience, 12: 3804-3817,
        1992.
    [4] Coulter, D.A., Huguenard, J.R., and Prince, D.A. Calcium currents
        in rat thalamocortical relay neurons: Kinetic properties of the
        transient, low-threshold current. Journal of Physiology, 414:
        587-604, 1989.

    Written by Martynas Dervinis @Cardiff University, 2013.

ENDCOMMENT

NEURON {
	SUFFIX itGHK
	USEION ca READ cai, cao WRITE ica
	RANGE pcabar, m_inf, km, tau_m, tau_m_min, tau_m_mean, tau_m_peak, mshift, adj
    RANGE h_inf, kh, tau_h, tau_h_min, hshift
}

UNITS {
	(molar) = (1/liter)
	(mV) =	(millivolt)
	(mA) =	(milliamp)
	(mM) =	(millimolar)
	FARADAY = (faraday) (coulomb)
	R = (k-mole) (joule/degC)
}

PARAMETER {
	v                   (mV)
	celsius	= 35        (degC)
	pcabar	= 8.8e-5	(cm/s)      : maximum permeability of the 1st population of channels
	mshift	= 0         (mV)        : shift of activation steady state
	hshift = 0          (mV)        : shift of inactivation steady state
    km = 6.2
    kh = 4
	cai	= 50e-6         (mM)
	cao	= 1.5           (mM)
    tau_m_min = 0
    tau_h_min = 0
    adj = 0
    tau_m_mean = -55
    tau_m_peak = 20
}

STATE {
	m h
}

ASSIGNED {
	ica     (mA/cm2)
	m_inf
	tau_m	(ms)
	h_inf
	tau_h	(ms)
	phi
}

BREAKPOINT {
	SOLVE states METHOD cnexp
	ica = pcabar * m^2*h * ghk(v, cai, cao)
}

DERIVATIVE states {
	gating(v)
	m' = (m_inf - m) / tau_m
    h' = (h_inf - h) / tau_h
}


UNITSOFF
INITIAL {
	phi = 3 ^ ((celsius-24)/10)
	gating(v)
	m = m_inf
	h = h_inf
}

PROCEDURE gating(v(mV)) {
:   Comment left from the previous implementation of the model by Alain
:   Destexhe:
:       - The activation functions were estimated by John Huguenard. The
:         V_1/2 were of -57 and -81 in the vclamp simulations, and -60 and
:         -84 in the current clamp simulations.
:
:         The activation function were empirically corrected in order to
:         account for the contamination of inactivation. Therefore the
:         simulations using these values reproduce more closely the voltage
:         clamp experiments.
:
:         (cfr. Huguenard & McCormick, J Neurophysiol, 1992).
:
	m_inf = 1.0 / ( 1 + exp(-(v-mshift+57)/km) )
	h_inf = 1.0 / ( 1 + exp((v-hshift+81)/kh) )
    if (adj) {
        if (v <= tau_m_mean) {
            tau_m = 3.5 + (tau_m_peak-3.5)*exp(-((v-tau_m_mean)^2)/(2*5^2))
        } else {
            tau_m = 0.5 + (tau_m_peak-0.5)*exp(-((v-tau_m_mean)^2)/(2*5^2))
        }
    } else {
        tau_m = tau_m_min + ( 0.612 + 1.0 / ( exp(-(v-mshift+132)/16.7) + exp((v-mshift+16.8)/18.2) ) ) / phi
    }
    if( (v-hshift) < -80) {
		tau_h = tau_h_min + (exp((v-hshift+467)/66.6)) / phi
	} else {
		tau_h = tau_h_min + ( 28 + exp(-(v-hshift+22)/10.5) ) / phi
	}
}

FUNCTION ghk(v(mV), ci(mM), co(mM)) (.001 coul/cm3) {
	LOCAL z, eci, eco
	z = (1e-3)*2*FARADAY*v/(R*(celsius+273.15))
	eco = co*efun(z)
	eci = ci*efun(-z)
	ghk = (.001)*2*FARADAY*(eci - eco)
}

FUNCTION efun(z) {
	if (fabs(z) < 1e-4) {
		efun = 1 - z/2
	}else{
		efun = z/(exp(z) - 1)
	}
}
UNITSON
