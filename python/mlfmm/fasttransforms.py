# mlfmm / fasttransforms.py

import numpy as np
from scipy.special import sph_harm, jn, yv, lpmv, eval_legendre, hankel1, lpmn
from scipy.misc import factorial
from numpy.polynomial.legendre import leggauss
from scipy.fftpack import fft, ifft

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

def dir2coord(kdir):
    
    theta = kdir[:,:,0]
    phi = kdir[:,:,1]
    
    x = np.cos(theta)*np.sin(phi)
    y = np.sin(theta)*np.sin(phi)
    z = np.cos(phi)
    
    kcoord = np.concatenate((x[...,None], y[...,None], z[...,None]), axis=2)
    
    return kcoord


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

def sphhankel12(l, z):
    '''
    Spherical Hankel function of the first kind.
    '''
    return sphjn(l, z) + 1j*sphyv(l, z)

def sphhankel1(l, z):
    return np.sqrt(np.pi/(2*z))*hankel1(l + 0.5, z)
    
def sphharm(l, m, theta, phi):
    
    ret = np.sqrt((2*l + 1)/(4*np.pi)*factorial(l - m)/ \
        factorial(l + m))*lpmv(m, l, np.cos(phi))* \
        np.exp(1j*m*theta)
    
    return ret

def mag(r, axis=-1):
    
    return np.sqrt(np.sum(r**2, axis=axis, keepdims=True))
    
def ffcoeff(q, srcpos, centerpos, k, kcoord):
    '''
    Returns the far-field signature coefficients of a collection of sources in
    the specified directions.
    '''
    delta_r = centerpos - srcpos
    ntheta, nphi = kcoord.shape[:2]
    #kpos = sph2cart(np.c_[np.ones_like(ktheta), ktheta, kphi], cat=True)
    
    coeff = np.zeros((ntheta, nphi), dtype='complex')
    
    for i in xrange(ntheta):
        for j in xrange(nphi):
            
            coeff[i, j] = np.sum(q*np.exp(1j*k*delta_r.dot(kcoord[i,j,:])))
        
    return coeff
    
def ffeval(coeff, fieldpos, centerpos, weights, k, kcoord, order, rho, c):
    '''
    Evaluates the acoustic field at a specified point using far-field
    signature coefficients.
    '''
    #kpos = sph2cart(np.c_[np.ones_like(ktheta), ktheta, kphi], cat=True)
    delta_pos = fieldpos - centerpos
    #ndir = kdir.shape[0]
    
    #total = 0
    
    #for i in xrange(ndir):
        #total += weights[i]*mlop(delta_pos, k, kdir[i,:], order)*coeff[i]
            
    total = np.sum(weights.ravel()*mlop(delta_pos, k, kcoord, order)* \
        coeff.ravel(), axis=1)
    
    return -k**2*rho*c/(16*np.pi**2)*total
    
def nfeval(coeff, weights):
    '''
    Evaluates the acoustic field at a specified point using near-field
    signature coefficients.
    '''
    pass

def mlop(pos, k, kcoord, order):
    '''
    M_L operator used in evaluation and translation of multipole expansions.
    '''
    #kpos = sph2cart(np.c_[np.ones_like(ktheta), ktheta, kphi], cat=True)
    
    #r, theta, phi = cart2sph(pos, cat=False)
    r = mag(pos)
    #rhat = pos/r[[Ellipsis,] + [None for x in range(pos.ndim - 1)]]
    rhat = pos/mag(pos)
     
    kcoord = kcoord.reshape((-1,3))
    
    npos = pos.shape[0]
    ndir = kcoord.shape[0]

    total = np.zeros((npos, ndir), dtype='complex')
    
    for l in xrange(order + 1):
        total += (2*l + 1)*(1j**l)*sphhankel1(l, k*r)*eval_legendre(l, 
            rhat.dot(kcoord.T))
    
    return total

def quadrule(order):
    '''
    Returns abscissas (in theta/phi form) and weights for a 
    Legendre-Gauss quadrature rule for integration over a unit sphere.
    '''
    absc1, w1 = leggauss(2*order)
    absc2, w2 = leggauss(order)
    
    theta = (absc1 + 1)*np.pi
    phi = (absc2 + 1)*np.pi/2
    
    weights1 = w1*np.pi
    weights2 = w2*np.pi/2*np.sin(phi)
    weights = weights1[:,None].dot(weights2[None,:])
    
    #weights = w1[:,None].dot((w2*np.sin(phi)*np.pi**2/2)[None,:])
    #absc = np.array([(a,b) for a in theta for b in phi])
    #kdir = sph2cart(np.c_[np.ones(absc.shape[0]), absc])
    
    ntheta = theta.shape[0]
    nphi = phi.shape[0]
    
    kdir = (np.tile(theta[:,None, None], (1, nphi, 1)), 
        np.tile(phi[None,:, None], (ntheta, 1, 1)))
    
    kdir = np.concatenate(kdir, axis=2)
    
    return kdir, weights, weights1, weights2

def quadrule2(order):
    
    absc1 = np.linspace(0, 2*np.pi, 2*order)
    w1 = np.ones(2*order)*2*np.pi/(2*order - 1)
    w1[0] = w1[0]/2
    w1[-1] = w1[-1]/2
    weights1 = w1
    theta = absc1
    
    absc2, w2 = leggauss(order)
    
    #theta = (absc1 + 1)*np.pi
    phi = (absc2 + 1)*np.pi/2
    
    weights2 = w2*np.pi/2*np.sin(phi)
    weights = weights1[:,None].dot(weights2[None,:])
    
    ntheta = theta.shape[0]
    nphi = phi.shape[0]
    
    kdir = (np.tile(theta[:,None, None], (1, nphi, 1)), 
        np.tile(phi[None,:, None], (ntheta, 1, 1)))
    
    kdir = np.concatenate(kdir, axis=2)
    
    return kdir, weights, weights1, weights2

def ff2nfop(startpos, endpos, kdir, order):
    pass

def ff2ffop(startpos, endpos, k, kdir):
    pass

def lpml(m, l, z):
    
    z = z.ravel()
    out = np.zeros((m + 1, l + 1, z.size))
    
    for ind in xrange(z.size):
        out[..., ind] = lpmn(m, l, z[ind])[0]
    
    return out

def interpolate(coeff, weights, kdir, newkdir):
    
    M, L = kdir.shape[:2]
    kphi = kdir[0,:,1]
    newL = newkdir.shape[1]
    newkphi = newkdir[0,:,1]
    
    b_m = fft(coeff, axis=0)
    
    b_lm = np.sum(weights[None,None,:]*lpml(L - 1, L - 1, np.cos(kphi))*
        b_m[:L,None,:], axis=2)

    newcoeff = ifft(np.sum(b_lm[:,:,None]*lpml(L - 1, L - 1, np.cos(newkphi)), 
        axis=1), axis=0, n=newL*2)

    return newcoeff, b_lm

def filter(coeff, order):
    pass






    



