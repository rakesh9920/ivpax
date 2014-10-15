# mlfmm / fftinterpolate_tester.py

import numpy as np
import scipy as sp
from mlfmm.fasttransforms import *
from pyfield.util import distance
from matplotlib import pyplot as pp

nsource = 10
D0 = 0.001
level = 3
box = np.array([[-0.5, 0.5],[-0.5, 0.5],[0, 0]])*D0/(2**level)
f = 1e6
rho = 1000
c = 1540
k = 2*np.pi*f/c
D = box[0,1] - box[0,0]
obs_d = 4*D
center = np.array([0, 0, 0])

v = np.sqrt(3)*D*k
C = 3/1.6
order1 = np.int(np.ceil(v + C*np.log(v + np.pi)))
stab_cond = 0.15*v/np.log(v + np.pi)
print order1, stab_cond, stab_cond > C

v = np.sqrt(3)*D*k*2
C = 3/1.6
order2 = np.int(np.ceil(v + C*np.log(v + np.pi)))
stab_cond = 0.15*v/np.log(v + np.pi)
print order2, stab_cond, stab_cond > C

if __name__ == '__main__':
    
    srcx = sp.rand(nsource)*(box[0,1] - box[0,0])
    srcy = sp.rand(nsource)*(box[1,1] - box[1,0])
    srcz = sp.rand(nsource)*(box[2,1] - box[2,0])
    sources = np.c_[srcx, srcy, srcz] - 0.5*np.array([D, D, 0])
    strengths = np.ones(nsource)
    
    r_obs, theta_obs, phi_obs = np.mgrid[obs_d:(obs_d+1):1, 0:2*np.pi:360j, 
        np.pi/2:np.pi/2+1:1]
    points = sph2cart(np.c_[r_obs.ravel(), theta_obs.ravel(), phi_obs.ravel()])
    dist = distance(points, sources)
    
    pres_exact = np.sum(1j*k*rho*c/(4*np.pi)*np.exp(1j*k*dist)/ \
        dist*strengths[None,:], axis=1)
    
    kdir, weights, w1, w2 = fftquadrule(order1)
    kcoord = dir2coord(kdir)
    
    coeff = ffcoeff(strengths, sources, center, k, kcoord)

    newkdir, newweights, _, _ = fftquadrule(order2)
    newkcoord = dir2coord(newkdir)
    
    newcoeff = fftinterpolate(coeff, kdir, newkdir)
    pres_fmm2 = ffeval(newcoeff, points, center, newweights, k, newkcoord, 
        order2, rho, c)
    pres_fmm1 = ffeval(coeff, points, center, weights, k, kcoord, 
        order1, rho, c)
    
    newcoeff_ref = ffcoeff(strengths, sources, center, k, newkcoord)

    fig1 = pp.figure()
    fig1.add_subplot(111)
    pp.plot(np.abs(pres_exact),'b')
    pp.plot(np.abs(pres_fmm1),'go', markerfacecolor='none')
    pp.plot(np.abs(pres_fmm2),'r.')
    pp.xlabel('angle (degrees)')
    pp.ylabel('pressure')
    pp.title('pressure amplitude after interpolation')
    pp.legend(('exact','882 angles', '3362 angles'), loc='best')
    
    fig2 = pp.figure()
    fig2.add_subplot(111)
    pp.plot(np.angle(pres_exact),'b')
    pp.plot(np.angle(pres_fmm1),'go', markerfacecolor='none')
    pp.plot(np.angle(pres_fmm2),'r.')
    pp.xlabel('angle (degrees)')
    pp.ylabel('phase')
    pp.title('pressure phase after interpolation')
    pp.legend(('exact','882 angles', '3362 angles'), loc='best')
    
    pp.show()