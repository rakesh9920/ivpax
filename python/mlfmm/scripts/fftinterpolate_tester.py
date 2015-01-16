# mlfmm / fftinterpolate_tester.py

import numpy as np
import scipy as sp
from mlfmm.fasttransforms import *
from pyfield.util import distance
from matplotlib import pyplot as pp

D0 = 0.002
level = 3
f = 1e6
rho = 1000
c = 1540
k = 2*np.pi*f/c
nsource = 10

box = np.array([[-0.5, 0.5],[-0.5, 0.5],[0, 0]])*D0/(2**level)
Dx = box[0,1] - box[0,0]
Dy = box[1,1] - box[1,0]
Dz = box[2,1] - box[2,0]
obs_d = 4*Dx
center = np.array([0, 0, 0])
v = np.sqrt(3)*Dx*k
C = 3/1.6
order1 = np.int(np.ceil(v + C*np.log(v + np.pi)))
stab_cond = 0.15*v/np.log(v + np.pi)
#print order1, stab_cond, stab_cond > C
v = np.sqrt(3)*Dx*k*2
C = 3/1.6
order2 = np.int(np.ceil(v + C*np.log(v + np.pi)))
stab_cond = 0.15*v/np.log(v + np.pi)
#print order2, stab_cond, stab_cond > C

if __name__ == '__main__':
    
    srcx = sp.rand(nsource)*Dx
    srcy = sp.rand(nsource)*Dy
    srcz = sp.rand(nsource)*Dz
    sources = np.c_[srcx, srcy, srcz] + center - 0.5*np.array([Dx, Dy, Dz])
    strengths = np.ones(nsource)
    
    r_obs, theta_obs, phi_obs = np.mgrid[obs_d:(obs_d+1):1, 0:2*np.pi:360j, 
        np.pi/2:np.pi/2+1:1]
    fieldpos = sph2cart(np.c_[r_obs.ravel(), theta_obs.ravel(), phi_obs.ravel()])
    
    pres_exact = directeval(strengths, sources, fieldpos, k, rho, c)
    
    kdir, weights, w1, w2 = fftquadrule2(order1)
    kcoord = dir2coord(kdir)
    
    coeff = ffcoeff(strengths, sources, center, k, kcoord)

    newkdir, newweights, _, _ = fftquadrule2(order2)
    newkcoord = dir2coord(newkdir)
    
    newcoeff = fftinterpolate2(coeff, kdir, newkdir)
    pres_fmm2 = ffeval(newcoeff, fieldpos, center, newweights, k, newkcoord, 
        order2, rho, c)
    pres_fmm1 = ffeval(coeff, fieldpos, center, weights, k, kcoord, 
        order1, rho, c)
    
    #newcoeff_ref = ffcoeff(strengths, sources, center, k, newkcoord)

    fig1 = pp.figure()
    fig1.add_subplot(111)
    pp.plot(np.abs(pres_exact),'b')
    pp.plot(np.abs(pres_fmm1),'go', markerfacecolor='none')
    pp.plot(np.abs(pres_fmm2),'r.')
    pp.xlabel('angle (degrees)')
    pp.ylabel('pressure')
    pp.title('pressure amplitude after interpolation')
    pp.legend(('exact','L='+str(order1), 'L='+str(order2)), loc='best')
    
    fig2 = pp.figure()
    fig2.add_subplot(111)
    pp.plot(np.angle(pres_exact),'b')
    pp.plot(np.angle(pres_fmm1),'go', markerfacecolor='none')
    pp.plot(np.angle(pres_fmm2),'r.')
    pp.xlabel('angle (degrees)')
    pp.ylabel('phase')
    pp.title('pressure phase after interpolation')
    pp.legend(('exact','L='+str(order1), 'L='+str(order2)), loc='best')
    
    pp.show()
    
    