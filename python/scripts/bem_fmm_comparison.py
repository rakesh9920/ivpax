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
f = 19e6
      
if __name__ == '__main__':
    
    matfile = loadmat(matfilename)
    
    s_n = np.float(matfile['dx']*matfile['dy'])
    c = np.float(matfile['fluid_c'])
    rho = np.float(matfile['fluid_rho'])
    #omega = np.float(matfile['w'])
          
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
    #X = np.squeeze(np.array(matfile['U'], dtype='cfloat'))
    #Zr = np.array(matfile['Zr'], dtype='cfloat')
    membranes = np.squeeze(matfile['membranes'])
    
    del matfile
    
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
    op.params['nodes'] = nodes
    op.params['min_level'] = 2
    op.params['max_level'] = 5
    
    op.setup(verbose=False)
    op.precompute()

    # create exact acoutic impedance matrix
    dist = distance(nodes, nodes)
    Zr = 1j*omega*rho*s_n/(2*np.pi)*np.exp(-1j*k*dist)/dist
    Zr[np.eye(*dist.shape).astype(bool)] = rho*c*(0.5*(k*a_eff)**2 +
        1j*8/(3*np.pi)*k*a_eff)
    
    # create matrices for mechanical dynamics and full dynamics
    Gmech = -omega**2*M + 1j*omega*B + K
    G = Gmech + 1j*omega*Zr
    
    # find inverse of Gmech for use as a preconditioner
    Gmech_inv = np.linalg.inv(Gmech)

    # define matrix-vector products that use fmm
    counter = 0
    def matvec1(x):
        global counter
        
        u = 1j*omega*x
        p1 = op.apply(2*np.squeeze(u))
        p2 = (-omega**2*M + 1j*omega*B + K).dot(x)
        
        print counter
        counter += 1
        
        return p1 + np.squeeze(np.array(p2))
    
    def matvec2(x):
        global counter
        
        u = 1j*omega*x
        p1 = op.apply(2*np.squeeze(u))
        p2 = Gmech_inv.dot(p1) + x
        
        print counter
        counter += 1
        
        return p2
    
    # define linear operators
    operator1 = ssl.LinearOperator(shape=(nnodes,nnodes), matvec=matvec1, 
        dtype='cfloat')
    operator2 = ssl.LinearOperator(shape=(nnodes,nnodes), matvec=matvec2, 
        dtype='cfloat')
        
    x_fmm, niter = ssl.cgs(operator2, Gmech_inv.dot(P), x0=np.zeros(1444), 
        tol=1e-9, maxiter=20)
    #x_fmm, niter = ssl.cgs(operator1, P, M=Gmech_inv, x0=np.zeros(1444), 
        #tol=1e-9, maxiter=15)
    x_exact = sp.linalg.solve(G, P)
    #x_exact = sp.linalg.inv(G).dot(P)
    error = np.abs(np.abs(x_fmm) - np.abs(x_exact))/np.abs(x_exact)*100
    
    p_fmm = op.apply(2*1j*omega*x_exact)
    p_exact = G.dot(x_exact)
    
    fig1 = pp.figure()
    ax1 = fig1.add_subplot(111)
    #ax1 = fig1.add_subplot(111, projection='3d')
    xmax = np.max(np.abs(x_fmm))
    xmin = np.min(np.abs(x_fmm))
    for mem in membranes:
        
        membrane_nodes = mem['node_x'][0,0].astype(float)
        center = np.squeeze(np.array(mem['center'][0,0].astype(float)))
        width = np.squeeze(np.array(mem['width'][0,0].astype(float)))
        corner1 = center - width/2.0
        corner2 = center + width/2.0
        #nodesx = membrane_nodes[:,0].reshape((19,19))
        #nodesy = membrane_nodes[:,1].reshape((19,19))
        idx = mem['node_no'][0,0].astype(int) - 1
        knodes = idx.size
        nodesx, nodesy = np.mgrid[corner1[0]:corner2[0]:20*1j,corner1[1]:\
            corner2[1]:20*1j] - (width/19/2)[:,None,None]
        disp = x_fmm[idx].reshape((19,19))
        pc = ax1.pcolormesh(nodesx, nodesy, np.abs(disp), vmax=xmax, vmin=0, 
            cmap='jet')
        #ax1.plot_surface(nodesx, nodesy, np.abs(disp), vmax=xmax, vmin=xmin,
            #rstride=1, cstride=1)
    
    pp.colorbar(pc)
    ax1.set_aspect('equal')
    
    
    
    fig2 = pp.figure()
    ax2 = fig2.add_subplot(111)
    ax2.plot(np.abs(x_exact))
    ax2.plot(np.abs(x_fmm),'r.', markersize=4)
    ax2.legend(('direct','mlfmm + cgs'), loc='best', numpoints=1)
    ax2.set_xlabel('Node no.')
    ax2.set_ylabel('Displacement amplitude (m)')
    ax2.set_title('Displacement profile for f = %2.2f MHz' % (f/1e6))
        
    pp.show()

    fig3 = pp.figure()
    ax3 = fig3.add_subplot(111)
    ax3.plot(error)
    ax3.set_xlabel('Node no.')
    ax3.set_ylabel('Error (%)')
    ax3.set_title('Displacement error for f = %2.2f MHz' % (f/1e6))
        
    pp.show()
    