# scripts / simple_lumen_apply_bsc.py

from pyfield.field import apply_bsc, apply_wgn

import h5py
import numpy as np

######################### SET SCRIPT PARAMETERS HERE ###########################
file_path = './data/simple_lumen_data.h5'
bsc_key = 'bsc/experimental/blood_hmtc8_shung'
raw_key = 'field/rfdata/raw/fluid2'
out_key = 'field/rfdata/blood/fluid2'
snr = 12
################################################################################

def mean_power(rfdata, axis=-1):
    
    return np.mean(rfdata**2, axis=axis)
    
if __name__ == '__main__':
   
    with h5py.File(file_path, 'a') as root:   
        bsc = root[bsc_key][:].copy()

    apply_bsc((file_path, raw_key), (file_path, out_key), bsc=bsc, write=True, 
        method='fir')
    
    with h5py.File(file_path, 'a') as root:
        rfdata = root[out_key][:]
        
    signal_pwr = np.min(mean_power(rfdata, axis=0))
    signal_pwrdb = 10*np.log10(signal_pwr)
    #noise_pwr = signal_pwr/10**(snr/10.0)
    #noise_db = 10*np.log10(noise_pwr)
    noise_pwrdb = signal_pwrdb - snr
    
    apply_wgn((file_path, out_key), (file_path, out_key), 
        dbw=noise_pwrdb, write=True)