from scipy.signal import correlate, butter, filtfilt, fftconvolve
from scipy.fftpack import fft, ifft, fftshift, ifftshift
import numpy as np

def ffts(x, *args, **kwargs):
    
    fs = kwargs.pop('fs', 1)
    return fftshift(fft(x, *args, **kwargs)/fs)

def iffts(x, *args, **kwargs):
    
    fs = kwargs.pop('fs', 1)
    return ifft(ifftshift(x), *args, **kwargs)*fs

def xcorr(in1, in2, mode='full', norm=True):
    
    in1 = in1.ravel()
    in2 = in2.ravel()
    
    size1 = in1.size
    size2 = in2.size
    
    if size1 > size2:
        in2 = np.pad(in2, (0, size1-size2), mode='constant')
    elif size2 > size1:
        in1 = np.pad(in1, (0, size2-size1), mode='constant')
    
    # note: fftconvolve is much faster than correlate
    if norm:
        #xc = correlate(in1, in2, mode)/np.sqrt(np.sum(in1**2)*np.sum(in2**2))
        xc = fftconvolve(in1, in2[::-1], mode)/np.sqrt(np.sum(in1**2)*np.sum(in2**2))
    else:
        #xc = correlate(in1, in2, mode)
        xc = fftconvolve(in1, in2[::-1], mode)
    
    return xc

def xcorr2(in1, in2, mode='full', norm=True, fs=1):
    
    xc = xcorr(in1, in2, mode=mode, norm=norm)
    nsample = xc.shape[0]
    
    lags = (np.arange(1, nsample + 1) - (nsample + 1)/2.0)/fs
    
    return xc, lags

def lowpass(in1, fh, fs, order=6, axis=-1):
    
    b, a = butter(order, fh/fs/2.0, 'lowpass', analog=False)
    
    return filtfilt(b, a, in1, axis=axis)
    
def bandpass(in1, fc, fs, order=6, axis=-1):

    b, a = butter(order, (fc[0]/fs/2.0, fc[1]/fs/2.0), 'bandpass', analog=False)
    
    return filtfilt(b, a, in1, axis=axis)

def highpass(in1, fl, fs, order=6, axis=-1):
    
    b, a = butter(order, fl/fs/2.0, 'highpass', analog=False)
    
    return filtfilt(b, a, in1, axis=axis)

def iqdemod(in1, fc, bw, fs, axis=-1):
    
    nsample = in1.shape[axis]
    
    t = np.arange(0, nsample, dtype='double') /fs
    
    mix1 = lambda x: x*np.cos(2*np.pi*fc*t)
    mix2 = lambda x: x*np.sin(2*np.pi*fc*t)
    
    mixI = np.apply_along_axis(mix1, axis, in1)
    mixQ = np.apply_along_axis(mix2, axis, in1)
    
    I = lowpass(mixI, bw/2.0, fs, axis=axis)
    Q = lowpass(mixQ, bw/2.0, fs, axis=axis)
    
    return I, Q
    
def wgn(shape, dbw=1):
    return np.random.standard_normal(shape)*np.sqrt(10**(dbw/10.0))

def deconvwnr(image, psf, nsr=0, axis=-1):
    
    H = fft(psf, image.shape[axis], axis=axis)
    I = fft(image, axis=axis)
    Sx = 1
    
    numer = np.conj(H) * Sx
    denom = np.abs(H)**2 * Sx + nsr
    denom = np.maximum(denom, np.finfo(image.dtype).eps)
    
    G = numer / denom
    
    if I.ndim > G.ndim:
        for i in xrange(I.ndim - G.ndim):
            G = G[:,None]
        
    J = np.real(ifft(G * I, axis=axis))
    
    return J

