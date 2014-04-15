
import numpy as np
import scipy as sp

def run(f2):
     
    rho = 1000
    c = 1540
    fs = 100e6
    fc = 5e6
    bw = 6e6
    att = 0
    freq_att = 0
    att_f0 = 5e6

     
    f2.set_field("c", c)
    f2.set_field("fs", fs)
    f2.set_field("att", att)
    f2.set_field("freq_att", freq_att)
    f2.set_field("att_f0", att_f0)
    f2.set_field("use_att", 1)
        
    impulse_response = sp.sin(2*sp.pi*fc*np.arange(0,1/fc + 1/fs,1/fs));
    impulse_response = impulse_response*(sp.hanning(np.size(impulse_response)))
    excitation = impulse_response.copy()
    
    Th = f2.xdc_piston(0.01, 0.001)
    f2.xdc_impulse(Th, impulse_response)
    f2.xdc_excitation(Th, excitation)
    f2.xdc_focus_times(Th, np.zeros((1,1)), np.zeros((1,1)))
    
    return (Th, Th)