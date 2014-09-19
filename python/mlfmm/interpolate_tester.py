# mlfmm / interpolate_tester.py

import numpy as np
import scipy as sp
from mlfmm.fasttransforms import *
from pyfield.util import distance
from matplotlib import pyplot as pp

nsource = 10
box = np.array([[-0.0005, 0.0005],[-0.0005, 0.0005],[0, 0]])
f = 1000000
rho = 1000
c = 1540
k = 2*np.pi*f/c
obs_d = 100
center = np.array([0, 0, 0])
ml_order = 10
####

if __name__ == '__main__':
    
    srcx = sp.rand(nsource)*(box[0,1] - box[0,0])
    srcy = sp.rand(nsource)*(box[1,1] - box[1,0])
    srcz = sp.rand(nsource)*(box[2,1] - box[2,0])
    sources = np.c_[srcx, srcy, srcz]
    strengths = np.ones(nsource)
    
    r_obs, theta_obs, phi_obs = np.mgrid[obs_d:(obs_d+1):1, 0:2*np.pi:360j, 
        np.pi/2:np.pi/2+1:1]
    points = sph2cart(np.c_[r_obs.ravel(), theta_obs.ravel(), phi_obs.ravel()])
    dist = distance(points, sources)
    
    pres_exact = np.sum(1j*k*rho*c/(4*np.pi)*np.exp(1j*k*dist)/ \
        dist*strengths[None,:], axis=1)
    
    kdir, weights, w1, w2 = quadrule2(21)
    kcoord = dir2coord(kdir)
    
    coeff = ffcoeff(strengths, sources, center, k, kcoord)
    #pres_fmm = ffeval(coeff, points, center, weights, k, kcoord, ml_order, 
    #    rho, c)
    
    newkdir, newweights, _, _ = quadrule2(41)
    newkcoord = dir2coord(newkdir)
    
    newcoeff, b_lm = filter(coeff, w2, kdir, newkdir)
    pres_fmm2 = ffeval(newcoeff, points, center, newweights, k, newkcoord, 
        ml_order, rho, c)
    pres_fmm1 = ffeval(coeff, points, center, weights, k, kcoord, 
        ml_order, rho, c)
    
    newcoeff_ref = ffcoeff(strengths, sources, center, k, newkcoord)

    fig1 = pp.figure()
    fig1.add_subplot(111)
    pp.plot(np.abs(pres_exact),'b')
    pp.plot(np.abs(pres_fmm1),'g.')
    pp.plot(np.abs(pres_fmm2),'r.')
    pp.xlabel('angle (degrees)')
    pp.ylabel('pressure')
    pp.title('pressure amplitude after interpolation')
    pp.legend(('exact','882 angles', '3362 angles'), loc='best')
    
    fig2 = pp.figure()
    fig2.add_subplot(111)
    pp.plot(np.angle(pres_exact),'b')
    pp.plot(np.angle(pres_fmm1),'g.')
    pp.plot(np.angle(pres_fmm2),'r.')
    pp.xlabel('angle (degrees)')
    pp.ylabel('phase')
    pp.title('pressure phase after interpolation')
    pp.legend(('exact','882 angles', '3362 angles'), loc='best')
    
    pp.show()