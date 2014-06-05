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

def meshview(vec1, vec2, vec3, geom='cart'):
    
    if geom.lower() in ('cart', 'cartesian', 'rect'):
        
        x, y, z = np.meshgrid(vec1, vec2, vec3)
        
    elif geom.lower() in ('spherical', 'sphere', 'polar'):
        
        r, theta, phi = np.meshgrid(vec1, vec2, vec3)
        
        x = r*np.cos(theta)*np.sin(phi)
        y = r*np.sin(theta)*np.sin(phi)
        z = r*np.cos(phi)
    
    return np.c_[x.ravel(), y.ravel(), z.ravel()]  

class CartesianView:
    
    def __getitem__(self, idx):
        
        vec1 = self._slice2range(idx[0])
        vec2 = self._slice2range(idx[1])
        vec3 = self._slice2range(idx[2])
        
        return meshview(vec1, vec2, vec3, geom='cart')
    
    def _slice2range(self, idx):
        
        if isinstance(idx.step, complex):
            return np.linspace(idx.start, idx.stop, abs(idx.step), 
                endpoint=True)
        else:
            return np.arange(idx.start, idx.stop, idx.step)

class SphericalView:
    
    def __getitem__(self, idx):
        
        vec1 = self._slice2range(idx[0])
        vec2 = self._slice2range(idx[1])
        vec3 = self._slice2range(idx[2])
        
        return meshview(vec1, vec2, vec3, geom='sphere')
    
    def _slice2range(self, idx):
        
        if isinstance(idx.step, complex):
            return np.linspace(idx.start, idx.stop, abs(idx.step), 
                endpoint=True)
        else:
            return np.arange(idx.start, idx.stop, idx.step)

mcview = CartesianView()
msview = SphericalView()


