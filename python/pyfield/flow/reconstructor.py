# pyfield / flow / reconstructor.py

from . import corr_lag_doppler, inst_phase_doppler
import h5py

class Reconstructor():
    
    file_path = ('','')
    input_key = ''
    output_ley = ''
    coeff_key = ''
    options = { 'method': '',
                'ensemble': 1,
                'gate': 1,
                'interleave': 1,
                'interpolate': 1,
                'resample': 1,
                'threshold': 0,
                'retcoeff': False,
                'c': None,
                'prf': None,
                'fc': None,
                'bw': None,
                'fs': None }
    
    def __init__(self):
        pass
    
    def set_options(self, **kwargs):
        
        for k, v in [(k, v) for (k, v) in kwargs if k in self.options]:
            self.options[k] = v
    
    def start(self):
                
        method = self.options['method'].lower()
        file_path = self.file_path
        input_key = self.input_key
        vel_key = self.input_key
        coeff_key = self.coeff_key
        
        if method == 'corr_lag':
            corr_lag_doppler((file_path, input_key), vel_key=vel_key,
                coeff_key=coeff_key, **self.options)
            
        elif method == 'inst_phase':
            inst_phase_doppler((file_path, input_key), vel_key=vel_key,
                **self.options)
            
        elif method == 'corr_match':
            
            pass
            
        else:
            
            pass
     
            