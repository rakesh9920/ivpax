# mlfmm / operator_tester.py

import numpy as np
import scipy as sp
from matplotlib import pyplot as pp
from mlfmm.operators import CachedOperator
#from mlfmm.quadtree2 import Operator
from mlfmm.fasttransforms import *

rho = 1000
c = 1540
f = 0.05e6
origin = np.array([0.0, 0.0, 0.0])
D0 = 0.001
dim = np.array([1.01, 1.01])*D0
k = 2*np.pi*f/c
nxnodes = 60
nynodes = 60
freqs = np.arange(50e3, 20e6, 0.5e6)

if __name__ == '__main__':

    x, y, z = np.mgrid[0:D0:(nxnodes*1j), 0:D0:(nynodes*1j), 0:1:1]
    nodes = np.c_[x.ravel(), y.ravel(), z.ravel()]
    nnodes = nodes.shape[0]
    
    s_n = (D0/(nxnodes-1))**2
    
    u = np.zeros((nxnodes, nynodes), dtype='cfloat')
    u[0,0] = 1
    u = u.ravel()
    #u[0:30] = 1
    #np.random.shuffle(u)
    
    q = 1j*rho*c*2*np.pi*f/c*s_n*u

    op = CachedOperator()
    op.params['density'] = rho
    op.params['sound_speed'] = c
    op.params['node_area'] = s_n
    op.params['wave_number'] = 2*np.pi*f/c
    op.params['box_dims'] = dim
    op.params['origin'] = origin
    op.params['nodes'] = nodes
    op.params['min_level'] = 2
    op.params['max_level'] = 4
    
    max_errors = []
    mean_errors = []
    max_phase_errors = []
    
    for f in freqs:
        
        print f
        k = 2*np.pi*f/c
        op.params['wave_number'] = k
        
        op.setup(verbose=False)
        op.precompute()
        
        pressure = op.apply(u).reshape((nxnodes,nynodes))
    
        q = 1j*rho*c*2*np.pi*f/c*s_n*u
        pressure_exact = directeval(q, nodes, nodes, k, rho, c).reshape((nxnodes,
            nynodes))
        
        maskedu = np.abs(u.reshape((nxnodes,nynodes)))
        maskedu = np.ma.masked_where(maskedu < 0.5, maskedu)
        
        error_amp = np.abs(pressure - pressure_exact)/np.abs(pressure_exact)*100
        
        error_amp[np.isnan(error_amp)] = 0
        error_phase = np.abs(np.angle(pressure) - np.angle(pressure_exact))
            
        mean_errors.append(np.mean(error_amp))
        max_errors.append(np.max(error_amp))
        max_phase_errors.append(np.max(error_phase))
    
    fig1 = pp.figure()
    ax1 = fig1.add_subplot(111)
    ax1.plot(freqs/1e6, max_errors)
    ax1.plot(freqs/1e6, mean_errors)
    ax1.set_xlabel('Frequency (MHz)')
    ax1.set_ylabel('Error (%)')
    ax1.set_title('Amplitude error analysis of a 3-level MLFMM operator, \nsingle excited node')
    ax1.legend(('maximum','mean'))
    
    fig2 = pp.figure()
    ax2 = fig2.add_subplot(111)
    ax2.plot(freqs/1e6, max_phase_errors)
    ax2.set_xlabel('Frequency (MHz)')
    ax2.set_ylabel('Error (radians)')
    ax2.set_title('Phase error analysis of a 3-level MLFMM operator, \nsingle excited node')
    ax2.legend(('maximum',))