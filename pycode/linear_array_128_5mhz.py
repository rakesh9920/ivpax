
import numpy as np
import scipy as sp

def get_prms():
    
    fc = 5e6
    fs = 100e6
    impulse_response = sp.sin(2*sp.pi*fc*np.arange(0,1/fc + 1/fs,1/fs));
    impulse_response = impulse_response*(sp.hanning(np.size(impulse_response)))
    excitation = impulse_response.copy()
    
    prms = dict()
    prms['density'] = 1000
    prms['sound_speed'] = 1540
    prms['sample_frequency'] = 100e6
    prms['center_frequency'] = 5e6
    prms['use_attenuation'] = 0
    prms['attenuation'] = 0
    prms['frequency_attenuation'] = 0
    prms['attenuation_center_frequency'] = 5e6
    prms['tx_impulse_response'] = impulse_response
    prms['rx_impulse_response'] = impulse_response
    prms['tx_excitation'] = excitation
    prms['tx_positions'] = np.array([[0, 0, 0]])
    prms['rx_positions'] = np.array([[0, 0, 0]]) 
    
    return prms 

def get_apertures(f2):
     
    prms = get_prms()
    f2.set_field('c', prms['sound_speed'])
    f2.set_field('fs', prms['sample_frequency'])
    f2.set_field('att', prms['frequency_attenuation'])
    f2.set_field('freq_att', prms['sound_speed'])
    f2.set_field('att_f0', prms['attenuation_center_frequency'])
    f2.set_field('use_att', prms['use_attenuation'])
    
    Th = f2.xdc_piston(0.01, 0.001)
    f2.xdc_impulse(Th, prms['impulse_response'])
    f2.xdc_excitation(Th, prms['excitation'])
    f2.xdc_focus_times(Th, np.zeros((1,1)), np.zeros((1,1)))
    
    return (Th, Th)