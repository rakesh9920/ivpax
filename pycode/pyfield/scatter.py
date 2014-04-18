# pyfield / scatter.py
import h5py
import numpy as np
import scipy as sp

def cube(outpath, dims=None, center=None, vel=None, nframe=None, ns=None, 
    prf=None):
    
    center = np.array(center)
    vel = np.array(vel)
    
    ntarget = int(round(dims[0]*dims[1]*dims[2]*ns))
    
    x = sp.rand(ntarget, 1)*dims[0]
    y = sp.rand(ntarget, 1)*dims[1]
    z = sp.rand(ntarget, 1)*dims[2]
    
    pos = np.concatenate((x, y, z), axis=1) + center
    amp = np.ones((ntarget, 1))
    
    root = h5py.File(outpath[0], 'a')
    path = outpath[1]
    
    if path in root:
        del root[path]
    
    dset = root.create_dataset(path, shape=(ntarget, 4, nframe), dtype='double',
        compression='gzip')
    
    dset[:,:,0] = np.concatenate((pos, amp), axis=1)
    
    for f in xrange(1, nframe):
        
        new_pos = pos + vel/prf*f
        dset[:,:,f] = np.concatenate((new_pos, amp), axis=1)
    
    