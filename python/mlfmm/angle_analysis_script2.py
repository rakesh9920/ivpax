# mlfmm / angle_error_analysis.py

import numpy as np
import scipy as sp
from mlfmm.fasttransforms import *
from matplotlib import pyplot as pp

# set parameters
D0 = 0.001
level = 4
f = 5e6
rho = 1000
c = 1540
k = 2*np.pi*f/c
nsource = 100
nfieldpos = 100
C = 3/1.6
freqs = np.arange(50e3, 20e6, 50e3)

sugg_angles2 = np.fromstring('''
    4  4  4  4  4  4  6  6  6  6  6  6  6  6  6  6  6  6  6  6  6  6  9  9  9
    9  9  9  9  9 10 10 10 10 10 10 10 10 10 12 12 12 12 12 12 12 12 12 14 14
    14 14 14 14 14 14 14 15 15 15 15 15 15 15 15 15 17 17 17 17 17 17 17 17 17
    18 18 18 18 18 18 18 18 18 18 20 20 20 20 20 20 20 20 20 20 21 21 21 21 21
    21 21 21 21 21 23 23 23 23 23 23 23 23 23 25 25 25 25 25 25 25 25 25 25 26
    26 26 26 26 26 26 26 26 26 28 28 28 28 28 28 28 28 28 28 30 30 30 30 30 30
    30 30 30 30 30 31 31 31 31 31 31 31 31 31 31 32 32 32 32 34 34 34 34 34 34
    34 34 34 35 35 35 35 35 35 35 37 37 37 37 37 37 37 37 37 37 37 37 37 38 38
    38 38 38 38 38 39 40 40 40 40 40 40 40 40 40 41 41 42 42 42 42 42 42 42 42
    42 42 47 47 47 47 47 47 47 47 47 47 47 47 47 47 48 48 48 48 48 48 48 48 49
    49 49 49 49 49 49 49 49 49 49 49 49 49 50 50 50 52 52 52 52 52 52 52 52 52
    52 52 52 52 52 53 57 57 57 57 57 57 57 57 57 57 57 57 57 57 57 57 57 57 57
    57 57 57 57 57 57 57 57 57 57 57 57 57 57 57 57 57 57 57 57 57 57 57 57 59
    59 59 59 59 59 59 59 59 59 59 59 59 59 59 59 59 59 59 59 59 59 59 59 59 59
    59 59 59 59 59 60 60 60 61 61 61 61 61 61 61 61 61 61 61 61 61 61 61 61 61
    61 61 61 61 61 61 61 61 61 61 61 61 61 61 61 61 61 61 61 61 61 61 61 61
    ''', sep=' ')

sugg_angles3 = np.fromstring('''
    4  4  4  4  4  4  5  5  5  5  5  5  5  5  5  5  5  5  5  5  5  5  7  7  7
    7  7  7  7  7  8  8  8  8  8  8  8  8  8  9  9  9  9  9  9  9  9  9 11 11
    11 11 11 11 11 11 11 11 11 11 11 11 11 11 11 11 13 13 13 13 13 13 13 13 13
    13 13 13 13 13 13 13 13 13 13 15 15 15 15 15 15 15 15 15 15 15 15 16 16 16
    16 16 16 16 16 17 17 17 17 17 17 17 17 17 19 19 19 19 19 19 19 19 19 19 19
    19 19 19 19 19 19 19 19 19 21 21 21 21 21 21 21 21 21 21 22 22 22 22 22 22
    22 22 22 22 22 23 23 23 23 23 23 23 23 23 23 25 25 25 25 25 25 25 25 25 25
    25 25 26 26 26 26 26 26 26 26 27 27 27 27 27 27 27 27 27 27 27 27 27 27 27
    27 28 28 28 28 28 29 29 29 31 31 31 31 31 31 31 31 31 31 31 31 33 33 33 33
    33 33 33 35 35 35 35 35 35 35 35 35 35 35 35 35 35 35 35 35 35 35 35 37 37
    37 37 37 37 37 37 37 37 37 37 37 37 37 37 37 37 37 37 37 37 37 37 37 37 39
    39 39 39 39 39 39 39 39 39 39 39 39 41 41 41 41 41 41 41 41 41 41 41 41 41
    41 41 41 41 41 41 41 41 41 41 41 41 41 41 41 41 41 41 41 41 41 41 41 41 41
    41 41 41 41 41 41 41 41 41 41 43 43 43 43 43 43 43 43 43 43 43 43 43 45 45
    45 45 45 45 45 45 46 46 46 46 46 46 46 46 46 46 46 46 46 46 46 46 46 46 46
    46 46 46 46 46 46 46 46 46 46 46 49 49 49 49 49 49 49 49 49 49 49 49 49
    ''', sep=' ')

