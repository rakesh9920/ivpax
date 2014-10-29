# mlfmm / fasttransforms.py

import numpy as np
from scipy.special import sph_harm, jn, yv, lpmv, eval_legendre, hankel1, lpmn
from scipy.misc import factorial
from numpy.polynomial.legendre import leggauss
from scipy.fftpack import fft, ifft, fft2, ifft2, fftshift, ifftshift

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
        
def mag(r, axis=-1):
    '''
    '''
    return np.sqrt(np.sum(r**2, axis=axis, keepdims=True))
           
def distance(a, b):
    '''
    '''
    a = a.reshape((-1,3)).T
    b = b.reshape((-1,3)).T
    
    return np.sqrt(np.sum(b*b, 0)[None,:] + np.sum(a*a, 0)[:,None] - \
        2*np.dot(a.T, b))
        
def dir2coord(kdir):
    '''
    '''
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
    '''
    '''
    return np.sqrt(np.pi/(2*z))*hankel1(l + 0.5, z)
    
def sphharm(l, m, theta, phi):
    '''
    '''
    ret = np.sqrt((2*l + 1)/(4*np.pi)*factorial(l - m)/ \
        factorial(l + m))*lpmv(m, l, np.cos(phi))* \
        np.exp(1j*m*theta)
    
    return ret
    
def ffcoeff(q, srcpos, centerpos, k, kcoord):
    '''
    Returns the far-field signature coefficients of a collection of sources in
    the specified far-field directions.
    '''
    delta_r = centerpos - srcpos
    
    if delta_r.ndim == 1:
        delta_r = delta_r[None,:]
    
    ntheta, nphi = kcoord.shape[:2]
    #kpos = sph2cart(np.c_[np.ones_like(ktheta), ktheta, kphi], cat=True)
    
    #coeff = np.zeros((ntheta, nphi), dtype='complex')
    
    #for i in xrange(ntheta):
    #    for j in xrange(nphi):
    #        
    #        coeff[i, j] = np.sum(q*np.exp(1j*k*delta_r.dot(kcoord[i,j,:])))
    
    shift = np.exp(1j*k*delta_r.dot(np.transpose(kcoord, (0,2,1))))
    coeff = np.sum((q*shift.T).T, axis=0)
        
    return coeff
    
def ffeval(coeff, fieldpos, centerpos, weights, k, kcoord, order, rho, c):
    '''
    Evaluates the acoustic field at a specified point using far-field
    signature coefficients.
    '''
    #kpos = sph2cart(np.c_[np.ones_like(ktheta), ktheta, kphi], cat=True)
    delta_r = fieldpos - centerpos
    #npos = delta_r.shape[0]
    #ndir = kdir.shape[0]
    
    #total = 0
    
    #for i in xrange(ndir):
        #total += weights[i]*mlop(delta_pos, k, kdir[i,:], order)*coeff[i]
            
    total = np.sum(weights.ravel()*mlop(delta_r, k, kcoord, order)* \
        coeff.ravel(), axis=1)
    
    #kcoordT = np.transpose(kcoord, (0,2,1))
    #
    #total = np.zeros(npos, dtype='complex')
    #
    #for pt in xrange(npos):
    #    
    #    r = delta_r[pt,:]
    #    magr = mag(r)
    #    rhat = r/mag(r)
    #
    #    cos_angle = rhat.dot(kcoordT)
    #    
    #    total[pt] = np.sum(weights*m2l(magr, cos_angle, k, order)*coeff)
    
    return -k**2*rho*c/(16*np.pi**2)*total
    
def nfeval(coeff, fieldpos, centerpos, weights, k, kcoord, rho, c):
    '''
    Evaluates the acoustic field at a specified point using near-field
    signature coefficients.
    '''
    r = fieldpos - centerpos
    
    if r.ndim == 1:
        r = r[None,:]

    total = np.sum(np.sum(np.exp(1j*k*r.dot(np.transpose(kcoord, (0,2,1))))*
        coeff*weights, axis=1), axis=1)

    return -k**2*rho*c/(16*np.pi**2)*total

