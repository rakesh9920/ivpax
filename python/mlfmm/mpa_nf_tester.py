# mlfmm / mpa_nf_tester.py

import numpy as np
import scipy as sp
from mlfmm.mptransforms import *
from mlfmm.fasttransforms import *
from pyfield.util import distance
from matplotlib import pyplot as pp

nsource = 10
nfieldpos = 20
box = np.array([[-0.5, 0.5],[-0.5, 0.5],[0, 0]])*0.007/2**4
f = 20e6
rho = 1000
c = 1540
k = 2*np.pi*f/c
D = box[0,1] - box[0,0]
obs_d = 2*D
center1 = np.array([0, 0, 0])
center2 = np.array([0, 1, 0])*obs_d

v = np.sqrt(3)*D*k
C = 1
sugg_order = np.int(np.ceil(v + C*np.log(v + np.pi)))
order = 10
stab_cond = 0.15*v/np.log(v + np.pi)
print sugg_order, stab_cond, stab_cond > C
mp.dps = 75
####

if __name__ == '__main__':
    
    srcx = sp.rand(nsource)*(box[0,1] - box[0,0])
    srcy = sp.rand(nsource)*(box[1,1] - box[1,0])
    srcz = sp.rand(nsource)*(box[2,1] - box[2,0])
    sources = np.c_[srcx, srcy, srcz] + center1
    strengths = np.ones(nsource)
    
    srcx = sp.rand(nfieldpos)*(box[0,1] - box[0,0])
    srcy = sp.rand(nfieldpos)*(box[1,1] - box[1,0])
    srcz = sp.rand(nfieldpos)*(box[2,1] - box[2,0])
    fieldpos = np.c_[srcx, srcy, srcz] + center2
    dist = distance(fieldpos, sources)
    
    pres_exact = directeval(strengths, sources, fieldpos, k, rho, c)
    
    kdir, weights, w1, w2 = mp_fftquadrule(order)
    kcoord = mp_dir2coord(kdir)
    kcoordT = np.transpose(kcoord, (0,2,1))
    
    r = center2 - center1
    rhat = r/mag(r)
    cos_angle = rhat.dot(kcoordT)
    
    ####
    coeff = ffcoeff(strengths, sources, center1, k, np.cfloat(kcoord))
    translator = m2l(mag(r), np.cfloat(cos_angle), k, order)
    pres_fmm = nfeval(coeff*translator, fieldpos, center2, np.cfloat(weights), 
        k, np.cfloat(kcoord), rho, c)
        
    ####
    mp_translator = mp_m2l(mag(r), cos_angle, k, order)
    pres_mp = mp_nfeval(coeff*mp_translator, fieldpos, center2, weights, k, 
        kcoord, rho, c)

        
    fig1 = pp.figure()
    fig1.add_subplot(111)
    pp.plot(np.abs(pres_exact),'o', markerfacecolor='none')
    pp.plot(np.abs(pres_mp),'r.')
    pp.plot(np.abs(pres_fmm), 'g+')
    pp.title('amplitude')
    
    fig2 = pp.figure()
    fig2.add_subplot(111)
    pp.plot(np.angle(pres_exact),'o', markerfacecolor='none')
    pp.plot(np.angle(pres_mp),'r.')
    pp.plot(np.angle(pres_fmm), 'g+')
    pp.title('phase')
    
    pp.show()
    
    
    
    