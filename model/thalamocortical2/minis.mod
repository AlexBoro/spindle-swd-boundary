TITLE Spontaneuos (miniature) post-synaptic potentials (sPSPs or minis)

COMMENT
    The minis follow the experimental data in [1]. However, the mean rate
    of minis is not a continuous time-dependent function but a step
    function with the initial mean rate of 0.005 (corresponding to 200 ms
    average interval and a frequency of 5 Hz) followed by a step to 0.01
    (100 ms; 10 Hz). These numbers are correct with a single source
    (synapse) of minis. When there are more synapses the intervals should
    be multiplied by a factor corresponding to the number of synpses in
    order to keep the average minis rate per cell independent from the
    number of synapses. The implementation of the mod file is based on the
    NEURON's native NetStim.mod.

    References:
    [1] Timofeev, I., Grenier, F., Bazhenov, M., Sejnowski, T.J., and
        Steriade, M. Origin of Slow Cortical Oscillations in Deafferented
        Cortical Slabs. Cerebral Cortex, 10:1185-1199, 2000.

ENDCOMMENT

NEURON	{ 
  ARTIFICIAL_CELL minis
  RANGE noise, interval1, dur, interval2
  THREADSAFE : only true if every instance has its own distinct Random
  POINTER donotuse
}

PARAMETER {
	noise = 1 <0,1>         : amount of randomness (0.0 - 1.0)
    interval1 = 200 (ms)    : the mean interval for minis generation following a spike
    dur = 1000 (ms)         : the duration of the minis depression following the spike
    interval2 = 100 (ms)    : the mean interval following dur
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

NET_RECEIVE (w, t0 (ms)) {
    : w and t0 are per stream (could be more than a single input)
    INITIAL {
        t0 = -dur
        event = invl(interval2)   : generate the first mini and place it in a que
        if (event < 1e-9) { event = 1e-9 }
        net_send(event, 1)
    }

	if (flag == 0) { : external event
        if (w > 0) {
            t0 = t
            event = invl(interval1) : the minis generation rate initially drops following an action potential
            if (event < 1e-9) { event = 1e-9 }
            net_move(t+event)
		}
	} else if (flag == 1) { : internal event
		net_event(t)    : send the signal to a down-stream NetCon (only one!)
        if ((t-t0) > 1000) {
            event = invl(interval2)   : generate a new mini and place it in a que (regular generation rate)
        } else {
            event = invl(interval1)
        }
        if (event < 1e-9) { event = 1e-9 }
        net_send(event, 1)
	}
}
