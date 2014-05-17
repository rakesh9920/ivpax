# scripts / simplelumen_beamforming

import numpy as np
from pyfield.beamform import Beamformer
import h5py

def write_view(view_path):
    
    x, y, z = np.mgrid[-0.01:0.01:20j, -0.01:0.01:20j, 0:0.04:40j]
    ngrid = x.size

    grid = np.concatenate((x.reshape((ngrid, -1)), y.reshape((ngrid, -1)),
        z.reshape((ngrid, -1))), axis=1)
        
    with h5py.File(view_path[0], 'a') as root:
        
        if view_path[1] in root:
            del root[view_path[1]]
        
        root.create_dataset(view_path[1], data=grid, compression='gzip')

if __name__ == '__main__':
    
    file_path = './data/simple lumen flow/simple_lumen_experiments.hdf5'
    input_key = 'field/rfdata/raw/00000'
    view_key = 'view/view0'
    output_key = 'bfdata/00000'
    
    #write_view((file_path, view_key))
    
    bf = Beamformer()
    
    opt = { 'nwin': 401,
            'resample': 1,
            'chmask': False,
            'planetx': True,
            'overwrite': True,
            'maxpointsperchunk': 10000 }  
            
    bf.set_options(**opt)
    
    bf.input_path = (file_path, input_key)
    bf.output_path = (file_path, output_key)
    bf.view_path = (file_path, view_key)
    
    bf.start(nproc=2, frames=None)
    
    print bf