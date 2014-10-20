# mlfmm / full_tester.py

import numpy as np
import scipy as sp
from mlfmm.fasttransforms import *
from pyfield.util import distance
from matplotlib import pyplot as pp

# set parameters
D0 = 0.001
level = 3
f = 1e6
rho = 1000
c = 1540
k = 2*np.pi*f/c
nsource = 50
nfieldpos = 50

# define geometry
box = np.array([[-0.5, 0.5],[-0.5, 0.5],[0, 0]])*D0/(2**level)
Dx = box[0,1] - box[0,0]
Dy = box[1,1] - box[1,0]
Dz = box[2,1] - box[2,0]
obs_d = 2*Dx
center1 = np.array([-Dx/4, Dy/4, 0])
center2 = np.array([0, 0, 0])
center3 = np.array([0, obs_d, 0])
center4 = np.array([-Dx/4, -Dy/4, 0]) + center3

# determine truncation order
v = np.sqrt(3)*Dx*k/2
C = 3/1.6
order1 = np.int(np.ceil(v + C*np.log(v + np.pi)))

v = np.sqrt(3)*Dx*k
C = 3/1.6
order2 = np.int(np.ceil(v + C*np.log(v + np.pi)))

if __name__ == '__main__':
    
    srcx = sp.rand(nsource)*Dx/2
    srcy = sp.rand(nsource)*Dy/2
    srcz = sp.rand(nsource)*Dz/2
    sources = np.c_[srcx, srcy, srcz] + center1 - 0.5*np.array([Dx/2, Dy/2, Dz/2])
    strengths = np.ones(nsource)

    srcx = sp.rand(nfieldpos)*Dx/2
    srcy = sp.rand(nfieldpos)*Dy/2
    srcz = sp.rand(nfieldpos)*Dz/2
    fieldpos = np.c_[srcx, srcy, srcz] + center4 - 0.5*np.array([Dx/2, Dy/2, Dz/2])
    
    pres_exact = directeval(strengths, sources, fieldpos, k, rho, c)
    
    kdir, weights, w1, w2 = fftquadrule(order1*2)
    kcoord = dir2coord(kdir)
    kcoordT = np.transpose(kcoord, (0,2,1))

    newkdir, newweights, _, _ = fftquadrule(order2*2)
    newkcoord = dir2coord(newkdir)    
    newkcoordT = np.transpose(newkcoord, (0,2,1))
    
    coeff = ffcoeff(strengths, sources, center1, k, kcoord)

    r = center2 - center1
    rhat = r/mag(r)
    cos_angle = rhat.dot(newkcoordT)
    #cos_angle = rhat.dot(kcoordT)
    shifter1 = m2m(mag(r), cos_angle, k)

    r = center3 - center2
    rhat = r/mag(r)
    cos_angle = rhat.dot(newkcoordT)
    #cos_angle = rhat.dot(kcoordT)
    translator = m2l(mag(r), cos_angle, k, order2)

    r = center4 - center3
    rhat = r/mag(r)
    cos_angle = rhat.dot(newkcoordT)
    #cos_angle = rhat.dot(kcoordT)
    shifter2 = m2m(mag(r), cos_angle, k)
    
    newffcoeff = shifter1*fftinterpolate(coeff, kdir, newkdir)
    newnfcoeff = newffcoeff*translator*shifter2
    
    nfcoeff = fftfilter(newnfcoeff, newkdir, kdir)
    
    #nfcoeff = shifter1*shifter2*coeff*translator

    pres_fmm = nfeval(nfcoeff, fieldpos, center4, weights, k, kcoord, 
        rho, c)
        
    #pres_fmm = ffeval(coeff, fieldpos, center1, weights, k, kcoord, order1, 
        #rho, c)
        
    perr = np.abs(np.abs(pres_fmm) - np.abs(pres_exact))/np.abs(pres_exact)*100
    
    print 'order1:', str(order1)
    print 'order2:', str(order2)
    print 'mean error:', '%.4f' % np.mean(perr) + '%'
    print 'max error:', '%.4f' % np.max(perr) + '%'
    
    fig1 = pp.figure()
    fig1.add_subplot(111)
    pp.plot(np.abs(pres_exact),'o', markerfacecolor='none')
    pp.plot(np.abs(pres_fmm),'r.')
    pp.xlabel('point no.')
    pp.ylabel('pressure')
    pp.title('pressure amplitude after interpolation')
    
    fig2 = pp.figure()
    fig2.add_subplot(111)
    pp.plot(np.angle(pres_exact),'o', markerfacecolor='none')
    pp.plot(np.angle(pres_fmm),'r.')
    pp.xlabel('point no.')
    pp.ylabel('phase')
    pp.title('pressure phase after interpolation')
    
    pp.show()