def directeval(q, srcpos, fieldpos, k, rho, c):
    '''
    '''
    r = distance(fieldpos, srcpos)
    
    mat = (1j*k*rho*c/(4*np.pi)*np.exp(1j*k*r)/r)*q
    
    mat[np.isnan(mat)] = 0
    
    return np.sum(mat, axis=1)

    
def mlop(pos, k, kcoord, order):
    '''
    Translation operator used in evaluation and translation of far-field 
    expansions.
    '''
    #kpos = sph2cart(np.c_[np.ones_like(ktheta), ktheta, kphi], cat=True)
    
    #r, theta, phi = cart2sph(pos, cat=False)
    #r = mag(pos)
    #rhat = pos/r[[Ellipsis,] + [None for x in range(pos.ndim - 1)]]
    #rhat = pos/mag(pos)
    
    pos = pos.reshape((-1,3))
    kcoord = kcoord.reshape((-1,3))
    
    r = mag(pos)
    rhat = pos/mag(pos)
    
    npos = pos.shape[0]
    ndir = kcoord.shape[0]

    total = np.zeros((npos, ndir), dtype='complex')
    
    for l in xrange(order + 1):
        total += (2*l + 1)*(1j**l)*sphhankel1(l, k*r)*eval_legendre(l, 
            rhat.dot(kcoord.T))
    
    #l = np.arange(0, order + 1)
    #total = np.sum((2*l + 1)*(1j**l)*sphhankel1(l, k*r)*eval_legendre(l, 
    #    rhat.dot(kcoord.T)))
    
    return total

def m2lop(r, cos_angle, k, order):
    '''
    Far to local transform.
    '''
    l = np.arange(0, order + 1)
    
    operator =  np.sum((2*l + 1)*(1j**l)*sphhankel1(l, k*r)*eval_legendre(l, 
        cos_angle))
    
    return operator

m2l = np.vectorize(m2lop, excluded=['r', 'k', 'order'])

def m2m(r, cos_angle, k):
    
    return np.exp(1j*k*r*cos_angle)

def m2m2(center, newcenter, k, kcoord):
    
    r = newcenter - center
    kcoordT = np.transpose(kcoord, (0,2,1))
    
    return np.exp(1j*k*r.dot(kcoordT))

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

#factorial2 =np.vectorize(factorial, excluded=('exact'))

def lpml(m, l, z):
    
    z = z.ravel()
    out = np.zeros((m + 1, l + 1, z.size))
    
    ms = np.tile(np.arange(0, m + 1)[:,None], (1, l + 1))   
    ls = np.tile(np.arange(0, l + 1)[None,:], (m + 1, 1))
    
    norm = np.sqrt((ls + 0.5)*factorial(ls - ms)/factorial(ls + ms))
    
    for ind in xrange(z.size):
        out[..., ind] = norm*lpmn(m, l, z[ind])[0]
    
    return out

#def interpolate(coeff, weights, kdir, newkdir):
#    
#    M, L = kdir.shape[:2]
#    kphi = kdir[0,:,1]
#    newM, newL = newkdir.shape[:2]
#    newkphi = newkdir[0,:,1]
#    
#    b_m1 = fft(coeff, axis=0)
#    
#    lp = lpml(L - 1, L - 1, np.cos(kphi))
#    lp = np.concatenate((np.pad(lp, ((0,1), (0,0), (0,0)), mode='constant'), 
#        np.flipud(lp[1:,:,:])), axis=0)
#
#    b_lm = np.sum(weights[None,None,:]*lp*b_m1[:,None,:], axis=2)
#
#    newlp = lpml(L - 1, L - 1, np.cos(newkphi))
#    newlp = np.concatenate((np.pad(newlp, ((0,1), (0,0), (0,0)), mode='constant'), 
#        np.flipud(newlp[1:,:,:])), axis=0)
#    
#    b_m2 = np.sum(b_lm[:,:,None]*newlp, axis=1)
#    
#    padded = np.zeros((newM, newL), dtype='complex')
#    padded[0:M/2,:] = b_m2[0:M/2,:]
#    padded[-M/2:,:] = b_m2[M/2:M,:]
#    
#    #padded = np.zeros((newL*2, newL), dtype='complex')
#    #padded[0:L,:] = b_m2[0:L,:]
#    #padded[-L:,:] = b_m2[L:2*L,:]
#    
#    newcoeff = newM/np.double(M)*ifft(padded, axis=0)
#    #newcoeff = ifft(np.sum(b_lm[:,:,None]*newlp, axis=1), axis=0, n=newL*2)
#        
#    #b_lm = np.sum(weights[None,None,:]*lpml(L - 1, L - 1, np.cos(kphi))*
#        #b_m[:L,None,:], axis=2)
#
#    #newcoeff = ifft(np.sum(b_lm[:,:,None]*lpml(L - 1, L - 1, np.cos(newkphi)), 
#    #    axis=1), axis=0, n=newL*2)
#
#    return newcoeff

