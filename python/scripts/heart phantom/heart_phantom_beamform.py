# scripts / carotid_phantom_beamform.py

from pyfield.beamform import Beamformer, envelope, imdisp, msview

import numpy as np
import h5py
from sys import stdout

######################### SET SCRIPT PARAMETERS HERE ###########################
file_path = './data/heart_phantom_data.h5'
input_key = 'field/rfdata/full'
view_key = 'view/view0'
output_key = 'bfdata/full'
nproc = 1
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
    
    view = msview[0.001:0.071:0.001, 0:1:1, -np.pi/4:np.pi/4:100j]

        
    with h5py.File(view_path[0], 'a') as root:
        
        if view_path[1] in root:
            del root[view_path[1]]
        
        root.create_dataset(view_path[1], data=view, compression='gzip')

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
    
    
    