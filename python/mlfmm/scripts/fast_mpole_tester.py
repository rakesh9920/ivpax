# mlfmm / mpole_tester.py

import numpy as np

from mlfmm.fasttransforms import *
from pyfield.util import distance
from matplotlib import pyplot as plt

monopole = np.array([0, 0, 0])
dipole = np.array([[1, 0, 0], [-1, 0, 0]])
quadrupole = np.array([[1, 1, 0], [1, -1, 0], [-1, 1, 0], [-1, -1, 0]])*0.1
center = np.zeros((1,3))
strengths = np.array([1, -1, -1, 1])
f = 10000
rho = 1000
c = 1540
k = 2*np.pi*f/c
ml_order = 50
#quad_order = 25

####
kdir, weights, w1, w2 = quadrule(ml_order + 1)
kcoord = dir2coord(kdir)

#coeff_mono = ffcoeff(strengths[0], monopole, center, k, kdir)
#coeff_di = ffcoeff(strengths[:2], dipole, center, k, kdir)
coeff_quad = ffcoeff(strengths, quadrupole, center, k, kcoord)

####
r, theta, phi = np.mgrid[1000:1001:1, 0:2*np.pi:360j, np.pi/2:np.pi/2+1:1]

points = sph2cart(np.c_[r.ravel(), theta.ravel(), phi.ravel()])

#pres_mono = ffeval(coeff_mono, points, center, weights, k, kdir, ml_order, rho, 
#    c)
#pres_di = ffeval(coeff_di, points, center, weights, k, kdir, ml_order, rho, 
#    c)
pres_quad = ffeval(coeff_quad, points, center, weights, k, kcoord, ml_order, rho, 
    c)
    
####
#dist = distance(points, monopole[None,:])
#pres_mono_exact = np.sum(1j*k*rho*c/(4*np.pi)*np.exp(1j*k*dist)/ \
#    dist*strengths[0], axis=1)
#
#dist = distance(points, dipole)
#pres_di_exact = np.sum(1j*k*rho*c/(4*np.pi)*np.exp(1j*k*dist)/ \
#    dist*strengths[None,:2], axis=1)
   
dist = distance(points, quadrupole)
pres_quad_exact = np.sum(1j*k*rho*c/(4*np.pi)*np.exp(1j*k*dist)/ \
    dist*strengths[None,:], axis=1)

perr = (np.abs(pres_quad) - np.abs(pres_quad_exact))/np.abs(pres_quad_exact)*100
perr[np.isinf(perr)] = 0

print np.max(perr)
#####
#fig2 = plt.figure()
#plt.polar(theta.ravel(), np.abs(pres_mono_exact))
#plt.polar(theta.ravel(), np.abs(pres_mono),'.')
#fig2.show()
#
#fig3 = plt.figure()
#plt.polar(theta.ravel(), np.abs(pres_di_exact))
#plt.polar(theta.ravel(), np.abs(pres_di),'.')
#fig3.show()

fig1 = plt.figure()
plt.plot(theta.ravel(), np.abs(pres_quad_exact),'-')
plt.plot(theta.ravel(), np.abs(pres_quad),'.')
fig1.show()