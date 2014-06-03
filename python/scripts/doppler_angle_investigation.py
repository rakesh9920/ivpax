# scripts / dopper_angle_investigation.py

import numpy as np
import scipy.signal as sig
import scipy as sp

from pyfield.field import Field
from pyfield.signal import xcorr, xcorr2
from pyfield.util import distance

fc = 5e6
fbw = 1
fs = 100e6

#impulse_response = sp.sin(2*sp.pi*fc*np.arange(0,1/fc + 1/fs,1/fs));
#impulse_response = impulse_response*(sp.hanning(np.size(impulse_response)))
#excitation = impulse_response.copy()

cutoff = sig.gausspulse('cutoff', fc=fc, bw=fbw, tpr=-60, bwr=-3)
adj_cutoff = np.ceil(cutoff*fs)/fs
t = np.arange(-adj_cutoff, adj_cutoff + 1/fs, 1/fs)
_, impulse_response = sig.gausspulse(t, fc=fc, bw=fbw, retquad=True, bwr=-3)
excitation = impulse_response.copy()  

prms = dict()
prms['density'] = 1000
prms['sound_speed'] = 1540
prms['sample_frequency'] = fs
prms['center_frequency'] = fc
prms['bandwidth'] = fc*fbw
prms['use_attenuation'] = 1
prms['attenuation'] = 0
prms['frequency_attenuation'] = 0
prms['attenuation_center_frequency'] = fc
prms['tx_impulse_response'] = impulse_response
prms['rx_impulse_response'] = impulse_response
prms['tx_excitation'] = excitation
prms['area'] = 0.01*290e-6*128
centers = (np.arange(0,128) - 63.5)*300e-6
centers = np.c_[centers, np.zeros((128,2))]
prms['tx_positions'] = np.zeros((1,3))
prms['rx_positions'] = centers

if __name__ == '__main__':
    
    f2 = Field()
    
    f2.field_init(-1)
    
    f2.set_field('c', prms['sound_speed'])
    f2.set_field('fs', prms['sample_frequency'])
    f2.set_field('att', prms['attenuation'])
    f2.set_field('freq_att', prms['frequency_attenuation'])
    f2.set_field('att_f0', prms['attenuation_center_frequency'])
    f2.set_field('use_att', prms['use_attenuation'])
    
    pos1 = np.array([[0, 0, 0.02]])
    pos2 = np.array([[0, 0, 0.021]])
    
    txdelays = -distance(centers, pos1).T/1540
    txdelays = txdelays - np.min(txdelays)
    #rxdelays = -distance(centers[0:16,:], pos1).T/1540
    
    planetx = f2.xdc_linear_array(128, 290e-6, 0.01, 10e-6, 1, 1, 
        np.array([0, 0, 300])) 
    f2.xdc_impulse(planetx, prms['tx_impulse_response'])
    f2.xdc_excitation(planetx, prms['tx_excitation'])
    f2.xdc_focus_times(planetx, np.zeros((1,1)), np.zeros((1,128)))
    #f2.xdc_focus_times(tx, np.zeros((1,1)), txdelays)
    
    fullrx = f2.xdc_linear_array(128, 290e-6, 0.01, 10e-6, 1, 1, 
        np.array([0, 0, 300])) 
    #org = np.mean(centers[0:16,:], axis=0)
    #rx = f2.xdc_shift(rx, org, free=True)
    f2.xdc_impulse(fullrx, prms['tx_impulse_response'])
    f2.xdc_excitation(fullrx, prms['tx_excitation'])
    #f2.xdc_focus_times(fullrx, np.zeros((1,1)), txdelays[:,0:16])
    f2.xdc_focus_times(fullrx, np.zeros((1,1)), txdelays)
    
    subrx = f2.xdc_linear_array(128, 290e-6, 0.01, 10e-6, 1, 1, 
        np.array([0, 0, 300])) 
    f2.xdc_impulse(subrx, prms['tx_impulse_response'])
    f2.xdc_excitation(subrx, prms['tx_excitation'])
    f2.xdc_focus_times(subrx, np.zeros((1,1)), txdelays)
    apod = np.zeros((1, 128))
    apod[:,0:16] = 1
    f2.xdc_apodization(subrx, np.zeros((1,1)), apod)
    
    htx, t0 = f2.calc_h(planetx, pos1, fs=fs)
    htx = np.pad(htx, ((np.round(t0*fs), 0), (0,0)), mode='constant')
    hrx, t0 = f2.calc_h(fullrx, pos1, fs=fs)
    hrx = np.pad(hrx, ((np.round(t0*fs), 0), (0,0)), mode='constant')
    hrx1, t0 = f2.calc_h(subrx, pos1, fs=fs)
    hrx1 = np.pad(hrx1, ((np.round(t0*fs), 0), (0,0)), mode='constant') 
    
    #f2.field_end()
    
