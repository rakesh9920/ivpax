# scripts / doppler_angle_investigation2.py

import numpy as np
import scipy.signal as sig
import scipy as sp
from matplotlib import pyplot as pp
from pyfield.field import Field
from pyfield.signal import xcorr2

fc = 5e6
fbw = 1
fs = 100e7

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
ns = 10 * 100**2

def mag(r, axis=-1):
    return np.sqrt(np.sum(r*r, axis=axis, keepdims=True))
    
if __name__ == '__main__':
    
    f2 = Field()
    
    f2.field_init(-1)
    
    f2.set_field('c', prms['sound_speed'])
    f2.set_field('fs', prms['sample_frequency'])
    f2.set_field('att', prms['attenuation'])
    f2.set_field('freq_att', prms['frequency_attenuation'])
    f2.set_field('att_f0', prms['attenuation_center_frequency'])
    f2.set_field('use_att', prms['use_attenuation'])
    
    pos1 = np.array([[0.000, 0, 0.02]])
    pos2 = np.array([[0.000, 0, 0.0205]])

    nscat = ns*0.02**2
    bg_x = sp.rand(nscat)*0.02
    bg_y = np.zeros(nscat)
    bg_z = sp.rand(nscat)*0.02
    bg = np.c_[bg_x, bg_y, bg_z] - np.array([0.02, 0, 0.02])/2.0 + pos1
    
    scat1 = np.concatenate((bg, pos1), axis=0)
    scat2 = np.concatenate((bg, pos2), axis=0)
    
    v = (pos2 - pos1).squeeze()
    t0_tx = mag(v)/1540*2
    v /= mag(v)
    
    #tx1 = f2.xdc_linear_array(128, 290e-6, 0.01, 10e-6, 1, 1, pos1) 
    #f2.xdc_impulse(tx1, prms['tx_impulse_response'])
    #f2.xdc_excitation(tx1, prms['tx_excitation'])
    #apod = np.zeros((1, 128))
    #apod[:,63:67] = 1
    #f2.xdc_apodization(tx1, np.zeros((1,1)), apod)
    
    planetx1 = f2.xdc_linear_array(128, 290e-6, 0.01, 10e-6, 1, 1, 
        np.array([[0, 0, 300]])) 
    f2.xdc_impulse(planetx1, prms['tx_impulse_response'])
    f2.xdc_excitation(planetx1, prms['tx_excitation'])
    f2.xdc_focus_times(planetx1, np.zeros((1,1)), np.zeros((1,128)))
    
    subrx1 = f2.xdc_linear_array(128, 290e-6, 0.01, 10e-6, 1, 1, pos1) 
    f2.xdc_impulse(subrx1, prms['tx_impulse_response'])
    f2.xdc_excitation(subrx1, prms['tx_excitation'])
    apod = np.zeros((1, 128))
    apod[:,127] = 1
    f2.xdc_apodization(subrx1, np.zeros((1,1)), apod)

    htx1, t0 = f2.calc_scat(planetx1, planetx1, pos1, np.ones((1,1)))
    htx1 = np.pad(htx1, ((np.round(t0*fs), 0), (0,0)), mode='constant')

    htx2, t0 = f2.calc_scat(planetx1, planetx1, pos2, np.ones((1,1)))
    htx2 = np.pad(htx2, ((np.round(t0*fs), 0), (0,0)), mode='constant')

    xc_tx, lags = xcorr2(htx1, htx2, fs=fs)
    
    delta_t = []
    delta_t_sugg = []
    
    v_tx = np.array([0, 0, 1])
    
    for idx in xrange(128):
        
        print idx
        apod = np.zeros((1, 128))
        apod[:,idx] = 1
        f2.xdc_apodization(subrx1, np.zeros((1,1)), apod)

        #hrx1, t0 = f2.calc_scat(planetx1, subrx1, scat1, np.ones(scat1.shape[0]))
        hrx1, t0 = f2.calc_hhp(planetx1, subrx1, scat1)
        hrx1 = np.sum(hrx1, axis=1, keepdims=True)
        hrx1 = np.pad(hrx1, ((np.round(t0*fs), 0), (0,0)), mode='constant')
        
        #hrx2, t0 = f2.calc_scat(planetx1, subrx1, scat2, np.ones(scat1.shape[0]))
        hrx2, t0 = f2.calc_hhp(planetx1, subrx1, scat2)
        hrx2 = np.sum(hrx2, axis=1, keepdims=True)
        hrx2 = np.pad(hrx2, ((np.round(t0*fs), 0), (0,0)), mode='constant')
        
        xc_rx, lags_rx = xcorr2(hrx2, hrx1, fs=fs)
        
        delta_t.append(lags_rx[np.argmax(xc_rx)]/t0_tx)
               
        v_rx = pos1.squeeze() - centers[idx,:]
        v_rx /= mag(v_rx)
        
        cos_angle = v.dot(0.5*(v_tx + v_rx))
        
        delta_t_sugg.append(cos_angle)
    
    delta_t = np.array(delta_t)
    delta_t_sugg = np.array(delta_t_sugg)
    
    pp.plot(delta_t)
    pp.plot(delta_t_sugg)
    pp.show()
