# pyfield / flow / reconstructor.py

from . import corr_lag_doppler, inst_phase_doppler

class Reconstructor():
    
    input_path = ('','')
    output_path = ('','')
    
    options = { 'ensemble': 1,
                'gate': 1,
                'interleave': 1,
                'interpolate': 1,
                'resample': 1,
                'threshold': 0,
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
        pass
            