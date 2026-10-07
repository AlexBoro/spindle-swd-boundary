TITLE Na+ leak current

COMMENT
    A substance P-activated non-specific cation leak current (I_SP)
    mediated by NALCN protein [1]. The channel protein is densly expressed
    in the central nervous system, including the neocortex and the thalamus
    [2]. The properties of this current were characterised in the past with
    its reversal potential being ~10 mV [3].

    References:
    [1] Lu, B., Su, Y., Das, S., Liu, J., Xia, J., and Ren, D. The
        Neuronal Channel NALCN Contributes Resting Sodium Permeability and
        Is Required for Normal Respiratory Rhythm. Cell, 129: 371-383, 2007.
    [2] Lee, J.-H., Cribbs, L. L., and Perez-Reyes, E. Cloning of a novel
        four repeat protein related to voltage-gated sodium and calcium
        channels. FEBS Letters, 445: 231-236, 1999.
    [3] Lu, B., Su1, Y., Das, S., Wang, H., Wang, Y., Liu, J., and Ren, D.
        Peptide neurotransmitters activate a cation channel complex of
        NALCN and UNC-80. Nature, 457: 741-745, 2009.

    Written by Martynas Dervinis @Cardiff University, 2013.

ENDCOMMENT

NEURON {
    SUFFIX naleak
    NONSPECIFIC_CURRENT i
    RANGE i, e, g
}

PARAMETER {
    g = 0.001 (siemens/cm2) < 0, 1e9 >
    e = 10   (millivolt)
}

ASSIGNED {
    i (milliamp/cm2)
    v (millivolt)
}

BREAKPOINT {
    i = g*(v - e)
}