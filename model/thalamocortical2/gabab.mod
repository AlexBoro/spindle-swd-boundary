TITLE simple GABAb receptors

COMMENT
-----------------------------------------------------------------------------

	Kinetic model of GABA-B receptors
	=================================

  MODEL OF SECOND-ORDER G-PROTEIN TRANSDUCTION AND FAST K+ OPENING
  WITH COOPERATIVITY OF G-PROTEIN BINDING TO K+ CHANNEL

  PULSE OF TRANSMITTER

  SIMPLE KINETICS WITH NO DESENSITIZATION

	Features:

  	  - peak at 100 ms; time course fit to Tom Otis' PSC
	  - SUMMATION (psc is much stronger with bursts)


	Approximations:

	  - single binding site on receptor	
	  - model of alpha G-protein activation (direct) of K+ channel
	  - G-protein dynamics is second-order; simplified as follows:
		- saturating receptor
		- no desensitization
		- Michaelis-Menten of receptor for G-protein production
		- "resting" G-protein is in excess
		- Quasi-stat of intermediate enzymatic forms
	  - binding on K+ channel is fast


	Kinetic Equations:

	  dR/dt = K1 * T * (1-R-D) - K2 * R

	  dG/dt = K3 * R - K4 * G

	  R : activated receptor
	  T : transmitter
	  G : activated G-protein
	  K1,K2,K3,K4 = kinetic rate cst

  n activated G-protein bind to a K+ channel:

	n G + C <-> O		(Alpha,Beta)

  If the binding is fast, the fraction of open channels is given by:

	O = G^n / ( G^n + KD )

  where KD = Beta / Alpha is the dissociation constant

-----------------------------------------------------------------------------

  Parameters estimated from patch clamp recordings of GABAB PSP's in
  rat hippocampal slices (Otis et al, J. Physiol. 463: 391-407, 1993).

-----------------------------------------------------------------------------

  PULSE MECHANISM

  Kinetic synapse with release mechanism as a pulse.  

  Warning: for this mechanism to be equivalent to the model with diffusion 
  of transmitter, small pulses must be used...

  see details at http://cns.iaf.cnrs-gif.fr

  Written by A. Destexhe, 1995
  27-11-2002: the pulse is implemented using a counter, which is more
	stable numerically (thanks to Yann LeFranc)

-----------------------------------------------------------------------------
ENDCOMMENT

NEURON {
	POINT_PROCESS GABAb_S
	RANGE C, R, G, g, gbar, Cmax, Cdur, K1, K2, K3, K4, KD, n, Erev, refractory, P_release, weight_b
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
	Cmax	= 0.5	(mM)	: max transmitter concentration
	Cdur	= 0.3	(ms)	: transmitter duration (rising phase)
	K1	= 0.52	 (/ms mM)	: forward binding rate to receptor
	K2	= 0.0013 (/ms)		: backward (unbinding) rate of receptor
	K3	= 0.098  (/ms)		: rate of G-protein production
	K4	= 0.033  (/ms)		: rate of G-protein decay
	KD	= 100               : dissociation constant of K+ channel
	n	= 4                 : nb of binding sites of G-protein on K+
	Erev = -95	 (mV)		: reversal potential (E_K)
    refractory = 0 (ms)     : refractory period
    gbar = 1	(umho)		: maximum conductance
    P_release = 1 <0,1>     : release probability (0.0 - 1.0)
    weight_b = 1    (1)     : synaptic weight
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
	g = gbar * Gn / (Gn+KD)
	i = weight_b*g*(v - Erev)
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
    if (!(P_release > 0) || !(weight > 0)) {
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
                t0 = t
                C = C + Cmax
                net_send(Cdur, 1)
            }
        }
    } else if (flag == 1) { : if this associated with last spike then turn off
		C = C - Cmax
	}
}