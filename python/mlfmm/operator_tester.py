# mlfmm / operator_tester.py

import numpy as np
import scipy as sp
from matplotlib import pyplot as pp
from mlfmm.operators import CachedOperator
#from mlfmm.quadtree2 import Operator
from mlfmm.fasttransforms import *

rho = 1000
c = 1540
f = 5e6
origin = np.array([0.0, 0.0, 0.0])
D0 = 0.001
dim = np.array([1.01, 1.01])*D0
k = 2*np.pi*f/c
nxnodes = 60
nynodes = 60

if __name__ == '__main__':

    x, y, z = np.mgrid[0:D0:(nxnodes*1j), 0:D0:(nynodes*1j), 0:1:1]
    nodes = np.c_[x.ravel(), y.ravel(), z.ravel()]
    nnodes = nodes.shape[0]
    
    s_n = (D0/(nxnodes-1))**2
    
    u = np.zeros((nxnodes, nynodes), dtype='cfloat')
    #u[7,7] = 1
    u[0,0] = 1
    u = u.ravel()
    #u[0:30] = 1
    #np.random.shuffle(u)
    
    q = s_n*u

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
    
    op.setup(verbose=True)
    op.precompute()
    pressure = op.apply(u).reshape((nxnodes,nynodes))

    pressure_exact = directeval(q, nodes, nodes, k, rho, c)*2
    a_eff = np.sqrt(s_n/np.pi)
    pressure_exact += rho*c*(0.5*(k*a_eff)**2 + 1j*8/(3*np.pi)*k*a_eff)/2.0*u
    pressure_exact = pressure_exact.reshape((nxnodes,
        nynodes))
    
    #maskedu = np.abs(u.reshape((nxnodes,nynodes)))
    #maskedu = np.ma.masked_where(maskedu < 0.5, maskedu)
    
    error_amp = np.abs(pressure - pressure_exact)/np.abs(pressure_exact)*100
    
    error_amp[np.isnan(error_amp)] = 0
    error_phase = np.abs(np.angle(pressure) - np.angle(pressure_exact))
        
    print np.mean(error_amp), np.max(error_amp), np.max(error_phase)
    
    pp.figure(tight_layout=True)
    pp.imshow(np.abs(pressure), interpolation='none')
    cb = pp.colorbar()
    #pp.imshow(np.abs(pressure), interpolation='none', cmap='gray')
    cb.set_label('Pressure (Pa)')
    pp.title('Pressure amplitude with source distr. overlay \n MLFMM, 5 MHz, '
        '1x1mm area, 3600 nodes')
    pp.show()
    
    pp.figure(tight_layout=True)
    pp.imshow(np.angle(pressure), interpolation='none')
    cb = pp.colorbar()
    #pp.imshow(maskedu, interpolation='none', cmap='gray')
    cb.set_label('Phase (radians)')
    pp.title('Pressure phase with source distr. overlay \n MLFMM, 5 MHz, '
        '1x1mm area, 3600 nodes')
    pp.show()
    
    pp.figure(tight_layout=True)
    pp.imshow(np.abs(pressure_exact), interpolation='none')
    cb = pp.colorbar()
    #pp.imshow(maskedu, interpolation='none', cmap='gray')
    cb.set_label('Pressure (Pa)')
    pp.title('Pressure amplitude with source distr. overlay \n Exact, 5 MHz, '
        '1x1mm area, 3600 nodes')
    pp.show()
    
    pp.figure(tight_layout=True)
    pp.imshow(np.angle(pressure_exact), interpolation='none')
    cb = pp.colorbar()
    #pp.imshow(maskedu, interpolation='none', cmap='gray')
    cb.set_label('Phase (radians)')
    pp.title('Pressure phase with source distr. overlay \n Exact, 5 MHz, '
        '1x1mm area, 3600 nodes')
    pp.show()
    
    pp.figure(tight_layout=True)
    pp.imshow(error_amp, interpolation='none')
    cb = pp.colorbar()
    #pp.imshow(maskedu, interpolation='none', cmap='gray')
    cb.set_label('Error (%)')
    pp.title('Amplitude error with source distr. overlay \n 5 MHz, '
        '1x1mm area, 3600 nodes')
    pp.show()

    pp.figure(tight_layout=True)
    pp.imshow(error_phase, interpolation='none', clim=[0, np.pi/16])
    cb = pp.colorbar()
    #pp.imshow(maskedu, interpolation='none', cmap='gray')
    cb.set_label('Error (radians)')
    pp.title('Phase error with source distr. overlay \n 5 MHz, '
        '1x1mm area, 3600 nodes')
    pp.show()

    