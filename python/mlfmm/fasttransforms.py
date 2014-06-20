# mlfmm / fasttransforms.py

import numpy as np
from scipy.special import sph_harm, jn, yv, lpmv, eval_legendre
from scipy.misc import factorial

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

def calc_pressure_exact(q, points, center, k, rho, c):
    '''
    Return exact pressure using the baffled Rayleigh integral.
    '''
    delta_r = points - center
    r, theta, phi = cart2sph(delta_r, cat=False)
    
    #q = 1j*k*c*s_n*u
    
    return np.sum(q.ravel()*1j*rho*c*k/(2*np.pi)*np.exp(1j*k*r)/r)

def calc_self_pressure(q, s_n, k, rho, c):
    '''
    Return pressure at node approximated by radiation impedance of a piston.
    '''
    a_eff = np.sqrt(s_n/np.pi)
    
    pres = q/s_n*rho*c*(0.5*(k*a_eff)**2 + 1j*8/(3*np.pi)*(k*a_eff))
    
    return pres

def m2m():
    pass

def l2l():
    pass

def ffmu(origin, new_origin, k0, order):
    
    delta_r = new_origin - origin
    
    cos_gamma = delta_r.dot(sph2cart(k0))
    x12 = np.sqrt(np.sum((delta_r**2)))
    
    total = 0j
    for l in xrange(order):
        total += 1j**l*(2*l + 1)*sphhankel1(l, x12)*eval_legendre(l, cos_gamma)
    
    return total

def fflambda(origin, new_origin, k0):
    
    delta_r = new_origin - origin
    
    return np.exp(1j*delta_r.dot(sph2cart(k0)))
     
def l2m():
    pass

def fftransform(q, src_pos, origin, k0):
    
    delta_r = origin - src_pos
    #r, theta, phi = cart2sph(delta_r, cat=False)
    #k0 = sph2cart(np.array([1, ktheta, kphi]))

    return np.sum(q.reshape((-1,1))*np.exp(1j*delta_r.dot(sph2cart(k0))))
    
def ffeval():
    pass



def interpolate():
    pass

def filter():
    pass
    



