# mlfmm / angle_error_analysis.py

import numpy as np
import scipy as sp
from mlfmm.fasttransforms import *
from matplotlib import pyplot as pp

# set parameters
D0 = 0.001
level = 2
rho = 1000
c = 1540
nsource = 1
nfieldpos = 1
C = 5/1.6
freqs = np.arange(50e3, 20e6, 50e3)

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

sugg_angles4 = np.fromstring('''
    5  5  7  7  7  7  7  7  8  8  8  8  8  8  9  9  9  9  9  9  9 11 11 11 11
    11 11 11 13 13 13 13 13 13 13 13 15 15 15 15 15 15 15 15 15 15 15 15 15 15
    15 15 17 17 17 17 17 17 17 17 17 17 17 17 17 17 17 17 19 19 19 19 19 19 19
    19 19 21 21 21 21 21 21 21 21 21 21 21 21 21 21 21 21 21 23 23 23 23 23 23
    23 23 23 25 25 25 25 25 25 25 25 25 25 25 25 25 25 25 25 25 25 27 27 27 27
    27 27 27 27 27 27 29 29 29 29 29 29 29 29 29 29 29 29 29 29 29 29 29 29 29
    31 31 31 31 31 31 31 31 31 33 33 33 33 33 33 33 33 33 33 33 33 33 33 33 33
    33 33 33 35 35 35 35 35 35 35 35 35 35 35 35 35 35 35 35 35 35 35 35 37 37
    37 37 37 37 37 37 37 37 39 39 39 39 39 39 39 39 39 39 39 39 39 39 39 39 39
    39 39 39 41 41 41 41 41 41 41 41 41 41 41 41 41 41 41 41 41 41 41 41 43 43
    43 43 43 43 43 43 43 43 45 45 45 45 45 45 45 45 45 45 45 45 45 45 45 45 45
    45 45 45 47 47 47 47 47 47 47 47 47 47 47 47 47 47 47 47 47 47 47 47 47 49
    49 49 49 49 49 49 49 49 49 49 49 49 49 49 49 49 49 49 49 51 51 51 51 51 51
    51 51 51 51 51 51 51 51 51 51 51 51 51 51 51 51 51 51 51 51 51 51 51 51 51
    51 51 51 51 51 51 51 51 51 51 51 51 51 51 51 51 51 51 51 51 51 51 51 51 51
    51 51 51 51 51 51 51 51 51 51 51 51 51 51 51 51 51 51 51 51 51 51 51 51
    ''', sep=' ')

sugg_angles3 = np.fromstring('''
    6  6  8  8  8  8  8  8  9  9  9  9  9  9 10 10 10 10 10 10 10 11 11 11 11
    11 11 11 13 13 13 13 13 13 13 13 15 15 15 15 15 15 15 15 15 15 15 15 15 15
    15 15 17 17 17 17 17 17 17 17 17 17 17 17 17 17 17 17 19 19 19 19 19 19 19
    19 19 21 21 21 21 21 21 21 21 21 21 21 21 21 21 21 21 21 23 23 23 23 23 23
    23 23 23 25 25 25 25 25 25 25 25 25 25 25 25 25 25 25 25 25 25 27 27 27 27
    27 27 27 27 27 27 29 29 29 29 29 29 29 29 29 29 29 29 29 29 29 29 29 29 29
    31 31 31 31 31 31 31 31 31 33 33 33 33 33 33 33 33 33 33 33 33 33 33 33 33
    33 33 33 35 35 35 35 35 35 35 35 35 35 35 35 35 35 35 35 35 35 35 35 37 37
    37 37 37 37 37 37 37 37 39 39 39 39 39 39 39 39 39 39 39 39 39 39 39 39 39
    39 39 39 41 41 41 41 41 41 41 41 41 41 41 41 41 41 41 41 41 41 41 41 43 43
    43 43 43 43 43 43 43 43 45 45 45 45 45 45 45 45 45 45 45 45 45 45 45 45 45
    45 45 45 47 47 47 47 47 47 47 47 47 47 47 47 47 47 47 47 47 47 47 47 47 49
    49 49 49 49 49 49 49 49 49 49 49 49 49 49 49 49 49 49 49 51 51 51 51 51 51
    51 51 51 51 51 51 51 51 51 51 51 51 51 51 51 51 51 51 51 51 51 51 51 51 51
    51 51 51 51 51 51 51 51 51 51 51 51 51 51 51 51 51 51 51 51 51 51 51 51 51
    51 51 51 51 51 51 51 51 51 51 51 51 51 51 51 51 51 51 51 51 51 51 51 51
    ''', sep=' ')

