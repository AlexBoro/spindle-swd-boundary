TITLE AMPA + NMDA receptors

NEURON {
	POINT_PROCESS GLU_S2
	RANGE g_a, gbar_a, Cmax_a, Cdur_a, Alpha_a, Beta_a, Erev_a, Rinf_a, Rtau_a, weight_a
    RANGE tau1_b, tau1_init_b, tau2_0_b, a2_b, b2_b, wtau2_b, tau3_0_b, a3_b, b3_b, tauV_b, e_b
    RANGE i_b, gVI_b, gVDst_b, gVDv0_b, Mg_b, K0_b, delta_b, tp_b, wf_b
    RANGE tauAdj_b, gf_b, inf_b, tau2_b, tau3_b, weight_b
    RANGE refractory, P_release, u, tau_U, Ulast, d1, d2, tau_D1, tau_D2, D1last, D2last
    RANGE amp, f, phi
	NONSPECIFIC_CURRENT iAMPA
    NONSPECIFIC_CURRENT iNMDA
    THREADSAFE : only true if every instance has its own distinct Random
    POINTER donotuse
}

UNITS {
	(nA) = (nanoamp)
	(mV) = (millivolt)
	(uS) = (microsiemens)
    (mM) = (milli/liter)
    (msM)= (ms mM)
    (S)  = (siemens)
	(pS) = (picosiemens)
	(um) = (micron)
	(J)  = (joules)
}

PARAMETER {
    : Shared:
        refractory  = 0   (ms)  : refractory period
        P_release   = 1   <0,1> : release probability (0.0 - 1.0)
        u           = 1   (1)   : fast facilitation ()
        tau_U       = 634 (ms)  : fast facilitation recovery time constant
        d1      = 1     (1)     : fast depression (0.78)
        d2      = 1     (1)     : slow depression (0.97)
        tau_D1  = 634   (ms)    : fast depression recovery time constant
        tau_D2  = 9300  (ms)    : slow depression recovery time constant
        amp = 0         (1)     : ISO amplitude
        f = 0.03        (hz)    : ISO frequency
        phi = 0         (rad)   : phase displacement
    : AMPA:
        gbar_a  = 0.001 (uS)    : maximal conductance according to Destexhe: 0.00035-0.001
        Cdur_a	= 0.3	(ms)	: transmitter duration (rising phase)
        Cmax_a	= 0.5	(mM)	: max transmitter concentration
        Alpha_a	= 0.94	(/msM)	: forward (binding) rate
        Beta_a	= 0.18	(/ms)	: backward (unbinding) rate
        Erev_a	= 0     (mV)	: reversal potential
        weight_a= 1     (1)     : synaptic weight
    : NMDA:
        tau1_init_b = 1.69  (ms)    <1e-9,1e9>  : Spruston95 CA1 dend [Mg=0 v=-80 celcius=18] be careful: Mg can change these values
        tau2_0_b = 3.97     (ms)
        a2_b = 0.70         (ms)
        b2_b = 0.0243		(1/mV)
        wtau2_b = 0.65              <1e-9,1>    : Hestrin90
        tau3_0_b = 41.62	(ms)
        a3_b = 34.69		(ms)
        b3_b = 0.01         (1/mV)
        Q10_tau1_b = 2.2                        : Hestrin90
        Q10_tau2_b = 3.68                       : Hestrin90 -> 3.5-+0.9, Korinek10 -> NR1/2B -> 3.68
        Q10_tau3_b = 2.65                       : Korinek10
        T0_tau_b = 35       (degC)              : reference temperature 
        tp_b = 30			(ms)                : time of the peack -> when C + B - A reaches the maximum value or simply when NMDA has the peack current
        tauV_b = 7          (ms)	<1e-9,1e9>	: Kim11 
		gVDst_b = 0.007     (1/mV)              : steepness of the gVD-V graph from Clarke08 -> 2 units / 285 mv
        gVDv0_b = -100      (mV)                : Membrane potential at which there is no voltage dependent current, from Clarke08 -> -90 or -100
        gVI_b = 1			(uS)                : Maximum Conductance of Voltage Independent component, This value is used to calculate gVD
        Q10_b = 1.52                            : Kim11
        T0_b = 26			(degC)              : reference temperature 
        Mg_b = 1			(mM)                : external magnesium concentration from Spruston95
        K0_b = 4.1          (mM)                : IC50 at 0 mV from Spruston95
        delta_b = 0.8       (1)                 : the electrical distance of the Mg2+ binding site from the outside of the membrane from Spruston95
        e_b = -0.7          (mV)                : in CA1-CA3 region = -0.7 from Spruston95
        tauAdj_b = 1        (1)
        gf_b = 1            (1)
        weight_b = 1        (1)                 : synaptic weight
}

