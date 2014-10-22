# mlfmm / angle_error_analysis.py

import numpy as np
import scipy as sp
from mlfmm.fasttransforms import *
from matplotlib import pyplot as pp

# set parameters
D0 = 0.001
level = 3
f = 5e6
rho = 1000
c = 1540
k = 2*np.pi*f/c
nsource = 100
nfieldpos = 100
C = 3/1.6

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
    errors = []
        
    for freq in np.arange(50e3, 5e6, 50e3):
        
        k = 2*np.pi*freq/c
        
        pres_exact = directeval(strengths, sources, fieldpos, k, rho, c)
        
        v = np.sqrt(3)*Dx*k/2
        order1 = np.int(np.ceil(v + C*np.log(v + np.pi)))
        
        v = np.sqrt(3)*Dx*k
        order2 = np.int(np.ceil(v + C*np.log(v + np.pi)))
        
        angles1 = order1
        angles2 = order2
        
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
            if maxerr < 1.0:
                
                errors.append(maxerr)
                orders.append(angles2)
                break
                
            elif angles1 > 25 or angles2 > 25:
                
                orders.append(np.nan)
                errors.append(np.nan)
                break
                
            angles1 += 1
            angles2 += 1
    
    
    