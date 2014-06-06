# pyfield / beamform / imaging.py

import scipy as sp
import numpy as np
import matplotlib.pyplot as plt

def envelope(bfdata, axis=-1):
    
    envdata = np.abs(sp.signal.hilbert(bfdata, axis=axis))
    
    return envdata
    
def imdisp(img, r=None, phi=None, dyn=60, cmap=plt.cm.gray, interp='none'):
    
    maxval = np.max(img)
    dbimg = 20*np.log10(img/maxval)
    
    dbimg[dbimg < -dyn] = -dyn
    
    norm = plt.Normalize()
    norm.autoscale(dbimg)
    
    if r is None:
        
        plt.imshow(dbimg, cmap=cmap, interpolation=interp, norm=norm)
        
    else:
        
        if isinstance(r, slice):
            
            rslice = slice(r.start - r.step/2, r.stop + r.step/2, r.step)
            
        else:
            
            rmin = np.min(r)
            rmax = np.max(r)
            rstep = (rmax - rmin)/r.size
            
            rslice = np.linspace(rmin - rstep/2, rmax + rstep/2, r.size + 1, 
                endpoint=True)
            #rslice = slice(rmin - rstep/2, rmax + rstep/2, rstep)
        
        if isinstance(phi, slice):
            
            phislice = slice(phi.start - phi.step/2, phi.stop + phi.step/2, 
                phi.step)
                
        else:
            
            phimin = np.min(phi)
            phimax = np.max(phi)
            phistep = (phimax - phimin)/phi.size
            
            phislice = np.linspace(phimin - phistep/2, phimax + phistep/2, 
                phi.size + 1, endpoint=True)
             
        #x, _, z = msview[rslice, 0:1:1, phislice]
        x, y, z = meshview(rslice, 0, phislice, geom='sphere')
        x = np.squeeze(x)
        z = np.squeeze(z)
        
        
        if interp is True:
            plt.pcolormesh(x, z, dbimg.reshape(np.array(x.shape)-1),
                shading='gourad', cmap=cmap, norm=norm) 
        else:
            plt.pcolormesh(x, z, dbimg.reshape(np.array(x.shape)-1),
                shading='flat', edgecolor='None', cmap=cmap, norm=norm) 
        
        plt.gca().set_aspect('equal', 'datalim')
        plt.gca().set_aspect('equal', 'box')
        

def imdisp3d(x, y, z, img, dyn=60, cmap=plt.cm.gray, ax=None, azim=90, elev=0):
    
    maxval = np.max(np.abs(img))
    dbimg = 20*np.log10(np.abs(img)/maxval)
    
    dbimg[dbimg < -dyn] = -dyn
    
    if ax is None:
        fig = plt.figure()
        ax = fig.add_subplot(111, projection='3d')
    
    norm = plt.Normalize()
    norm.autoscale(dbimg)
    
    ax.plot_surface(x, y, z, cstride=1, rstride=1, facecolors=cmap(norm(dbimg)))
    ax.azim = azim
    ax.elev = elev
    
    return ax

def meshview(vec1, vec2, vec3, geom='cart'):
    
    if geom.lower() in ('cart', 'cartesian', 'rect'):
        
        x, y, z = np.meshgrid(vec1, vec2, vec3)
        
    elif geom.lower() in ('spherical', 'sphere', 'polar'):
        
        r, theta, phi = np.meshgrid(vec1, vec2, vec3)
        
        x = r*np.cos(theta)*np.sin(phi)
        y = r*np.sin(theta)*np.sin(phi)
        z = r*np.cos(phi)
    
    #return np.c_[x.ravel(), y.ravel(), z.ravel()]  
    return x, y, z

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


