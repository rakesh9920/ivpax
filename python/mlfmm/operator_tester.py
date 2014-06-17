# mlfmm / operator_tester.py

import numpy as np
import scipy as sp

from mlfmm.quadtree import QuadTree, Operator

rho = 1000
c = 1500
#nnodes = 1000
#s_n = 1.0/nnodes
f = 100e6
origin = [0.0, 0.0, 0.0]
dim = [70.1e-6, 70.1e-6]
k = 2*np.pi*f/c
order = 2

if __name__ == '__main__':
    
    #x, y, z = np.mgrid[0:65.3e-6:28j, 0:65.3e-6:28j, 0:1:1]
    x, y, z = np.mgrid[0:70e-6:30j, 0:70e-6:30j, 0:1:1]
    #nodes = np.c_[x[1:-1, 1:-1].ravel(), y[1:-1, 1:-1].ravel(), 
    #    z[1:-1, 1:-1].ravel()]
    nodes = np.c_[x.ravel(), y.ravel(), z.ravel()]
    nnodes = nodes.shape[0]
    
    #nodes = sp.rand(nnodes, 3)
    
    s_n = (70e-6/29)**2
    #s_n = (70e-6)**2/nnodes
    
    u = np.zeros((30, 30), dtype='cfloat')
    u[14,14] = 1
    u = u.reshape((-1, 1))
    
    #q = 1j*rho*c*2*np.pi*f/c*s_n*u

    qt = QuadTree(nodes, origin, dim)
    qt.assign_nodes(5)
    qt.populate_tree(5, 5)
    
    op = Operator(qt)
    op.rho = rho
    op.c = c
    op.s_n = s_n
    op.k = 2*np.pi*f/c
    op.order = order
    
    #op.calculate_mpole_coeff(q, k, rho, c, 1)
    #op.matvec(disp)