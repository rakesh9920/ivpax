# scripts / dopper_angle_investigation.py

import numpy as np
import scipy.signal as sig
import scipy as sp
from matplotlib import pyplot as pp
from pyfield.field import Field
from pyfield.signal import xcorr, xcorr2
from pyfield.util import distance

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
    pos2 = np.array([[0, 0, 0.0201]])
    t0_tx = (pos1[0,2] - pos2[0,2])/1540*2

    tx1 = f2.xdc_linear_array(128, 290e-6, 0.01, 10e-6, 1, 1, pos1) 
    f2.xdc_impulse(tx1, prms['tx_impulse_response'])
    f2.xdc_excitation(tx1, prms['tx_excitation'])
    apod = np.zeros((1, 128))
    apod[:,63:67] = 1
    f2.xdc_apodization(tx1, np.zeros((1,1)), apod)
    
    subrx1 = f2.xdc_linear_array(128, 290e-6, 0.01, 10e-6, 1, 1, pos1) 
    f2.xdc_impulse(subrx1, prms['tx_impulse_response'])
    f2.xdc_excitation(subrx1, prms['tx_excitation'])
    apod = np.zeros((1, 128))
    apod[:,127] = 1
    f2.xdc_apodization(subrx1, np.zeros((1,1)), apod)

    tx2 = f2.xdc_linear_array(128, 290e-6, 0.01, 10e-6, 1, 1, pos2) 
    f2.xdc_impulse(tx2, prms['tx_impulse_response'])
    f2.xdc_excitation(tx2, prms['tx_excitation'])
    apod = np.zeros((1, 128))
    apod[:,63:67] = 1
    f2.xdc_apodization(tx2, np.zeros((1,1)), apod)
    
    subrx2 = f2.xdc_linear_array(128, 290e-6, 0.01, 10e-6, 1, 1, pos2) 
    f2.xdc_impulse(subrx2, prms['tx_impulse_response'])
    f2.xdc_excitation(subrx2, prms['tx_excitation'])
    apod = np.zeros((1, 128))
    apod[:,127] = 1
    f2.xdc_apodization(subrx2, np.zeros((1,1)), apod)
    
    htx1, t0 = f2.calc_h(tx1, pos1, fs=fs)
    htx1 = np.pad(htx1, ((np.round(t0*fs), 0), (0,0)), mode='constant')

    htx2, t0 = f2.calc_h(tx2, pos2, fs=fs)
    htx2 = np.pad(htx2, ((np.round(t0*fs), 0), (0,0)), mode='constant')
 
    hhtx1 = np.convolve(htx1.squeeze(), htx1.squeeze())/fs
    hhtx2 = np.convolve(htx2.squeeze(), htx2.squeeze())/fs
 
    xc_tx, lags = xcorr2(hhtx1, hhtx2, fs=fs)

    delta_t = []
    delta_t_sugg = []
    
    v_tx = np.array([0, 0, 1])
    
    for idx in xrange(128):
        
        apod = np.zeros((1, 128))
        apod[:,idx] = 1
        f2.xdc_apodization(subrx1, np.zeros((1,1)), apod)
        f2.xdc_apodization(subrx2, np.zeros((1,1)), apod)
        
        hrx1, t0 = f2.calc_h(subrx1, pos1, fs=fs)
        hrx1 = np.pad(hrx1, ((np.round(t0*fs), 0), (0,0)), mode='constant')
        
        hrx2, t0 = f2.calc_h(subrx2, pos2, fs=fs)
        hrx2 = np.pad(hrx2, ((np.round(t0*fs), 0), (0,0)), mode='constant')
        
        hhrx1 = np.convolve(htx1.squeeze(), hrx1.squeeze())/fs
        hhrx2 = np.convolve(htx2.squeeze(), hrx2.squeeze())/fs
        
        xc_rx, lags_rx = xcorr2(hhrx1, hhrx2, fs=fs)
        
        #delta_t.append(lags[np.argmax(xc_rx)]/lags[np.argmax(xc_tx)])
        delta_t.append(lags_rx[np.argmax(xc_rx)]/t0_tx)
               
        v_rx = pos1.squeeze() - centers[idx,:]
        v_rx /= np.sqrt(np.sum(v_rx**2))
        
        #cos_angle = 0.5*(v_tx.dot(v_tx) + v_tx.dot(v_rx))
        cos_angle = v_tx.dot(0.5*(v_tx + v_rx))
        
        #delta_t_exact.append(0.5*lags[np.argmax(xc_tx)] - 
        #    lags[np.argmax(xc_tx)]*v_tx.dot(v_rx)*0.5)
        delta_t_sugg.append(cos_angle)
    
    delta_t = np.array(delta_t)
    delta_t_sugg = np.array(delta_t_sugg)
    
    #delta_t_exact = np.round(delta_t_exact*fs)/fs
    
    pp.plot(delta_t)
    pp.plot(delta_t_sugg)
    pp.show()
    
    
    #htx, t0 = f2.calc_hhp(tx, pos1, fs=fs)
    #txdelays = -distance(centers, pos1).T/1540.0
    #txdelays = txdelays - np.min(txdelays)
    #f2.field_end()
    #f2.xdc_focus_times(tx, np.zeros((1,1)), np.zeros((1,128)))
    #f2.xdc_focus_times(tx, np.zeros((1,1)), txdelays)
    #rxdelays = -distance(centers[0:16,:], pos1).T/1540
    #fullrx = f2.xdc_linear_array(128, 290e-6, 0.01, 10e-6, 1, 1, pos1) 
    #f2.xdc_impulse(fullrx, prms['tx_impulse_response'])
    #f2.xdc_excitation(fullrx, prms['tx_excitation'])
    #f2.xdc_focus_times(fullrx, np.zeros((1,1)), txdelays)