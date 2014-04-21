# beamformer.py

import numpy as np
import scipy as sp
from multiprocessing import Process, Queue
import h5py

def chunks(items, nitems):
    
    if nitems < 1:
        nitems = 1
    return [slice(i, i + nitems) for i in xrange(0, len(items), nitems)]
    
def distance(a, b):
    
    a = a.T
    b = b.T
    
    return np.sqrt(np.sum(b*b, 0) + np.sum(a*a,0) - 2*np.dot(a.T, b))

def work(in_queue, out_queue, txpos, rxpos, nwin, **kwargs):
    
    fs = kwargs.get('fs', 100e6)
    c = kwargs.get('c', 1500)
    resample = kwargs.get('resample', 1)
    planetx = kwargs.get('planetx', False)
    chmask = kwargs.get('chmask', False)
    t0 = kwargs.get('t0', 0)
        
    for rfdata, fieldpos in iter(in_queue, 'STOP'):
        
        npos = fieldpos.shape[0]
        nsample, nchannel, nframe = rfdata.shape
        
        if not chmask:
            chmask = np.ones(nchannel)
        
        # calculate delays
        if planetx:
            txdelay = np.abs(fieldpos[:,3])/c
        else:
            txdelay = distance(fieldpos, txpos)/c
            
        rxdelay = distance(fieldpos, txpos)/c
        sdelay = np.round((txdelay + rxdelay - t0)*fs*resample)
        
        # resample data
        if resample != 1:
            
            rfdata = sp.signal.resample(rfdata, nsample*resample)
            nsample = rfdata.shape[0]
        
        # pad data
        if nwin % 2:
            nwin += 1
        
        nwinhalf = (nwin - 1)/2
        
        #pad_width = (((nwin - 1)/2, (nwin - 1)/2), (0, 0), (0, 0))
        pad_width = ((nwin, nwin), (0, 0), (0, 0))
        rfdata = np.pad(rfdata, pad_width, mode='constant')
        
        # apply delays in loop over field points and channels
        for pos in xrange(npos):
            
            pdelay = sdelay[pos,:]
            valid_delay = pdelay <= nsample + nwinhalf or \
                -(nwinhalf + 1)
            
            if not np.any(valid_delay):
                continue
                
            #idx = [i for (i,x) in enumerate(pdelay) if x <= nsample - 1] 
            
            bfsig = np.zeros((nwin, nframe))
            
            for ch in xrange(nchannel):
                
                if not valid_delay(ch):
                    continue
                
                if not chmask(ch):
                    continue
                
                delay = pdelay[ch] + nwin + 1 - nwinhalf
                bfsig += rfdata[delay:(delay + nwin),ch,:]
        
        out_queue.put(bfsig)
    
class Beamformer():
    
    workers = []
    input_path = ''
    output_path = ''
    
    
    def __init__(self):
        pass
    
    def load_data(self, path):
        self.input_path = path
        
    def start(self, nproc=1):
        
        in_queue = Queue()
        out_queue = Queue()
        
        inroot = h5py.File(self.input_path[0], 'a')
        rfdata = inroot[self.input_path[1]]
        
        nframe = rfdata.shape[2]
        
        
        
        
    
    def join(self):
        pass
    
    def terminate(self):
        pass
        
    def write_data(self):
        pass
        
        
        
        
        
        
        
        
        
        
        
        
        
        
        
        
        
        
        
        
        
        
        
        
        
        
        