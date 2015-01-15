# scripts / custombsc_analysis.py

from pyfield.signal import ffts, iffts
from pyfield.field import apply_bsc
from pyfield.util import align_cat

import h5py
import numpy as np
from scipy import fftpack as ft, signal as sig
from matplotlib import pyplot as pp
from scipy.stats import rayleigh

######################### SET SCRIPT PARAMETERS HERE ###########################
file_path = './data/bsc/fieldii_bsc_data.h5'
raw_key = 'custombsc/field/rfdata/raw2/'
ref_key = 'custombsc/field/rfdata/raw2/ref'

#out_key = 'custombsc/field/rfdata/blood/'
#bsc_key = 'bsc/experimental/blood_hmtc8_shung'
#out_key = 'custombsc/field/rfdata/kidney/'
#bsc_key = 'custombsc/field/bsc/kidney_wear'
#out_key = 'custombsc/field/rfdata/liver/'
#bsc_key = 'custombsc/field/bsc/liver_wear'
out_key = 'custombsc/field/rfdata/heart'
bsc_key = 'bsc/experimental/heart_dog_odonnell'

ninstance = 1000
filter_method = 'fir'
emtype = 'av'
################################################################################
  
if __name__ == '__main__':
    
    # get bsc spectrum 
    root = h5py.File(file_path, 'a')    
    bsc = root[bsc_key][:].copy()
    root.close()
    
    if True:
        # apply bsc to raw rf data
        
        for inst in xrange(ninstance):  
            apply_bsc((file_path, raw_key + '{:05d}'.format(inst)), 
                (file_path, out_key + '{:05d}'.format(inst)), bsc=bsc, 
                write=True, method=filter_method, emtype=emtype)
        
        # apply bsc to reference rf data to give unit bsc
        bsc_one = np.ones((1024,1))*20*1000**3
        bsc_one[0] = 0
        bsc_one[-1] = 0
        bsc_one = np.insert(bsc_one, 0, np.linspace(0, 100e6/2, 1024), axis=1)
        
        apply_bsc((file_path, ref_key), (file_path, out_key + 'ref'), 
            bsc=bsc_one, write=True, method=filter_method)
    
    root = h5py.File(file_path, 'a') 
    
    # get attributes from bsc-applied data
    focus = 0.02
    fs = root[out_key + '00000'].attrs['sample_frequency']
    c = root[out_key + '00000'].attrs['sound_speed']
    fc = root[out_key + '00000'].attrs['center_frequency']
    #area = root[out_key + '00000'].attrs['area'] 
    area = 1.9838392692290149e-05
    
    # read bsc-applied data into a single large array
    for inst in xrange(ninstance):
        
        if inst == 0:
            
            rfdata = root[out_key + '{:05d}'.format(inst)][:]
            t0 = root[out_key + '{:05d}'.format(inst)].attrs['start_time']
            
        else:
            
            rf1 = root[out_key + '{:05d}'.format(inst)][:]
            t1 = root[out_key + '{:05d}'.format(inst)].attrs['start_time']
            rfdata, t0 = align_cat(rfdata, t0, rf1, t1, 100e6, axis=1)
    
    rfdata = rfdata.reshape((rfdata.shape[0], -1))
    
    # read reference bsc-applied data 
    ref = root[out_key + 'ref'][:]
    ref = ref.reshape((ref.shape[0], 1))
    #ref_t0 = root[ref_key].attrs['start_time']
    
    root.close()
    
    # define measurement parameters
    focus_time = focus*2/c
    gate_length = 5*c/fc
    gate_duration = gate_length*2/c
    gate = np.round((focus_time - t0 + np.array([-gate_duration/2, 
        gate_duration/2]))*fs) + 32
    
    nfft = 2**13
    f_lower = 1e6
    f_upper = 12e6
    wintype = 'hann'
    
    freq = ft.fftshift(ft.fftfreq(nfft, 1/fs))
    k = freq*2*np.pi/c
    freq1 = np.argmin(np.abs(freq[nfft/2:] - f_lower)) + nfft/2
    freq2 = np.argmin(np.abs(freq[nfft/2:] - f_upper)) + nfft/2
    
    window = sig.get_window(wintype, gate[1]-gate[0])
    energy_correction = (gate[1]-gate[0])/np.sum(window**2)
    windata = rfdata[gate[0]:gate[1],:]*window[:,None]
    
    data_psd = 2*np.abs(ffts(windata, n=nfft, axis=0, fs=fs))**2 * \
        energy_correction
    ref_psd = 2*np.abs(ffts(ref, n=nfft, axis=0, fs=fs))**2
    
    ratio = data_psd[freq1:freq2,:]/ref_psd[freq1:freq2,:] * \
        (k[freq1:freq2,None]**2) 
    cam = ratio*area/(0.46*(2*np.pi)**2*focus**2*gate_length)
    
    error_upper = np.mean(cam, axis=1)/(1 + 1.96/np.sqrt(cam.shape[1]))
    error_lower = np.mean(cam, axis=1)/(1 - 1.96/np.sqrt(cam.shape[1]))
    bsc = bsc
    
    #fig1 = pp.figure()
    #ax1 = fig1.add_subplot(111)
    #ax1.set_xscale('log')
    #ax1.set_yscale('log')
    #ax1.set_xlim(f_lower/1e6, f_upper/1e6)
    #line1, = pp.plot(freq[freq1:freq2]/1e6, np.mean(cam, axis=1), 'b')
    #line2, = pp.plot(freq[freq1:freq2]/1e6, error_upper,'b:')
    #pp.plot(freq[freq1:freq2]/1e6, error_lower, 'b:')
    #line3, = pp.plot(bsc[:-1,0]/1e6, bsc[:-1,1], 'ro')
    #pp.legend((line1, line2, line3), ('CAM','95% CI','Shung et. al.'), 
    #    loc='upper left')
    #pp.xlabel('Frequency ($MHz$)', fontsize=12)
    #pp.ylabel(r'Backscattering Coefficient ($m^{-1}Sr^{-1}$)', fontsize=12)
    #fig1.show()
    
    # scale bsc based on mean for each frequency bin such that the root bsc will
    # has a rayleigh distribution with scale parameter = 1
    
    #pdf = np.sqrt((cam/np.mean(cam, axis=1)[:,None]).ravel()) 
    #pdf = (np.sqrt(cam)/np.sqrt(np.mean(cam, axis=1)[:,None])).ravel()
    
    bsc_normed = 2*cam/np.mean(cam, axis=1)[:,None]
    bsc_normed = bsc_normed.ravel()
    root_bsc = np.sqrt(bsc_normed)
    
    #pdf = root_bsc/(np.sqrt(2/np.pi)*np.mean(root_bsc, axis=1)[:,None])
    #pdf = pdf.ravel()
    
    #cam, bsc, root_bsc, freq[freq1:freq2], mean_cam
    
    npzvars = dict()
    #npzvars['cam_blood'] = cam
    #npzvars['bsc_blood'] = bsc
    #npzvars['root_bsc'] = root_bsc
    #npzvars['freq'] = freq[freq1:freq2]
    #npzvars['mean_cam'] = np.mean(cam, axis=1)
    npzvars['cam_heart'] = cam
    npzvars['bsc_heart'] = bsc
    #npzvars['root_bsc'] = root_bsc
    #npzvars['freq'] = freq[freq1:freq2]
    #npzvars['mean_cam'] = np.mean(cam, axis=1)
    np.savez('./data/custombsc_data.npz', **npzvars)
    