sugg_angles2 = np.fromstring('''
    7  7  9  9  9  9  9  9  9 10 10 10 10 10 11 11 11 11 11 11 11 11 11 11 11
    11 11 11 13 13 13 13 13 13 13 13 15 15 15 15 15 15 15 15 15 15 15 15 15 15
    15 15 17 17 17 17 17 17 17 17 17 17 17 17 17 17 17 17 19 19 19 19 19 19 19
    19 19 21 21 21 21 21 21 21 21 21 21 21 21 21 21 21 21 21 23 23 23 23 23 23
    23 23 23 25 25 25 25 25 25 25 25 25 25 25 25 25 25 25 25 25 25 27 27 27 27
    27 27 27 27 27 27 29 29 29 29 29 29 29 29 29 29 29 29 29 29 29 29 29 29 29
    31 31 31 31 31 31 31 31 31 33 33 33 33 33 33 33 33 33 33 33 33 33 33 33 33
    33 33 33 35 35 35 35 35 35 35 35 35 35 35 35 35 35 35 35 35 35 35 35 37 37
    37 37 37 37 37 37 37 37 39 39 39 39 39 39 39 39 39 39 39 39 39 39 39 39 39
    39 39 39 41 41 41 41 41 41 41 41 41 41 41 41 41 41 41 41 41 41 41 41 43 43
    43 43 43 43 43 43 43 43 45 45 45 45 45 45 45 45 45 45 45 45 45 45 45 45 45
    45 45 45 47 47 47 47 47 47 47 47 47 47 47 47 47 47 47 47 47 47 47 47 47 49
    49 49 49 49 49 49 49 49 49 49 49 49 49 49 49 49 49 49 49 51 51 51 51 51 51
    51 51 51 51 51 51 51 51 51 51 51 51 51 51 51 51 51 51 51 51 51 51 51 51 51
    51 51 51 51 51 51 51 51 51 51 51 51 51 51 51 51 51 51 51 51 51 51 51 51 51
    51 51 51 51 51 51 51 51 51 51 51 51 51 51 51 51 51 51 51 51 51 51 51 51
    ''', sep=' ')

if __name__ == '__main__':

    sources = np.array([Dx, Dy, Dz])/8 + center1 
    sources = sources[None,:]
    strengths = np.ones(nsource)
    fieldpos = np.array([-Dx, -Dy, -Dz])/8 + center6
    fieldpos = fieldpos[None,:]
    
    min_angles1 = []
    min_angles2 = []
    max_errors = []
    mean_errors = []
        
    idx = 0
    for f in freqs:
        
        print f
    
        k = 2*np.pi*f/c
        
        pres_exact = directeval(strengths, sources, fieldpos, k, rho, c)
        
        v = np.sqrt(3)*Dx*k/4
        order1 = np.int(np.ceil(v + C*np.log(v + np.pi)))

        v = np.sqrt(3)*Dx*k/2
        order2 = np.int(np.ceil(v + C*np.log(v + np.pi)))
    
        v = np.sqrt(3)*Dx*k/1
        order3 = np.int(np.ceil(v + C*np.log(v + np.pi)))
        
        angle1 = sugg_angles4[idx]
        angle2 = sugg_angles3[idx]
        angle3 = sugg_angles3[idx]
        
        threshold = 1.0
        
        while True:
        
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
            
            maxerr = np.max(perr)
            
            if maxerr < threshold:
                
                max_errors.append(maxerr)
                min_angles1.append(angle3)
                break
                
            #elif angle2 == angle3:
            #elif angle2 >= order3*4:
            elif angle3 > 70:
                
                if threshold >= 10.0:
                    max_errors.append(np.inf)
                    min_angles1.append(0.0)
                    break
                    
                threshold += 0.5
                angle3 = sugg_angles3[idx]
                
            angle1 += 0
            angle2 += 0
            angle3 += 1
        
        idx += 1
        
    sugg_angles = np.zeros_like(min_angles1)
    sugg_angles[0] = min_angles1[0]
    temp = sugg_angles[0]
    
    for x in xrange(1, len(sugg_angles)):
        
        order = min_angles1[x]
        if order < temp:
            sugg_angles[x] = temp
        else:
            sugg_angles[x] = order
            temp = order
    