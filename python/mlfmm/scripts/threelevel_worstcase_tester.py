# mlfmm / angle_error_analysis.py

import numpy as np
import scipy as sp
from mlfmm.fasttransforms import *
from matplotlib import pyplot as pp
from matplotlib.patches import Rectangle

# set parameters
D0 = 0.001
level = 2
f = 5e6
rho = 1000
c = 1540
k = 2*np.pi*f/c
nsource = 1
nfieldpos = 1
C = 5/1.6
freqs = np.arange(50e3, 10e6, 50e4)
####
    
# define geometry
box = np.array([[-0.5, 0.5],[-0.5, 0.5],[0, 0]])*D0/(2**level)
Dx = box[0,1] - box[0,0]
Dy = box[1,1] - box[1,0]
Dz = box[2,1] - box[2,0]
obs_d = 2*Dx

center3 = np.array([0, 0, 0])
center2 = np.array([Dx, Dy, 0])/4 + center3
center1 = np.array([Dx, Dy, 0])/8 + center2
center4 = np.array([0, obs_d, 0])
center5 = np.array([-Dx, -Dy, 0])/4 + center4
center6 = np.array([-Dx, -Dy, 0])/8 + center5

sugg_angles1 = np.fromstring('''
    5  8  9 11 13 15 17 19 21 21 21 23 25 27 29 31 31 33 35 35
    ''', sep=' ')
    
sugg_angles2 = np.fromstring('''
    6  9 10 11 13 15 17 19 21 21 21 23 25 27 29 31 31 33 35 35
    ''', sep=' ')
  
sugg_angles3 = np.fromstring('''
    7 10 11 11 13 15 17 19 21 21 21 23 25 27 29 31 31 33 35 35
    ''', sep=' ')
    
if __name__ == '__main__':
    
    sources = np.array([Dx, Dy, Dz])/8 + center1 
    sources = sources[None,:]
    strengths = np.ones(nsource)
    fieldpos = np.array([-Dx, -Dy, -Dz])/8 + center6
    fieldpos = fieldpos[None,:]
    
    mean_error = []
    max_error = []
    orders1 = []
    orders2 = []
    orders3 = []
    
    idx = 0
    
    for f in freqs:
        
        print f
        
        k = 2*np.pi*f/c
        
        pres_exact = directeval(strengths, sources, fieldpos, k, rho, c)
        
        v = np.sqrt(3)*Dx*k/4
        order1 = np.int(np.ceil(v + C*np.log(v + np.pi)))
        angle1 = sugg_angles1[idx]
        
        v = np.sqrt(3)*Dx*k/2
        order2 = np.int(np.ceil(v + C*np.log(v + np.pi)))
        angle2 = sugg_angles2[idx]

        v = np.sqrt(3)*Dx*k/1
        order3 = np.int(np.ceil(v + C*np.log(v + np.pi)))
        angle3 = sugg_angles3[idx]
        
        kdir1, weights1, _, _ = fftquadrule2(angle1)
        kcoord1 = dir2coord(kdir1)
        kcoordT1 = np.transpose(kcoord1, (0,2,1))
    
        kdir2, weights2, _, _ = fftquadrule2(angle2)
        kcoord2 = dir2coord(kdir2)
        kcoordT2 = np.transpose(kcoord2, (0,2,1))
        
        kdir3, weights3, _, _ = fftquadrule2(angle3)
        kcoord3 = dir2coord(kdir3)
        kcoordT3 = np.transpose(kcoord3, (0,2,1))
        
        coeff = ffcoeff(strengths, sources, center1, k, kcoord1)
    
        r = center2 - center1
        rhat = r/mag(r)
        cos_angle = rhat.dot(kcoordT2)
        shifter12 = m2m(mag(r), cos_angle, k)

        r = center3 - center2
        rhat = r/mag(r)
        cos_angle = rhat.dot(kcoordT3)
        shifter23 = m2m(mag(r), cos_angle, k)
        
        r = center4 - center3
        rhat = r/mag(r)
        cos_angle = rhat.dot(kcoordT3)
        translator34 = m2l(mag(r), cos_angle, k, order3)
    
        r = center5 - center4
        rhat = r/mag(r)
        cos_angle = rhat.dot(kcoordT3)
        shifter45 = m2m(mag(r), cos_angle, k)
        
        r = center6 - center5
        rhat = r/mag(r)
        cos_angle = rhat.dot(kcoordT2)
        shifter56 = m2m(mag(r), cos_angle, k)
        
        coeff2 = shifter12*fftinterpolate2(coeff, kdir1, kdir2)
        coeff3 = shifter23*fftinterpolate2(coeff2, kdir2, kdir3)
        coeff4 = translator34*coeff3
        coeff5 = fftfilter2(shifter45*coeff4, kdir3, kdir2)
        coeff6 = fftfilter2(shifter56*coeff5, kdir2, kdir1)
        
        pres_fmm = nfeval(coeff6, fieldpos, center6, weights1, k, kcoord1, 
            rho, c)

        perr = np.abs(pres_fmm - pres_exact)/np.abs(pres_exact)*100
        
        ####
        max_error.append(np.max(perr))
        mean_error.append(np.mean(perr))
        orders1.append(order1)
        orders2.append(order2)
        orders3.append(order3)

    box1 = Rectangle((center1[0] - 0.5*Dx/4, center1[1] - 0.5*Dy/4), Dx/4, Dy/4,
        facecolor='blue', alpha=0.5)
    box2 = Rectangle((center2[0] - 0.5*Dx/2, center2[1] - 0.5*Dy/2), Dx/2, Dy/2,
        facecolor='green', alpha=0.5)
    box3 = Rectangle((center3[0] - 0.5*Dx, center3[1] - 0.5*Dy), Dx, Dy,
        facecolor='yellow', alpha=0.5)    
    box4 = Rectangle((center4[0] - 0.5*Dx, center4[1] - 0.5*Dy), Dx, Dy,
        facecolor='red', alpha=0.5)    
    box5 = Rectangle((center5[0] - 0.5*Dx/2, center5[1] - 0.5*Dy/2), Dx/2, Dy/2,
        facecolor='red', alpha=0.5)    
    box6 = Rectangle((center6[0] - 0.5*Dx/4, center6[1] - 0.5*Dy/4), Dx/4, Dy/4,
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
    ax3.add_patch(box5)
    ax3.add_patch(box6)
    ax3.set_xticks((-Dx, 0, Dx))
    ax3.set_xlabel('x (m)')
    ax3.set_ylabel('y (m)')
    
    pp.show()
    