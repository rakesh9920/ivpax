# scripts / simple_lumen_1dflow_reconstruction.py

import numpy as np
from scipy.interpolate import interp1d

from pyfield.flow import Reconstructor

######################### SET SCRIPT PARAMETERS HERE ###########################
file_path = './data/tendon poc/tendon_poc_datasets.h5'
input_key = 'bfdata/0'
output_key = 'flowdata/0'
coeff_key = ''
opts = { 'method': 'corr_lag',
         'ensemble': 8,
         'gate': 1,
         'interleave': 1,
         'interpolate': 40,
         'resample': 4,
         'threshold': 0,
         'retcoeff': False }
################################################################################

def despike(flowdata, threshold):
    '''
    '''
    x = np.arange(flowdata.size)
    
    # remove spike points first
    mask = flowdata >= threshold
    masked_x = x[mask]
    masked_flowdata = flowdata[mask]
    
    # interpolate using cubic splines and evaluate at original locations
    interp_func = interp1d(masked_x, masked_flowdata, 'cubic')
    new_flowdata = interp_func(x)
    
    return new_flowdata

def despike2(flowdata, threshold):
    '''
    '''
    x = np.arange(flowdata.size)
    
    # remove spike points first
    mask = np.diff(flowdata) < threshold
    mask = np.insert(mask, 0, False)
    masked_x = x[mask == False]
    masked_flowdata = flowdata[mask == False]
    
    # interpolate using cubic splines and evaluate at original locations
    interp_func = interp1d(masked_x, masked_flowdata, 'cubic')
    new_flowdata = interp_func(x)
    
    return new_flowdata
    
    
if __name__ == '__main__':
    
    rec = Reconstructor()
    
    rec.file_path = file_path
    rec.input_key = input_key
    rec.output_key = output_key
    rec.coeff_key = coeff_key
    rec.set_options(**opts)

    rec.start()
    
            
    
    
    
    