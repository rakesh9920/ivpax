# mlfmm / bem_fmm_comparison.py

import numpy as np
import scipy as sp
from matplotlib import pyplot as pp
from mlfmm.operators import CachedOperator
from scipy.sparse.linalg import gmres

rho = 1000
c = 1500
f = 0.05e6
origin = np.array([0.0, 0.0, 0.0])
D0 = 0.001
dim = np.array([1.01, 1.01])*D0
k = 2*np.pi*f/c
matfilename = ''

if __name__ == '__main__':
    
    matfile = sp.io.loadmat(matfilename)
    
    nodes = matfile['node_x']
    s_n = None
    K = matfile['K']
    M = None
    
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
    
    op.setup(verbose=False)
    op.precompute()

    