# mlfmm / angle_error_analysis.py

import numpy as np
import scipy as sp
from mlfmm.fasttransforms import *
from matplotlib import pyplot as pp

# set parameters
D0 = 0.001
level = 5
f = 19e6
rho = 1000
c = 1540
k = 2*np.pi*f/c
#nsource = 1
source_density = 10.
nfieldpos = 1
C = 3/1.6
freqs = np.arange(50e3, 20e6, 50e3)
####
    
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
    
    sources = np.array([Dx, Dy, Dz])/2 + center1 
    sources = sources[None,:]
    strengths = np.ones(nsource)
    fieldpos = np.array([-Dx, -Dy, -Dz])/2 + center4
    fieldpos = fieldpos[None,:]
    
    min_angle1 = []
    min_angle2 = []
    sugg_angle1 = []
    sugg_angle2 = []
    error = []
    idx = 0
    
    for f in freqs:
        
        print f
        
        k = 2*np.pi*f/c
        
        pres_exact = directeval(strengths, sources, fieldpos, k, rho, c)
        
        v = np.sqrt(3)*Dx*k/2
        order1 = np.int(np.ceil(v + C*np.log(v + np.pi)))
        angle1 = order1
        
        v = np.sqrt(3)*Dx*k
        order2 = np.int(np.ceil(v + C*np.log(v + np.pi)))
        angle2 = order2
        #angle2 = min_angle2[idx]
        
        sugg_angle1.append(angle1)
        sugg_angle2.append(angle2)
        
        error_temp = 0
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
            
            error_delta = np.abs(perr - error_temp)
            
            #if error_delta < 0.001:
            if np.abs(perr - max_error[idx]) < 0.1:
                
                min_angle1.append(angle1)
                min_angle2.append(angle2)
                error.append(float(perr))                
                break
                
            elif angle1 > 80 or angle2 > 80:
            #elif angle1 == angle2:
                
                min_angle1.append(np.nan)
                min_angle2.append(np.nan)
                error.append(np.nan)
                
                #min_angle1.append(angle1)    
                #error.append(float(perr))             
                break
                
            angle1 += 1
            angle2 += 1
            error_temp = perr
        
        idx +=1
    
    