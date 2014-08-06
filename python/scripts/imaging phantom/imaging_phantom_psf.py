
import numpy as np
import h5py

from pyfield.field import Field
from pyfield.beamform import Beamformer

script = 'pyfield.field.linear_array_128_5mhz'
file_path = './data/psf_data.h5'
rf_key = 'field/rfdata/psf'

if __name__ == '__main__':
    
    def_script = __import__(script, fromlist=['asdf'])
    prms = def_script.get_prms()
    
    excitation = prms['tx_excitation']
    impulse_response = prms['rx_impulse_response']
    fs = prms['sample_frequency']

    f2 = Field()
    
    f2.field_init(-1, 'tester.txt')
    
    Tx, Rx = def_script.get_apertures(f2)
    
    points = np.array([[0,0,0.01],[0,0,0.02],[0,0,0.03]])
    amp = np.ones((3,1))
    
    scat, t0 = f2.calc_scat_all(Tx, Rx, points, amp, 1)
    
    with h5py.File(file_path, 'a') as root:
        
        if rf_key in root:
            del root[rf_key]
        
        root.create_dataset(rf_key, data=scat, compression='gzip')
        
        for key, val in prms.iteritems():
            root[rf_key].attrs.create(key, val)
        
        root[rf_key].attrs.create('start_time', t0)