CONSTANT {
	T = 273.16	(degC)
	F = 9.648e4	(coul)	: Faraday's constant (coulombs/mol)
	R = 8.315	(J/degC): universal gas constant (joules/mol/K)
	z = 2		(1)		: valency of Mg2+
}

ASSIGNED {
    : Shared:
        v		(mV)	: postsynaptic voltage
        donotuse
        Ulast
        D1last
        D2last
        ISO     (1)
    : AMPA:
        iAMPA   (nA)
        g_a 	(uS)	: conductance
        Rinf_a			: steady state channels open
        Rtau_a	(ms)	: time constant of channel binding
        synon_a
    : NMDA:
        iNMDA	(nA)
        g_b		(uS)
        factor_b
        wf_b
        q10_tau2_b
        q10_tau3_b
        inf_b	(uS)
        tau_b	(ms)
        tau1_b  (ms)
        tau2_b	(ms)
        tau3_b	(ms)
        wtau3_b
        celsius (degC)  : actual temperature for simulation, defined in Neuron
}

STATE {
    : AMPA:
        Ron_a
        Roff_a
    : NMDA:
        A_b         : Gating in response to release of Glutamate
        B_b         : Gating in response to release of Glutamate
        C_b         : Gating in response to release of Glutamate
        gVD_b (uS)  : Voltage dependent gating
}

PROCEDURE seed(x) {
	set_seed(x)
}

INITIAL {
    : Shared:
        if (P_release > 1) {
            P_release = 1
        } else if (P_release < 0) {
            P_release = 0
        }
        Ulast = 1
        D1last = 1
        D2last = 1
    : AMPA:
        Rinf_a = Cmax_a*Alpha_a / (Cmax_a*Alpha_a + Beta_a)
        Rtau_a = 1 / (Cmax_a*Alpha_a + Beta_a)
        synon_a = 0
        Ron_a = 0
        Roff_a = 0
    : NMDA:
        Mgblock(v)
        tau1_b = tauAdj_b*tau1_init_b * Q10_tau1_b^((T0_tau_b - celsius)/10(degC))
        q10_tau2_b = Q10_tau2_b^((T0_tau_b - celsius)/10(degC))
        q10_tau3_b = Q10_tau3_b^((T0_tau_b - celsius)/10(degC))
        tau_b = tauAdj_b*tauV_b * Q10_b^((T0_b - celsius)/10(degC))
        timeCnsts(v)
        wtau3_b = 1 - wtau2_b
        factor_b = -exp(-tp_b/tau1_b) + wtau2_b*exp(-tp_b/tau2_b) + wtau3_b*exp(-tp_b/tau3_b)
        factor_b = 1/factor_b
        A_b = 0
        B_b = 0
        C_b = 0
        gVD_b = 0
        wf_b = 1
}

BREAKPOINT {
	SOLVE rates METHOD derivimplicit
    : AMPA:
        g_a = gbar_a*(Ron_a + Roff_a)
        iAMPA = g_a*(v - Erev_a)
        iAMPA = weight_a*iAMPA
    : NMDA:
        iNMDA = gf_b*(wtau3_b*C_b + wtau2_b*B_b - A_b)*(gVI_b + gVD_b)*Mgblock(v)*(v - e_b)
        iNMDA = weight_b*iNMDA
}

DERIVATIVE rates {
    : AMPA:
        Ron_a' = (synon_a*Rinf_a - Ron_a)/Rtau_a
        Roff_a' = -Beta_a*Roff_a
    : NMDA:
        timeCnsts(v)
        A_b' = -A_b/tau1_b
        B_b' = -B_b/tau2_b
        C_b' = -C_b/tau3_b
        gVD_b' = ((wtau3_b*C_b + wtau2_b*B_b)/wf_b)*(inf_b-gVD_b)/tau_b
}

FUNCTION Mgblock(v(mV)) {
	Mgblock = 1 / (1 + (Mg_b/K0_b)*exp((0.001)*(-z)*delta_b*F*v/R/(T+celsius)))
}

