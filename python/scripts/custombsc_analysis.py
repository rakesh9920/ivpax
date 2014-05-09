# scripts / custombsc_analysis.py

from pyfield.signal import ffts, iffts
from pyfield.field import apply_bsc
from pyfield.util import align_cat

import h5py
import numpy as np
from scipy import fftpack as ft, signal as sig
from matplotlib import pyplot as pp

if __name__ == '__main__':
    
    # define paths
    file_path = './data/fieldii_bsc_experiments.hdf5'
    raw_key = 'custombsc/field/rfdata/raw2/'
    ref_key = 'custombsc/field/rfdata/raw2/ref'
    out_key = 'custombsc/field/rfdata/blood/'
    bsc_key = 'custombsc/field/bsc/shung_hmtc8'
    
    # get bsc spectrum 
    root = h5py.File(file_path, 'a')    
    bsc = root[bsc_key][:].copy()
    root.close()
    
    # apply bsc to raw rf data
    ninstance = 100
    for inst in xrange(ninstance):  
        apply_bsc((file_path, raw_key + '{:05d}'.format(inst)), 
            (file_path, out_key + '{:05d}'.format(inst)), bsc=bsc, write=True)
    
    # apply bsc to reference rf data to give unit bsc
    bsc_one = np.ones((1024,1))*20*1000**3
    bsc_one[0] = 0
    bsc_one[-1] = 0
    bsc_one = np.insert(bsc_one, 0, np.linspace(0, 100e6/2, 1024), axis=1)
    
    apply_bsc((file_path, ref_key), (file_path, out_key + 'ref'), bsc=bsc_one,
        write=True)
    
    root = h5py.File(file_path, 'a') 
    
    # get attributes from bsc-applied data
    focus = 0.02
    fs = root[out_key + '00000'].attrs['sample_frequency']
    c = root[out_key + '00000'].attrs['sound_speed']
    fc = root[out_key + '00000'].attrs['center_frequency']
    area = root[out_key + '00000'].attrs['area'] 
    
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
    gate_length = 10*c/fc
    gate_duration = gate_length*2/c
    gate = np.round((focus_time - t0 + np.array([-gate_duration/2, 
        gate_duration/2]))*fs) + 30
    
    nfft = 2**13
    f_lower = 1e6
    f_upper = 20e6
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
    
    fig1 = pp.figure()
    ax1, = pp.plot(freq[freq1:freq2], np.mean(cam, axis=1), 'b')
    ax2, = pp.plot(freq[freq1:freq2], error_upper,'b:')
    pp.plot(freq[freq1:freq2], error_lower, 'b:')
    ax3, = pp.plot(bsc[:-1,0], bsc[:-1,1], 'ro')
    pp.legend((ax1, ax2, ax3), ('CAM','95% CI','Shung et. al.'))
    pp.xlabel('Frequency ($Hz$)')
    pp.ylabel('Backscattering Coefficient ($m^{-1}Sr^{-1}$)')
    fig1.show()

    
    
    