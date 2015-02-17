# scripts / simple_lumen_beamforming

from pyfield.beamform import Beamformer

import numpy as np
import h5py
from sys import stdout

######################### SET SCRIPT PARAMETERS HERE ###########################
file_path = './data/tendon poc/tendon_poc_datasets.h5'
input_key = 'rfdata/raw'
view_key = 'views/0'
output_key = 'bfdata/0'
nproc = 2
frames = None
centers = (np.arange(0,128) - 63.5)*300e-6
centers = np.c_[centers, np.zeros((128, 2))]
chmask = False

opt = { 'nwin': 401,
        'resample': 4,
        'chmask': chmask,
        'planetx': True,
        'overwrite': True,
        'maxpointsperchunk': 2000,
        'maxframesperchunk': 10}  
################################################################################
       
def write_view(view_path):
    
    x, y, z = np.mgrid[-0.02:0.02:40j, 0:1:1j, 0.001:0.041:40j]
    ngrid = x.size

    grid = np.concatenate((x.reshape((ngrid, -1)), y.reshape((ngrid, -1)),
        z.reshape((ngrid, -1))), axis=1)

    #grid = np.array([[0.015, 0, 0.01],[-0.015, 0, 0.01]])
        
    with h5py.File(view_path[0], 'a') as root:
        
        if view_path[1] in root:
            del root[view_path[1]]
        
        root.create_dataset(view_path[1], data=grid, compression='gzip')

if __name__ == '__main__':
    
    write_view((file_path, view_key))
    
    bf = Beamformer()
        
    bf.set_options(**opt)
    bf.input_path = (file_path, input_key)
    bf.output_path = (file_path, output_key)
    bf.view_path = (file_path, view_key)
    
    bf.start(nproc=nproc, frames=frames)
    
    print bf
    stdout.flush()
    #bf.join()
    
    
    
    