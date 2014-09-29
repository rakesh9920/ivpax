# mlfmm / operator_tester.py

import numpy as np
import scipy as sp
from matplotlib import pyplot as pp
from mlfmm.operators import CachedOperator
from mlfmm.quadtree2 import Operator
from mlfmm.fasttransforms import *

rho = 1000
c = 1000
f = 3e6
origin = np.array([0.0, 0.0, 0.0])
mfac = 100
dim = np.array([70.1e-6, 70.1e-6])*mfac
k = 2*np.pi*f/c

if __name__ == '__main__':
    
    #x, y, z = np.mgrid[0:65.3e-6:28j, 0:65.3e-6:28j, 0:1:1]
    x, y, z = np.mgrid[0:70e-6:60j, 0:70e-6:60j, 0:1:1]*mfac
    #nodes = np.c_[x[1:-1, 1:-1].ravel(), y[1:-1, 1:-1].ravel(), 
    #    z[1:-1, 1:-1].ravel()]
    nodes = np.c_[x.ravel(), y.ravel(), z.ravel()]
    nnodes = nodes.shape[0]
    
    #nodes = sp.rand(nnodes, 3)
    
    s_n = (70e-6/29)**2
    #s_n = (70e-6)**2/nnodes
    
    u = np.zeros((60, 60), dtype='cfloat')
    #u[14,14] = 1
    u = u.ravel()
    u[0:50] = 1
    np.random.shuffle(u)
    
    q = 1j*rho*c*2*np.pi*f/c*s_n*u
    #qt = QuadTree(nodes, origin, dim)
    #qt.setup(2, 4)
    
    op = CachedOperator()
    op.params['density'] = rho
    op.params['sound_speed'] = c
    op.params['node_area'] = s_n
    op.params['wave_number'] = 2*np.pi*f/c
    op.params['box_dims'] = dim
    op.params['origin'] = origin
    op.params['nodes'] = nodes
    op.params['min_level'] = 2
    op.params['max_level'] = 3
    
    op.setup()
    op.precompute()
    pressure = op.apply(u).reshape((60,60))
    
    pressure_exact = directeval(q, nodes, nodes, k, rho, c).reshape((60,60))
    
    maskedu = np.abs(u.reshape((60,60)))
    maskedu = np.ma.masked_where(maskedu < 0.5, maskedu)
    
    pp.figure()
    pp.imshow(np.abs(pressure), interpolation='none')
    pp.colorbar()
    #pp.imshow(maskedu, interpolation='none', cmap='gray')
    pp.title('pressure amplitude (mlfmm)')
    pp.show()
    
    pp.figure()
    pp.imshow(np.abs(pressure_exact), interpolation='none')
    pp.title('pressure amplitude (exact)')
    pp.colorbar()
    pp.show()
    
    pp.figure()
    pp.imshow(np.angle(pressure), interpolation='none')
    pp.colorbar()
    #pp.imshow(maskedu, interpolation='none', cmap='gray')
    pp.title('pressure phase (mlfmm)')
    pp.show()
    
    pp.figure()
    pp.imshow(np.angle(pressure_exact), interpolation='none')
    pp.title('presure phase (exact)')
    pp.colorbar()
    pp.show()
    
    
    