PROCEDURE timeCnsts(v (mV)) {
	inf_b = (v - gVDv0_b) * gVDst_b * gVI_b
	tau2_b = tauAdj_b*(tau2_0_b + a2_b*(1-exp(-b2_b*v)))*q10_tau2_b
	tau3_b = tauAdj_b*(tau3_0_b + a3_b*(1-exp(-b3_b*v)))*q10_tau3_b
	if (tau1_b/tau2_b > .9999) {
		tau1_b = .9999*tau2_b
	}
	if (tau2_b/tau3_b > .9999) {
		tau2_b = .9999*tau3_b
	}
}

VERBATIM
double nrn_random_pick(void* r);
void* nrn_random_arg(int argpos);
ENDVERBATIM

FUNCTION erand() {
VERBATIM
	if (_p_donotuse) {
		/*
		:Supports separate independent but reproducible streams for
		: each instance. However, the corresponding hoc Random
		: distribution MUST be set to Random.negexp(1)
		*/
		_lerand = nrn_random_pick(_p_donotuse);
	}else{
		/* only can be used in main thread */
		if (_nt != nrn_threads) {
hoc_execerror("multithread random in NetStim"," only via hoc Random");
		}
ENDVERBATIM
		: the old standby. Cannot use if reproducible parallel sim
		: independent of nhost or which host this instance is on
		: is desired, since each instance on this cpu draws fromt0
		: the same stream
		erand = nrnran123_dblpick()
VERBATIM
	}
ENDVERBATIM
}

PROCEDURE noiseFromRandom() {   : call from hoc to supply a ref to a Random() class object
                                : must have a uniform(0,1) distribution (see NEURON's documentation)
VERBATIM
 {
	void** pv = (void**)(&_p_donotuse);
	if (ifarg(1)) {
		*pv = nrn_random_arg(1);
	}else{
		*pv = (void*)0;
	}
 }
ENDVERBATIM
}

NET_RECEIVE(weight, U, D1, D2, t0 (ms), r0_a, t0_a (ms), toss) {
    : Non-saturating synapse capable of summating over separate streams.
    : weight, U, D1, D2, t0, r0_a, t0_a, toss are per stream.
    : flag is an implicit argument of NET_RECEIVE with 0 signaling an external event
    LOCAL response
    if (!(P_release > 0) || !(weight > 0) || (!(weight_a > 0) && !(weight_b > 0))) {
        VERBATIM
        return;
        ENDVERBATIM
    }
    INITIAL {
        U = 1
        D1 = 1
        D2 = 1
        t0 = -1e9
        r0_a = 0
        t0_a = -1e9
	}
    if (flag == 0) { : a spike, so turn on if not already in a Cdur pulse
        if (t - t0 > refractory) {
            if (P_release < 1) {
                toss = erand()
            }
            if (toss <= P_release) {
                : Shared:
                    U = 1 - (1-U)*exp(-(t - t0)/tau_U)
                    D1 = 1 - (1-D1)*exp(-(t - t0)/tau_D1)
                    D2 = 1 - (1-D2)*exp(-(t - t0)/tau_D2)
                    Ulast = U
                    D1last = D1
                    D2last = D2
                    ISO = 2*amp*sin(2*3.14159265359*f*t + phi)
                    if (ISO > amp) {
                        ISO = amp
                    } else if (ISO < -amp) {
                        ISO = -amp
                    }
                    if (d1*d2<1) {
                        response = (((1-(1-(1-d1)*U)*(1-(1-d2)*U))*D1*D2)/(1-d1*d2)) + ISO
                    } else {
                        response = 1 + ISO
                    }
                    t0 = t
                : AMPA:
                    if (weight_a>0) {
                        r0_a = r0_a*exp(-Beta_a*(t - t0_a))
                        synon_a = synon_a + weight*response
                        Ron_a = Ron_a + r0_a
                        Roff_a = Roff_a - r0_a
                        t0_a = t
                        : come again in Cdur with flag = response
                        net_send(Cdur_a, response)
                    }
                : NMDA:
                    if (weight_b>0) {
                        wf_b = factor_b*weight*response
                        A_b = A_b + wf_b
                        B_b = B_b + wf_b
                        C_b = C_b + wf_b
                    }
                : Shared:
                    D1 = D1*(1-(1-d1)*U)
                    D2 = D2*(1-(1-d2)*U)
                    U = 2-(2-U)*(2-u)
            }
        }
    } else { : if this is associated with last spike then turn off
		r0_a = weight*flag*Rinf_a + (r0_a - weight*flag*Rinf_a)*exp(-(t - t0_a)/Rtau_a)
		synon_a = synon_a - weight*flag
		Ron_a = Ron_a - r0_a
		Roff_a = Roff_a + r0_a
        t0_a = t
	}
}