TITLE Anomalous rectifier current I_h in TC and NRT neurons

COMMENT
    Anomalous rectifier or hyperpolarisation activated (Na+/K+) current I_h

    The model is expressed in the most general form so that it could be
    adapted for different type of neurons in the thalamocortical circuit:
    TC, NRT, and cortical cells.

    The TC version of the model could be found in [1] with its experimental
    characterisation found in [2]. The effects of diffuse neuromodulatory
    systems on the I_h TC neurons have been described in [3]. The specific
    values of parameters are:
    -   V_half = -75 mV;
    -   s = 5.5 mV/pA;

    The NRT version of the model is given by [4] with time constant
    available both in [4] and [5]. The specific values of parameters are:
    -   V_half = -106 mV;
    -   s = 9 mV/pA;
    Note the hyperpolarising shift of ~30 mV in NRT cells relative to TC.
    The same study [4] also reported a similar shift in TC cells relative
    to previous estimates. This could be a result of experimental
    conditions since it is known that in the presence of cAMP I_h channels
    shift their activation voltage dependence.

    Finally, the model includes time constant adjustment (optional)
    positively shifting and slowing down the activation time constant as
    described in [6].

    References:
    [1] Huguenard, J.R., McCormick, D.A. Simulation of the currents
        involved in rhythmic oscillations in thalamic relay neurons.
        Journal of Neurophysiology. 68: 1373-1383, 1992.
    [2] McCormick, D.A., Pape, H.-C. Properties of a hyperpolarization-
        activated cation current and its role in rhythmic oscillation in
        thalamic relay neurones. Journal of Physiology. 431: 291-318, 1990.
    [3] McCormick, D.A., Pape, H.-C. Noradrenergic and serotonergic
        modulation of a hyperpolarization-activated cation current in
        thalamic relay neurones. Journal of Physiology. 431: 319-342, 1990.
    [4] Rateau, Y., Ropert, N. Expression of a functional hyperpolarization-
        activated current (Ih) in the mouse nucleus reticularis thalami.
        Journal of Neurophysiology. 95: 3073-3085, 2006.
    [5] Abbas, S.Y., Ying, S.-W., Goldstein, P.A. Compartmental
        distribution of hyperpolarization-activated cyclic-nucleotide-gated
        channels 2 and 4 in thalamic reticular and thalamocortical relay
        neurons. Neuroscience. 141: 1811-1825, 2006.
    [6] Soltesz, I., Lightowler, S., Leresche, N., Jassik-Gerschenfeld, D.,
        Pollard, C.E., Crunelli, V. The inward currents and the
        transformation of low-frequency oscillations of rat and cat
        thalamocortical cells. Journal of Physiology. 441:175-197, 1991.

    Written by Martynas Dervinis @ Cardiff University, 2017.

ENDCOMMENT

NEURON {
	SUFFIX iarreg
	USEION h READ eh WRITE ih VALENCE 1
    RANGE ghbar, V_half, s, tau_min, shift, adj
}

UNITS {
	(mA) 	= (milliamp)
	(mV) 	= (millivolt)
}


PARAMETER {
	eh      = -40	 (mV)
	celsius = 35	 (degC)
	ghbar	= 0.00047 (mho/cm2)
    V_half  = -75     (mV)
    s       = 5.5
    tau_min = 20     (ms)
    shift   = 0      (mV)
    adj     = 0
}


STATE {
	m
}


ASSIGNED {
	v	  (mV)
	ih    (mA/cm2)
	m_inf
    tau_m (ms)
	phi
}


BREAKPOINT {
	SOLVE states METHOD cnexp
	ih = ghbar * m * (v - eh)
}

DERIVATIVE states {
	gates(v)
	m' = (m_inf - m) / tau_m
}

UNITSOFF
INITIAL {
    phi = 3.0 ^ ((celsius-36 (degC) )/10 (degC) )
	gates(v)
	m = m_inf
}

PROCEDURE gates(v(mV)) {
    m_inf = 1 / (1 + exp((v-(V_half+shift))/s))
	if (!adj) {
        tau_m = (tau_min + 1000 / ( exp((v+71.5-shift)/14.2) + exp(-(v+89-shift)/11.6) ) ) / phi
    } else {
        tau_m = (6600 / ( exp((v+71.5-27.5)/14.2) + exp(-(v+89-27.5)/11.6) ) ) / phi
    }
}
UNITSON
