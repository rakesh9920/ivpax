# mlfmm / bem_fmm_comparison.py

import numpy as np
import scipy as sp
from matplotlib import pyplot as pp
from mlfmm.operators import CachedOperator
from scipy.sparse import linalg as spsl
from scipy.io import loadmat
from scipy import sparse as sps
from mlfmm.fasttransforms import *
from mlfmm.tools import *
from mpl_toolkits.mplot3d import Axes3D

origin = np.array([0.0, 0.0, 0.0])
D0 = 0.001
dim = np.array([1.0, 1.0])*D0
f = 19e6
c = 1500.
rho = 1000.
nmems_x = 4
nmems_y = 4
pitch_x = 45e-6
pitch_y = 45e-6

if __name__ == '__main__':
    
    s_n = 1
    omega = 2*np.pi*f
    k = 2*np.pi*f/c
    a_eff = np.sqrt(s_n/np.pi)
    
    op = CachedOperator()
    op.params['density'] = rho
    op.params['sound_speed'] = c
    op.params['node_area'] = s_n
    op.params['wave_number'] = k
    op.params['box_dims'] = dim
    op.params['origin'] = origin
    op.params['nodes'] = None
    op.params['min_level'] = 2
    op.params['max_level'] = 6
    op.params['translators_file'] = './data/test.dat'
    
    op.setup(verbose=False, full=True)
    op.save_translators('./data/test.dat')