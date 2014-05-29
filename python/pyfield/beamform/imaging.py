# pyfield / beamform / imaging.py

import scipy as sp
import numpy as np
import matplotlib.pylab as pylab

def envelope(bfdata, axis=-1):
    
    envdata = np.abs(sp.signal.hilbert(bfdata, axis=axis))
    
    return envdata
    
def imdisp(img, dyn=60, cmap='gray', interp='none'):
    
    maxval = np.max(np.abs(img))
    dbimg = 20*np.log10(np.abs(img)/maxval)
    
    dbimg[dbimg < -dyn] = -dyn
    
    pylab.imshow(dbimg, cmap=cmap, interpolation=interp)
    
    
    

