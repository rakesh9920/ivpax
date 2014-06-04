# pyfield / field / ice_array_64_10mhz.py

# 1D ICE array made of 64 elements arranged linearly. Element pitch is 63um and
# element size is 1mm (elevation) by 53um (azimuth)

import numpy as np
from scipy import signal as sig

############################### SCRIPT PARAMETERS ##############################
fc = 10e6
fbw = 1
fs = 100e6
pitch = 63e-6
length = 1e-3
width = 53e-6
nelement = 64
rfocus = 0.035
nsubx = 1
nsuby = 10
################################################################################

kerf = pitch - width

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
prms['tx_positions'] = np.zeros((1,3))
prms['rx_positions'] = np.zeros((1,3))
prms['area'] = length*width*nelement

centers = (np.arange(0, nelement) - nelement/2.0 + 0.5)*pitch
prms['tx_positions'] = np.zeros((1,3))
prms['rx_positions'] = np.hstack((centers[:,None], np.zeros((nelement,2))))

def get_prms():
    
    return prms 

def get_apertures(f2):
     
    #prms = get_prms()
    f2.set_field('c', prms['sound_speed'])
    f2.set_field('fs', prms['sample_frequency'])
    f2.set_field('att', prms['attenuation'])
    f2.set_field('freq_att', prms['frequency_attenuation'])
    f2.set_field('att_f0', prms['attenuation_center_frequency'])
    f2.set_field('use_att', prms['use_attenuation'])
    
    Th = f2.xdc_focused_array(nelement, width, length, kerf, rfocus, nsubx, 
        nsuby, np.array([0, 0, 300])) 
    f2.xdc_impulse(Th, prms['tx_impulse_response'])
    f2.xdc_excitation(Th, prms['tx_excitation'])
    f2.xdc_focus_times(Th, np.zeros((1, 1)), np.zeros((1, nelement)))
    
    return (Th, Th)