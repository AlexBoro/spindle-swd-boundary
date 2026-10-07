TITLE simple GABAa+GABAb receptors

NEURON {
	POINT_PROCESS GABA_S2
	RANGE g_a, gbar_a, Cmax_a, Cdur_a, Alpha_a, Beta_a, Erev_a, Rinf_a, Rtau_a, weight_a
    RANGE C_b, R_b, G_b, g_b, gbar_b, Cmax_b, Cdur_b, K1_b, K2_b, K3_b, K4_b, KD_b, n_b, Erev_b, weight_b
    RANGE C_c, R_c, G_c, g_c, gbar_c, Cmax_c, Cdur_c, K1_c, K2_c
    RANGE K3_c, K4_c, KD_c, n_c, Erev_c, weight_c, refractory, P_release
	NONSPECIFIC_CURRENT i_a
    NONSPECIFIC_CURRENT i_b
    NONSPECIFIC_CURRENT iKLeak
    THREADSAFE : only true if every instance has its own distinct Random
    POINTER donotuse
}
UNITS {
	(nA) = (nanoamp)
	(mV) = (millivolt)
    (mM) = (milli/liter)
    (msM)= (ms mM)
    (S)  = (siemens)
    (uS) = (microsiemens)
}

PARAMETER {
    : Shared:
    	P_release   = 1 <0,1>           : release probability (0.0 - 1.0)
        refractory  = 0        (ms)     : refractory period
    : GABAa part:
        gbar_a      = 1        (uS)
        Cdur_a      = 0.3      (ms)     : transmitter duration (rising phase)
        Cmax_a      = 0.5      (mM)     : max transmitter concentration
        Alpha_a     = 0.94     (/ms)	: forward (binding) rate
        Beta_a      = 0.18     (/ms)	: backward (unbinding) rate
        Erev_a      = 0        (mV)     : reversal potential
        weight_a    = 1        (1)      : synaptic weight
    : GABAb part:
        Cmax_b      = 0.5      (mM)     : max transmitter concentration
        Cdur_b      = 0.3      (ms)     : transmitter duration (rising phase)
        K1_b        = 0.52     (/msM)   : forward binding rate to receptor
        K2_b        = 0.0013   (/ms)	: backward (unbinding) rate of receptor
        K3_b        = 0.098    (/ms)	: rate of G-protein production
        K4_b        = 0.033    (/ms)	: rate of G-protein decay
        KD_b        = 100               : dissociation constant of K+ channel
        n_b         = 4                 : nb of binding sites of G-protein on K+
        Erev_b      = -95      (mV)     : reversal potential (E_K)
        gbar_b      = 1        (uS)     : maximum conductance
        weight_b    = 1        (1)      : synaptic weight
    : extrasynaptic GABAa part:
        Cmax_c      = 1        (mM)     : max transmitter concentration
        Cdur_c      = 1        (ms)     : transmitter duration (rising phase)
        K1_c        = 0.009    (/msM)	: forward binding rate to receptor
        K2_c        = 0.0012   (/ms)	: backward (unbinding) rate of receptor
        K3_c        = 0.18     (/ms)	: rate of G-protein production
        K4_c        = 0.034    (/ms)	: rate of G-protein decay
        KD_c        = 100               : dissociation constant of K+ channel
        n_c         = 4                 : number of binding sites of G-protein on K+
        Erev_c      = -80      (mV)     : reversal potential (E_K)
        gbar_c      = 0.001    (uS)     : maximum conductance
        weight_c    = 1        (1)      : synaptic weight
}

ASSIGNED {
    : Shared:
        v		(mV)	: postsynaptic voltage
        donotuse
    : GABAa:
        i_a 	(nA)	: current = g_a*(v - Erev_a)
        g_a 	(uS)	: conductance
        Rinf_a			: steady state channels open
        Rtau_a	(ms)	: time constant of channel binding
        synon_a
    : GABAb:
        i_b     (nA)	: current = g_b*(v - Erev_b)
        g_b 	(uS)	: conductance
        C_b		(mM)	: transmitter concentration
        Gn_b
    : eGABAa:
        iKLeak 	(nA)	: current = g*(v - Erev)
        g_c 	(uS)	: conductance
        C_c		(mM)	: transmitter concentration
        Gn_c
}

STATE {
    : GABAa:
        Ron_a
        Roff_a 
    : GABAb:
        R_b
        G_b
    : eGABAa:
        R_c			: fraction of activated receptor
        G_c			: fraction of activated G-protein
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
    : GABAa:
        Rinf_a = Cmax_a*Alpha_a / (Cmax_a*Alpha_a + Beta_a)
        Rtau_a = 1 / (Cmax_a*Alpha_a + Beta_a)
        synon_a = 0
    : GABAb:
        C_b = 0
        R_b = 0
        G_b = 0
    : eGABAa:
        C_c = 0
        R_c = 0
        G_c = 0
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
    : eGABAa:
        Gn_c = G_c^n_c
        g_c = weight_c * gbar_c * Gn_c / (Gn_c+KD_c)
        iKLeak = g_c*(v - Erev_c)
}

DERIVATIVE rates {
    : GABAa:
        Ron_a' = (synon_a*Rinf_a - Ron_a)/Rtau_a
        Roff_a' = -Beta_a*Roff_a
    : GABAb:
        R_b' = K1_b * C_b * (1-R_b) - K2_b * R_b
        G_b' = K3_b * R_b - K4_b * G_b
    : eGABAa:
        R_c' = K1_c * C_c * (1-R_c) - K2_c * R_c
        G_c' = K3_c * R_c - K4_c * G_c
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

NET_RECEIVE(weight, r0_a, t0 (ms), t0_a (ms), toss) {
    : Non-saturating synapse capable of summating over separate streams.
    : weight, r0_a, t0, t0_a, and toss are per stream and all except w are
    : initialised to 0.
    : flag is an implicit argument of NET_RECEIVE with 0 signaling an external event
    if (!(P_release > 0) || !(weight > 0) || (!(weight_a > 0) && !(weight_b > 0))) {
        VERBATIM
        return;
        ENDVERBATIM
    }
    if (flag == 0) { : a spike, so turn on if not already in a Cdur pulse
        if (t - t0 > refractory) {
            if (P_release < 1) {
                toss = erand()
            }
            if (toss <= P_release) {
                : Shared:
                    t0 = t
                : GABAa:
                    r0_a = r0_a*exp(-Beta_a*(t - t0_a))
                    synon_a = synon_a + weight
                    Ron_a = Ron_a + r0_a
                    Roff_a = Roff_a - r0_a
                    t0_a = t
                    net_send(Cdur_a, 1)
                : GABAb:
                    C_b = C_b + Cmax_b
                    net_send(Cdur_b, 2)
                : eGABAa:
                    C_c = C_c + Cmax_c
                    net_send(Cdur_c, 3)
            }
        }
    } else if (flag == 1) { : if this associated with last spike then turn off GABAa
		r0_a = weight*Rinf_a + (r0_a - weight*Rinf_a)*exp(-(t - t0_a)/Rtau_a)
		synon_a = synon_a - weight
		Ron_a = Ron_a - r0_a
		Roff_a = Roff_a + r0_a
        t0_a = t
	} else if (flag == 2) { : if this associated with last spike then turn off GABAb
        C_b = C_b - Cmax_b
    } else if (flag == 3) { : if this associated with last spike then turn off eGABAa
		C_c = C_c - Cmax_c
    }
}