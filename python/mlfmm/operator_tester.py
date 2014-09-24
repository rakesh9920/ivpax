# mlfmm / operator_tester.py

import numpy as np
import scipy as sp
from matplotlib import pyplot as pp
from mlfmm.quadtree2 import *

rho = 1000
c = 1500
f = 1e6
origin = np.array([0.0, 0.0, 0.0])
dim = np.array([70.1e-6, 70.1e-6])*4
k = 2*np.pi*f/c

if __name__ == '__main__':
    
    #x, y, z = np.mgrid[0:65.3e-6:28j, 0:65.3e-6:28j, 0:1:1]
    x, y, z = np.mgrid[0:70e-6:30j, 0:70e-6:30j, 0:1:1]*4
    #nodes = np.c_[x[1:-1, 1:-1].ravel(), y[1:-1, 1:-1].ravel(), 
    #    z[1:-1, 1:-1].ravel()]
    nodes = np.c_[x.ravel(), y.ravel(), z.ravel()]
    nnodes = nodes.shape[0]
    
    #nodes = sp.rand(nnodes, 3)
    
    s_n = (70e-6/29)**2
    #s_n = (70e-6)**2/nnodes
    
    u = np.zeros((30, 30), dtype='cfloat')
    u[14,14] = 1
    u = u.ravel()
    
    q = 1j*rho*c*2*np.pi*f/c*s_n*u
    #qt = QuadTree(nodes, origin, dim)
    #qt.setup(2, 4)
    
    op = Operator()
    op.params['density'] = rho
    op.params['sound_speed'] = c
    op.params['node_area'] = s_n
    op.params['wave_number'] = 2*np.pi*f/c
    op.params['box_dims'] = dim
    op.params['origin'] = origin
    op.params['nodes'] = nodes
    op.params['min_level'] = 3
    op.params['max_level'] = 4
    
    op.setup()
    pressure = op.apply(u).reshape((30,30))
    
    pressure_exact = directeval(q, nodes, nodes, k, rho, c).reshape((30,30))
    
    pp.imshow(np.abs(pressure), interpolation='none')
    pp.colorbar()
    pp.show()
    
    
    