#def filter(coeff, weights, kdir, newkdir):
#    
#    M, L = kdir.shape[:2]
#    kphi = kdir[0,:,1]
#    newM, newL = newkdir.shape[:2]
#    newkphi = newkdir[0,:,1]
#    
#    b_m1 = fft(coeff, axis=0)
#    
#    lp = lpml(L - 1, L - 1, np.cos(kphi))
#    lp = np.concatenate((np.pad(lp, ((0,1), (0,0), (0,0)), mode='constant'), 
#        np.flipud(lp[1:,:,:])), axis=0)
#
#    b_lm = np.sum(weights[None,None,:]*lp*b_m1[:,None,:], axis=2)
#
#    newlp = lpml(L - 1, L - 1, np.cos(newkphi))
#    newlp = np.concatenate((np.pad(newlp, ((0,1), (0,0), (0,0)), mode='constant'), 
#        np.flipud(newlp[1:,:,:])), axis=0)
#    
#    b_m2 = np.sum(b_lm[:,:,None]*newlp, axis=1)
#    
#    padded = np.zeros((newM, newL), dtype='complex')
#    padded[0:newM/2,:] = b_m2[0:newM/2,:newL]
#    padded[-newM/2:,:] = b_m2[newM/2:newM,:newL]
#    
#    newcoeff = newM/np.double(M)*ifft(padded, axis=0)
#
#    return newcoeff
'''
Interpolation, filtering, and quadrature functions for Legendre/FFT method.
'''
def legquadrule(order):
    '''
    '''
    # 1: theta/azimuthal
    M = 2*(order + 1)
    absc1 = np.linspace(0, 2*np.pi, M, endpoint=False)
    w1 = np.ones(M)*2*np.pi/M
    weights1 = w1
    theta = absc1
    
    # 2: phi/polar
    N = order + 1
    
    absc2, w2 = leggauss(N)
    phi = (absc2 + 1)*np.pi/2
    weights2 = w2*np.pi/2*np.sin(phi)
    
    weights = weights1[:,None].dot(weights2[None,:])
    
    ntheta = theta.shape[0]
    nphi = phi.shape[0]
    
    kdir = (np.tile(theta[:,None, None], (1, nphi, 1)), 
        np.tile(phi[None,:, None], (ntheta, 1, 1)))
    
    kdir = np.concatenate(kdir, axis=2)
    
    return kdir, weights, weights1, weights2
    
def leginterpolate(coeff, weights, kdir, newkdir):
    
    M1, N1 = kdir.shape[:2]
    kphi1 = kdir[0,:,1]
    M2, N2 = newkdir.shape[:2]
    kphi2 = newkdir[0,:,1]
    
    padM = (M2 - M1)/2
    
    b_m1 = fft(coeff, axis=0)
    
    lp1 = lpml(N1 - 1, N1 - 1, np.cos(kphi1))
    lp1 = np.concatenate((np.pad(lp1, ((0,1), (0,0), (0,0)), mode='constant'), 
        np.flipud(lp1[1:,:,:])), axis=0)

    b_lm = np.sum(weights[None,None,:]*lp1*b_m1[:,None,:], axis=2)

    lp2 = lpml(N1 - 1, N1 - 1, np.cos(kphi2))
    lp2 = np.concatenate((np.pad(lp2, ((0,1), (0,0), (0,0)), mode='constant'), 
        np.flipud(lp2[1:,:,:])), axis=0)
    
    b_m2 = np.sum(b_lm[:,:,None]*lp2, axis=1)
    
    padded = np.pad(fftshift(b_m2, axes=0), ((padM, padM),(0,0)), 
        mode='constant')
    
    newcoeff = M2/np.double(M1)*ifft(ifftshift(padded, axes=0), axis=0)

    return newcoeff

