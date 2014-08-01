import numpy as np
import scipy as sp
from scipy import signal as sig

def get_prms():
    
    fc = 5e6
    fbw = 1
    fs = 100e6
    exc_scale_factor = 1.0
    imp_scale_factor = 3.0665168804261907e+17

    #impulse_response = sp.sin(2*sp.pi*fc*np.arange(0,1/fc + 1/fs,1/fs));
    #impulse_response = impulse_response*(sp.hanning(np.size(impulse_response)))
    #excitation = impulse_response.copy()
    
    cutoff = sig.gausspulse('cutoff', fc=fc, bw=fbw, tpr=-60, bwr=-3)
    adj_cutoff = np.ceil(cutoff*fs)/fs
    t = np.arange(-adj_cutoff, adj_cutoff + 1/fs, 1/fs)
    _, impulse_response = sig.gausspulse(t, fc=fc, bw=fbw, retquad=True, bwr=-3)
    excitation = impulse_response.copy()
    
    excitation = exc_scale_factor*excitation
    impulse_response = imp_scale_factor*impulse_response
    
    prms = dict()
    prms['density'] = 1000
    prms['sound_speed'] = 1540
    prms['sample_frequency'] = fs
    prms['center_frequency'] = fc
    prms['bandwidth'] = fc*fbw
    prms['use_attenuation'] = 0
    prms['attenuation'] = 0
    prms['frequency_attenuation'] = 0
    prms['attenuation_center_frequency'] = fc
    prms['tx_impulse_response'] = impulse_response
    prms['rx_impulse_response'] = impulse_response
    prms['tx_excitation'] = excitation
    prms['tx_positions'] = np.zeros((1,3))
    prms['rx_positions'] = np.zeros((1,3))
    prms['area'] = 0.003*290e-6*128
    
    centers = (np.arange(0,128) - 63.5)*300e-6
    prms['tx_positions'] = np.zeros((1,3))
    prms['rx_positions'] = np.hstack((centers[:,None], np.zeros((128,2))))
    
    return prms 

def get_apertures(f2):
     
    prms = get_prms()
    f2.set_field('c', prms['sound_speed'])
    f2.set_field('fs', prms['sample_frequency'])
    f2.set_field('att', prms['attenuation'])
    f2.set_field('freq_att', prms['frequency_attenuation'])
    f2.set_field('att_f0', prms['attenuation_center_frequency'])
    f2.set_field('use_att', prms['use_attenuation'])
    
    Th = f2.xdc_linear_array(128, 290e-6, 0.003, 10e-6, 1, 1, 
        np.array([0, 0, 300])) 
    f2.xdc_impulse(Th, prms['tx_impulse_response'])
    f2.xdc_excitation(Th, prms['tx_excitation'])
    f2.xdc_focus_times(Th, np.zeros((1,1)), np.zeros((1,128)))
    
    return (Th, Th)