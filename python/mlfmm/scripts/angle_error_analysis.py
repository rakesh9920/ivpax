# mlfmm / angle_error_analysis.py

import numpy as np
import scipy as sp
from mlfmm.fasttransforms import *
from matplotlib import pyplot as pp

# set parameters
D0 = 0.001
level = 2
f = 5e6
rho = 1000
c = 1540
k = 2*np.pi*f/c
nsource = 100
nfieldpos = 100
C = 3/1.6
freqs = np.arange(50e3, 20e6, 50e3)
####
m3 = 1.6349831866097405e-06
y03 = 4.1439024697421942
m4 = 8.7283031699852648e-07
y04 = 3.785481291167617
m4_2 = 1.1530396342615333e-06
y04_2 = 3.7778743340763956

sugg_angles2 = np.fromstring('''
    4  4  4  4  4  4  6  6  6  6  6  6  6  6  6  6  6  6  6  6  6  6  9  9  9
    9  9  9  9  9 11 11 11 11 11 11 11 11 11 12 12 12 12 12 12 12 12 12 14 14
    14 14 14 14 14 14 14 15 15 15 15 15 15 15 15 15 17 17 17 17 17 17 17 17 17
    18 18 18 18 18 18 18 18 18 18 20 20 20 20 20 20 20 20 20 20 21 21 21 21 21
    21 21 21 21 21 23 23 23 23 23 23 23 23 23 25 25 25 25 25 25 25 25 25 25 26
    26 26 26 26 26 26 26 26 26 28 28 28 28 28 28 28 28 28 28 30 30 30 30 30 30
    30 30 30 30 30 31 31 31 31 31 31 31 31 31 31 34 34 34 34 34 34 34 34 34 34
    35 35 35 35 35 35 35 35 35 35 37 37 37 37 37 37 37 37 37 37 37 39 39 39 39
    39 39 39 39 39 39 42 42 42 42 42 42 42 42 42 42 42 44 44 44 44 44 44 44 44
    44 44 47 49 50 50 50 50 50 50 50 50 50 50 50 50 50 50 50 50 50 50 50 50 50
    50 50 50 50 50 50 50 50 50 50 50 50 50 50 50 50 50 50 50 50 50 50 50 50 50
    50 50 50 50 50 51 51 51 51 51 51 51 51 51 51 51 51 51 51 51 51 51 51 51 51
    51 52 52 52 52 52 52 52 52 52 52 52 52 52 52 52 52 52 52 52 52 52 54 54 54
    54 54 54 54 54 54 54 54 54 54 54 54 54 54 54 54 54 54 54 54 54 54 54 54 54
    54 54 54 54 54 54 54 54 54 54 54 54 54 54 54 57 57 57 57 57 57 57 57 57 57
    57 57 57 57 57 57 57 57 57 57 57 57 60 60 60 60 60 60 60 60 60 60 60 60
    ''', sep=' ')

sugg_angles3 = np.fromstring('''
    4  4  4  4  4  4  4  4  4  4  4  4  6  6  6  6  6  6  6  6  6  6  6  6  6
    6  6  6  6  6  6  6  6  6  6  6  6  6  6  6  6  6  6  6  9  9  9  9  9  9
    9  9  9  9  9  9  9  9  9  9 11 11 11 11 11 11 11 11 11 11 11 11 11 11 11
    11 11 11 12 12 12 12 12 12 12 12 12 12 12 12 12 12 12 12 12 12 14 14 14 14
    14 14 14 14 14 14 14 14 14 14 14 14 14 14 15 15 15 15 15 15 15 15 15 15 15
    15 15 15 15 15 15 15 15 17 17 17 17 17 17 17 17 17 17 17 17 17 17 17 17 17
    17 18 18 18 18 18 18 18 18 18 18 18 18 18 18 18 18 18 18 18 18 20 20 20 20
    20 20 20 20 20 20 20 20 20 20 20 20 20 20 20 21 21 21 21 21 21 21 21 21 21
    21 21 21 21 21 21 21 21 21 21 23 23 23 23 23 23 23 23 23 23 23 23 23 23 23
    23 23 23 23 25 25 25 25 25 25 25 25 25 25 25 25 25 25 25 25 25 25 25 25 26
    26 26 26 26 26 26 26 26 26 26 26 26 26 26 26 26 26 26 26 28 28 28 28 28 28
    28 28 28 28 28 28 28 28 28 28 28 28 28 28 30 30 30 30 30 30 30 30 30 30 30
    30 30 30 30 30 30 30 30 30 30 31 31 31 31 31 31 31 31 31 31 31 31 31 31 31
    31 31 31 31 31 32 32 32 32 32 32 32 32 32 32 32 32 32 32 32 32 32 32 32 32
    32 34 34 34 34 34 34 34 34 34 34 34 34 34 34 34 34 34 34 34 34 37 37 37 37
    37 37 37 37 37 37 37 37 37 37 37 37 37 37 37 37 37 37 37 37 37 37 37 37
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
    23 23 23 23 23 23 23 23 23 23 23 23 23 23 23 23 23 23 23 23 23 23 23 23 23
    23 25 25 25 25 25 25 25 25 25 25 25 25 25 25 25 25 25 25 25 25 27 27 27 27
    27 27 27 27 27 27 27 27 27 27 27 27 27 27 27 27 27 27 27 27 27 27 27 27
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

# determine truncation order

if __name__ == '__main__':
    
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
    
    orders = []
    orders1 = []
    errors = []
    max_error = []
    mean_error = []
    
    idx = 0
    for f in freqs:
        
        print f
        
        k = 2*np.pi*f/c
        
        pres_exact = directeval(strengths, sources, fieldpos, k, rho, c)
        
        v = np.sqrt(3)*Dx*k/2
        order1 = np.int(np.ceil(v + C*np.log(v + np.pi)))
        #angles1 = np.ceil(m4_2*f + y04_2)
        angles1 = sugg_angles3[idx]
        
        v = np.sqrt(3)*Dx*k
        order2 = np.int(np.ceil(v + C*np.log(v + np.pi)))
        #angles2 = np.ceil(m3*f + y03)
        angles2 = sugg_angles2[idx]
        
        #angles1 = order1
        #angles2 = order2
        
        threshold = 1.0
        idx += 1
        
        while True:
        
            kdir, weights, w1, w2 = fftquadrule2(angles1)
            kcoord = dir2coord(kdir)
            kcoordT = np.transpose(kcoord, (0,2,1))
        
            newkdir, newweights, _, _ = fftquadrule2(angles2)
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
            
            ####
            max_error.append(maxerr)
            mean_error.append(np.mean(perr))
            break
            
            if maxerr < threshold:
                
                errors.append(maxerr)
                orders.append(angles2)
                orders1.append(angles1)
                break
                
            elif angles1 > 60 or angles2 > 60:
                
                if threshold > 10.0:
                    orders.append(np.nan)
                    orders1.append(np.nan)
                    errors.append(np.nan)
                    break
                    
                threshold += 0.5
                angles1 = order1
                angles2 = order2
                
            temperr = maxerr
            angles1 += 1
            angles2 += 1
    
    