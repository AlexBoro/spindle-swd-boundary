function inds = findRange(t, range)
i1 = findInd(t, range(1));
i2 = findInd(t, range(2)) - 1;
inds = [i1 i2];