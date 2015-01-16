# mlfmm / mp_error_analysis.py

import numpy as np
import scipy as sp
from mlfmm.mptransforms import *
from pyfield.util import distance
from matplotlib import pyplot as pp

nsource = 50
nfieldpos = 50
level = 5
D0 = 0.001
f = 0.05e6
rho = 1000
c = 1540
dps = 2
mp.dps = 100

box = np.array([[-0.5, 0.5],[-0.5, 0.5],[0, 0]])*D0/(2**level)
k = 2*np.pi*f/c
D = box[0,1] - box[0,0]
obs_d = 2*D
center1 = np.array([0, 0, 0])
center2 = np.array([0, 1, 0])*obs_d
wavelength = c/f

v = np.sqrt(3)*D*k
C = dps/1.6
sugg_order = np.int(np.ceil(v + C*np.log(v + np.pi)))
#order = sugg_order
stab_cond = 0.15*v/np.log(v + np.pi)
#print sugg_order, stab_cond, stab_cond > C
print level, sugg_order, wavelength/D

####

if __name__ == '__main__':
    
    srcx = sp.rand(nsource)*(box[0,1] - box[0,0])
    srcy = sp.rand(nsource)*(box[1,1] - box[1,0])
    srcz = sp.rand(nsource)*(box[2,1] - box[2,0])
    sources = np.c_[srcx, srcy, srcz] + center1 -0.5*D
    strengths = np.ones(nsource)
    
    srcx = sp.rand(nfieldpos)*(box[0,1] - box[0,0])
    srcy = sp.rand(nfieldpos)*(box[1,1] - box[1,0])
    srcz = sp.rand(nfieldpos)*(box[2,1] - box[2,0])
    fieldpos = np.c_[srcx, srcy, srcz] + center2 - 0.5*D
    dist = distance(fieldpos, sources)
    
    pres_exact = directeval(strengths, sources, fieldpos, k, rho, c)

    float64_merr = []
    float64_perr = []
    mp_merr = []
    mp_perr = []

    for order in xrange(1, 20):
        
        kdir, weights, w1, w2 = mp_fftquadrule(order)
        kcoord = mp_dir2coord(kdir)
        kcoordT = np.transpose(kcoord, (0,2,1))
        
        r = center2 - center1
        rhat = r/mag(r)
        cos_angle = rhat.dot(kcoordT)
        
        ####
        coeff = ffcoeff(strengths, sources, center1, k, kcoord.astype(float))
        
        translator = m2l(mag(r), cos_angle.astype(float), k, order)
        pres_fmm = nfeval(coeff*translator, fieldpos, center2, np.cfloat(weights), 
            k, kcoord.astype(float), rho, c)
        
        perr = np.abs(np.abs(pres_fmm) - np.abs(pres_exact))/np.abs(pres_exact)*100
        mean_perr = np.mean(perr)
        peak_perr = np.max(perr)
        
        float64_merr.append(mean_perr)
        float64_perr.append(peak_perr)
        
        ####
        mp_coeff = mp_ffcoeff(strengths, sources, center1, k, kcoord)
        
        mp_translator = mp_m2l(mag(r), cos_angle, k, order)
        pres_mp = mp_nfeval(mp_coeff*mp_translator, fieldpos, center2, weights, k, 
            kcoord, rho, c)
    
        perr = np.abs(np.abs(pres_mp) - np.abs(pres_exact))/np.abs(pres_exact)*100
        mean_perr = np.mean(perr)
        peak_perr = np.max(perr)
        
        mp_merr.append(mean_perr)
        mp_perr.append(peak_perr)
        
        if peak_perr > 100 or mean_perr > 100:
            break
    
    pp.plot(np.arange(1,20), mp_perr)
    pp.plot(np.arange(1,20), float64_perr)
    pp.title('Error analysis for multi-precision FMM \n D0=1mm, f=50kHz, level 5, D ~ $\lambda/985$')
    pp.xlabel('truncation number L')
    pp.ylabel('maximum relative error (percent)')
    pp.legend(('float336 (100-digits)','float64'))
    pp.gca().set_ylim(0, 6)
    pp.show()
    
    
    