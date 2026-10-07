TITLE Metabotropic glutamate receptor type 1a (mGluR1a)

COMMENT
    A metabotropic glutamate receptor 1a responsible for increase in the
    input resistance of thalamic cells in response to cortical input. The
    model is described in [1] and is adjusted to match the experimental
    data in [2].

    References:
    [1] Emri, Z., Antal, K., and Crunelli, V. The impact of corticothalamic
        feedback on the output dynamics of a thalamocortical neurone model:
        The role of synapse location and metabotropic glutamate receptors.
        Journal of Neuroscience, 117: 229-239, 2003.
    [2] Turner, J.P. and Salt, T.E. Characterization of sensory and
        corticothalamic excitatory inputs to rat thalamocortical neurons in
        vitro. Journal of Physiology (London), 510: 829–843, 1998.

ENDCOMMENT

NEURON {
	POINT_PROCESS mGluR1a
	RANGE C, R, G, g, gbar, gbase, Cmax, Cdur, K1, K2, K3, K4, KD, n, Erev, refractory, P_release, weight_c
	NONSPECIFIC_CURRENT i
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
	Cmax	= 1	(mM)        : max transmitter concentration
	Cdur	= 1	(ms)        : transmitter duration (rising phase)
	K1	= 0.009	 (/ms mM)	: forward binding rate to receptor
	K2	= 0.0012 (/ms)		: backward (unbinding) rate of receptor
	K3	= 0.18   (/ms)		: rate of G-protein production
	K4	= 0.034  (/ms)		: rate of G-protein decay
	KD	= 100               : dissociation constant of K+ channel
	n	= 4                 : nb of binding sites of G-protein on K+
	Erev = -95      (mV)	: reversal potential (E_K)
    refractory = 0  (ms)    : refractory period
    gbar = 0.001	(umho)	: maximum conductance
    gbase = 0.001   (umho)	: baseline K+ leak conductance
    P_release = 1 <0,1>     : release probability (0.0 - 1.0)
    weight_c = 1    (1)     : synaptic weight
}

ASSIGNED {
	v		(mV)		: postsynaptic voltage
	i 		(nA)		: current = g*(v - Erev)
	g 		(umho)		: conductance
	C		(mM)		: transmitter concentration
	Gn
    donotuse
}

STATE {
	R				: fraction of activated receptor
	G				: fraction of activated G-protein
}

PROCEDURE seed(x) {
	set_seed(x)
}

INITIAL {
    if (P_release > 1) {
        P_release = 1
    } else if (P_release < 0) {
        P_release = 0
    }
	C = 0
	R = 0
	G = 0
}

BREAKPOINT {
	SOLVE bindkin METHOD cnexp
	Gn = G^n
	g = weight_c * gbar * Gn / (Gn+KD)
	i = (gbase - g)*(v - Erev)
}

DERIVATIVE bindkin {
	R' = K1 * C * (1-R) - K2 * R
	G' = K3 * R - K4 * G
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

NET_RECEIVE(weight, t0 (ms), toss) {
    : Non-saturating synapse capable of summating over separate streams.
    : weight, t0, and toss are per stream and all except weight are initialised to 0.
    : flag is an implicit argument of NET_RECEIVE with 0 signaling an external event
    if (flag == 0) { : a spike, so turn on if not already in a Cdur pulse
        if (t - t0 > refractory && P_release > 0) {
            if (P_release < 1) {
                toss = erand()
            }
            if (toss <= P_release) {
                t0 = t
                C = C + Cmax
                net_send(Cdur, 1)
            }
        }
    } else if (flag == 1) { : if this associated with last spike then turn off
		C = C - Cmax
	}
}