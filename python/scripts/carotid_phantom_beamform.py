# scripts / carotid_phantom_beamform.py

from pyfield.beamform import Beamformer, envelope, imdisp

import numpy as np
import h5py
from sys import stdout

######################### SET SCRIPT PARAMETERS HERE ###########################
file_path = './data/carotid_phantom_data.h5'
input_key = 'field/rfdata/full'
view_key = 'view/view0'
output_key = 'bfdata/full'
nproc = 12
frames = None
chmask = False

opt = { 'nwin': 101,
        'resample': 1,
        'chmask': chmask,
        'planetx': True,
        'overwrite': True,
        'maxpointsperchunk': 10000,
        'maxframesperchunk': 1000 }  
################################################################################
       
def write_view(view_path):
    
    #x, y, z = np.mgrid[-0.01:0.01:40j,, 0:0.04:80j]
    x, y, z = np.meshgrid(np.linspace(-0.02, 0.02, 800, endpoint=True),
        0, np.linspace(0, 0.03, 600, endpoint=True))
    ngrid = x.size

    grid = np.concatenate((x.reshape((ngrid, -1)), y.reshape((ngrid, -1)),
        z.reshape((ngrid, -1))), axis=1)
        
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
##
#    with h5py.File(file_path, 'r') as root:
#        bfdata = np.squeeze(root[output_key][:])
#    
#    envdata = envelope(bfdata, axis=1)
#    img = envdata[:,100].reshape((800, 600))
#    
#    imdisp(img.T, dyn=30)
    
    
    