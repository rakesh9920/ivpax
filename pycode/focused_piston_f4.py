import numpy as np
import scipy.signal as sig
import scipy as sp

def get_prms():
    
    fc = 6e6
    bw = 9e6
    fbw = bw/fc
    fs = 100e6

    #impulse_response = sp.sin(2*sp.pi*fc*np.arange(0,1/fc + 1/fs,1/fs));
    #impulse_response = impulse_response*(sp.hanning(np.size(impulse_response)))
    #excitation = impulse_response.copy()
    
    cutoff = sig.gausspulse('cutoff', fc=6e6, bw=0.5, tpr=-60)
    adj_cutoff = np.ceil(cutoff*fs)/fs
    t = np.arange(-adj_cutoff, adj_cutoff + 1/fs, 1/fs)
    x, impulse_response = sig.gausspulse(t, fc=6e6, bw=0.5, retquad=True)
    impulse_response[0] = 0
    impulse_response[-1] = 0
    excitation = impulse_response.copy()
    
    prms = dict()
    prms['density'] = 1000
    prms['sound_speed'] = 1540
    prms['sample_frequency'] = fs
    prms['center_frequency'] = fc
    prms['use_attenuation'] = 1
    prms['attenuation'] = 0
    prms['frequency_attenuation'] = 0
    prms['attenuation_center_frequency'] = 6e6
    prms['tx_impulse_response'] = impulse_response
    prms['rx_impulse_response'] = impulse_response
    prms['tx_excitation'] = excitation
    prms['tx_positions'] = np.zeros((1,3))
    prms['rx_positions'] = np.zeros((1,3))
    
    return prms 

def get_apertures(f2):
     
    prms = get_prms()
    f2.set_field('c', prms['sound_speed'])
    f2.set_field('fs', prms['sample_frequency'])
    f2.set_field('att', prms['frequency_attenuation'])
    f2.set_field('freq_att', prms['sound_speed'])
    f2.set_field('att_f0', prms['attenuation_center_frequency'])
    f2.set_field('use_att', prms['use_attenuation'])
    
    Th = f2.xdc_concave(2.5/1000, 0.02, 0.1/1000)
    f2.xdc_impulse(Th, prms['tx_impulse_response'])
    f2.xdc_excitation(Th, prms['tx_excitation'])
    f2.xdc_focus_times(Th, np.zeros((1,1)), np.zeros((1,1)))
    
    return (Th, Th)