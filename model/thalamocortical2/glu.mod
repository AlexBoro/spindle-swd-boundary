TITLE AMPA + NMDA receptors

NEURON {
	POINT_PROCESS GLU_S
	RANGE g_a, gbar_a, Cmax_a, Cdur_a, Alpha_a, Beta_a, Erev_a, Rinf_a, Rtau_a, weight_a
    RANGE g_b, gbar_b, Cmax_b, Cdur_b, Alpha_b, Beta_b, Erev_b, Rinf_b, Rtau_b, mg_b, weight_b
    RANGE refractory, P_release
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
}

PARAMETER {
    : Shared:
        refractory = 0   (ms)   : refractory period
        P_release = 1    <0,1>  : release probability (0.0 - 1.0)
    : AMPA:
        gbar_a  = 0.001  (uS)   : maximal conductance according to Destexhe: 0.00035-0.001
        Cdur_a	= 0.3	 (ms)	: transmitter duration (rising phase)
        Cmax_a	= 0.5	 (mM)	: max transmitter concentration
        Alpha_a	= 0.94	 (/msM)	: forward (binding) rate
        Beta_a	= 0.18	 (/ms)	: backward (unbinding) rate
        Erev_a	= 0      (mV)	: reversal potential
        weight_a= 1      (1)    : synaptic weight
    : NMDA:
        gbar_b  = 0.0006 (umho) : maximal conductance according to Destexhe: 0.00001-0.0006
        Cdur_b	= 0.3	 (ms)	: transmitter duration (rising phase)
        Cmax_b	= 0.5	 (mM)	: max transmitter concentration
        Alpha_b	= 0.94	 (/msM)	: forward (binding) rate
        Beta_b	= 0.18	 (/ms)	: backward (unbinding) rate
        Erev_b	= 0      (mV)   : reversal potential
        mg_b    = 1      (mM)   : external magnesium concentration
        weight_b= 1      (1)    : synaptic weight
}

ASSIGNED {
    : Shared:
        v		(mV)	: postsynaptic voltage
        donotuse
    : AMPA:
        iAMPA   (nA)
        g_a 	(uS)	: conductance
        Rinf_a			: steady state channels open
        Rtau_a	(ms)	: time constant of channel binding
        synon_a
    : NMDA:
        iNMDA 	(nA)
        g_b 	(umho)	: conductance
        Rinf_b			: steady state channels open
        Rtau_b	(ms)	: time constant of channel binding
        B_b             : magnesium block
        synon_b
}

STATE {
    : AMPA:
        Ron_a
        Roff_a
    : NMDA:
        Ron_b
        Roff_b
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
    : AMPA:
        Rinf_a = Cmax_a*Alpha_a / (Cmax_a*Alpha_a + Beta_a)
        Rtau_a = 1 / (Cmax_a*Alpha_a + Beta_a)
        synon_a = 0
    : NMDA:
        Rinf_b = Cmax_b*Alpha_b / (Cmax_b*Alpha_b + Beta_b)
        Rtau_b = 1 / (Cmax_b*Alpha_b + Beta_b)
        synon_b = 0
}

BREAKPOINT {
	SOLVE rates METHOD cnexp
    : AMPA:
        g_a = gbar_a*(Ron_a + Roff_a)
        iAMPA = g_a*(v - Erev_a)
        iAMPA = weight_a*iAMPA
    : NMDA:
        B_b = Mgblock(v)              : B is the block by magnesium at this voltage
        g_b = gbar_b*B_b*(Ron_b + Roff_b)
        iNMDA = g_b*(v - Erev_b)
        iNMDA = weight_b*iNMDA
}

DERIVATIVE rates {
    : AMPA:
        Ron_a' = (synon_a*Rinf_a - Ron_a)/Rtau_a
        Roff_a' = -Beta_a*Roff_a
    : NMDA:
        Ron_b' = (synon_b*Rinf_b - Ron_b)/Rtau_b
        Roff_b' = -Beta_b*Roff_b
}

FUNCTION Mgblock(v(mV)) {
	TABLE 
	DEPEND mg_b
	FROM -140 TO 80 WITH 1000

	Mgblock = 1 / (1 + exp(0.062 (/mV) * -v) * (mg_b / 3.57 (mM)))
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

NET_RECEIVE(weight, r0_a, r0_b, t0 (ms), t0_a (ms), t0_b (ms), toss) {
    : Non-saturating synapse capable of summating over separate streams.
    : weight, r0_a, r0_b, t0, t0_a, t0_b toss are per stream and all
    : except weight are initialised to 0.
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
                : AMPA:
                    r0_a = r0_a*exp(-Beta_a*(t - t0_a))
                    t0_a = t
                    synon_a = synon_a + weight
                    Ron_a = Ron_a + r0_a
                    Roff_a = Roff_a - r0_a
                    : come again in Cdur_a with flag = 1
                    net_send(Cdur_a, 1)
                : NMDA:
                    r0_b = r0_b*exp(-Beta_b*(t - t0_b))
                    t0_b = t
                    synon_b = synon_b + weight
                    Ron_b = Ron_b + r0_b
                    Roff_b = Roff_b - r0_b
                    : come again in Cdur_b with flag = 2
                    net_send(Cdur_b, 2)
            }
        }
    } else if (flag == 1) { : if this associated with last spike then turn off
		r0_a = weight*Rinf_a + (r0_a - weight*Rinf_a)*exp(-(t - t0_a)/Rtau_a)
		t0_a = t
		synon_a = synon_a - weight
		Ron_a = Ron_a - r0_a
		Roff_a = Roff_a + r0_a
	} else if (flag == 2) { : if this associated with last spike then turn off
		r0_b = weight*Rinf_b + (r0_b - weight*Rinf_b)*exp(-(t - t0_b)/Rtau_b)
		t0_b = t
		synon_b = synon_b - weight
		Ron_b = Ron_b - r0_b
		Roff_b = Roff_b + r0_b
	}
}