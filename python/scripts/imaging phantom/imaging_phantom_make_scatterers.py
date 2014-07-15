# scripts / imaging phantom / imaging_phantom_make_scatterers.py

from pyfield.field import sct_rectangle
from pyfield.util import scatter3d

import numpy as np
import h5py
import matplotlib.pyplot as plt

file_path = './data/imaging_phantom_data2.h5'
key = 'field/targdata/'
tissue = ('background', 'mat1', 'mat2', 'mat3', 'mat4')
range_x = (-0.025, 0.025)
range_y = (-0.005, 0.005)
range_z = (0.001, 0.051)
target_density = 20*1000**3

def draw3d():
    
    with h5py.File(file_path, 'r') as root:
        
        bg = root['field/targdata/background'][:]
        m1 = root['field/targdata/mat1'][:]
        m2 = root['field/targdata/mat2'][:]
        m3 = root['field/targdata/mat3'][:]
        m4 = root['field/targdata/mat4'][:]   
           
    fig = plt.figure(figsize=(6,6))
    ax = fig.add_subplot(111, projection='3d')
    scatter3d(bg, mask=10, color='r', size=10, ax=ax)
    scatter3d(m1, mask=10, color='b', size=10, ax=ax)
    scatter3d(m2, mask=10, color='b', size=10, ax=ax)  
    scatter3d(m3, mask=10, color='b', size=10, ax=ax)  
    scatter3d(m4, mask=10, color='b', size=10, ax=ax)
    
    ax.azim = 90
    ax.elev = 0
    ax.set_xlim(-0.025, 0.025)
    ax.set_zlim(0, 0.05)
    
    #ax.set_aspect('equal', 'box')
    #ax.set_aspect('equal', 'datalim')
       
def sct_cyl(target_pos, radius, origin):
    
    dist = target_pos - origin.reshape((1,3))
    
    r = np.sqrt(dist[:,0]**2 + dist[:,2]**2)
    
    return target_pos[r <= radius,:], target_pos[~(r <= radius),:]
    
if __name__ == '__main__':
    
    target_pos = sct_rectangle(range_x, range_y, range_z, ns=target_density)
    
    targ1, rem = sct_cyl(target_pos, 0.0005, np.array([-0.015, 0, 0.01]))
    targ2, rem = sct_cyl(rem, 0.0015, np.array([-0.015, 0, 0.02]))
    targ3, rem = sct_cyl(rem, 0.0025, np.array([-0.015, 0, 0.03]))
    targ4, rem = sct_cyl(rem, 0.0035, np.array([-0.015, 0, 0.04]))
    
    mat1 = np.concatenate((targ1, targ2, targ3, targ4), axis=0)
    
    targ1, rem = sct_cyl(rem, 0.0005, np.array([-0.005, 0, 0.01]))
    targ2, rem = sct_cyl(rem, 0.0015, np.array([-0.005, 0, 0.02]))
    targ3, rem = sct_cyl(rem, 0.0025, np.array([-0.005, 0, 0.03]))
    targ4, rem = sct_cyl(rem, 0.0035, np.array([-0.005, 0, 0.04]))

    mat2 = np.concatenate((targ1, targ2, targ3, targ4), axis=0)

    targ1, rem = sct_cyl(rem, 0.0005, np.array([0.005, 0, 0.01]))
    targ2, rem = sct_cyl(rem, 0.0015, np.array([0.005, 0, 0.02]))
    targ3, rem = sct_cyl(rem, 0.0025, np.array([0.005, 0, 0.03]))
    targ4, rem = sct_cyl(rem, 0.0035, np.array([0.005, 0, 0.04]))

    mat3 = np.concatenate((targ1, targ2, targ3, targ4), axis=0)

    targ1, rem = sct_cyl(rem, 0.0005, np.array([0.015, 0, 0.01]))
    targ2, rem = sct_cyl(rem, 0.0015, np.array([0.015, 0, 0.02]))
    targ3, rem = sct_cyl(rem, 0.0025, np.array([0.015, 0, 0.03]))
    targ4, rem = sct_cyl(rem, 0.0035, np.array([0.015, 0, 0.04]))

    mat4 = np.concatenate((targ1, targ2, targ3, targ4), axis=0)
    
    background = rem
    
    mats = (background, mat1, mat2, mat3, mat4)

    with h5py.File(file_path, 'a') as root:
        
        for i in xrange(len(tissue)):
                
            tkey = key + tissue[i]
            
            if tkey in root:
                del root[tkey]
            
            tdata = mats[i]
            tdata = np.concatenate((tdata, np.ones((tdata.shape[0], 1))), 
                axis=1)
            
            root.create_dataset(tkey, data=tdata, compression='gzip')
            
            root[tkey].attrs.create('target_density', target_density)
