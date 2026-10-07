TITLE Spontaneuos (miniature) post-synaptic potentials (sPSPs or minis) in an isolated cell

COMMENT
    Based on minis.mod with no inputs.

ENDCOMMENT

NEURON	{ 
  ARTIFICIAL_CELL minisI
  RANGE noise, interval
  THREADSAFE : only true if every instance has its own distinct Random
  POINTER donotuse
}

PARAMETER {
	noise = 1 <0,1>         : amount of randomness (0.0 - 1.0)
    interval = 100 (ms)     : the mean interval for minis generation
}

ASSIGNED {
	event (ms)      : latency of the next mini
	donotuse
}

INITIAL {
    if (noise < 0) {
        noise = 0
    }
    if (noise > 1) {
        noise = 1
    }
    event = invl(interval)  : generate the first mini and place it in a que
    if (event < 1e-9) { event = 1e-9 }
    net_send(event, 1)
}

PROCEDURE seed(x) {
	set_seed(x)
}

FUNCTION invl(mean (ms)) { : get the timing of the next event
    if (noise == 0) {
		invl = mean
	}else{
		invl = (1. - noise)*mean + noise*mean*erand()   : fixed + noise parts
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
		erand = exprand(1)
VERBATIM
	}
ENDVERBATIM
}

PROCEDURE noiseFromRandom() {   : call from hoc to supply a ref to a Random() class object
                                : must have a negexp(1) distribution (see NEURON's documentation)
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

NET_RECEIVE (w) {
    if (flag == 1) { : internal event
		net_event(t)            : send the signal to a down-stream NetCon (only one!)
        event = invl(interval)  : generate a new mini and place it in a que
        if (event < 1e-9) { event = 1e-9 }
        net_send(event, 1)
	}
}
