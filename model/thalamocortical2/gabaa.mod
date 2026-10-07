TITLE simple GABAa receptors

COMMENT
-----------------------------------------------------------------------------

	Simple model for GABAa receptors
	================================

  - FIRST-ORDER KINETICS, FIT TO WHOLE-CELL RECORDINGS

    Whole-cell recorded GABA-A postsynaptic currents (Otis et al, J. Physiol. 
    463: 391-407, 1993) were used to estimate the parameters of the present
    model; the fit was performed using a simplex algorithm (see Destexhe et
    al., J. Neurophysiol. 72: 803-818, 1994).

  - SHORT PULSES OF TRANSMITTER (0.3 ms, 0.5 mM)

    The simplified model was obtained from a detailed synaptic model that 
    included the release of transmitter in adjacent terminals, its lateral 
    diffusion and uptake, and its binding on postsynaptic receptors (Destexhe
    and Sejnowski, 1995).  Short pulses of transmitter with first-order
    kinetics were found to be the best fast alternative to represent the more
    detailed models.

  - ANALYTIC EXPRESSION

    The first-order model can be solved analytically, leading to a very fast
    mechanism for simulating synapses, since no differential equation must be
    solved (see references below).



References

   Destexhe, A., Mainen, Z.F. and Sejnowski, T.J.  An efficient method for
   computing synaptic conductances based on a kinetic model of receptor binding
   Neural Computation 6: 10-14, 1994.  

   Destexhe, A., Mainen, Z.F. and Sejnowski, T.J. Synthesis of models for
   excitable membranes, synaptic transmission and neuromodulation using a 
   common kinetic formalism, Journal of Computational Neuroscience 1: 
   195-230, 1994.

See also:

   http://cns.iaf.cnrs-gif.fr

Written by A. Destexhe, 1995
27-11-2002: the pulse is implemented using a counter, which is more
	stable numerically (thanks to Yann LeFranc)

-----------------------------------------------------------------------------
ENDCOMMENT

NEURON {
	POINT_PROCESS GABAa_S
	RANGE g, gbar, Cmax, Cdur, Alpha, Beta, Erev, Rinf, Rtau, refractory, P_release
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
    gbar    = 1     (umho)
	Cdur	= 0.3	(ms)	: transmitter duration (rising phase)
    Cmax	= 0.5	(mM)	: max transmitter concentration
	Alpha	= 0.94	(/ms)	: forward (binding) rate
	Beta	= 0.18	(/ms)	: backward (unbinding) rate
	Erev	= 0	(mV)		: reversal potential
    refractory = 0 (ms)     : refractory period
    P_release = 1 <0,1>     : release probability (0.0 - 1.0)
}

ASSIGNED {
	v		(mV)		: postsynaptic voltage
	i 		(nA)		: current = g*(v - Erev)
	g 		(umho)		: conductance
	Rinf				: steady state channels open
	Rtau	(ms)		: time constant of channel binding
	synon
    donotuse
}

STATE {Ron Roff}

PROCEDURE seed(x) {
	set_seed(x)
}

INITIAL {
    if (P_release > 1) {
        P_release = 1
    } else if (P_release < 0) {
        P_release = 0
    }
	Rinf = Cmax*Alpha / (Cmax*Alpha + Beta)
	Rtau = 1 / (Cmax*Alpha + Beta)
	synon = 0
}

BREAKPOINT {
	SOLVE release METHOD cnexp
	g = gbar*(Ron + Roff)
	i = g*(v - Erev)
}

DERIVATIVE release {
	Ron' = (synon*Rinf - Ron)/Rtau
	Roff' = -Beta*Roff
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

NET_RECEIVE(weight, r0, t0 (ms), t0_a (ms), toss) {
    : Non-saturating synapse capable of summating over separate streams.
    : weight, r0, t0, t0_a, and toss are per stream and all except w are
    : initialised to 0.
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
                r0 = r0*exp(-Beta*(t - t0_a))
                t0 = t
                t0_a = t
                synon = synon + weight
                Ron = Ron + r0
                Roff = Roff - r0
                : come again in Cdur with flag = 1
                net_send(Cdur, 1)
            }
        }
    } else if (flag == 1) { : if this associated with last spike then turn off
		r0 = weight*Rinf + (r0 - weight*Rinf)*exp(-(t - t0_a)/Rtau)
		t0_a = t
		synon = synon - weight
		Ron = Ron - r0
		Roff = Roff + r0
	}
}