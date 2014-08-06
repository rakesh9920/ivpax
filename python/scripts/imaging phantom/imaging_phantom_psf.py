
import numpy as np

from pyfield.field import Field

script = 'pyfield.field.linear_array_128_5mhz'


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
    
    scat, t0 = f2.calc_scat_multi(Tx, Rx, points, amp)
