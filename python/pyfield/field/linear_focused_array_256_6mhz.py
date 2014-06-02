import numpy as np
from scipy import signal as sig

rfocus = 0.015

def get_prms():
    
    fc = 6e6
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
    prms['tx_positions'] = np.zeros((1,3))
    prms['rx_positions'] = np.zeros((1,3))
    prms['area'] = 0.01*290e-6*256
    
    centers = (np.arange(0,256) - 127.5)*150e-6
    prms['tx_positions'] = np.zeros((1,3))
    prms['rx_positions'] = np.hstack((centers[:,None], np.zeros((256,2))))
    prms['elevation_focus'] = rfocus
    
    return prms 

def get_apertures(f2):
     
    prms = get_prms()
    f2.set_field('c', prms['sound_speed'])
    f2.set_field('fs', prms['sample_frequency'])
    f2.set_field('att', prms['attenuation'])
    f2.set_field('freq_att', prms['frequency_attenuation'])
    f2.set_field('att_f0', prms['attenuation_center_frequency'])
    f2.set_field('use_att', prms['use_attenuation'])
    
    Th = f2.xdc_focused_array(256, 140e-6, 0.01, 10e-6, rfocus, 1, 30, 
        np.array([0, 0, 300])) 
    f2.xdc_impulse(Th, prms['tx_impulse_response'])
    f2.xdc_excitation(Th, prms['tx_excitation'])
    f2.xdc_focus_times(Th, np.zeros((1,1)), np.zeros((1,256)))
    
    return (Th, Th)