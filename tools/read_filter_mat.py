import sys, os; # requires h5py (MATLAB v7.3 files are HDF5)
import h5py, numpy as np
f=h5py.File("model/thalamocortical2/filter.mat","r")
def s(ds):  # uint16 char array -> str
    return "".join(chr(c) for c in np.array(ds).ravel())
print("top-level b:", np.array(f['b']).ravel())
print("top-level a:", np.array(f['a']).ravel())
d=f['#refs#/d']
print("\nfspecs (ref d), class =", s(d['class']))
for k in ['Fs','Fpass1','Fpass2','Fstop1','Fstop2','Apass','Astop1','Astop2','NormalizedFrequency']:
    print("  %-20s %s"%(k, np.array(d[k]).ravel()))
c=f['#refs#/c/CaptureState/fspecs_bpmin']
print("\nCaptureState fspecs_bpmin, Fs =", s(c['Fs']))
for k in ['Fpass1','Fpass2','Fstop1','Fstop2','Apass','Astop1','Astop2','NormalizedFrequency']:
    print("  %-20s %s"%(k, np.array(c[k]).ravel()))
print("  ResponseType:", s(c['ResponseType']))
B=f['#refs#/B']
sos=np.array(B['refsosMatrix']).T   # stored transposed
sv=np.array(B['refScaleValues']).ravel()
print("\nrefsosMatrix shape", sos.shape, " scaleValues n=", sv.size)

print(sos[:3])
print("designmethod:", s(B['designmethod']), "| class:", s(B['class']))
