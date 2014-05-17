# scripts / simple_lumen_1dflow_reconstruction.py

import h5py

from pyfield.flow import Reconstructor

if __name__ == '__main__':
    
    rec = Reconstructor()
    
    rec.file_path = './data/simple lumen flow/simple_lumen_experiments.hdf5'
    rec.input_key = 'bfdata/00000'
    rec.output_key = 'flowdata/00000'
    rec.coeff_key = ''
    options = { 'method': 'corr_lag',
                'ensemble': 1,
                'gate': 1,
                'interleave': 1,
                'interpolate': 10,
                'resample': 1,
                'threshold': 0,
                'retcoeff': False }
    rec.set_options(**options)
    
    rec.start()
    
            
    
    
    
    