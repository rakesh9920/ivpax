# mlfmm / bem_fmm_comparison.py

import numpy as np
import scipy as sp
from matplotlib import pyplot as pp
from mlfmm.operators import CachedOperator
from scipy.sparse import linalg as ssl
from scipy.io import loadmat
from scipy import sparse

origin = np.array([0.0, 0.0, 0.0])
D0 = 0.001
dim = np.array([1.0, 1.0])*D0
matfilename = './data/bem_vars.mat'

if __name__ == '__main__':
    
    matfile = loadmat(matfilename)
    
    s_n = np.float(matfile['dx']*matfile['dy'])
    c = np.float(matfile['fluid_c'])
    rho = np.float(matfile['fluid_rho'])
    omega = np.float(matfile['w']  )
          
    nodes = matfile['node_x']
    nnodes = nodes.shape[0]
    nodes = np.c_[nodes, np.zeros(nnodes)]
    K = sparse.csr_matrix(matfile['K'], dtype='float')
    M = sparse.csr_matrix(matfile['M'], dtype='float')
    B = sparse.csr_matrix(matfile['B'], dtype='float')
    P = np.array(matfile['P'], dtype='cfloat')
    U = np.array(matfile['U'], dtype='cfloat')
    Zr = np.array(matfile['Zr'], dtype='cfloat')
    membranes = np.squeeze(matfile['membranes'])
    
    del matfile
    
    f = omega/(2*np.pi)
    k = 2*np.pi*f/c
    
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

    def matvec(u):
        
        p1 = op.apply(u)
        p2 = (-omega**2*M + 1j*omega*B + K).dot(u/(1j*omega))
        
        return p1, p2
    
    operator = ssl.LinearOperator(shape=(1444,1444), matvec=matvec, dtype='cfloat')
    
    G = -omega**2*M + 1j*omega*B + K + 1j*omega*Zr
    
    
    #res = ssl.cg(operator, np.squeeze(P), x0=np.ones(1444), maxiter=50)
    #x = res[0]/(1j*omega)
    
    u = np.zeros(nnodes, dtype='cfloat')
    u[P.ravel().astype(bool)] = 1
    
        
    #fig1 = pp.figure()
    #ax1 = fig1.add_subplot(111)
    #xmax = np.max(np.abs(x))
    #for mem in membranes:
    #    
    #    membrane_nodes = mem['node_x'][0,0].astype(float)
    #    nodesx = membrane_nodes[:,0].reshape((19,19))
    #    nodesy = membrane_nodes[:,1].reshape((19,19))
    #    idx = mem['node_no'][0,0].astype(int) - 1
    #    disp = x[idx].reshape((19,19))
    #    ax1.pcolormesh(nodesx, nodesy, np.abs(disp), vmax=xmax, vmin=0)
    #
    #ax1.set_aspect('equal')
    #pp.show()
        
        
    
    