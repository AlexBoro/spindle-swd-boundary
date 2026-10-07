TITLE K+ leak current

COMMENT
    A potasium leak current. Used in cortical neurons; reduced under
    cholinergic activation.

    Written by Martynas Dervinis @Cardiff University, 2014.

ENDCOMMENT

NEURON {
    SUFFIX kleak
    NONSPECIFIC_CURRENT i
    RANGE i, e, g
}

PARAMETER {
    g = 0.025E-4 (siemens/cm2) < 0, 1e9 >
    e = -90      (millivolt)
}

ASSIGNED {
    i (milliamp/cm2)
    v (millivolt)
}

BREAKPOINT {
    i = g*(v - e)
}