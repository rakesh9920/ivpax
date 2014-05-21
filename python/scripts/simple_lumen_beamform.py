# scripts / simple_lumen_beamforming

from pyfield.beamform import Beamformer

import numpy as np
import h5py
from sys import stdout

######################### SET SCRIPT PARAMETERS HERE ###########################
file_path = './data/simple lumen flow/simple_lumen_data.hdf5'
input_key = 'field/rfdata/blood/fluid2'
view_key = 'view/view1'
sub_rx_no = 0
nsubch = 4
#output_key = 'bfdata/fluid2_sub' + '{:01d}'.format(sub_rx_no)
output_key = 'bfdata/fluid2_sub0_31'
nproc = 1
frames = None
centers = (np.arange(0,128) - 63.5)*300e-6
centers = np.c_[centers, np.zeros((128, 2))]
#sub_rx_positions = np.array([[-0.018, 0, 0],
#                            [-0.0156, 0, 0],
#                            [-0.0132, 0, 0],
#                            [-0.0108, 0, 0],
#                            [-0.0084, 0, 0],
#                            [-0.006, 0, 0],
#                            [-0.0036, 0, 0],
#                            [-0.0012, 0, 0],
#                            [0.0012, 0, 0],
#                            [0.0036, 0, 0],
#                            [0.006, 0, 0],
#                            [0.0084, 0, 0],
#                            [0.0108, 0, 0],
#                            [0.0132, 0, 0],
#                            [0.0156, 0, 0],
#                            [0.018, 0, 0]])
chmask = np.zeros(128)
chmask[sub_rx_no*nsubch:sub_rx_no*nsubch+nsubch] = 1
#chmask = False

sub_rx_position = np.mean(centers[(chmask==1),:], axis=0)

opt = { 'nwin': 801,
        'resample': 2,
        'chmask': chmask,
        'planetx': True,
        'overwrite': True,
        'maxpointsperchunk': 10000,
        'maxframesperchunk': 1000 }  
################################################################################
       
def write_view(view_path):
    
    x, y, z = np.mgrid[-0.01:0.01:20j, -0.01:0.01:20j, 0.01:0.04:30j]
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
    
    with h5py.File(file_path, 'a') as root:
        
        bfdata = root[output_key]
        bfdata.attrs['sub_rx_no'] = sub_rx_no
        bfdata.attrs['sub_rx_position'] = sub_rx_position
    
    
    