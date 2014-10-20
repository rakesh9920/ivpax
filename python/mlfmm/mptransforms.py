# mlfmm / mptransforms.py

import numpy as np
from mlfmm.fasttransforms import *
from sympy import mpmath
mp = mpmath.mp

mp_legendre = np.frompyfunc(mpmath.legendre, 2, 1)

def mp_sphhankel1_pyfunc(l, z):
    
    return np.sqrt(mpmath.pi()/(2*z))*mpmath.hankel1(l + 0.5, z)

mp_sphhankel1 = np.frompyfunc(mp_sphhankel1_pyfunc, 2, 1)

def mp_m2lop(r, cos_angle, k, order):
    
    l = np.arange(0, order + 1)

    kr = mp.mpf(k*r)
    ca = mp.mpf(cos_angle)
    
    operator =  np.sum((2*l + 1)*(1j**l)*mp_sphhankel1(l, kr)*mp_legendre(l, 
        ca))
        
    return operator
    
mp_m2l = np.vectorize(mp_m2lop, excluded=['r', 'k', 'order'])

def mp_ffcoeff(q, srcpos, centerpos, k, kcoord):
    '''
    Returns the far-field signature coefficients of a collection of sources in
    the specified far-field directions.
    '''
    delta_r = centerpos - srcpos
    ntheta, nphi = kcoord.shape[:2]
    #kpos = sph2cart(np.c_[np.ones_like(ktheta), ktheta, kphi], cat=True)
    
    #coeff = np.zeros((ntheta, nphi), dtype='complex')
    
    #for i in xrange(ntheta):
    #    for j in xrange(nphi):
    #        
    #        coeff[i, j] = np.sum(q*np.exp(1j*k*delta_r.dot(kcoord[i,j,:])))
    
    shift = mp_exp(1j*k*delta_r.dot(np.transpose(kcoord, (0,2,1))))
    coeff = np.sum((q*shift.T).T, axis=0)
        
    return coeff
    
def mp_nfeval(coeff, fieldpos, centerpos, weights, k, kcoord, rho, c):
    
    r = fieldpos - centerpos

    total = np.sum(np.sum(mp_exp(1j*k*r.dot(np.transpose(kcoord, (0,2,1))))*
        coeff*weights, axis=1), axis=1)

    return np.cfloat(-k**2*rho*c/(16*mpmath.pi()**2)*total)

def mp_m2m(r, cos_angle, k):
    
    return mp_exp(1j*k*r*cos_angle)
    
mp_exp = np.frompyfunc(mp.exp, 1, 1)
mp_cos = np.frompyfunc(mp.cos, 1, 1)
mp_sin = np.frompyfunc(mp.sin, 1, 1)
mp_conj = np.frompyfunc(mp.conj, 1, 1)

def mp_dir2coord(kdir):
    
    theta = kdir[:,:,0]
    phi = kdir[:,:,1]
    
    x = mp_cos(theta)*mp_sin(phi)
    y = mp_sin(theta)*mp_sin(phi)
    z = mp_cos(phi)
    
    kcoord = np.concatenate((x[...,None], y[...,None], z[...,None]), axis=2)
    
    return kcoord
    
