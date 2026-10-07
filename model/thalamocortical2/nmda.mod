TITLE minimal model of NMDA receptors

COMMENT
-----------------------------------------------------------------------------

	Minimal kinetic model for glutamate NMDA receptors
	==================================================

  Model of Destexhe, Mainen & Sejnowski, 1994:

	(closed) + T <-> (open)

  The simplest kinetics are considered for the binding of transmitter (T)
  to open postsynaptic receptors.   The corresponding equations are in
  similar form as the Hodgkin-Huxley model:

	dr/dt = alpha * [T] * (1-r) - beta * r

	I = gmax * [open] * B(V) * (V-Erev)

  where [T] is the transmitter concentration and r is the fraction of 
  receptors in the open form.  B(V) represents the voltage-dependent 
  Mg++ block (see Jahr & Stevens J Neurosci 10: 1830, 1990; Jahr & Stevens
  J Neurosci 10: 3178, 1990).

  If the time course of transmitter occurs as a pulse of fixed duration,
  then this first-order model can be solved analytically, leading to a very
  fast mechanism for simulating synaptic currents, since no differential
  equation must be solved (see Destexhe, Mainen & Sejnowski, 1994).

-----------------------------------------------------------------------------

  Based on voltage-clamp recordings of NMDA receptor-mediated currents in rat
  hippocampal slices (Hessler et al., Nature 366: 569-572, 1993), this model 
  was fit directly to experimental recordings in order to obtain the optimal
  values for the parameters (see Destexhe, Mainen and Sejnowski, 1996).

-----------------------------------------------------------------------------

  This mod file includes a mechanism to describe the time course of transmitter
  on the receptors.  The time course is approximated here as a brief pulse
  triggered when the presynaptic compartment produces an action potential.
  The pointer "pre" represents the voltage of the presynaptic compartment and
  must be connected to the appropriate variable in oc.

-----------------------------------------------------------------------------

  See details in:

  Destexhe, A., Mainen, Z.F. and Sejnowski, T.J.  An efficient method for
  computing synaptic conductances based on a kinetic model of receptor binding
  Neural Computation 6: 10-14, 1994.  

  Destexhe, A., Mainen, Z.F. and Sejnowski, T.J.  Kinetic models of 
  synaptic transmission.  In: Methods in Neuronal Modeling (2nd edition; 
  edited by Koch, C. and Segev, I.), MIT press, Cambridge, 1998, pp. 1-28.

  (electronic copy available at http://cns.iaf.cnrs-gif.fr)

  Written by Alain Destexhe, Laval University, 1995
  27-11-2002: the pulse is implemented using a counter, which is more
       stable numerically (thanks to Yann LeFranc)

-----------------------------------------------------------------------------
ENDCOMMENT

NEURON {
	POINT_PROCESS NMDA_S
	RANGE g, gbar, Cmax, Cdur, Alpha, Beta, Erev, Rinf, Rtau, refractory, mg, P_release
	NONSPECIFIC_CURRENT i
    THREADSAFE : only true if every instance has its own distinct Random
    POINTER donotuse
}
UNITS {
	(nA) = (nanoamp)
	(mV) = (millivolt)
	(umho) = (micromho)
	(mM) = (milli/liter)
    (msM)	= (ms mM)
}

PARAMETER {
    gbar    = 0.0006 (umho)  : maximal conductance according to Destexhe: 0.00001-0.0006
	Cdur	= 0.3	 (ms)	 : transmitter duration (rising phase)
    Cmax	= 0.5	 (mM)	 : max transmitter concentration
	Alpha	= 0.94	 (/msM)	 : forward (binding) rate
	Beta	= 0.18	 (/ms)	 : backward (unbinding) rate
	Erev	= 0      (mV)    : reversal potential
    refractory = 0   (ms)    : refractory period
	mg      = 1      (mM)    : external magnesium concentration
    P_release = 1 <0,1>      : release probability (0.0 - 1.0)
}

ASSIGNED {
	v		(mV)		: postsynaptic voltage
	i 		(nA)		: current = g*(v - Erev)
	g 		(umho)		: conductance
	Rinf				: steady state channels open
	Rtau	(ms)		: time constant of channel binding
	B                   : magnesium block
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
	B = mgblock(v)              : B is the block by magnesium at this voltage
	g = gbar*B*(Ron + Roff)
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
    if (flag == 0) { : a spike, so turn on if not already in a Cdur pulse
        if (t - t0 > refractory && P_release > 0) {
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
    }
	if (flag == 1) { : if this associated with last spike then turn off
		r0 = weight*Rinf + (r0 - weight*Rinf)*exp(-(t - t0_a)/Rtau)
		t0_a = t
		synon = synon - weight
		Ron = Ron - r0
		Roff = Roff + r0
	}
}

FUNCTION mgblock(v(mV)) {
	TABLE 
	DEPEND mg
	FROM -140 TO 80 WITH 1000

	mgblock = 1 / (1 + exp(0.062 (/mV) * -v) * (mg / 3.57 (mM)))
}
