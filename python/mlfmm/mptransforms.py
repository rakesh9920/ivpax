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

def mp_nfeval(coeff, fieldpos, centerpos, weights, k, kcoord, rho, c):
    
    r = fieldpos - centerpos

    total = np.sum(np.sum(mp_exp(1j*k*r.dot(np.transpose(kcoord, (0,2,1))))*
        coeff*weights, axis=1), axis=1)

    return np.cfloat(-k**2*rho*c/(16*mpmath.pi()**2)*total)

mp_exp = np.frompyfunc(mp.exp, 1, 1)
mp_cos = np.frompyfunc(mp.cos, 1, 1)
mp_sin = np.frompyfunc(mp.sin, 1, 1)

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