
import numpy as np
from scipy import sparse as sps
from matplotlib.patches import Rectangle
from matplotlib import pyplot as plt
    
def make_bem(membranes):
    
    mem_counter = 0
    for mem in membranes.itervalues():
        
        length_x = mem['length_x']
        length_y = mem['length_y']
        nnodes_x = mem['nnodes_x']
        nnodes_y = mem['nnodes_y']
        center = mem['center']
        
        vect_x = np.linspace(-length_x/2, length_x/2, nnodes_x)
        vect_y = np.linspace(-length_y/2, length_y/2, nnodes_y)
        vect_z = 0.
        x, y, z = np.meshgrid(vect_x[1:-1], vect_y[1:-1], vect_z)
        pos = np.c_[x.ravel(), y.ravel(), z.ravel()] + center
        
        mem['nodes'] = pos
        nnodes = pos.shape[0]
        mem['dx'] = vect_x[1] - vect_x[0]
        mem['dy'] = vect_y[1] - vect_y[0]
        mem['nnodes'] = nnodes
        mem['nodes_idx'] = np.arange(mem_counter*nnodes, mem_counter*nnodes + nnodes)
        mem_counter += 1
        
        make_k(mem)
        make_b(mem)
        make_m(mem)
    
    K_list = [mem['K'] for mem in membranes.itervalues()]
    M_list = [mem['M'] for mem in membranes.itervalues()] 
    B_list = [mem['B'] for mem in membranes.itervalues()] 
    nodes_list = [mem['nodes'] for mem in membranes.itervalues()]
    
    K = sps.block_diag(K_list, format='csr')
    M = sps.block_diag(M_list, format='csr')
    B = sps.block_diag(B_list, format='csr')
    nodes = np.concatenate(nodes_list, axis=0)
    
    return nodes, M, B, K
    
def make_k(mem):
    
    dx = mem['dx']
    dy = mem['dy']
    E = mem['ymodulus']
    eta = mem['pratio']
    h = mem['thickness']
    nnodes = mem['nnodes']
    nodes = mem['nodes']
    x = nodes[:,0]
    y = nodes[:,1]
    
    D = E*h**3/12./(1 - eta**2)
    
    K = sps.dok_matrix((nnodes, nnodes), dtype='float')
    eps = np.finfo(K.dtype).eps
    
    for node in xrange(nnodes):
        
        node_x = x[node]
        node_y = y[node]
        
        K[node, node] = 6./dx**4 + 6./dy**4
        K[node, (np.abs(x-node_x+2*dx)<=eps) & (np.abs(y-node_y)<=eps)] = 1./dx**4
        K[node, (np.abs(x-node_x-2*dx)<=eps) & (np.abs(y-node_y)<=eps)] = 1./dx**4
        K[node, (np.abs(x-node_x+1*dx)<=eps) & (np.abs(y-node_y)<=eps)] = -4./dx**4
        K[node, (np.abs(x-node_x-1*dx)<=eps) & (np.abs(y-node_y)<=eps)] = -4./dx**4
        
        K[node, (np.abs(y-node_y+2*dx)<=eps) & (np.abs(x-node_x)<=eps)] = 1./dy**4
        K[node, (np.abs(y-node_y-2*dx)<=eps) & (np.abs(x-node_x)<=eps)] = 1./dy**4
        K[node, (np.abs(y-node_y+1*dx)<=eps) & (np.abs(x-node_x)<=eps)] = -4./dy**4
        K[node, (np.abs(y-node_y-1*dx)<=eps) & (np.abs(x-node_x)<=eps)] = -4./dy**4 
        
        K[node, (np.abs(x-node_x+1*dx)<=eps) & (np.abs(y-node_y+1*dy)<=eps)] = 2./9/dx**2/dy**2
        K[node, (np.abs(x-node_x-1*dx)<=eps) & (np.abs(y-node_y-1*dy)<=eps)] = 2./9/dx**2/dy**2  
        K[node, (np.abs(x-node_x-1*dx)<=eps) & (np.abs(y-node_y+1*dy)<=eps)] = 2./9/dx**2/dy**2  
        K[node, (np.abs(x-node_x+1*dx)<=eps) & (np.abs(y-node_y-1*dy)<=eps)] = 2./9/dx**2/dy**2  
        K[node, (np.abs(x-node_x+2*dx)<=eps) & (np.abs(y-node_y+2*dy)<=eps)] = 2./9/dx**2/dy**2  
        K[node, (np.abs(x-node_x-2*dx)<=eps) & (np.abs(y-node_y-2*dy)<=eps)] = 2./9/dx**2/dy**2  
        K[node, (np.abs(x-node_x+2*dx)<=eps) & (np.abs(y-node_y-2*dy)<=eps)] = 2./9/dx**2/dy**2  
        K[node, (np.abs(x-node_x-2*dx)<=eps) & (np.abs(y-node_y+2*dy)<=eps)] = 2./9/dx**2/dy**2  
        K[node, (np.abs(x-node_x-2*dx)<=eps) & (np.abs(y-node_y+1*dy)<=eps)] = -2./9/dx**2/dy**2  
        K[node, (np.abs(x-node_x+2*dx)<=eps) & (np.abs(y-node_y-1*dy)<=eps)] = -2./9/dx**2/dy**2  
        K[node, (np.abs(x-node_x-2*dx)<=eps) & (np.abs(y-node_y-1*dy)<=eps)] = -2./9/dx**2/dy**2  
        K[node, (np.abs(x-node_x+2*dx)<=eps) & (np.abs(y-node_y+1*dy)<=eps)] = -2./9/dx**2/dy**2  
        K[node, (np.abs(x-node_x-1*dx)<=eps) & (np.abs(y-node_y+2*dy)<=eps)] = -2./9/dx**2/dy**2  
        K[node, (np.abs(x-node_x+1*dx)<=eps) & (np.abs(y-node_y-2*dy)<=eps)] = -2./9/dx**2/dy**2  
        K[node, (np.abs(x-node_x-1*dx)<=eps) & (np.abs(y-node_y-2*dy)<=eps)] = -2./9/dx**2/dy**2  
        K[node, (np.abs(x-node_x+1*dx)<=eps) & (np.abs(y-node_y+2*dy)<=eps)] = -2./9/dx**2/dy**2  
          
    mem['K'] = D*K

