# mlfmm / mpole_tester.py

import numpy as np

from mlfmm.fasttransforms import *
from pyfield.util import distance
from matplotlib import pyplot as plt

quadrupole = np.array([[1, 1, 0], [1, -1, 0], [-1, 1, 0], [-1, -1, 0]])*0.1
center = np.zeros((1,3))
strengths = np.array([1, -1, -1, 1])
f = 10000
rho = 1000
c = 1540
k = 2*np.pi*f/c
d = 200
####

r, theta, phi = np.mgrid[d:(d+1):1, 0:2*np.pi:360j, np.pi/2:np.pi/2+1:1]
points = sph2cart(np.c_[r.ravel(), theta.ravel(), phi.ravel()])
dist = distance(points, quadrupole)
pres_quad_exact = np.sum(1j*k*rho*c/(4*np.pi)*np.exp(1j*k*dist)/ \
    dist*strengths[None,:], axis=1)
    
####

#ml_order = 15
#quad_order = 20
#kdir, weights = quadrule(quad_order)
error = []

#for quad_order in xrange(1,40):
for ml_order in xrange(100):
    
    kdir, weights = quadrule(ml_order + 1)

    coeff_quad = ffcoeff(strengths, quadrupole, center, k, kdir)
    pres_quad = ffeval(coeff_quad, points, center, weights, k, kdir, ml_order, 
        rho, c)
        
    error.append(np.max((np.abs(pres_quad - pres_quad_exact))**2))

####
#fig1 = plt.figure()
#plt.polar(theta.ravel(), np.abs(pres_quad_exact),'-')
#plt.polar(theta.ravel(), np.abs(pres_quad),'.')
#fig1.show()