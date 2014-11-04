# mlfmm / bem_fmm_comparison.py

import numpy as np
import scipy as sp
from matplotlib import pyplot as pp
from mlfmm.operators import CachedOperator
from scipy.sparse import linalg as ssl
from scipy.io import loadmat
from scipy import sparse
from mlfmm.fasttransforms import *
from mpl_toolkits.mplot3d import Axes3D

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
    #K = sparse.csr_matrix(matfile['K'], dtype='float')
    #M = sparse.csr_matrix(matfile['M'], dtype='float')
    #B = sparse.csr_matrix(matfile['B'], dtype='float')
    K = np.squeeze(np.array(matfile['K'], dtype='cfloat'))
    M = np.squeeze(np.array(matfile['M'], dtype='cfloat'))
    B = np.squeeze(np.array(matfile['B'], dtype='cfloat'))
    P = np.squeeze(np.array(matfile['P'], dtype='cfloat'))
    X = np.squeeze(np.array(matfile['U'], dtype='cfloat'))
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
    op.params['max_level'] = 5
    
    op.setup(verbose=False)
    op.precompute()

    counter = 0
    def matvec(x):
        
        global counter
        
        u = 1j*omega*x
        
        p1 = op.apply(2*np.squeeze(u))
        
        #x = np.matrix(u.reshape((-1,1)))/(1j*omega)
        #p2 = np.array((-omega**2*M + 1j*omega*B + K)*x)
        
        #x = u.reshape((-1,1))/(1j*omega)
        p2 = (-omega**2*M + 1j*omega*B + K).dot(x)
        
        print counter
        counter += 1
        
        return p1 + np.squeeze(np.array(p2))
    
    operator = ssl.LinearOperator(shape=(1444,1444), matvec=matvec, dtype='cfloat')
    
    G = -omega**2*M + 1j*omega*B + K + 1j*omega*Zr
    u = 2*1j*omega*X
    a_eff = np.sqrt(s_n/np.pi)
    
    #p1 = 1j*omega*Zr.dot(X)
    #p2 = op.apply(u)
    #p3 = directeval(s_n*u, nodes, nodes, k, rho, c) 
    #p3 += (rho*c*(0.5*(k*a_eff)**2 + 1j*8/(3*np.pi)*k*a_eff))/2*u
    #error = np.abs(np.abs(p2) - np.abs(p1))/np.abs(p1)*100
    #
    #pp.plot(np.abs(p1))
    #pp.plot(np.abs(p2),'.')
    ##pp.plot(np.abs(p3),'.')
    #pp.show()
    
    #Xmat = np.matrix(X.reshape((-1,1)))
    #pres_exact = np.squeeze(np.array(G*Xmat))
    #pres_fmm = matvec(X*1j*omega)
    #error = np.abs(pres_fmm - pres_exact)/np.abs(pres_exact)*100
    #
    #pp.plot(pres_exact)
    #pp.plot(pres_fmm, '--')
    #pp.plot(error)
    
    #P = np.ones(1444, dtype='complex')
    #counter = 0
    res = ssl.cg(operator, P, x0=np.zeros(1444)*1e-8, maxiter=1000)
    x = res[0]
    
    res2 = ssl.cg(G, P, x0=np.zeros(1444), tol=1e-12)
    x2 = res2[0]
    error = np.abs(np.abs(x2) - np.abs(X))/np.abs(X)*100
    #
    #X2 = sp.linalg.inv(np.array(G)).dot(P)
    #u = np.zeros(nnodes, dtype='cfloat')
    #u[P.ravel().astype(bool)] = 1
    #umat = np.matrix(u.reshape((-1,1)))
    #
    #pres_exact = Zr*umat
    #pres, _ = matvec(u)
    
    #q = s_n*u
    #pres_direct = directeval(2*q, nodes, nodes, k, rho, c)
    
    #fig1 = pp.figure()
    #ax1 = fig1.add_subplot(111)
    ##ax1 = fig1.add_subplot(111, projection='3d')
    #xmax = np.max(np.abs(x))
    #for mem in membranes:
    #    
    #    membrane_nodes = mem['node_x'][0,0].astype(float)
    #    nodesx = membrane_nodes[:,0].reshape((19,19))
    #    nodesy = membrane_nodes[:,1].reshape((19,19))
    #    idx = mem['node_no'][0,0].astype(int) - 1
    #    disp = x[idx].reshape((19,19))
    #    ax1.pcolormesh(nodesx, nodesy, np.abs(disp), vmax=xmax, vmin=0)
    #    #ax1.plot_surface(nodesx, nodesy, np.abs(disp))
    #
    #ax1.set_aspect('equal')
    #pp.show()
        
        
    
    