sugg_angles4 = np.fromstring('''
    4  4  4  4  4  4  4  4  4  4  4  4  5  5  5  5  5  5  5  5  5  5  5  5  5
    5  5  5  5  5  5  5  5  5  5  5  5  5  5  5  5  5  5  5  7  7  7  7  7  7
    7  7  7  7  7  7  7  7  7  7  9  9  9  9  9  9  9  9  9  9  9  9  9  9  9
    9  9  9  9  9  9  9  9  9  9  9  9  9  9  9  9  9  9  9  9  9 11 11 11 11
    11 11 11 11 11 11 11 11 11 11 11 11 11 11 11 11 11 11 11 11 11 11 11 11 11
    11 11 11 11 11 11 11 11 13 13 13 13 13 13 13 13 13 13 13 13 13 13 13 13 13
    13 13 13 13 13 13 13 13 13 13 13 13 13 13 13 13 13 13 13 13 13 15 15 15 15
    15 15 15 15 15 15 15 15 15 15 15 15 15 15 15 15 15 15 15 15 15 15 15 15 15
    15 15 15 15 15 15 15 15 15 15 17 17 17 17 17 17 17 17 17 17 17 17 17 17 17
    17 17 17 17 19 19 19 19 19 19 19 19 19 19 19 19 19 19 19 19 19 19 19 19 19
    19 19 19 19 19 19 19 19 19 19 19 19 19 19 19 19 19 19 19 21 21 21 21 21 21
    21 21 21 21 21 21 21 21 21 21 21 21 21 21 22 22 22 22 22 22 22 22 22 22 22
    22 22 22 22 22 22 22 22 22 22 23 23 23 23 23 23 23 23 23 23 23 23 23 23 23
    23 23 23 23 23 25 25 25 25 25 25 25 25 25 25 25 25 25 25 25 25 25 25 25 25
    25 25 25 25 25 25 25 25 25 25 25 25 25 25 25 25 25 25 25 25 25 27 27 27 27
    27 27 27 27 27 27 27 27 27 27 27 27 27 27 27 27 27 27 29 29 29 29 29 29
    ''', sep=' ')

sugg_angles5 = np.fromstring('''
    4  4  4  4  4  4  4  4  4  4  4  4  4  4  4  4  5  5  5  5  5  5  5  5  5
    5  5  5  5  5  5  5  5  5  5  5  5  5  5  5  5  5  5  5  5  5  5  5  5  5
    5  5  5  5  5  5  5  5  5  5  5  5  5  5  5  5  5  5  5  5  5  5  5  5  5
    5  5  5  5  5  5  5  5  5  5  5  5  5  7  7  7  7  7  7  7  7  7  7  7  7
    7  7  7  7  7  7  7  7  7  7  7  7  7  7  7  7  7  7  7  7  7  9  9  9  9
    9  9  9  9  9  9  9  9  9  9  9  9  9  9  9  9  9  9  9  9  9  9  9  9  9
    9  9  9  9  9  9  9  9  9  9  9  9  9  9  9  9  9  9  9  9  9  9  9  9  9
    9  9  9  9  9  9  9  9  9  9  9  9  9  9  9  9  9 11 11 11 11 11 11 11 11
    11 11 11 11 11 11 11 11 11 11 11 11 11 11 11 11 11 11 11 11 11 11 11 11 11
    11 11 11 11 11 11 11 11 11 11 11 11 11 11 11 11 11 11 11 11 11 11 11 11 11
    11 11 11 11 11 11 11 11 11 11 11 11 11 11 11 11 13 13 13 13 13 13 13 13 13
    13 13 13 13 13 13 13 13 13 13 13 13 13 13 13 13 13 13 13 13 13 13 13 13 13
    13 13 13 14 14 14 14 14 14 14 14 14 14 14 14 14 14 14 14 14 14 14 14 14 14
    14 14 14 14 14 14 14 14 14 14 14 14 14 14 14 14 14 15 15 15 15 15 15 15 15
    15 15 15 15 15 15 15 15 15 15 15 15 15 15 15 15 15 15 15 15 15 15 15 15 15
    15 15 15 15 15 15 15 15 15 15 15 15 15 15 15 15 15 15 15 15 15 15 15 15
    ''', sep=' ')
    
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

