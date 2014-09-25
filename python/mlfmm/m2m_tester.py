# mlfmm / m2m_tester.py

import numpy as np
import scipy as sp
from mlfmm.fasttransforms import *
from pyfield.util import distance
from matplotlib import pyplot as pp

nsource = 10
nfieldpos = 20
box = np.array([[-0.5, 0.5],[-0.5, 0.5],[0, 0]])*70e-6*25
f = 2e6
rho = 1000
c = 1540
k = 2*np.pi*f/c
D = box[0,1] - box[0,0]
obs_d = 2*D
center1 = np.array([0, 0, 0])
center2 = center1 + np.array([D, 0, 0])/1
center3 = np.array([0, 1, 0])*obs_d

v = np.sqrt(3)*D*k
C = 1
order = np.int(np.ceil(v + C*np.log(v + np.pi)))
stab_cond = 0.15*v/np.log(v + np.pi)
print order, stab_cond, stab_cond > C

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
    fieldpos = np.c_[srcx, srcy, srcz] + center3
    dist = distance(fieldpos, sources)
    
    pres_exact = directeval(strengths, sources, fieldpos, k, rho, c)
    
    kdir, weights, w1, w2 = quadrule2(order + 1)
    kcoord = dir2coord(kdir)
    kcoordT = np.transpose(kcoord, (0,2,1))
    
    r23 = center3 - center2
    rhat23 = r23/mag(r23)
    cos_angle23 = rhat23.dot(kcoordT)
    
    r12 = center2 - center1
    #rhat12 = r12/mag(r12)
    #cos_angle12 = rhat12.dot(kcoordT)
    
    coeff = ffcoeff(strengths, sources, center1, k, kcoord)
    shifter = m2m2(center1, center2, k, kcoord)
    translator = m2l(mag(r23), cos_angle23, k, order)
    
    pres_fmm = nfeval(coeff*shifter*translator, fieldpos, center3, weights, k, 
        kcoord, rho, c)
    
    fig1 = pp.figure()
    fig1.add_subplot(111)
    pp.plot(np.abs(pres_exact),'.')
    pp.plot(np.abs(pres_fmm),'r+')
    pp.title('amplitude')
    
    fig2 = pp.figure()
    fig2.add_subplot(111)
    pp.plot(np.angle(pres_exact),'.')
    pp.plot(np.angle(pres_fmm),'r+')
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
    
    
    