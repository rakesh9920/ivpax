# scripts / carotid_phantom_synthetic_beamform.py

from pyfield.beamform import Beamformer, envelope, imdisp, mcview

import numpy as np
import h5py
from sys import stdout
import scipy.signal as sig

######################### SET SCRIPT PARAMETERS HERE ###########################
file_path = '/data/bshieh/imaging_phantom_data3.h5'
input_key = 'field/rfdata/tissue/synthetic_0db/full'
#file_path = './data/psf_data.h5'
#input_key = 'field/rfdata/psf_192_wide'
temp_key = 'field/rfdata/temp'
view_key = 'view/view0'
output_key = 'bfdata/synthetic_0db/tx'
#output_key = 'bfdata/psf_192_wide_apod/tx'
nchannel = 192
nproc = 12
frames = None
chmask = False
useapod = True
apod = sig.hann(192)#[100-nchannel/2:100+nchannel/2]

opt = { 'nwin': 101,
        'resample': 1,
        'chmask': chmask,
        'planetx': False,
        'overwrite': True,
        'maxpointsperchunk': 50000,
        'maxframesperchunk': 1000,
        'useapodization': useapod,
        'apodization': apod }  
################################################################################
       
def write_view(view_path):
    
    #x, y, z = mcview[-0.02:0.020125:0.000125, 0:1:1, 0.001:0.041125:0.000125]
    x, y, z = mcview[-0.02:0.020250:0.000250, 0:1:1, 0.011:0.051250:0.000250]
    view = np.c_[x.ravel(), y.ravel(), z.ravel()]
    
    with h5py.File(view_path[0], 'a') as root:
        
        if view_path[1] in root:
            del root[view_path[1]]
        
        root.create_dataset(view_path[1], data=view, compression='gzip')

def sum_output(file_path, input_key, output_key):
    
    with h5py.File(file_path, 'a') as root:

        bfdata_t = root[input_key + str(0)][:]
        
        for ch in xrange(1, nchannel):
            
            bfdata = root[input_key + str(ch)][:]
            bfdata_t += bfdata
        
        if output_key in root:
            del root[output_key]
            
        root.create_dataset(output_key, data=bfdata_t, compression='gzip')  
    
if __name__ == '__main__':
    
    write_view((file_path, view_key))
    
    for tx in xrange(0, 192):
        
        startch = tx*nchannel
        endch = startch + nchannel
        
        with h5py.File(file_path, 'a') as root:
            
            rfdata = root[input_key][:,startch:endch,:]
            #rfdata = root[input_key][:,startch:endch]
            
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
        #stdout.flush()
        bf.join()

    #with h5py.File(file_path, 'r') as root:
    #    bfdata = np.squeeze(root[output_key + str(tx)][:])
    #
    #envdata = envelope(bfdata, axis=1)
    #img = envdata[:,100].reshape((800, 600))
    #
    #imdisp(img.T, dyn=30)
    
    
    