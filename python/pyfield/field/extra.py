# pyfield / extra.py

from pyfield.signal import wgn
from scipy import signal as sig
from scipy import fftpack as ft
import numpy as np
import h5py

def ffts(x, *args, **kwargs):
    
    fs = kwargs.pop('fs', 1)
    return ft.fftshift(ft.fft(x, *args, **kwargs)*fs)

def iffts(x, *args, **kwargs):
    
    fs = kwargs.pop('fs', 1)
    return ft.ifft(ft.ifftshift(x), *args, **kwargs)/fs

def bsc_to_filt(bsc, c=None, rho=None, area=None, ns=None, fs=None):
    
    filt_fft = 2*np.pi/(rho*c*area*np.sqrt(ns))*np.sqrt(np.abs(bsc.ravel()))
    filt = np.gradient(np.real(ft.ifftshift(iffts(filt_fft, fs=fs))), 1/fs)

    return filt

def bsc_to_fir(bsc, c=None, rho=None, area=None, ns=None, fs=None, deriv=True,
    ntap=100):
    
    bsc = bsc.reshape((-1, 2))
    
    freq_resp = 2*np.pi/(rho*c*area*np.sqrt(ns))*np.sqrt(np.abs(bsc[:,1]))

    imp_resp = sig.firwin2(ntap, bsc[:,0], freq_resp, nyq=fs/2.0, 
        antisymmetric=False, window='hamming')/fs
    
    if deriv:
        return np.gradient(imp_resp, 1/fs)
    else:
        return imp_resp
        
def apply_bsc(inpath, outpath, bsc=None, write=False, loop=False):
    
    inroot = h5py.File(inpath[0], 'a')
    indata = inroot[inpath[1]]
    
    if outpath[0] != inpath[0]:
        outroot = h5py.File(outpath[0], 'a')
    else:
        outroot = inroot
    
    if write:
        
        if outpath[1] in outroot:
            del outroot[outpath[1]]
            
        outdata = outroot.create_dataset(outpath[1], shape=indata.shape, 
            dtype='double', compression='gzip')
            
    else:
        outdata = outroot[outpath]
    
    if bsc is None:
        bsc = indata.attrs.get('bsc_spectrum')
    
    keys = ['c', 'rho', 'area', 'ns', 'fs']
    attrs = ['sound_speed', 'density', 'area', 'target_density', 
        'sample_frequency']
    params = {k : indata.attrs.get(a) for k,a in zip(keys, attrs)}
    
    #filt = bsc_to_filt(bsc, **params)
    filt = bsc_to_fir(bsc, **params)
    
    fs = params['fs']
    
    if loop:
        for f in xrange(indata.shape[2]):
            for c in xrange(indata.shape[1]):
                outdata[:,c,f] = sig.fftconvolve(indata[:,c,f], filt, 'same')/fs
                #outdata[:,c,f] = sig.filtfilt(filt, 1, indata[:,c,f])
    else:
        outdata[:] = np.apply_along_axis(sig.fftconvolve, 0, indata[:], 
            filt, 'same')/fs
        #outdata[:] = sig.filtfilt(filt, 1, indata[:], axis=0)
    
    for key, val in indata.attrs.iteritems():
        outdata.attrs.create(key, val)
      
def apply_wgn(inpath, outpath, dbw=1, write=False, loop=False):
    
    inroot = h5py.File(inpath[0], 'a')
    indata = inroot[inpath[1]]
    
    if outpath[0] != inpath[0]:
        outroot = h5py.File(outpath[0], 'a')
    else:
        outroot = inroot
    
    if write:
        if outpath[1] in outroot:
            del outroot[outpath[1]]
        
        outdata = outroot.create_dataset(outpath[1], shape=indata.shape, 
            dtype='double', compression='gzip')
    
    else:
        outdata = outroot[outpath]
    
    if loop:
        
        for f in xrange(indata.shape[2]):
            outdata[:,:,f] = indata[:,:,f] + wgn(indata.shape[0:2], dbw)
            
    else:
        outdata[:] = indata[:] + wgn(indata.shape, dbw)
    
def xdc_draw():
    pass




