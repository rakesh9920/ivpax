# mlfmm / translations.py

import numpy as np
from scipy.special import hankel1, sph_harm


def sph2cart(points, cat=True):
    
    x = points[:,0]*np.cos(points[:,1])*np.sin(points[:,2])
    y = points[:,0]*np.sin(points[:,1])*np.sin(points[:,2])
    z = points[:,0]*np.cos(points[:,2])
    
    if cat:
        return np.c_[x, y, z]
    else:
        return x, y, z
    
def cart2sph(points, cat=True):
    
    # theta is polar angle (colatitude)
    # phi is azimuthal (longitude)
    
    hypotxy = np.hypot(points[:,0], points[:,1])
    r = np.hypot(hypotxy, points[:,2])
    theta = np.arctan2(points[:,1], points[:,0])
    phi = np.arctan2(hypotxy, points[:,2])
    #r = np.sqrt(points[:,0]**2 + points[:,1]**2 + points[:,2]**2)
    #phi = np.arccos(points[:,2]/r)
    
    if cat:
        return np.c_[r, theta, phi]
    else:
        return r, theta, phi
    
def mec(q, points, center, l, m):
    '''
    Return the multipole expansion coefficient of degree l and order m for a
    given source distribution and origin.
    '''
    delta_r = points - center
    r, theta, phi = cart2sph(delta_r, cat=False)

    coeff = np.sqrt(4*np.pi/(2*l + 1))*np.sum(q*r**l*np.conj(sph_harm(m, l,
        phi, theta)))
    
    return coeff

def m2m():
    pass
 
def l2l():
    pass
       
def m2l():
    pass

