
import numpy as np

from pyfield.field import Field, apply_bsc
from pyfield.signal import deconvwnr

#script = 'pyfield.field.linear_focused_array_128_6mhz_calibrated'
script = 'pyfield.field.linear_array_128_5mhz'
sigma_bs = 1e-6

if __name__ == '__main__':
    
    def_script = __import__(script, fromlist=['asdf'])
    prms = def_script.get_prms()
    
    excitation = prms['tx_excitation']
    impulse_response = prms['rx_impulse_response']
    fs = prms['sample_frequency']
    sr = prms['area']

    f2 = Field()
    
    f2.field_init(-1, 'tester.txt')
    
    Tx, Rx = def_script.get_apertures(f2)
    
    points = np.array([0, 0, 0.02])
    amp = np.ones((1,1))*np.sqrt(sigma_bs)*2*np.pi/sr
    
    scat, t0 = f2.calc_scat_multi(Tx, Rx, points, amp)
    h, t0 = f2.calc_h(Tx, points)
    h = np.squeeze(h)
    
    rf = np.sum(scat, axis=1)
    
    ptx, t0 = f2.calc_hp(Tx, points) 
    ptx = np.squeeze(ptx)
    prx = deconvwnr(scat, impulse_response, axis=0, nsr=0)*fs
    
    #prx2 = ptx*2*np.pi*np.sqrt(sigma_bs)/sr/0.03
    prx2 = np.convolve(ptx*2*np.pi*np.sqrt(sigma_bs)/sr, h)/fs
    vrx = np.convolve(np.convolve(np.convolve(np.convolve(h, h), impulse_response), 
        impulse_response), excitation)/fs**4*amp[0]