def make_m(mem):
    
    rho = mem['density']
    h = mem['thickness']
    nnodes = mem['nnodes']
    
    mem['M'] = rho*h*sps.eye(nnodes)
    
def make_b(mem):
    
    att_mech = mem['att_mech']
    nnodes = mem['nnodes']
    
    mem['B'] = att_mech*sps.eye(nnodes)

def draw_quadtree(op):
    
    
    qt = op.quadtree
    nodes = op.params['nodes']
    
    for level_no, level in qt.levels.iteritems():
        
        fig1 = plt.figure()
        ax1 = fig1.add_subplot(111)
        ax1.set_aspect('equal')
        
        ax1.plot(nodes[:,0], nodes[:,1], marker='o', markersize=1, ls='none')
        
        xmax = 0
        ymax = 0
        
        for group in level.itervalues():
            
            center = group.center[:2]
            xlength, ylength = group.group_dims
            
            lcorner = center - np.array([xlength, ylength])/2.
            rcorner = center + np.array([xlength, ylength])/2.
            
            if rcorner[0] > xmax:
                xmax = rcorner[0]
            
            if rcorner[1] > ymax:
                ymax = rcorner[1]

            rect = Rectangle(lcorner, xlength, ylength, facecolor='none')
            ax1.add_patch(rect)
        
        ax1.set_xlim(xmax*-0.05, xmax*1.05)
        ax1.set_ylim(ymax*-0.05, ymax*1.05)
        plt.show()
        

if __name__ == '__main__':
    
    mems = dict()
    mems[0] = dict()
    mems[0]['length_x'] = 35e-6
    mems[0]['length_y'] = 35e-6
    mems[0]['center'] = np.array([0,0,0])
    mems[0]['nnodes_x'] = 21
    mems[0]['nnodes_y'] = 21
    mems[0]['ymodulus'] = 110e9
    mems[0]['pratio'] = 0.22
    mems[0]['density'] = 2040.
    mems[0]['thickness'] = 2e-6
    mems[0]['att_mech'] = 0.

    K, M, B, nodes = make_bem(mems)
    
    
    