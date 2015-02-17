# scripts / simple_lumen_1dflow_reconstruction.py

import numpy as np
from scipy.interpolate import interp1d
from scipy.signal import convolve
import h5py

file_path = './data/tendon poc/tendon_poc_datasets.h5'
mf_filepath = './data/tendon poc/input_sweep.npz'
input_key = 'flowdata/0'
ds_key = 'flowdata/ds0'


with np.load(mf_filepath) as root:
    
    filt = root['filt']

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
    new_flowdata = flowdata.copy()
    
    # remove spike points first
    mask = np.diff(flowdata) < threshold
    mask = np.insert(mask, 0, False)
    mask[-1] = False
    mask[-2] = False
    mask[-3] = False
    #masked_x = x[mask == False]
    #masked_flowdata = flowdata[mask == False]
    
    # interpolate using cubic splines and evaluate at original locations
    #interp_func = interp1d(masked_x, masked_flowdata, 'cubic')
    #new_flowdata = interp_func(x)
    
    for spk in x[mask]:
        
        xp = np.array([spk - 1, spk + 1, spk + 2, spk + 3])
        yp = flowdata[xp]
        
        interp_func = interp1d(xp, yp, 'cubic')
        nyp = interp_func(spk)
        
        new_flowdata[spk] = nyp
    
    return new_flowdata

def despike_h5(input_key, output_key):
    
    with h5py.File(file_path, 'a') as root:
        
        flowdata = root[input_key][:]
        
        if output_key in root:
            del root[output_key]
            
        new_flowdata = root.create_dataset(output_key, shape=flowdata.shape, 
            dtype='float', compression='gzip')
            
        for ind, ve in enumerate(flowdata):
            
            new_flowdata[ind,:] = despike2(ve, -0.015)

def matchedfilter_h5(input_key, output_key, filt):
    
    with h5py.File(file_path, 'a') as root:
        
        flowdata = root[input_key][:]
        
        if output_key in root:
            del root[output_key]
        
        shape = (flowdata.shape[0], filt.shape[0] + flowdata.shape[1] - 1)
        new_flowdata = root.create_dataset(output_key, shape=shape, 
            dtype='float', compression='gzip')
            
        for ind, ve in enumerate(flowdata):
            
            new_flowdata[ind,:] = convolve(ve - np.mean(ve), filt)

if __name__ == '__main__':
    
    
    pass
            
    
    
    
    