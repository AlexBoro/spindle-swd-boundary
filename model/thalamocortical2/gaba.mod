TITLE simple GABAa+GABAb receptors

NEURON {
	POINT_PROCESS GABA_S
	RANGE g_a, gbar_a, Cmax_a, Cdur_a, Alpha_a, Beta_a, Erev_a, Rinf_a, Rtau_a, weight_a
    RANGE C_b, R_b, G_b, g_b, gbar_b, Cmax_b, Cdur_b, K1_b, K2_b, K3_b, K4_b, KD_b, n_b, Erev_b, weight_b
    RANGE P_release, refractory, u, tau_U, d, tau_D
    RANGE amp, f, phi
	NONSPECIFIC_CURRENT i_a
    NONSPECIFIC_CURRENT i_b
    THREADSAFE : only true if every instance has its own distinct Random
    POINTER donotuse
}
UNITS {
	(nA) = (nanoamp)
	(mV) = (millivolt)
	(umho) = (micromho)
    (mM) = (milli/liter)
}

PARAMETER {
    : Shared:
    	P_release   = 1 <0,1>           : release probability (0.0 - 1.0)
        refractory  = 0         (ms)    : refractory period
        u           = 1         (1)     : fast facilitation ()
        tau_U       = 200       (ms)    : fast facilitation recovery time constant
        d           = 1         (1)     : fast depression (0.94)
        tau_D       = 1900      (ms)    : fast depression recovery time constant
        amp         = 0         (1)     : ISO amplitude
        f           = 0.03      (hz)    : ISO frequency
        phi         = 0         (rad)   : phase displacement
    : GABAa part:
        gbar_a      = 1         (umho)
        Cdur_a      = 0.3       (ms)	: transmitter duration (rising phase)
        Cmax_a      = 0.5       (mM)	: max transmitter concentration
        Alpha_a     = 0.94      (/ms)	: forward (binding) rate
        Beta_a      = 0.18      (/ms)	: backward (unbinding) rate
        Erev_a      = 0         (mV)	: reversal potential
        weight_a    = 1         (1)     : synaptic weight
    : GABAb part:
        Cmax_b      = 0.5       (mM)	: max transmitter concentration
        Cdur_b      = 0.3       (ms)	: transmitter duration (rising phase)
        K1_b        = 0.52      (/ms mM): forward binding rate to receptor
        K2_b        = 0.0013    (/ms)	: backward (unbinding) rate of receptor
        K3_b        = 0.098     (/ms)	: rate of G-protein production
        K4_b        = 0.033     (/ms)	: rate of G-protein decay
        KD_b        = 100               : dissociation constant of K+ channel
        n_b         = 4                 : nb of binding sites of G-protein on K+
        Erev_b      = -95       (mV)    : reversal potential (E_K)
        gbar_b      = 1         (umho)	: maximum conductance
        weight_b    = 1         (1)     : synaptic weight
}

ASSIGNED {
    : Shared:
        v		(mV)	: postsynaptic voltage
        donotuse
        ISO     (1)
    : GABAa:
        i_a 	(nA)	: current = g_a*(v - Erev_a)
        g_a 	(umho)	: conductance
        Rinf_a			: steady state channels open
        Rtau_a	(ms)	: time constant of channel binding
        synon_a
    : GABAb:
        i_b     (nA)	: current = g_b*(v - Erev_b)
        g_b 	(umho)	: conductance
        C_b		(mM)	: transmitter concentration
        Gn_b
}

STATE {Ron_a Roff_a R_b G_b}

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
    : GABAa:
        Rinf_a = Cmax_a*Alpha_a / (Cmax_a*Alpha_a + Beta_a)
        Rtau_a = 1 / (Cmax_a*Alpha_a + Beta_a)
        synon_a = 0
        Ron_a = 0
        Roff_a = 0
    : GABAb:
        C_b = 0
        R_b = 0
        G_b = 0
}

BREAKPOINT {
	SOLVE rates METHOD cnexp
    : GABAa:
        g_a = gbar_a*(Ron_a + Roff_a)
        i_a = weight_a*g_a*(v - Erev_a)
    : GABAb:
        Gn_b = G_b^n_b
        g_b = gbar_b * Gn_b / (Gn_b+KD_b)
        i_b = weight_b*g_b*(v - Erev_b)
}

DERIVATIVE rates {
    : GABAa:
        Ron_a' = (synon_a*Rinf_a - Ron_a)/Rtau_a
        Roff_a' = -Beta_a*Roff_a
    : GABAb:
        R_b' = K1_b * C_b * (1-R_b) - K2_b * R_b
        G_b' = K3_b * R_b - K4_b * G_b
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

NET_RECEIVE(weight, U, D, t0 (ms), r0_a, t0_a (ms), toss) {
    : Non-saturating synapse capable of summating over separate streams.
    : weight, U, D, t0, r0_a, t0_a, toss are per stream.
    : flag is an implicit argument of NET_RECEIVE with 0 signaling an external event
    LOCAL response
    if (!(P_release > 0) || !(weight > 0) || (!(weight_a > 0) && !(weight_b > 0))) {
        VERBATIM
        return;
        ENDVERBATIM
    }
    INITIAL {
        U = 1
        D = 1
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
                    D = 1 - (1-D)*exp(-(t - t0)/tau_D)
                    ISO = 2*amp*sin(2*3.14159265359*f*t + phi)
                    if (ISO > amp) {
                        ISO = amp
                    } else if (ISO < -amp) {
                        ISO = -amp
                    }
                    if (d<1) {
                        response = ((1-(1-(1-d)*U))*D)/(1-d) + ISO
                    } else {
                        response = 1 + ISO
                    }
                    t0 = t
                : GABAa:
                    if (weight_a>0) {
                        r0_a = r0_a*exp(-Beta_a*(t - t0_a))
                        synon_a = synon_a + weight*response
                        Ron_a = Ron_a + r0_a
                        Roff_a = Roff_a - r0_a
                        t0_a = t
                        net_send(Cdur_a, response)
                    }
                : GABAb:
                    if (weight_b>0) {
                        C_b = C_b + Cmax_b*response
                        net_send(Cdur_b, 10+response)
                    }
                : Shared:
                    D = D*(1-(1-d)*U)
                    U = 2-(2-U)*(2-u)
            }
        }
    } else if (flag < 10) { : if this is associated with last spike then turn off GABAa
		r0_a = weight*flag*Rinf_a + (r0_a - weight*flag*Rinf_a)*exp(-(t - t0_a)/Rtau_a)
		synon_a = synon_a - weight*flag
		Ron_a = Ron_a - r0_a
		Roff_a = Roff_a + r0_a
        t0_a = t
	} else { : if this is associated with last spike then turn off GABAb
        C_b = C_b - Cmax_b*(flag-10)
    }
}