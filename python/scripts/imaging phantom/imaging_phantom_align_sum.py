# scripts / imaging_phantom_align_sum.py

import h5py
from scipy.integrate import cumtrapz

from pyfield.util import align_and_sum
from pyfield.signal import deconvwnr

######################### SET SCRIPT PARAMETERS HERE ###########################
file_path = './data/imaging_phantom_data.h5'
names = ['background', 'mat1', 'mat2', 'mat3', 'mat4']
input_key = 'field/rfdata/tissue/synthetic/'
output_key = 'field/rfdata/tissue/synthetic/full'
deconvolve = True
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
        
        if deconvolve:
            
            rfdata_t = deconvwnr(rfdata_t, impulse_response, axis=0)
            
            if emtype.lower() == 'av':
                rfdata_t = rho*c*cumtrapz(rfdata_t, dx=1/fs, axis=0, initial=0)
        
        if output_key in root:
            del root[output_key]
            
        root.create_dataset(output_key, data=rfdata_t, compression='gzip')
        
        for k, v in root[input_key + names[0]].attrs.iteritems():
            root[output_key].attrs.create(k, v)
        
        root[output_key].attrs['start_time'] = t0_t
        
    
    
    
