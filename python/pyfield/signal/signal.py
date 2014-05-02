from scipy.signal import correlate, butter, filtfilt
from scipy.fftpack import fft, ifft
import numpy as np

def ffts():
    pass
    
def iffts():
    pass

def xcorr(in1, in2, mode='full', norm=True):
    
    if norm:
        xc = correlate(in1, in2, mode)/np.sqrt(np.sum(in1**2)*np.sum(in2**2))
    else:
        xc = correlate(in1, in2, mode)
    
    return xc

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



