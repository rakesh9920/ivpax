# mlfmm / mp_full_tester.py

import numpy as np
import scipy as sp
from mlfmm.mptransforms import *
from pyfield.util import distance
from matplotlib import pyplot as pp
from matplotlib.patches import Rectangle

# set parameters
D0 = 0.001
level = 2
f = 0.5e6
rho = 1000
c = 1540
k = 2*np.pi*f/c
nsource = 50
nfieldpos = 50
mp.dps = 100

# define geometry
box = np.array([[-0.5, 0.5],[-0.5, 0.5],[0, 0]])*D0/(2**level)
Dx = box[0,1] - box[0,0]
Dy = box[1,1] - box[1,0]
Dz = box[2,1] - box[2,0]
obs_d = 2*Dx
#center1 = np.array([0, 0, 0])
center1 = np.array(np.array([-Dx/4, Dy/4, 0]))
center2 = np.array([0, 0, 0])
center3 = np.array([0, obs_d, 0])
#center4 = center3 
center4 = np.array([-Dx/4, -Dy/4, 0]) + center3

# determine truncation order
v = np.sqrt(3)*Dx*k/2
C = 3/1.6
order1 = np.int(np.ceil(v + C*np.log(v + np.pi)))

v = np.sqrt(3)*Dx*k
C = 3/1.6
order2 = np.int(np.ceil(v + C*np.log(v + np.pi)))

order1 += 0
order2 += 0

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
    
    kdir, weights, w1, w2 = mp_fftquadrule(order1*2)
    kcoord = mp_dir2coord(kdir)
    kcoordT = np.transpose(kcoord, (0,2,1))

    newkdir, newweights, _, _ = mp_fftquadrule(order2*2)
    newkcoord = mp_dir2coord(newkdir)    
    newkcoordT = np.transpose(newkcoord, (0,2,1))
    
    coeff = mp_ffcoeff(strengths, sources, center1, k, kcoord)

    r = center2 - center1
    rhat = r/mag(r)
    cos_angle = rhat.dot(newkcoordT)
    #cos_angle = rhat.dot(kcoordT)
    shifter1 = mp_m2m(mag(r), cos_angle, k)

    r = center3 - center2
    #r = center4 - center1
    rhat = r/mag(r)
    cos_angle = rhat.dot(newkcoordT)
    #cos_angle = rhat.dot(kcoordT)
    translator = mp_m2l(mag(r), cos_angle, k, order2)

    r = center4 - center3
    rhat = r/mag(r)
    cos_angle = rhat.dot(newkcoordT)
    #cos_angle = rhat.dot(kcoordT)
    shifter2 = mp_m2m(mag(r), cos_angle, k)
    
    newffcoeff = shifter1*mp_fftinterpolate(coeff, kdir, newkdir)
    newnfcoeff = newffcoeff*translator*shifter2
    
    #newffcoeff = mp_fftinterpolate(coeff, kdir, newkdir)
    #newnfcoeff = newffcoeff*translator
    
    #nfcoeff = shifter1*shifter2*coeff*translator
    nfcoeff = mp_fftfilter(newnfcoeff, newkdir, kdir)
    #nfcoeff = translator*coeff

    pres_fmm = mp_nfeval(nfcoeff, fieldpos, center4, weights, k, kcoord, 
        rho, c)
    
    perr = np.abs(np.abs(pres_fmm) - np.abs(pres_exact))/np.abs(pres_exact)*100
    
    print 'order1:', str(order1)
    print 'order2:', str(order2)
    print 'mean error:', '%.4f' % np.mean(perr) + '%'
    print 'max error:', '%.4f' % np.max(perr) + '%'
    

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
    
    box1 = Rectangle((center1[0] - 0.5*Dx/2, center1[1] - 0.5*Dy/2), Dx/2, Dy/2,
        facecolor='blue', alpha=0.5)
    box2 = Rectangle((center2[0] - 0.5*Dx, center2[1] - 0.5*Dy), Dx, Dy,
        facecolor='green', alpha=0.5)
    box3 = Rectangle((center3[0] - 0.5*Dx, center3[1] - 0.5*Dy), Dx, Dy,
        facecolor='yellow', alpha=0.5)    
    box4 = Rectangle((center4[0] - 0.5*Dx/2, center4[1] - 0.5*Dy/2), Dx/2, Dy/2,
        facecolor='red', alpha=0.5)    
        
    fig3 = pp.figure()
    ax3 = fig3.add_subplot(111)
    ax3.plot(sources[:,0], sources[:,1], 'bo', markersize=2)
    ax3.plot(fieldpos[:,0], fieldpos[:,1], 'ro', markersize=2)
    ax3.set_aspect('equal', 'box')
    ax3.set_xlim(-Dx, Dx)
    ax3.set_ylim(-Dy, obs_d + Dy)
    ax3.add_patch(box1)
    ax3.add_patch(box2)
    ax3.add_patch(box3)
    ax3.add_patch(box4)
    ax3.set_xticks((-Dx, 0, Dx))
    
    pp.show()