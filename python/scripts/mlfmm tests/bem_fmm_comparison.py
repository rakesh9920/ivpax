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
    
    nmems = nmems_x*nmems_y
    
    centers_x, centers_y, centers_z = np.mgrid[0:nmems_x*pitch_x:pitch_x, 
        0:nmems_y*pitch_y:pitch_y,0:0:1j]
    
    centers = (np.c_[centers_x.ravel(), centers_y.ravel(), centers_z.ravel()] +
        np.array([25e-6, 25e-6, 0]))
    
    mems = dict()
    
    for x in xrange(nmems):
        
        mems[x] = dict()
        mems[x]['length_x'] = 35e-6
        mems[x]['length_y'] = 35e-6
        mems[x]['nnodes_x'] = 18
        mems[x]['nnodes_y'] = 18
        mems[x]['ymodulus'] = 110e9
        mems[x]['pratio'] = 0.22
        mems[x]['density'] = 2040.
        mems[x]['thickness'] = 2e-6
        mems[x]['att_mech'] = 1e5
        mems[x]['center'] = centers[x,:]
    
    nodes, M, B, K, Gmech_inv = make_bem(mems, inverse=True, freq=f)
    nnodes = nodes.shape[0]
    s_n = mems[0]['dx']*mems[0]['dy']
    
    P = np.zeros(nnodes, dtype='cfloat')
    P[mems[0]['nodes_idx']] = 1e6
    
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
    op.params['max_level'] = 6
    
    op.setup(verbose=False, full=False)
    op.precompute()

    # create matrices for mechanical dynamics and full dynamics
    Gmech = -omega**2*M + 1j*omega*B + K
    #Gmech_inv = spsl.inv(sps.csc_matrix(Gmech))
    
    # define matrix-vector products that use fmm
    counter = 0
    def matvec1(x):
        global counter
        
        u = 1j*omega*x
        p1 = op.apply(2*np.squeeze(u))
        p2 = Gmech.dot(x) + p1
        
        print counter
        counter += 1
        return p2
    
    def matvec2(x):
        global counter
        
        u = 1j*omega*x
        p1 = op.apply(2*np.squeeze(u))
        p2 = Gmech_inv.dot(p1) + x
        
        print counter
        counter += 1
        return p2
    
    # define linear operators
    operator1 = spsl.LinearOperator(shape=(nnodes,nnodes), matvec=matvec1, 
        dtype='cfloat')
        
    operator2 = spsl.LinearOperator(shape=(nnodes,nnodes), matvec=matvec2, 
        dtype='cfloat')
        
    x_fmm, niter = spsl.cgs(operator1, P, x0=np.zeros(nnodes), M=Gmech_inv, 
        tol=1e-10, maxiter=30)
    
    #x_fmm, niter = spsl.cgs(operator2, Gmech_inv.dot(P).T, x0=np.zeros(nnodes), 
    #    tol=1e-9, maxiter=20)
        
    #p_fmm = op.apply(2*1j*omega*x_exact)
    #p_exact = G.dot(x_exact)
    
    fig1 = pp.figure()
    ax1 = fig1.add_subplot(111)
    xmax = np.max(np.abs(x_fmm)*np.angle(x_fmm))
    xmin = np.min(np.abs(x_fmm)*np.angle(x_fmm))
    for mem in mems.itervalues():
        
        mem_nodes = mem['nodes_idx']
        center = mem['center']
        length_x = mem['length_x']
        length_y = mem['length_y']
        nnodes_x = mem['nnodes_x']
        nnodes_y = mem['nnodes_y']
        
        corner1 = center - np.array([length_x, length_y, 0])/2.
        corner2 = center + np.array([length_x, length_y, 0])/2.
        
        idx = mem_nodes
        knodes = idx.size
        nodesx, nodesy = np.mgrid[corner1[0]:corner2[0]:(nnodes_x-1)*1j,corner1[1]:\
            corner2[1]:(nnodes_y-1)*1j] - (np.array([length_x/(nnodes_x - 2), 
            length_y/(nnodes_y - 2)])/2)[:,None,None]
        disp = x_fmm[idx].reshape((nnodes_x - 2,nnodes_y - 2), order='F')
        pc = ax1.pcolormesh(nodesx, nodesy, np.real(np.abs(disp)*np.exp(-1j*np.angle(disp))), 
            cmap='jet')
        #pc = ax1.pcolormesh(nodesx, nodesy, np.abs(disp), cmap='jet')
    
    pp.colorbar(pc)
    ax1.set_aspect('equal')

    # create exact acoutic impedance matrix
    dist = distance(nodes, nodes)
    Zr = 1j*omega*rho*s_n/(2*np.pi)*np.exp(-1j*k*dist)/dist
    Zr[np.eye(*dist.shape).astype(bool)] = rho*c*(0.5*(k*a_eff)**2 +
        1j*8/(3*np.pi)*k*a_eff)
    G = Gmech + 1j*omega*Zr
    x_exact = sp.linalg.solve(G, P)
    error = np.abs(np.abs(x_fmm) - np.abs(x_exact))/np.abs(x_exact)*100
    error_abs = np.abs(x_fmm) - np.abs(x_exact)
    error_rel_max = (np.abs(np.abs(x_fmm) - np.abs(x_exact))/
        np.max(np.abs(x_exact))*100)
     
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
    #ax3.plot(error)
    ax3.plot(error_abs)
    #ax3.plot(error_rel_max)
    ax3.set_xlabel('Node no.')
    #ax3.set_ylabel('Error re max (%)')
    ax3.set_ylabel('Error (absolute) (m)')
    #ax3.set_ylabel('Error (%)')
    ax3.set_title('Displacement error for f = %2.2f MHz' % (f/1e6))
    pp.show()

    fig4 = pp.figure()
    ax4 = fig4.add_subplot(111, projection='3d')

    xmax = np.max(np.real(np.abs(x_fmm)*np.exp(-1j*np.angle(x_fmm))))
    xmin = np.min(np.real(np.abs(x_fmm)*np.exp(-1j*np.angle(x_fmm))))
    
    for mem in mems.itervalues():
        
        nnodes_x = mem['nnodes_x'] - 2
        nnodes_y = mem['nnodes_y'] - 2
        nodes_idx = mem['nodes_idx']
        X = mem['nodes'][:,0].reshape((nnodes_x,nnodes_y), order='F')
        Y = mem['nodes'][:,1].reshape((nnodes_x,nnodes_y), order='F')
        Z = np.real(np.abs(x_fmm[nodes_idx])*
            np.exp(-1j*np.angle(x_fmm[nodes_idx]))).reshape((nnodes_x, 
            nnodes_y), order='F')
        
        ax4.plot_surface(X, Y, Z, cstride=1, rstride=1, vmin=xmin, vmax=1e-8, 
            norm=pp.Normalize(xmin, 1e-8), cmap='jet', shade=True)
    
    ax4.elev = 60
    ax4.azim = -125
    pp.show()
    
    