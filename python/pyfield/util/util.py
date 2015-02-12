# pyfield / util / util.py

import numpy as np
import multiprocessing as mp
import h5py
import time
import scipy.fftpack as ft

import pyfield.signal as signal
#from multiprocessing import Value

class Progress():
    
    def __init__(self, total=None):
        self.counter = mp.Value('i', 0)
        self.total = mp.Value('i', 0)
        self.init_time = None
        self.elapsed_time = mp.Value('f', 0)
        self.fraction_done = mp.Value('f', 0)
    
    def increment(self):
        
        with self.counter.get_lock():
            self.counter.value += 1
        
        with self.fraction_done.get_lock():
            self.fraction_done.value = self.counter.value/float(self.total.value)
        
        with self.elapsed_time.get_lock():
            self.elapsed_time.value = time.time() - self.init_time
            
    def time_remaining(self):
        
        if self.fraction_done.value == 0:
            rtime = (np.inf, np.inf, np.inf, np.inf)
        else:
            rtime = self.sec_to_dhms((1/self.fraction_done.value - 1) * \
                self.elapsed_time.value)
            
        return rtime
    
    def sec_to_dhms(self, seconds):
        
        m, s = divmod(seconds, 60)
        h, m = divmod(m, 60)
        d, h = divmod(h, 24)
        
        return (d, h, m, s)
    
    def reset(self):
        self.init_time = time.time()
        self.counter.value = 0
        self.fraction_done.value = 0

def chunks(items, nitems):
    
    if nitems < 1:
        nitems = 1
    return [slice(i, i + nitems) for i in xrange(0, len(items), nitems)]

def sph2cart(points, cat=True):
    '''
    Coordinate transform from spherical to cartesian.
    '''
    if points.ndim < 2:
        points = points[None,:]
        
    x = points[:,0]*np.cos(points[:,1])*np.sin(points[:,2])
    y = points[:,0]*np.sin(points[:,1])*np.sin(points[:,2])
    z = points[:,0]*np.cos(points[:,2])
    
    if cat:
        return np.c_[x, y, z]
    else:
        return x, y, z
    
def cart2sph(points, cat=True):
    '''
    Coordinate transform from cartesian to spherical.
    '''
    # theta is azimuth angle (longitudinal)
    # phi is polar angle (colatitude)
    
    if points.ndim < 2:
        points = points[None,:]
        
    hypotxy = np.hypot(points[:,0], points[:,1])
    r = np.hypot(hypotxy, points[:,2])
    theta = np.arctan2(points[:,1], points[:,0])
    phi = np.arctan2(hypotxy, points[:,2])
    #r = np.sqrt(points[:,0]**2 + points[:,1]**2 + points[:,2]**2)
    #phi = np.arccos(points[:,2]/r)
    
    if cat:
        return np.c_[r, theta, phi]
    else:
        return r, theta, phi
        
def distance(a, b):
    
    a = a.T
    b = b.T
    
    return np.sqrt(np.sum(b*b, 0)[None,:] + np.sum(a*a, 0)[:,None] - \
        2*np.dot(a.T, b))
        
def nextpow2(n):
    return np.ceil(np.log2(n)).astype(int)
    
def quickfft(x, fs=1, n=None, dbscale=True, one_sided=True):
    
    if n is None:
        n = 2**nextpow2(x.size)
    
    amp = np.abs(signal.ffts(x, n, fs=fs))
    freq = ft.fftshift(ft.fftfreq(n, 1/fs))
    
    if dbscale:
        amp = 20*np.log10(amp/np.max(amp))
    
    if one_sided:
        amp = amp[n/2+1:]
        freq = freq[n/2+1:]
    
    return freq, amp
           
