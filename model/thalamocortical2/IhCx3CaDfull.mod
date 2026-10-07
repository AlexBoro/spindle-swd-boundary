TITLE Anomalous rectifier current I_h in cortical neurons (a Ca2+-dependent version)

COMMENT
    Anomalous rectifier or hyperpolarisation activated (Na+/K+) current I_h
    outlined in [1]. The Ca2+ dependence was taken from [2].

    References:
    [1] Keren, N., Peled, N., and Korngreen, A. Constraining Compartmental
        Models Using Multiple Voltage Recordings and Genetic Algorithms.
        Journal of Neurophysiology, 94: 3730–3742, 2005.
    [2] Destexhe, A., Bal, T., McCormick, D.A. and Sejnowski, T.J.  Ionic 
        mechanisms underlying synchronized oscillations and propagating
        waves in a model of ferret thalamic slices. Journal of
        Neurophysiology. 76: 2049-2070, 1996.

    Written by Martynas Dervinis @ Cardiff University, 2014.

ENDCOMMENT

NEURON {
	SUFFIX iarCx3CaDfull
	USEION h READ eh WRITE ih VALENCE 1
    USEION ca READ cai
    USEION caHVA READ caHVAi VALENCE 2
    RANGE ghbar, halfAct, ginc, cainf, k2, cac, nca, k4, Pc, nexp, m
}

UNITS {
	(mA) 	= (milliamp)
	(mV) 	= (millivolt)
    (molar)	= (1/liter)
	(mM)	= (millimolar)
	(msM)	= (ms mM)
}

PARAMETER {
	eh      = -30	 (mV)
	celsius = 37	 (degC)
	ghbar	= 0.0015 (mho/cm2)
    halfAct = -91
    ginc	= 2
    cainf   = 50e-6     (mM)
    cac     = 0.002     (mM)
	k2      = 0.0004    (1/ms)
	Pc      = 0.01
	k4      = 0.001     (1/ms)
	nca     = 4
	nexp	= 1
}

STATE {
	p0	: resting CB protein
	p1  : Ca2+-bound CB protein
    c   : closed unbound h channels
    o1  : open unbound h channels
    o2  : CB protein-bound open h channels
}

ASSIGNED {
	v	  (mV)
    cai      (mM)
    caHVAi   (mM)
    m
	ih    (mA/cm2)
	phi
	m_inf
    tau_m    (ms)
    alpha
    beta
    k1
    k3
    caiFull  (mM)
}

BREAKPOINT {
    caiFull = cai + caHVAi
    SOLVE ihkin METHOD sparse
    m = o1 + ginc * o2
	ih = ghbar * m * (v - eh)
}

KINETIC ihkin {
    rates(v,caiFull)
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
    caiFull = cai + caHVAi
	rates(v,caiFull)
}

PROCEDURE rates(v(mV), caiFull(mM)) {
    LOCAL caInc

    m_inf = 1 / (1 + exp((v-halfAct)/6))
	tau_m = 1/(0.0004 * exp(-0.025*v) + 0.088*exp(0.062*v))
    alpha = m_inf / tau_m
    beta  = ( 1 - m_inf ) / tau_m

    caInc = caiFull :- cainf
    :if (caInc < 0) {
    :	caInc = 0
    :}
    k1 = k2 * (caInc/cac)^nca
    k3 = k4 * (p1/Pc)^nexp
}
UNITSON
