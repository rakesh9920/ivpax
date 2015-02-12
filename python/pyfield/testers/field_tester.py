# pyfield / testers / field_tester.py
  
import numpy as np
import scipy as sp
from pyfield.field import Field
import scipy.signal as sig
 
if __name__ == '__main__':
     
    fc = 5e6
    fbw = 1
    fs = 100e6
    
    impulse_response = sp.sin(2*sp.pi*fc*np.arange(0, 1/fc + 1/fs, 1/fs))
    impulse_response = impulse_response*(sp.hanning(np.size(impulse_response)))
    impulse_response.shape = (1, np.size(impulse_response)) # force row vector
    excitation = impulse_response.copy()
    #
    #def_script = __import__('pyfield.field.linear_array_128_5mhz', 
    #    fromlist=['asdf'])
    
    f2 = Field()
    f2.field_init(-1, 'tester_log.txt')
    #(tx_aperture, rx_aperture) = def_script.get_apertures(f2)
    
    f2.set_field('c', 1540)
    f2.set_field('fs', 100e6)
    f2.set_field('att', 0)
    f2.set_field('freq_att', 0)
    f2.set_field('att_f0', 5e6)
    f2.set_field('use_att', 0)
    
    #cutoff = sig.gausspulse('cutoff', fc=fc, bw=fbw, tpr=-60, bwr=-3)
    #adj_cutoff = np.ceil(cutoff*fs)/fs
    #t = np.arange(-adj_cutoff, adj_cutoff + 1/fs, 1/fs)
    #_, impulse_response = sig.gausspulse(t, fc=fc, bw=fbw, retquad=True, bwr=-3)
    #excitation = impulse_response.copy()
    
    Th = f2.xdc_linear_array(128, 290e-6, 0.003, 10e-6, 1, 1, 
        np.array([0, 0, 300])) 
    f2.xdc_impulse(Th, impulse_response)
    f2.xdc_excitation(Th, excitation)
    #f2.xdc_focus_times(Th, np.zeros((1,1)), np.zeros((1,128)))
    #f2.field_init(0, diarypath='test.txt')
    #f2.set_field('fs', 100e6)
    #f2.set_field('c', 1500)
    #
    #Th1 = f2.xdc_piston(0.01, 0.001)
    #f2.xdc_impulse(Th1, impulse_response)
    #f2.xdc_excitation(Th1, excitation)
    #f2.xdc_focus_times(Th1, np.zeros((1,1)), np.zeros((1,1)))

    #Th2 = f2.xdc_linear_array(128, 290e-6, 0.003, 10e-6, 1, 1, 
    #    np.array([0, 0, 300])) 
    #Th2 = f2.xdc_linear_array(128, 300e-6, 300e-6, 150e-6, 1, 1, 
        #np.array([0, 0, 300]))
    #Th2 = f2.xdc_focused_array(128, 300e-6, 300e-6, 150e-6, 0.02, 1, 1, 
        #np.array([0, 0, 0.02]))
    #f2.xdc_impulse(Th2, impulse_response)
    #f2.xdc_excitation(Th2, excitation)
    #f2.xdc_focus_times(Th2, np.zeros((1,1)), np.zeros((1,128)))
    
    #Th3 = f2.xdc_2d_array(5, 5, 50e-6, 50e-6, 10e-6, 10e-6, np.ones((5,5)), 1, 1,
    #    np.array([0, 0, 300]))
    #f2.xdc_impulse(Th3, impulse_response)
    #f2.xdc_excitation(Th3, excitation)
    #f2.xdc_focus_times(Th3, np.zeros((1,1)), np.zeros((1,5*5)))
    
    #rect = f2.xdc_get(Th1, 'rect') # xdc_get doesn't work 
    
    points = np.array([[0,0,0.01],[0,0,0.02],[0,0,0.03],[0,0,0.04]])
    amplitudes = np.ones(points.shape[0])
    scat1,t01 = f2.calc_scat(Th, Th, points, amplitudes)
    #scat2, t02 = f2.calc_scat_multi(Th2, Th2, points, amplitudes)
    #scat3, t03 = f2.calc_scat_multi(Th3, Th3, points, amplitudes)
    #scat4, t04 = f2.calc_h(Th2, points)
    #scat5, t05 = f2.calc_hp(Th2, points)
    #scat6, t06 = f2.calc_hhp(Th2, Th2, points)
    #scat7, t07 = f2.calc_scat_all(Th, Th, points, amplitudes, 
        #1)
    
    #f2.xdc_free(Th1)
    #f2.xdc_free(Th2)
    #f2.xdc_free(Th3)
    f2.field_end()

    #pp.figure()
    #pp.plot(scat1)
    #pp.figure()
    #pp.plot(scat2)
    #pp.figure()
    #pp.plot(scat3)
    #pp.show()