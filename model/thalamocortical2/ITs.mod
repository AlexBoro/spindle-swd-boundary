TITLE Low voltage activated T-type Ca2+ current in NRT (I_Ts)

COMMENT
    The model was first described in [1]. The time constants were measured
    in the experiments and functions approximating these time constants
    were provided in [2]. The inactivation time constant was corrected in
    order to get a better approximation of experimentally observed I-V
    curve.

    References:
    [1] Huguenard, J.R., Prince, D.A. A Novel T-type Current Underlies
        Prolonged Ca*+-dependent Burst Firing in GABAergic Neurons of Rat
        Thalamic Reticular Nucleus. Neuroscience, 12: 3804-3817, 1992.
    [2] Destexhe, A., Contreras, D., Steriade, M., Sejnowski, T. J.,
        Huguenard, J.R., In Vivo, In Vitro, and Computational Analysis of
        Dendritic Calcium Currents in Thalamic Reticular Neurons.
        Neuroscience, 16: 169-185, 1996.

    Written by Martynas Dervinis @ Cardiff University, 2013

ENDCOMMENT

NEURON {
	SUFFIX its
	USEION ca READ cai, cao WRITE ica
    USEION cahva READ cahvai VALENCE 2
	RANGE gcabar, mshift, hshift, km, kh, taum_shift, tauh_shift, speedUpm, speedUph, adj
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
	v                     (mV)
	celsius     = 35	  (degC)
	gcabar      = 0.00069 (mho/cm2)
	cai         = 50e-6   (mM)
	cao         = 1.5     (mM)
    cahvai      = 0       (mM)
    mshift      = 0       (mV)        : shift of activation steady state
	hshift      = 0       (mV)        : shift of inactivation steady state
    km          = 7.4
    kh          = 5
    taum_shift  = 0       (ms)
    tauh_shift  = 0       (ms)
    speedUpm    = 1
    speedUph    = 1
    adj         = 1
}

STATE {
	m h
}

ASSIGNED {
	ica     (mA/cm2)
	carev	(mV)
	m_inf
	tau_m	(ms)
	h_inf
	tau_h	(ms)
	phi
}

BREAKPOINT {
	SOLVE states METHOD cnexp
	carev = (1e3) * (R*(celsius+273.15))/(2*FARADAY) * log (cao/(cai+cahvai))
	ica = gcabar * m^2 * h * (v-carev)
}

DERIVATIVE states {
	gating(v)
	m' = (m_inf - m) / tau_m
	h' = (h_inf - h) / tau_h
}

UNITSOFF
INITIAL {
    phi = 3.0 ^ ((celsius-24)/10)
	gating(v)
	m = m_inf
	h = h_inf
}

PROCEDURE gating(v(mV)) { 
    m_inf = 1.0 / ( 1 + exp(-(v-mshift+50)/km) )
    h_inf = 1.0 / ( 1 + exp((v-hshift+78)/kh) )

    :if (v < -60+hshift) {
    :    tau_m = 10
    :} else {
    tau_m = (( 3 + taum_shift + 1.0 / ( exp((v-mshift+25)/10) + exp(-(v-mshift+100)/15) ) ) / phi)/speedUpm
    :}
	
    if (adj) {
        if (v < -40+hshift) {
            tau_h = ( 85 + tauh_shift + 1.0 / ( exp((v-hshift+46)/4) + exp(-(v-hshift+405)/50) ) ) / phi
        } else if (v < 40+hshift) {
            tau_h = (-1.05275*(v - hshift) + tauh_shift + 43.11) / phi
        } else {
            tau_h = (tauh_shift + 1) / phi
        }
    } else {
        tau_h = (( 85 + tauh_shift + 1.0 / ( exp((v-hshift+46)/4) + exp(-(v-hshift+405)/50) ) ) / phi)/speedUph
    }
}
UNITSON
