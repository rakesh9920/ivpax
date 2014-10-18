# mlfmm / nf_tester.py

import numpy as np
import scipy as sp
from mlfmm.fasttransforms import *
from pyfield.util import distance
from matplotlib import pyplot as pp

D0 = 0.001
level = 5
f = 1e6
rho = 1000
c = 1540
k = 2*np.pi*f/c
nsource = 50
nfieldpos = 50

box = np.array([[-0.5, 0.5],[-0.5, 0.5],[0, 0]])*D0/(2**level)
Dx = box[0,1] - box[0,0]
Dy = box[1,1] - box[1,0]
Dz = box[2,1] - box[2,0]
obs_d = 2*Dx
center1 = np.array([0, 0, 0])
center2 = np.array([-Dx/2, -Dy/2, 0])
center3 = np.array([0, 1, 0])*obs_d
v = np.sqrt(3)*Dx*k
C = 3/1.6
order = np.int(np.ceil(v + C*np.log(v + np.pi)))
stab_cond = 0.15*v/np.log(v + np.pi)
wavelength = c/f
#order = 5
#print 'order ', order, stab_cond, stab_cond > C, wavelength/D
#print 'order', order, '|', 'D = lambda*' + str(wavelength/Dx)

####

if __name__ == '__main__':
    
    k = 2*np.pi*f/c
    v = np.sqrt(3)*Dx*k
    order = np.int(np.ceil(v + C*np.log(v + np.pi)))

    srcx = sp.rand(nsource)*Dx
    srcy = sp.rand(nsource)*Dy
    srcz = sp.rand(nsource)*Dz
    sources = np.c_[srcx, srcy, srcz] + center1 - 0.5*np.array([Dx, Dy, Dz])
    strengths = np.ones(nsource)
    
    srcx = sp.rand(nfieldpos)*Dx
    srcy = sp.rand(nfieldpos)*Dy
    srcz = sp.rand(nfieldpos)*Dz
    fieldpos = np.c_[srcx, srcy, srcz] + center3 - 0.5*np.array([Dx, Dy, Dz])
    dist = distance(fieldpos, sources)
    
    pres_exact = directeval(strengths, sources, fieldpos, k, rho, c)
    
    kdir, weights, w1, w2 = fftquadrule(order)
    kcoord = dir2coord(kdir)
    kcoordT = np.transpose(kcoord, (0,2,1))
    
    r = center2 - center1
    rhat = r/mag(r)
    cos_angle = rhat.dot(kcoordT)
    
    coeff = ffcoeff(strengths, sources, center1, k, kcoord)
    shifter = m2m(mag(r), cos_angle, k)
    pres_fmm = ffeval(coeff*shifter, fieldpos, center2, weights, k, kcoord, order, 
        rho, c)

    #pres_fmm = nfeval(coeff*translator, fieldpos, center2, weights, k, kcoord, 
        #rho, c)
    
    perr = np.abs(np.abs(pres_fmm) - np.abs(pres_exact))/np.abs(pres_exact)*100
    
    pp.figure()
    pp.plot(np.abs(pres_exact),'o', markerfacecolor='none')
    pp.plot(np.abs(pres_fmm), 'r.')

    pp.figure()
    pp.plot(np.angle(pres_exact),'o', markerfacecolor='none')
    pp.plot(np.angle(pres_fmm), 'r.')
    pp.show()

    print 'mean error:', str(np.mean(perr)) + '%', '|', 'max error:',  \
            str(np.max(perr)) + '%'

    
    