def align_and_sum(array1, t1, array2, t2, fs):
    
    s1 = round(t1*fs)
    s2 = round(t2*fs)
    
    if s2 > s1:
        fpad1, fpad2 = 0, s2 - s1             
    elif s2 < s1:
        fpad1, fpad2 = s1 - s2, 0
    else:
        fpad1, fpad2 = 0, 0
    
    nsample1 = array1.shape[0] + fpad1
    nsample2 = array2.shape[0] + fpad2
    
    if nsample1 > nsample2:
        bpad1, bpad2 = 0, nsample1 - nsample2
    elif nsample1 < nsample2:
        bpad1, bpad2 = nsample2 - nsample1, 0
    else:
        bpad1, bpad2 = 0, 0
    
    pad_width1 = [(fpad1, bpad1)] + [(0,0) for x in range(array1.ndim - 1)]
    pad_width2 = [(fpad2, bpad2)] + [(0,0) for x in range(array2.ndim - 1)]
    sum_array = np.pad(array1, pad_width1, mode='constant') + \
        np.pad(array2, pad_width2, mode='constant') 
    
    return sum_array, min(t1, t2)

def align_cat(array0, t0, array1, t1, fs, taxis=0, axis=-1):
    
    dims0 = array0.shape
    dims1 = array1.shape
    
    # determine frontpad for dim 0 (time sample)
    s0 = round(t0*fs)
    s1 = round(t1*fs)
    
    if s0 > s1:
        fpad1, fpad0 = 0, s0 - s1             
    elif s0 < s1:
        fpad1, fpad0 = s1 - s0, 0
    else:
        fpad1, fpad0 = 0, 0
    
    # determine backpad for dim 0 (time sample)
    nsample0 = dims0[taxis] + fpad0    
    nsample1 = dims1[taxis] + fpad1

    if nsample1 > nsample0:
        bpad1, bpad0 = 0, nsample1 - nsample0
    elif nsample1 < nsample0:
        bpad1, bpad0 = nsample0 - nsample1, 0
    else:
        bpad1, bpad0 = 0, 0
    
    pad_width0 = [(fpad0, bpad0)] + [(0,0) for x in xrange(len(dims0) - 1)]
    pad_width1 = [(fpad1, bpad1)] + [(0,0) for x in xrange(len(dims0) - 1)]

    new_array = np.concatenate((np.pad(array0, pad_width0, mode='constant'), 
        np.pad(array1, pad_width1, mode='constant')), axis=axis)
    
    return new_array, min(t0, t1)

def h5_tree(root, dsets=True):
    
    def print_attrs(name, obj):
        
        if dsets:
            print name
        else:
            if not isinstance(obj, h5py._hl.dataset.Dataset):
                print name
                
    root.visititems(print_attrs)

class cyl_mgrid_class:
    
    def __getitem__(self, key):
    
        x, y, z = np.mgrid[key]
        
        r = np.sqrt(x**2 + y**2)
        mask = r <= max(key[0].stop, key[1].stop)
        
        return x[mask], y[mask], z[mask]

cyl_mgrid = cyl_mgrid_class()

def read_daq(path, frame=None, channels=None):
    
    if channels is None:
        channels = np.arange(128)
    
    channel_route = np.array([0, 16, 32, 48, 64, 80, 96, 112, 1, 17, 33, 49, 65,
        81, 97, 113, 2, 18, 34, 50, 66, 82, 98, 114, 3, 19, 35, 51, 67, 83, 99,
        115, 4, 20, 36, 52, 68, 84, 100, 116, 5, 21, 37, 53, 69, 85, 101, 117, 
        6, 22, 38, 54, 70, 86, 102, 118, 7, 23, 39, 55, 71, 87, 103, 119, 8, 24,
        40, 56, 72, 88, 104, 120, 9, 25, 41, 57, 73, 89, 105, 121, 10, 26, 42,
        58, 74, 90, 106, 122, 11, 27, 43, 59, 75, 91, 107, 123, 12, 28, 44, 60,
        76, 92, 108, 124, 13, 29, 45, 61, 77, 93, 109, 125, 14, 30, 46, 62, 78,
        94, 110, 126, 15, 31, 47, 63, 79, 95, 111, 127])
    
    nchannel = channels.size
    
    for idx, ch in enumerate(channels):
        
        if ch < 10:
            filename = path + 'CH' + '00' + str(ch) + '.daq'
        elif ch < 100:
            filename = path + 'CH' + '0' + str(ch)  + '.daq'
        else:
            filename = path + 'CH' + str(ch)  + '.daq'
        
        if idx == 0:
            
            header = np.fromfile(filename, dtype='int32', count=3)
            _, nframe, nsample = header
            
            if frame is None:
                rfdata = np.zeros((nsample, nchannel, nframe), dtype='int16')
            else:
                rfdata = np.zeros((nsample, nchannel), dtype='int16')
        
        with open(filename, 'rb') as f:
        
            f.seek(12) # skips over header
            ch_idx = channel_route[ch]
            
            if frame is None:

                rfdata[:, ch_idx, :] = np.fromfile(f, dtype='int16', 
                    count=-1).reshape((nsample, nframe))
            else:
                
                f.seek(nsample*2*frame, 1)
                rfdata[:, ch_idx] = np.fromfile(f, dtype='int16', 
                    count=nsample)
    
    return rfdata, header

