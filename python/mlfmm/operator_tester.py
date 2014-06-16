# mlfmm / operator_tester.py

import numpy as np
import scipy as sp

from mlfmm.quadtree import QuadTree, Operator

rho = 1000
c = 1500
#nnodes = 1000
#s_n = 1.0/nnodes
f = 10e3
origin = [0.0, 0.0, 0.0]
dim = [1.1, 1.1]
k = 2*np.pi*f/c
order = 3

if __name__ == '__main__':
    
    x, y, z = np.mgrid[0:1:30j, 0:1:30j, 0:1:1]
    nodes = np.c_[x.ravel(), y.ravel(), z.ravel()]
    nnodes = nodes.shape[0]
    
    #nodes = sp.rand(nnodes, 3)
    
    s_n = 1.0/nnodes
    
    u = np.zeros(nnodes, dtype='cfloat')
    u[465] = 0.01
    
    q = 1j*rho*c*2*np.pi*f/c*s_n*u

    qt = QuadTree(nodes, origin, dim)
    qt.assign_nodes(4)
    qt.populate_tree(4, 3)
    
    op = Operator(qt)
    op.rho = rho
    op.c = c
    op.s_n = s_n
    op.k = 2*np.pi*f/c
    op.order = order
    
    #op.calculate_mpole_coeff(q, k, rho, c, 1)
    #op.matvec(disp)