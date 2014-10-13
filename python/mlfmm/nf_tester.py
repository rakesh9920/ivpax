# mlfmm / nf_tester.py

import numpy as np
import scipy as sp
from mlfmm.fasttransforms import *
from pyfield.util import distance
from matplotlib import pyplot as pp

nsource = 20
nfieldpos = 20
D0 = 0.001
level = 5
box = np.array([[-0.5, 0.5],[-0.5, 0.5],[0, 0]])*D0/(2**level)
f = 0.5e6
rho = 1000
c = 1540
k = 2*np.pi*f/c
D = box[0,1] - box[0,0]
obs_d = 2*D
center1 = np.array([0, 0, 0])
center2 = np.array([0, 1, 0])*obs_d

v = np.sqrt(3)*D*k
C = 3/1.6
order = np.int(np.ceil(v + C*np.log(v + np.pi)))
stab_cond = 0.15*v/np.log(v + np.pi)
print order, stab_cond, stab_cond > C

####

if __name__ == '__main__':
    
    srcx = sp.rand(nsource)*(box[0,1] - box[0,0])
    srcy = sp.rand(nsource)*(box[1,1] - box[1,0])
    srcz = sp.rand(nsource)*(box[2,1] - box[2,0])
    sources = np.c_[srcx, srcy, srcz] + center1 - 0.5*D
    strengths = np.ones(nsource)
    
    srcx = sp.rand(nfieldpos)*(box[0,1] - box[0,0])
    srcy = sp.rand(nfieldpos)*(box[1,1] - box[1,0])
    srcz = sp.rand(nfieldpos)*(box[2,1] - box[2,0])
    fieldpos = np.c_[srcx, srcy, srcz] + center2 - 0.5*D
    dist = distance(fieldpos, sources)
    
    pres_exact = directeval(strengths, sources, fieldpos, k, rho, c)
    
    kdir, weights, w1, w2 = fftquadrule(order)
    kcoord = dir2coord(kdir)
    kcoordT = np.transpose(kcoord, (0,2,1))
    
    r = center2 - center1
    rhat = r/mag(r)
    cos_angle = rhat.dot(kcoordT)
    
    coeff = ffcoeff(strengths, sources, center1, k, kcoord)
    translator = m2l(mag(r), cos_angle, k, order)
    pres_fmm = nfeval(coeff*translator, fieldpos, center2, weights, k, kcoord, 
        rho, c)
    
    perr = np.abs(np.abs(pres_fmm) - np.abs(pres_exact))/np.abs(pres_exact)*100
    
    fig1 = pp.figure()
    fig1.add_subplot(111)
    pp.plot(np.abs(pres_exact),'o', markerfacecolor='none')
    pp.plot(np.abs(pres_fmm),'r.')
    pp.title('amplitude')
    
    fig2 = pp.figure()
    fig2.add_subplot(111)
    pp.plot(np.angle(pres_exact),'o', markerfacecolor='none')
    pp.plot(np.angle(pres_fmm),'r.')
    pp.title('phase')
    
    pp.show()
    
    #plot(np.abs(pres_exact), 'b')
    #plot(np.abs(pres_fmm1), 'r--')
    #plot(np.abs(pres_fmm2), 'g--')
    #plot(np.abs(pres_fmm3), 'c--')
    #plot(np.abs(pres_fmm4), 'y--')
    #plot(np.abs(pres_fmm5), 'k--')
    #xlabel('angle (degrees)')
    #ylabel('pressure')
    #title('pressure amplitude convergence behavior')
    #legend(('exact', 'L=1', 'L=2', 'L=3', 'L=4', 'L=5'), loc='best')
    
    #plot(np.angle(pres_exact), 'b')
    #plot(np.angle(pres_fmm1), 'r--')
    #plot(np.angle(pres_fmm2), 'g--')
    #plot(np.angle(pres_fmm3), 'c--')
    #plot(np.angle(pres_fmm4), 'y--')
    #plot(np.angle(pres_fmm5), 'k--')
    #xlabel('angle (degrees)')
    #ylabel('phase')
    #title('pressure phase convergence behavior')
    #legend(('exact', 'L=1', 'L=2', 'L=3', 'L=4', 'L=5'), loc='best')

    #plot(np.angle(pres_exact), 'b')
    #plot(np.angle(pres_fmm25), 'r--')
    #plot(np.angle(pres_fmm26), 'g--')
    #plot(np.angle(pres_fmm27), 'c--')
    #xlabel('angle (degrees)')
    #ylabel('pressure')
    #title('pressure amplitude divergence behavior')
    #legend(('exact', 'L=25', 'L=26', 'L=27'), loc='lower right')
    
    
    