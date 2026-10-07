function ind = findInd(t, t1)
t1 = t - t1;
t1(t1<0) = 0;
ind = find(t1,1);