def legfilter(coeff, weights, kdir, newkdir):
    
    M1, N1 = kdir.shape[:2]
    kphi1 = kdir[0,:,1]
    M2, N2 = newkdir.shape[:2]
    kphi2 = newkdir[0,:,1]
    
    Mstart = (M1 - M2)/2
    Mstop = Mstart + M2
    
    b_m1 = fft(coeff, axis=0)
    
    lp1 = lpml(N1 - 1, N1 - 1, np.cos(kphi1))
    lp1 = np.concatenate((np.pad(lp1, ((0,1), (0,0), (0,0)), mode='constant'), 
        np.flipud(lp1[1:,:,:])), axis=0)

    b_lm = np.sum(weights[None,None,:]*lp1*b_m1[:,None,:], axis=2)

    lp2 = lpml(N1 - 1, N1 - 1, np.cos(kphi2))
    lp2 = np.concatenate((np.pad(lp2, ((0,1), (0,0), (0,0)), mode='constant'), 
        np.flipud(lp2[1:,:,:])), axis=0)
    
    b_m2 = np.sum(b_lm[:,:,None]*lp2, axis=1)
    
    truncated = fftshift(b_m2, axes=0)[Mstart:Mstop, ...]
    
    newcoeff = M2/np.double(M1)*ifft(ifftshift(truncated, axes=0), axis=0)

    return newcoeff

'''
Interpolation, filtering, and quadrature functions for entirely FFT method
'''
def fftquadrule(order):
    '''
    '''
    # 1: theta/azimuthal
    M = 2*(order + 1)
    absc1 = np.linspace(0, 2*np.pi, M, endpoint=False)
    theta = absc1
    w1 = np.ones(M)*2*np.pi/M
    #w1[0] = w1[0]/2
    #w1[-1] = w1[-1]/2
    
    thetaweights = w1

    # 2: phi/polar
    N = 2*(order + 1) + 1
    absc2 = np.linspace(-np.pi, np.pi, N, endpoint=False)
    #absc2 = np.linspace(-np.pi, np.pi, N, endpoint=True)
    phi = absc2
    w2 = np.ones(N)*2*np.pi/N
    #w2[0] = w2[0]/2
    #w2[-1] = w2[-1]/2
    w2 = w2/2 # divide by 2 for special considerations due to fft
    
    # handle special considerations for |sin(phi)| factor
    m = np.arange(-N, N + 1)
    sinabs = np.exp(1j*phi[:,None]*m[None,:])
    prefactor = np.zeros(2*N + 1)
    prefactor[1::2] = (2/np.pi/(1 - m[1::2]**2))
    sinabs = np.abs(np.sum(sinabs*prefactor, axis=1))
    
    phiweights = w2*sinabs
    
    weights = thetaweights[:,None].dot(phiweights[None,:])
    
    ntheta = theta.shape[0]
    nphi = phi.shape[0]
    
    kdir = (np.tile(theta[:,None, None], (1, nphi, 1)), 
        np.tile(phi[None,:, None], (ntheta, 1, 1)))
    
    kdir = np.concatenate(kdir, axis=2)
    
    kdir[:,:(N-1)/2,0] += np.pi
    kdir[:,:(N-1)/2,1] *= -1
    #kdir[:,-(N-1)/2:,0] += np.pi
    #kdir[:,-(N-1)/2:,1] *= -1
    
    return kdir, weights, thetaweights, phiweights

def fftinterpolate(coeff, kdir, newkdir):
    
    M1, N1 = kdir.shape[:2]
    M2, N2 = newkdir.shape[:2]
    
    padM = (M2 - M1)/2
    padN = (N2 - N1)/2
    
    spectrum1 = fft2(coeff)
    spectrum2 = np.pad(fftshift(spectrum1), ((padM, padM),(padN, padN)), 
        mode='constant')
    
    newcoeff = M2*N2/np.double(M1*N1)*ifft2(ifftshift(spectrum2))
        
    return newcoeff
    
