NEURON {
	POINT_PROCESS HalfGap
	ELECTRODE_CURRENT i
	RANGE r, i, vgap
}

PARAMETER {
	r = 1e9 (megohm)    : should be not too small to avoid producing membrane potential oscillations
}

ASSIGNED {
    v (millivolt)
    vgap (millivolt)
	i (nanoamp)
}

BREAKPOINT {
	i = (vgap - v)/r
}
