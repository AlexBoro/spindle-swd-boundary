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

    Hence, the model includes I_h [Ca2+]-dependence (modified from [6]) in
    addition to its regular voltage dependence. The [Ca2+]-dependence
    parameters are as follows:
    -   k1:	the rate constant of Ca2+ binding to the calcium-binding (CB)
            protein;
    -   k2:	this rate constant is the inverse of the real time constant of 
            the binding of Ca2+ to the CB protein;
	-   cac: the half activation (affinity) of the CB protein;
    -   nca: number of binding sites of Ca2+ on CB protein (usually 4);
    -   k3:	the rate constant of open h channels turning into CB
            ptorein-bound open form with increased conductance;
    -   k4:	this rate constant is the inverse of the real time constant of 
            open h channels turning into CB ptorein-bound open form;
    -   Pc:	the half activation (affinity) of the Ih channels for the
            CB protein;
    -   nexp: number of binding sites on Ih channels.

    Finally, the model includes time constant adjustment (optional)
    positively shifting and slowing down the activation time constant as
    described in [7].

    *Note: the code may produce segmentation faults if state values become
           extremely small (expecially true for fixed time step
           integration). To avoid that caInc should not be < 1e-10.

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
    [6] Destexhe, A., Bal, T., McCormick, D.A. and Sejnowski, T.J.  Ionic 
        mechanisms underlying synchronized oscillations and propagating
        waves in a model of ferret thalamic slices. Journal of
        Neurophysiology. 76: 2049-2070, 1996.
    [7] Soltesz, I., Lightowler, S., Leresche, N., Jassik-Gerschenfeld, D.,
        Pollard, C.E., Crunelli, V. The inward currents and the
        transformation of low-frequency oscillations of rat and cat
        thalamocortical cells. Journal of Physiology. 441:175-197, 1991.

    Written by Martynas Dervinis @ Cardiff University, 2017.

ENDCOMMENT

NEURON {
	SUFFIX iarg
	USEION h READ eh WRITE ih VALENCE 1
    USEION ca READ cai
    USEION cahva READ cahvai
    RANGE ghbar, V_half, s, tau_min, shift, ginc, cainf, k2, cac, nca, k4, Pc, nexp, adj
}

UNITS {
	(mA) 	= (milliamp)
	(mV) 	= (millivolt)
    (molar)	= (1/liter)
	(mM)	= (millimolar)
	(msM)	= (ms mM)
}

PARAMETER {
	eh      = -40       (mV)
	celsius = 35        (degC)
	ghbar	= 0.00047   (mho/cm2)
    V_half  = -75       (mV)
    s       = 5.5
    tau_min = 20        (ms)
    shift   = 0         (mV)
    ginc	= 2
    cainf   = 0         (mM)
    cac     = 0.002     (mM)
	k2      = 0.0004    (1/ms)
	Pc      = 0.01
	k4      = 0.001     (1/ms)
	nca     = 4
	nexp	= 1
    adj     = 0
}

STATE {
	p0	: resting CB protein
	p1  : Ca2+-bound CB protein
    c   : closed unbound h channels
    o1  : open unbound h channels
    o2  : CB protein-bound open h channels
}

ASSIGNED {
	v        (mV)
    cai      (mM)
    cahvai   (mM)
    m
	ih       (mA/cm2)
    phi
	m_inf
    tau_m    (ms)
    alpha
    beta
    k1
    k3
}

BREAKPOINT {
    SOLVE ihkin METHOD sparse
    m = o1 + ginc * o2
	ih = ghbar * m * (v - eh)
}

KINETIC ihkin {
    rates(v,cai,cahvai)
    ~ c  <-> o1		(alpha,beta)
    ~ p0 <-> p1		(k1,k2)
    ~ o1 <-> o2		(k3,k4)
    CONSERVE p0 + p1 = 1
    CONSERVE c + o1 + o2 = 1
}

UNITSOFF
INITIAL {
    c  = 1
    o1 = 0
    p0 = 1
    p1 = 0
    o2 = 0
    phi = 3.0 ^ ((celsius-36 (degC) )/10 (degC) )
	rates(v,cai,cahvai)
}

PROCEDURE rates(v(mV), cai(mM), cahvai(mM)) {
    LOCAL caInc
    
    m_inf = 1 / (1 + exp((v-V_half-shift)/s))
    if (!adj) {
        tau_m = (tau_min + 1000 / ( exp((v+71.5-shift)/14.2) + exp(-(v+89-shift)/11.6) ) ) / phi
    } else {
        tau_m = (6600 / ( exp((v+71.5-27.5)/14.2) + exp(-(v+89-27.5)/11.6) ) ) / phi
    }
    alpha = m_inf / tau_m
    beta  = ( 1 - m_inf ) / tau_m

    caInc = (cai+cahvai) - cainf    : Modulation Ca2+ relative to the baseline concentration.
                                    : Makes easier switching between modulated and regular versions of the model
    if (caInc < 0) {
    	caInc = 0
    }
    k1 = k2 * (caInc/(cac-cainf))^nca
    k3 = k4 * (p1/Pc)^nexp
}
UNITSON