def fftfilter(coeff, kdir, newkdir):

    M1, N1 = kdir.shape[:2]
    M2, N2 = newkdir.shape[:2]
    
    Mstart = (M1 - M2)/2
    Mstop = Mstart + M2
    Nstart = (N1 - N2)/2
    Nstop = Nstart + N2
    
    spectrum1 = fft2(coeff)
    spectrum2 = fftshift(spectrum1)[Mstart:Mstop, Nstart:Nstop]
    
    newcoeff = M2*N2/np.double(M1*N1)*ifft2(ifftshift(spectrum2))
        
    return newcoeff

def fftquadrule2(order):
    '''
    '''
    # 1: theta/azimuthal
    M = (order + 1)
    absc1 = np.linspace(0, np.pi, M, endpoint=False)
    theta = absc1
    w1 = np.ones(M)*np.pi/M
    thetaweights = w1

    # 2: phi/polar
    N = 2*(order + 1) + 1
    absc2 = np.linspace(-np.pi, np.pi, N, endpoint=False)
    phi = absc2
    w2 = np.ones(N)*2*np.pi/N
    #w2[1:] /= 2 # divide by 2 for special considerations due to fft
    
    # handle special considerations for |sin(phi)| factor
    m = np.arange(-N, N + 1)
    sinabs = np.exp(1j*phi[:,None]*m[None,:])
    prefactor = np.zeros(2*N + 1)
    prefactor[1::2] = (2/np.pi/(1 - m[1::2]**2))
    sinabs = np.abs(np.sum(sinabs*prefactor, axis=1))
    
    phiweights = w2*sinabs
    
    weights = thetaweights[:,None].dot(phiweights[None,:])
    
    ntheta = theta.shape[0]
    nphi = phi.shape[0]
    
    kdir = (np.tile(theta[:,None, None], (1, nphi, 1)), 
        np.tile(phi[None,:, None], (ntheta, 1, 1)))
    
    kdir = np.concatenate(kdir, axis=2)
    
    kdir[:,:(N-1)/2,0] += np.pi
    kdir[:,:(N-1)/2,1] *= -1
    
    return kdir, weights, thetaweights, phiweights
    
def fftinterpolate2(coeff, kdir, newkdir):
    
    M1, N1 = kdir.shape[:2]
    M2, N2 = newkdir.shape[:2]
    
    padM = (M2 - M1)
    padN = (N2 - N1)/2
    
    spectrum1 = halffft2(coeff)
    spectrum2 = np.pad(spectrum1, ((padM, padM),(padN, padN)), 
        mode='constant')
    
    newcoeff = M2*N2/np.double(M1*N1)*halfifft2(spectrum2)
    
    return newcoeff

def fftfilter2(coeff, kdir, newkdir):
    
    M1, N1 = kdir.shape[:2]
    M2, N2 = newkdir.shape[:2]
    
    Mstart = (M1 - M2)
    Mstop = Mstart + 2*M2
    Nstart = (N1 - N2)/2
    Nstop = Nstart + N2
    
    spectrum1 = halffft2(coeff)
    spectrum2 = spectrum1[Mstart:Mstop, Nstart:Nstop]
    
    newcoeff = M2*N2/np.double(M1*N1)*halfifft2(spectrum2)
        
    return newcoeff  

def halffft2(x):
    
    N, M = x.shape
    
    v = fftshift(fft(x, axis=1), axes=1)
    dummy = np.fliplr(v).copy()
    v = np.concatenate((v, dummy), axis=0)
    
    w = fftshift(fft(v[:,:M/2+1], axis=0), axes=0)
    dummy = np.fliplr(w[:,:-1]).copy()
    
    if N % 2 == 0: # not 100% sure why DC appears differently since full FFT 
                    #is always even here
        for n in xrange(dummy.shape[0]):
            dummy[n,:] *= (-1)**(n)
    else:
        for n in xrange(dummy.shape[0]):
            dummy[n,:] *= (-1)**(n + 1)
    
    return np.concatenate((w, dummy), axis=1)

def halfifft2(x):
    
    N, M = x.shape
    
    return ifft2(ifftshift(x))[:N/2,:]
    







    



