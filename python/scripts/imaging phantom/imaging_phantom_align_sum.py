# scripts / imaging_phantom_align_sum.py

import h5py
import numpy as np
from scipy.integrate import cumtrapz

from pyfield.util import align_and_sum
from pyfield.signal import deconvwnr
from pyfield.field import addwgn

######################### SET SCRIPT PARAMETERS HERE ###########################
file_path = '/data/bshieh/imaging_phantom_data3.h5'
#names = ['background', 'mat1', 'mat2', 'mat3', 'mat4']
names = ['mat1', 'mat2', 'mat3', 'mat4']
input_key = 'field/rfdata/tissue/synthetic/'
output_key = 'field/rfdata/tissue/synthetic_10db/full'
deconvolve = False
addnoise = True
noisesnr = 10
emtype = 'av'
################################################################################

if __name__ == '__main__':
    
    with h5py.File(file_path, 'a') as root:
        
        rfdata_t = root[input_key + names[0]][:]
        t0_t = root[input_key + names[0]].attrs['start_time']
        fs = root[input_key + names[0]].attrs['sample_frequency']
        rho = root[input_key + names[0]].attrs['density']
        c = root[input_key + names[0]].attrs['sound_speed'] 
        impulse_response = root[input_key + 
            names[0]].attrs['rx_impulse_response']  
         
        for i in names[1:]:
            
            rfdata = root[input_key + i][:]
            t0 = root[input_key + i].attrs['start_time']
            
            rfdata_t, t0_t = align_and_sum(rfdata_t, t0_t, rfdata, t0, fs)
     
        # deconvolve if desired
        if deconvolve:
            
            rfdata_t = deconvwnr(rfdata_t, impulse_response, axis=0)*fs
            
            if emtype.lower() == 'av':
                rfdata_t = rho*c*cumtrapz(rfdata_t, dx=1/fs, axis=0, initial=0)
        
        # add noise if desired
        if addnoise:
            
            # first pad zeros so that start time is 0
            fpad = round(t0_t*fs)
            pad_width = [(fpad, 0)] + [(0,0) for x in range(rfdata_t.ndim - 1)]
            rfdata_t = np.pad(rfdata_t, pad_width, mode='constant')
            t0_t = 0
            
            # add white gaussian noise
            rfdata_t, dbw = addwgn(rfdata_t, psnr=noisesnr, mode='mean')

        # write dataset
        if output_key in root:
            del root[output_key]
            
        root.create_dataset(output_key, data=rfdata_t, compression='gzip')
        
        for k, v in root[input_key + names[0]].attrs.iteritems():
            root[output_key].attrs.create(k, v)
        
        root[output_key].attrs['start_time'] = t0_t
        
        if addnoise:
            root[output_key].attrs.create('noise_dbw', dbw)
        
    
    
    