#def make_plot():
#
#    pp.rc('mathtext', fontset='stix', default='regular')
#    pp.rc('axes', linewidth = 0.6)
#
#    # spectrum plots for cam and bsc
#    fig2 = pp.figure(figsize=(3.5,2.7), dpi=100, tight_layout=True)
#    ax2 = fig2.add_subplot(111)
#    ax2.tick_params(labelsize=8)
#    #ax2.set_xscale('log')
#    ax2.set_yscale('log')
#    ax2.set_xlim(2, 12)
#    
#    c1, = pp.plot(freq[freq1:freq2]/1e6, np.mean(cam1, axis=1), 'b-')
#    #e1, = pp.plot(freq[freq1:freq2]/1e6, error_upper1,'b:')
#    #pp.plot(freq[freq1:freq2]/1e6, error_lower1, 'b:')
#    b1, = pp.plot(bsc1[:,0]/1e6, bsc1[:,1], color='#fb8072', marker='o', 
#        alpha=0.9, ls='none')
#
#    c2, = pp.plot(freq[freq1:freq2]/1e6, np.mean(cam2, axis=1), 'b-')
#    #e2, = pp.plot(freq[freq1:freq2]/1e6, error_upper2,'b:')
#    #pp.plot(freq[freq1:freq2]/1e6, error_lower2, 'b:')
#    b2, = pp.plot(bsc2[:,0]/1e6, bsc2[:,1], color='#fdb462', marker='v', 
#        alpha=0.9, ls='none')
#
#    c3, = pp.plot(freq[freq1:freq2]/1e6, np.mean(cam3, axis=1), 'b-')
#    #e3, = pp.plot(freq[freq1:freq2]/1e6, error_upper3,'b:')
#    #pp.plot(freq[freq1:freq2]/1e6, error_lower3, 'b:')
#    b3, = pp.plot(bsc3[:,0]/1e6, bsc3[:,1], color='#80b1d3', marker='s', 
#        alpha=0.9, ls='none')
#
#    #ax2.legend((c1, e1, b1, b2, b3), ('CAM','95% CI',' Blood, Shung et. al.',
#        #'Kidney, Wear et. al.','Liver, Wear et. al.'), loc='center left', 
#        #frameon=False, fontsize=10)
#    #ax2.legend((c1, b1, b2, b3), ('CAM', 'blood', 'kidney', 'liver'),
#    #    frameon=False, fontsize=9, loc='center left')
#    ax2.legend((c1, b1, b2), ('CAM', 'heart','blood'),
#        frameon=False, fontsize=9, loc='center left')
#    ax2.set_xlabel('Frequency ($MHz$)', fontsize=10)
#    #ax2.set_ylabel(r'Backscattering Coefficient ($m^{-1}Sr^{-1}$)', fontsize=10)
#    ax2.set_ylabel(r'$\eta(f) \, (m^{-1}Sr^{-1}$)', fontsize=10)
#    
#    # histogram for root bsc
#    fig3 = pp.figure(figsize=(3.5,2.7), dpi=100, tight_layout=True)
#    ax3 = fig3.add_subplot(111)
#    ax3.tick_params(labelsize=8)
#    
#    _, _, patches = ax3.hist(root_bsc, bins=30, normed=True,
#        facecolor='#fdb462')
#    
#    for p in patches:
#        p.set_linewidth(0.4)
#        p.set_edgecolor('black')
#        
#    ax3.plot(np.linspace(0, 4, 100), rayleigh.pdf(np.linspace(0, 4, 100)), 
#        'k--', linewidth=0.8)
#    
#    ax3.set_xlabel(r'$[2 \eta(f) / \bar{\eta}(f)]^{1/2}$',
#        fontsize=10) 
#    ax3.set_ylabel('Probability density', fontsize=10)
#    ax3.legend((r'Rayleigh pdf' '\n' r'$(\alpha = 1)$','CAM'), 
#        fontsize=10, frameon=False, loc='top right')
#    fig3.show()
