# mlfmm / fasttransforms.py

import numpy as np
from scipy.special import sph_harm, jn, yv, lpmv, eval_legendre
from scipy.misc import factorial
from numpy.polynomial.legendre import leggauss

def sph2cart(points, cat=True):
    '''
    Coordinate transform from spherical to cartesian.
    '''
    if points.ndim < 2:
        points = points[None,:]
        
    x = points[:,0]*np.cos(points[:,1])*np.sin(points[:,2])
    y = points[:,0]*np.sin(points[:,1])*np.sin(points[:,2])
    z = points[:,0]*np.cos(points[:,2])
    
    if cat:
        return np.c_[x, y, z]
    else:
        return x, y, z
    
def cart2sph(points, cat=True):
    '''
    Coordinate transform from cartesian to spherical.
    '''
    # theta is azimuth angle (longitudinal)
    # phi is polar angle (colatitude)
    
    if points.ndim < 2:
        points = points[None,:]
        
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

def sph_jn(l, z):
    '''
    Spherical Bessel function of the first kind.
    '''
    if z == 0:
        return z**l/np.product(np.arange(1, 2*l + 3, 2))
    else:
        return np.sqrt(np.pi/(2*z))*jn(l + 0.5, z)

sphjn = np.vectorize(sph_jn)

def sph_yv(l, z):
    '''
    Spherical Bessel function of the second kind.
    '''
    if z == 0:
        return -np.inf
    else:
        return np.sqrt(np.pi/(2*z))*yv(l + 0.5, z)

sphyv = np.vectorize(sph_yv)

def sphhankel1(l, z):
    '''
    Spherical Hankel function of the first kind.
    '''
    return sphjn(l, z) + 1j*sphyv(l, z)

def sphharm(l, m, theta, phi):
    
    ret = np.sqrt((2*l + 1)/(4*np.pi)*factorial(l - m)/ \
        factorial(l + m))*lpmv(m, l, np.cos(phi))* \
        np.exp(1j*m*theta)
    
    return ret

def ffcoeff(q, srcpos, centerpos, k, kdir):
    '''
    Returns the far-field signature coefficients of a collection of sources in
    the specified directions.
    '''
    delta_r = centerpos - srcpos
    ndir = kdir.shape[0]
    #kpos = sph2cart(np.c_[np.ones_like(ktheta), ktheta, kphi], cat=True)
    
    coeff = np.zeros(ndir)
    
    for i in xrange(ndir):
        coeff[i] = np.sum(q*np.exp(1j*k*delta_r.dot(kdir[i,:])))
        
    return coeff

def mag(r):
    
    return np.sqrt(np.sum(r**2))
    
def ffeval(coeff, fieldpos, centerpos, weights, k, kdir, order, rho, c):
    '''
    Evaluates the acoustic field at a specified point using far-field
    signature coefficients.
    '''
    #kpos = sph2cart(np.c_[np.ones_like(ktheta), ktheta, kphi], cat=True)
    delta_pos = fieldpos - centerpos
    ndir = kdir.shape[0]
    
    total = 0
    
    for i in xrange(ndir):
        total += weights[i]*mlop(delta_pos, k, kdir[i,:], order)*coeff[i]
            
    return 1j*k*rho*c/(4*np.pi)*total
    
def nfeval(coeff, weights):
    '''
    Evaluates the acoustic field at a specified point using near-field
    signature coefficients.
    '''
    pass

def mlop(pos, k, kdir, order):
    '''
    M_l operator used in evaluation and translation of multipole expansions.
    '''
    #kpos = sph2cart(np.c_[np.ones_like(ktheta), ktheta, kphi], cat=True)
    
    r, theta, phi = cart2sph(pos, cat=False)
    
    total = 0
    
    for l in xrange(order + 1):
        total += (2*l + 1)*1j**l*sphhankel1(l, k*r)*eval_legendre(l, 
            pos.dot(kdir))
    
    return total

def quadrule(order):
    '''
    Returns abscissas (in cartesian coordinates) and weights for a 
    Legendre-Gauss quadrature rule for integration over a unit sphere.
    '''
    absc1, w1 = leggauss(2*order)
    absc2, w2 = leggauss(order)
    
    theta = (absc1 + 1)*np.pi
    phi = (absc2 + 1)*np.pi/2
    
    weights = w1[:,None].dot((w2*np.sin(phi)*np.pi**2/2)[None,:]).ravel()
    absc = np.array([(a,b) for a in theta for b in phi])
    kdir = sph2cart(np.c_[np.ones(absc.shape[0]), absc])
    
    return kdir, weights
 
def ff2nfop(startpos, endpos, ktheta, kphi, order):
    pass

def ff2ffop(startpos, endpos, k, ktheta, kphi):
    pass

#def ff2ff():
#    pass
#
#def ff2nf():
#    pass

def interpolate():
    pass

def filter():
    pass






    



