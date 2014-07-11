# scripts / make_carotid_phantom.py

from pyfield.field import sct_rectangle

import numpy as np
import h5py

file_path = './data/imaging_phantom_data.h5'
key = 'field/targdata/'
tissue = ('background', 'mat1', 'mat2', 'mat3', 'mat4')
range_x = (-0.02, 0.02)
range_y = (-0.005, 0.005)
range_z = (0.001, 0.061)
target_density = 20*1000**3

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

    with h5py.File(file_path, 'a') as root:
        
        for i in xrange(len(tissue)):
            
            if tissue[i] == 'empty':
                continue
                
            tkey = key + tissue[i]
            
            if tkey in root:
                del root[tkey]
            
            tdata = target_pos[tissue_idx == levels[i],:]
            tdata = np.concatenate((tdata, np.ones((tdata.shape[0], 1))), 
                axis=1)
            
            root.create_dataset(tkey, data=tdata, compression='gzip')
            
            root[tkey].attrs.create('target_density', target_density)
