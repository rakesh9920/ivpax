# mlfmm / translations.py

import numpy as np
from scipy.special import sph_harm, jn, yv, lpmv
from scipy.misc import factorial
from mlfmm.wigner3j import wigner3j


def sph2cart(points, cat=True):

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
    
def mec(q, points, center, k, rho, c, l, m):
    '''
    Return the multipole expansion coefficient of degree l and order m for a
    given source distribution and origin.
    '''
    delta_r = points - center
    r, theta, phi = cart2sph(delta_r, cat=False)

    #coeff = np.sqrt(4*np.pi/(2*l + 1))*np.sum(q*r**l*np.conj(sph_harm(m, l,
        #phi, theta)))
    
    #coeff = 1j*k*np.sum(q*sphjn(l, k*r)*np.conj(sph_harm(m, l, theta, phi)))
    coeff = -k**2*rho*c*np.sum(q*sphjn(l, k*r)*np.conj((-1)**m*sph_harm(m, l, 
        theta, phi))) 

     
    return coeff

def mpole_coeff(q, points, center, k, rho, c, order):
    '''
    '''
    coeff = []
    
    for l in xrange(order + 1):
        for m in xrange(-l, l + 1): 
            coeff.append(mec(q, points, center, k, rho, c, l, m))
    
    return coeff

def mpole_eval(coeff, points, center, k):
    '''
    '''
    delta_r = points - center
    r, theta, phi = cart2sph(delta_r, cat=False)
    
    idx = 0
    pres = np.zeros(points.shape[0], dtype='cfloat')
    
    for l in xrange(np.sqrt(len(coeff)).astype(int)):
        
        for m in xrange(-l, l + 1):
            
            pres += coeff[idx]*sphhankel1(l, k*r)*(-1)**m*sph_harm(m, l, theta, 
                phi)
            idx += 1
    
    return pres

def local_eval(coeff, points, center, k):
    pass

def m2m(coeff, center1, center2, k):
    
    def c(l1, l2, l3, m1, m2, m3):
        
        ret = wigner3j(l1, l2, l3, -m1, m2, m3)*wigner3j(l1, l2, l3, 0, 0, 0)* \
            np.sqrt((2*l1+1)*(2*l2+1)*(2*l3+1)/(4*np.pi))#*1j**(l2 + l3 - 1)
        
        return ret
    
    delta_r = center2 - center1
    #delta_r = center1 - center2
    #x = delta_r[0,0]

    r, theta, phi = cart2sph(delta_r, cat=False)

    ncoeff = np.sqrt(len(coeff)).astype(int)
    #ret = np.zeros(len(coeff), dtype='cfloat')
    ret = []
    idx1 = 0
    
    for l1 in xrange(ncoeff):
        for m1 in xrange(-l1, l1 + 1):
            
            new_coeff = 0
            idx2 = 0
            
            for l2 in xrange(ncoeff):
                for m2 in xrange(-l2, l2 + 1):
                    
                    old_coeff = coeff[idx2]
                    m3 = m1 - m2
                    
                    for l3 in xrange(np.abs(l1 - l2), l1 + l2 + 1):
                        
                        if np.abs(m3) > l3:
                            continue
                            
                        #new_coeff += old_coeff*wigner3j(l1, l2, l3, m1, m2, 
                        #    m3)*4*np.pi*sphjn(l3, k*x)*np.conj(sph_harm(m3, l3,
                        #    theta, phi))*1j**(l2 + l3 - 1)
                        
                        new_coeff += old_coeff*c(l1, l2, l3, m1, m2, m3)*4* \
                            np.pi*sphjn(l3, k*r)*np.conj(sph_harm(m3, l3,
                            theta, phi))

                    idx2 += 1
                
            #ret[idx1] = new_coeff[0]
            ret.append(new_coeff[0])
            idx1 += 1
    
    return ret
 
def l2l(coeff, center1, center2, k):
    
    return m2m(coeff, center1, center2, k)
       
def m2l():
    pass