def mp_fftquadrule(order):
    
    # 1: theta/azimuthal
    M = 2*(order + 1)
    absc1 = mp.linspace(0, 2*mpmath.pi(), M, endpoint=False)
    theta = np.array(absc1)
    w1 = np.ones(M)*2*mpmath.pi()/M
    thetaweights = w1

    # 2: phi/polar
    N = 2*(order + 1) + 1
    absc2 = mp.linspace(-mpmath.pi(), mpmath.pi(), N, endpoint=False)
    phi = np.array(absc2)
    w2 = np.ones(N)*2*mpmath.pi()/N
    w2 = w2/2 # divide by 2 for special considerations due to fft
    
    # handle special considerations for |sin(phi)| factor
    m = np.arange(-N, N + 1)
    sinabs = mp_exp(1j*phi[:,None]*m[None,:])
    prefactor = np.zeros(2*N + 1, dtype='object')
    prefactor[1::2] = (2/mpmath.pi()/(1 - m[1::2]**2))
    sinabs = np.abs(np.sum(sinabs*prefactor, axis=1))
    
    phiweights = w2*sinabs
    
    weights = thetaweights[:,None].dot(phiweights[None,:])
    
    ntheta = theta.shape[0]
    nphi = phi.shape[0]
    
    kdir = (np.tile(theta[:,None, None], (1, nphi, 1)), 
        np.tile(phi[None,:, None], (ntheta, 1, 1)))
    
    kdir = np.concatenate(kdir, axis=2)
    
    kdir[:,:(N-1)/2,0] += mpmath.pi()
    kdir[:,:(N-1)/2,1] *= -1
    
    #return kdir.astype(float), weights, thetaweights, phiweights
    return kdir, weights, thetaweights, phiweights

def _fft(x):
    
    N = len(x)
    
    if N <= 1: return x
    
    even = _fft(x[0::2])
    odd = _fft(x[1::2])
    
    k = np.arange(N/2)
    
    return np.concatenate((even[k] + mp_exp(-2j*mpmath.pi()*k/N)*odd[k],
        even[k] - mp_exp(-2j*mpmath.pi()*k/N)*odd[k]))

def _slowfft(x):
    
    N = len(x)
    
    n = np.arange(N)
    
    return np.sum(x*(mp_exp(-1j*2*mpmath.pi()*n[:,None]*n[None,:]/mp.mpf(N))), 
        axis=1)

def slowfft(x, axis=-1):
    return np.apply_along_axis(_slowfft, axis, x)

def slowfft2(x):
    return slowfft(slowfft(x, axis=0), axis=1)

def _slowifft(x):
    
    N = len(x)
    
    n = np.arange(N)
    
    return np.sum(x*(mp_exp(1j*2*mpmath.pi()*n[:,None]*n[None,:]/mp.mpf(N))), 
        axis=1)/N

def slowifft(x, axis=-1):
    return np.apply_along_axis(_slowifft, axis, x)

def slowifft2(x):
    return slowifft(slowifft(x, axis=0), axis=1)

def mp_fftinterpolate(coeff, kdir, newkdir):
    
    M1, N1 = kdir.shape[:2]
    M2, N2 = newkdir.shape[:2]
    
    padM = (M2 - M1)/2
    padN = (N2 - N1)/2
    
    spectrum1 = fftshift(slowfft2(coeff))
    spectrum2 = np.pad(spectrum1, ((padM, padM), (padN, padN)), 
        mode='constant')
    
    newcoeff = M2*N2/np.double(M1*N1)*slowifft2(ifftshift(spectrum2))
        
    return newcoeff  

def mp_fftfilter(coeff, kdir, newkdir):

    M1, N1 = kdir.shape[:2]
    M2, N2 = newkdir.shape[:2]
    
    Mstart = (M1 - M2)/2
    Mstop = Mstart + M2
    Nstart = (N1 - N2)/2
    Nstop = Nstart + N2
    
    spectrum1 = fftshift(slowfft2(coeff))
    spectrum2 = spectrum1[Mstart:Mstop, Nstart:Nstop]
    
    newcoeff = M2*N2/np.double(M1*N1)*slowifft2(ifftshift(spectrum2))
        
    return newcoeff


#def mp_fft(x, axis=-1):
#    return np.apply_along_axis(_fft, axis, x)
#    
#def mp_ifft(x, axis=-1):
#    
#    N = x.shape[axis]
#    return mp_conj(np.apply_along_axis(_fft, axis, mp_conj(x)))/N
#    
#def mp_fft2(x):
#    return mp_fft(mp_fft(x, axis=0), axis=1)
#
#def mp_ifft2(x): 
#    return mp_ifft(mp_ifft(x, axis=0), axis=1)      

 