def daq2h5(path, h5file, h5key, channels=None, overwrite=False):
    '''
    '''
    rfdata, header = read_daq(path, frame=0, channels=channels)
    _, nframe, nsample = header
    nchannel = rfdata.shape[1]
    
    with h5py.File(h5file, 'a') as root:
             
        if h5key in root and overwrite:
            del root[h5key]

        root.create_dataset(h5key, shape=(nsample, nchannel, nframe), 
            dtype='int16')
        
        root[h5key][:,:,0] = rfdata
        
        for fr in xrange(1, nframe):
            
            rfdata, _ = read_daq(path, frame=fr, channels=channels)
            root[h5key][:,:,fr] = rfdata
        
        
def daq_to_h5(path, h5file, h5key, channels=None, overwrite=False):
    '''
    '''
    if channels is None:
        channels = np.arange(128)
    
    channel_route = np.array([0, 16, 32, 48, 64, 80, 96, 112, 1, 17, 33, 49, 65,
        81, 97, 113, 2, 18, 34, 50, 66, 82, 98, 114, 3, 19, 35, 51, 67, 83, 99,
        115, 4, 20, 36, 52, 68, 84, 100, 116, 5, 21, 37, 53, 69, 85, 101, 117, 
        6, 22, 38, 54, 70, 86, 102, 118, 7, 23, 39, 55, 71, 87, 103, 119, 8, 24,
        40, 56, 72, 88, 104, 120, 9, 25, 41, 57, 73, 89, 105, 121, 10, 26, 42,
        58, 74, 90, 106, 122, 11, 27, 43, 59, 75, 91, 107, 123, 12, 28, 44, 60,
        76, 92, 108, 124, 13, 29, 45, 61, 77, 93, 109, 125, 14, 30, 46, 62, 78,
        94, 110, 126, 15, 31, 47, 63, 79, 95, 111, 127])
        
    rfdata, header = read_daq(path, frame=0, channels=channels)
    _, nframe, nsample = header
    nchannel = channels.size
    
    with h5py.File(h5file, 'a') as root:
             
        if h5key in root and overwrite:
            del root[h5key]

        root.create_dataset(h5key, shape=(nsample, nchannel, nframe), 
            dtype='double', compression='gzip')
    
        for idx, ch in enumerate(channels):
            
            if ch < 10:
                filename = path + 'CH' + '00' + str(ch) + '.daq'
            elif ch < 100:
                filename = path + 'CH' + '0' + str(ch)  + '.daq'
            else:
                filename = path + 'CH' + str(ch)  + '.daq'
            
            with open(filename, 'rb') as f:
            
                f.seek(12) # skips over header
                ch_idx = channel_route[ch]
            
                root[h5key][:, ch_idx, :] = np.fromfile(f, dtype='int16', 
                    count=-1).reshape((nsample, nframe), order='F')
                
                root.flush()

    
    
    