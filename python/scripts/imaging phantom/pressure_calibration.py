# scripts / imaging phantom / pressure_calibration.py

from pyfield.field import Field

import numpy as np

######################### SET SCRIPT PARAMETERS HERE ###########################
script_path = 'pyfield.field.linear_array_128_5mhz_calibrated'
################################################################################

if __name__ == '__main__':
    
    f2 = Field()
    
    f2.field_init(-1)
    script = __import__(script_path, fromlist=['asdf'])
    
            
    prms = script.get_prms()
    tx, rx = script.get_apertures(f2)
    
    scale_factor = 1.0
    f2.xdc_impulse(tx, prms['tx_impulse_response']*scale_factor)
    pres, t0 = f2.calc_hp(tx, np.array([0,0,0.04]))
    
    print np.max(np.abs(pres))
    
    
    
        

        
    
    
    
    
    
