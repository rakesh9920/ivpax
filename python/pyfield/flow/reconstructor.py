# pyfield / flow / reconstructor.py

from . import corr_lag_doppler, inst_phase_doppler
import h5py

class Reconstructor():
    
    file_path = ''
    input_key = ''
    output_key = ''
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
        
        for k, v in [(k, v) for (k, v) in kwargs.iteritems() if k in 
            self.options]:
            
            self.options[k] = v
    
    def start(self):
                
        method = self.options['method'].lower()
        file_path = self.file_path
        input_key = self.input_key
        vel_key = self.output_key
        coeff_key = self.coeff_key
        
        opts = self.options.copy()
        
        with h5py.File(file_path, 'r') as root:
            
            bfdata = root[input_key]
            
            if opts['c'] is None:
                opts['c'] = bfdata.attrs['sound_speed']
            if opts['prf'] is None:
                opts['prf'] = bfdata.attrs['pulse_repitition_frequency']            
            if opts['fc'] is None:
                opts['fc'] = bfdata.attrs['center_frequency']            
            if opts['bw'] is None:
                opts['bw'] = bfdata.attrs['bandwidth']        
            if opts['fs'] is None:
                opts['fs'] = bfdata.attrs['sample_frequency']
                        
        if method == 'corr_lag':
            corr_lag_doppler((file_path, input_key), vel_key=vel_key,
                coeff_key=coeff_key, **opts)
            
        elif method == 'inst_phase':
            inst_phase_doppler((file_path, input_key), vel_key=vel_key,
                **opts)
            
        elif method == 'corr_match':
            
            pass
            
        else:
            
            pass
        
        with h5py.File(file_path, 'a') as root:
            
            for k, v in root[input_key].attrs.iteritems():
                root[vel_key].attrs.create(k, v)
            