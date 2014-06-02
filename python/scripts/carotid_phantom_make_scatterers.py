# scripts / make_carotid_phantom.py

from pyfield.field import sct_rectangle

from matplotlib.pylab import imread
import numpy as np
import h5py

file_path = './data/carotid_phantom_data.hdf5'
key = 'field/targdata/'
img = np.mean(imread('./data/carotid_phantom_map.bmp'), axis=2)
npixelz, npixelx = img.shape
levels = np.unique(img)
#tissue = ('dermis', 'fat', 'artery', 'plaque', 'blood')
tissue = ('blood', 'plaque', 'artery', 'fat', 'dermis')
range_x = (-0.02, 0.02)
range_y = (-0.005, 0.005)
range_z = (0.001, 0.031)
target_density = 20*1000**3

if __name__ == '__main__':
    
    target_pos = sct_rectangle(range_x, range_y, range_z, ns=target_density)
    
    x_idx = np.round((target_pos[:,0] - range_x[0])/(range_x[1] - 
        range_x[0])*(npixelx - 1)).astype(int)
    
    z_idx = np.round((target_pos[:,2] - range_z[0])/(range_z[1] - 
        range_z[0])*(npixelz - 1)).astype(int)
    
    tissue_idx = img[z_idx, x_idx]    
    
    #dermis = target_pos[tissue_idx == levels[0],:]
    #fat = target_pos[tissue_idx == levels[1],:]
    #artery = target_pos[tissue_idx == levels[2],:]
    #plaque = target_pos[tissue_idx == levels[3],:]
    #blood = target_pos[tissue_idx == levels[4],:]
    
    with h5py.File(file_path, 'a') as root:
        
        for i in xrange(len(tissue)):
            
            tkey = key + tissue[i]
            
            if tkey in root:
                del root[tkey]
            
            tdata = target_pos[tissue_idx == levels[i],:]
            tdata = np.concatenate((tdata, np.ones((tdata.shape[0], 1))), 
                axis=1)
            
            root.create_dataset(tkey, data=tdata, compression='gzip')
            
            root[tkey].attrs.create('target_density', target_density)
