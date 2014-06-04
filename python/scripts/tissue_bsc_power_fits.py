# scripts / tissue_bsc_power_fits

import h5py
import numpy as np
import scipy as sp

file_path = './data/bsc/tissue experimental bsc/tissue_bsc_data.h5'
exp_key = 'bsc/experimental/heart_dog_odonnell'
powerfit_key = 'bsc/powerfit/heart_dog_odonnell'
fmax = 20e6

if __name__ == '__main__':
    
    with h5py.File(file_path, 'a') as root:
        
        x = root[exp_key][:,0]
        y = root[exp_key][:,1]
        
        slope, intercept, _, _, _ = sp.stats.linregress(np.log(x), np.log(y))
        
        power = slope
        coeff = np.e**intercept
        
        xf = np.arange(0, fmax + 1e6, 1e6)
        yf = coeff*xf**power
        
        if powerfit_key in root:
            del root[powerfit_key]
        
        root.create_dataset(powerfit_key, data=np.c_[xf, yf], 
            compression='gzip')
    