if __name__ == '__main__':
    
    min_angles1 = []
    max_errors = []
    mean_errors = []
        
    idx = 0
    for f in freqs:
        
        print f
        
        srcx = sp.rand(nsource)*Dx/2
        srcy = sp.rand(nsource)*Dy/2
        srcz = sp.rand(nsource)*Dz/2
        sources = np.c_[srcx, srcy, srcz] + center1 - 0.5*np.array([Dx/2, Dy/2, 
            Dz/2])
        strengths = np.ones(nsource)
    
        srcx = sp.rand(nfieldpos)*Dx/2
        srcy = sp.rand(nfieldpos)*Dy/2
        srcz = sp.rand(nfieldpos)*Dz/2
        fieldpos = np.c_[srcx, srcy, srcz] + center4 - 0.5*np.array([Dx/2, Dy/2, 
            Dz/2])

        k = 2*np.pi*f/c
        
        pres_exact = directeval(strengths, sources, fieldpos, k, rho, c)
        
        v = np.sqrt(3)*Dx*k/2
        order1 = np.int(np.ceil(v + C*np.log(v + np.pi)))

        v = np.sqrt(3)*Dx*k
        order2 = np.int(np.ceil(v + C*np.log(v + np.pi)))
        
        angle1 = order1
        angle2 = sugg_angles4[idx]
        
        threshold = 1.0
        
        while True:
        
            kdir, weights, w1, w2 = fftquadrule2(angle1)
            kcoord = dir2coord(kdir)
            kcoordT = np.transpose(kcoord, (0,2,1))
        
            newkdir, newweights, _, _ = fftquadrule2(angle2)
            newkcoord = dir2coord(newkdir)    
            newkcoordT = np.transpose(newkcoord, (0,2,1))
            
            coeff = ffcoeff(strengths, sources, center1, k, kcoord)
        
            r = center2 - center1
            rhat = r/mag(r)
            cos_angle = rhat.dot(newkcoordT)
            shifter1 = m2m(mag(r), cos_angle, k)
        
            r = center3 - center2
            rhat = r/mag(r)
            cos_angle = rhat.dot(newkcoordT)
            translator = m2l(mag(r), cos_angle, k, order2)
        
            r = center4 - center3
            rhat = r/mag(r)
            cos_angle = rhat.dot(newkcoordT)
            shifter2 = m2m(mag(r), cos_angle, k)
            
            newffcoeff = shifter1*fftinterpolate2(coeff, kdir, newkdir)
            newnfcoeff = newffcoeff*translator*shifter2
            
            nfcoeff = fftfilter2(newnfcoeff, newkdir, kdir)
        
            pres_fmm = nfeval(nfcoeff, fieldpos, center4, weights, k, kcoord, 
                rho, c)
    
            perr = np.abs(np.abs(pres_fmm) - np.abs(pres_exact))/np.abs(pres_exact)*100
            
            maxerr = np.max(perr)
            meanerr = np.mean(perr)
            
            if maxerr < threshold:
                
                max_errors.append(maxerr)
                mean_errors.append(meanerr)
                min_angles1.append(angle1)
                break
                
            elif angle1 >= angle2:
                
                if threshold > 5.0:
                    max_errors.append(np.inf)
                    mean_errors.append(np.inf)
                    min_angles1.append(0.0)
                    break
                    
                threshold += 0.5
                angle1 = order1
                
            angle1 += 1
        
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
    