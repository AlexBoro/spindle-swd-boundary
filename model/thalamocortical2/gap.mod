NEURON {
	POINT_PROCESS gap
	NONSPECIFIC_CURRENT i
	RANGE r, i
	POINTER vgap
}
PARAMETER {
	r = 1e10 (megohm)   : should be not too small to avoid producing membrane potential oscillations
}
ASSIGNED {
    v (millivolt)
	vgap (millivolt)
	i (nanoamp)
}
BREAKPOINT {
	i = (v - vgap)/r
}

