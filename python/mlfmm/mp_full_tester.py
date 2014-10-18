# mlfmm / mp_full_tester.py

import numpy as np
import scipy as sp
from mlfmm.mptransforms import *
from pyfield.util import distance
from matplotlib import pyplot as pp

# set parameters
D0 = 0.001
level = 2
f = 0.05e6
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
    
    srcx = sp.rand(nsource)*Dx
    srcy = sp.rand(nsource)*Dy
    srcz = sp.rand(nsource)*Dz
    sources = np.c_[srcx, srcy, srcz] + center1 - 0.5*np.array([Dx/2, Dy/2, Dz/2])
    strengths = np.ones(nsource)

    srcx = sp.rand(nfieldpos)*Dx
    srcy = sp.rand(nfieldpos)*Dy
    srcz = sp.rand(nfieldpos)*Dz
    fieldpos = np.c_[srcx, srcy, srcz] + center4 - 0.5*np.array([Dx/2, Dy/2, Dz/2])
    
    pres_exact = directeval(strengths, sources, fieldpos, k, rho, c)
    
    kdir, weights, w1, w2 = mp_fftquadrule(order1)
    kcoord = mp_dir2coord(kdir)
    kcoordT = np.transpose(kcoord, (0,2,1))

    newkdir, newweights, _, _ = mp_fftquadrule(order2)
    newkcoord = mp_dir2coord(newkdir)    
    newkcoordT = np.transpose(newkcoord, (0,2,1))
    
    coeff = mp_ffcoeff(strengths, sources, center1, k, kcoord)

    r = center2 - center1
    rhat = r/mag(r)
    cos_angle = rhat.dot(newkcoordT)
    shifter1 = mp_m2m(mag(r), cos_angle, k)

    r = center3 - center2
    rhat = r/mag(r)
    cos_angle = rhat.dot(newkcoordT)
    translator = mp_m2l(mag(r), cos_angle, k, order2)

    r = center4 - center3
    rhat = r/mag(r)
    cos_angle = rhat.dot(newkcoordT)
    shifter2 = mp_m2m(mag(r), cos_angle, k)
    
    newffcoeff = shifter1*fftinterpolate(coeff, kdir, newkdir)
    newnfcoeff = newffcoeff*translator*shifter2
    
    nfcoeff = mp_fftfilter(newnfcoeff, newkdir, kdir)

    pres_fmm = mp_nfeval(nfcoeff, fieldpos, center4, weights, k, kcoord, 
        rho, c)
    
    perr = np.abs(np.abs(pres_fmm) - np.abs(pres_exact))/np.abs(pres_exact)*100
    
    print 'mean error:', str(np.mean(perr)) + '%', '|', 'max error:',  \
        str(np.max(perr)) + '%'
    
    fig1 = pp.figure()
    fig1.add_subplot(111)
    pp.plot(np.abs(pres_exact),'o', markerfacecolor='none')
    pp.plot(np.abs(pres_fmm),'r.')
    pp.xlabel('angle (degrees)')
    pp.ylabel('pressure')
    pp.title('pressure amplitude after interpolation')
    
    fig2 = pp.figure()
    fig2.add_subplot(111)
    pp.plot(np.angle(pres_exact),'o', markerfacecolor='none')
    pp.plot(np.angle(pres_fmm),'r.')
    pp.xlabel('angle (degrees)')
    pp.ylabel('phase')
    pp.title('pressure phase after interpolation')
    
    pp.show()