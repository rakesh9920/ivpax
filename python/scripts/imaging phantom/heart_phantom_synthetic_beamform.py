# scripts / carotid_phantom_synthetic_beamform.py

from pyfield.beamform import Beamformer, envelope, imdisp, msview

import numpy as np
import h5py
from sys import stdout

######################### SET SCRIPT PARAMETERS HERE ###########################
file_path = './data/heart_phantom_data.h5'
input_key = 'field/rfdata/synthetic/full'
temp_key = 'field/rfdata/temp'
view_key = 'view/view0'
output_key = 'bfdata/synthetic/tx'
nchannel = 64
nproc = 12
frames = None
chmask = False

opt = { 'nwin': 101,
        'resample': 1,
        'chmask': chmask,
        'planetx': False,
        'overwrite': True,
        'maxpointsperchunk': 10000,
        'maxframesperchunk': 1000 }  
################################################################################
       
def write_view(view_path):
    
    x, y, z = msview[0.001:0.071:0.00025, 0:1:1, -np.pi/4:np.pi/4:400j]
    view = np.c_[x.ravel(), y.ravel(), z.ravel()]
    
    with h5py.File(view_path[0], 'a') as root:
        
        if view_path[1] in root:
            del root[view_path[1]]
        
        root.create_dataset(view_path[1], data=view, compression='gzip')

def sum_output(output_path):
    
    file_path = output_path[0]
    input_key = output_path[1]
    
    with h5py.File(file_path, 'a') as root:

        bfdata_t = root[input_key + str(0)][:]
        #t0_t = root[input_key + str(0)].attrs['start_time']
        #fs = root[input_key + str(0)].attrs['sample_frequency']
        
        for ch in xrange(1, nchannel):
            
            bfdata = root[input_key + str(ch)][:]
            #t0 = root[input_key + str(ch)].attrs['start_time']
            
            bfdata_t += bfdata
    
    return bfdata_t     
    
if __name__ == '__main__':
    
    write_view((file_path, view_key))
    
    for tx in xrange(23, nchannel):
        
        startch = tx*nchannel
        endch = startch + nchannel
        
        with h5py.File(file_path, 'a') as root:
            
            rfdata = root[input_key][:,startch:endch,:]
            
            if temp_key in root:
                del root[temp_key]
            
            root.create_dataset(temp_key, data=rfdata, compression='gzip')
            
            for k, v in root[input_key].attrs.iteritems():
                root[temp_key].attrs.create(k, v)
            
            root[temp_key].attrs['tx_positions'] = root[temp_key]. \
                attrs['rx_positions'][tx,:]
                
        bf = Beamformer()
            
        bf.set_options(**opt)
        bf.input_path = (file_path, temp_key)
        bf.output_path = (file_path, output_key + str(tx))
        bf.view_path = (file_path, view_key)
        
        bf.start(nproc=nproc, frames=frames)
        
        print bf
        stdout.flush()
        bf.join()
#
    #with h5py.File(file_path, 'r') as root:
    #    bfdata = np.squeeze(root[output_key + str(tx)][:])
    #
    #envdata = envelope(bfdata, axis=1)
    #img = envdata[:,100].reshape((800, 600))
    #
    #imdisp(img.T, dyn=30)
    
    
    