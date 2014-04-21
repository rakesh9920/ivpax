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

def delegate(in_queue, out_queue, input_path, output_path, maxframesperchunk):
    
    inroot = h5py.File(input_path[0], 'a')
    rfdata = inroot[input_path[1]]
    
    nframe = rfdata.shape[2]
    

def work(in_queue, out_queue, attrs):
    
    txpos = attrs.get('txpos')
    rxpos = attrs.get('rxpos')
    nwin = attrs.get('nwin')
    fs = attrs.get('fs')
    c = attrs.get('c')
    resample = attrs.get('resample')
    planetx = attrs.get('planetx')
    chmask = attrs.get('chmask')
    t0 = attrs.get('t0', 0)
        
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
            
        rxdelay = distance(fieldpos, rxpos)/c
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
    delegator = None
    input_path = ''
    output_path = ''
    options = dict.fromkeys(['nwin','resample', 'planetx', 'chmask'])
    
    def __init__(self):
        pass
    
    def load_data(self, path):
        self.input_path = path
    
    def set_options(self, **kwargs):
        
        self.options['nwin'] = kwargs.get('nwin')
        self.options['resample'] = kwargs.get('resample')
        self.options['planetx'] = kwargs.get('planetx')
        self.options['chmask'] = kwargs.get('chmask')
        
    def start(self, nproc=1, maxframesperchunk=1000):
        
        in_queue = Queue()
        out_queue = Queue()
        
        inroot = h5py.File(self.input_path[0], 'a')
        rfdata = inroot[self.input_path[1]]
        
        attrs = {'c': rfdata.attrs.get('sound_speed'),
                 'fs': rfdata.attrs.get('sample_frequency'),
                 't0': rfdata.attrs.get('start_time'),
                 'txpos': rfdata.attrs.get('transmit_positions'),
                 'rxpos': rfdata.attrs.get('receive_positions')}
                    
        attrs.update(self.options)
        
        inroot.close()
        
        for x in range(nproc):
            w = Process(target=work, args=(in_queue, out_queue, attrs))
            self.workers.append(w)
            
        self.delegator = Process(target=delegate, args=(in_queue, out_queue, 
            self.input_path, self.output_path, maxframesperchunk))      
        

    
    def join(self):
        pass
    
    def terminate(self):
        pass
        
    def write_data(self):
        pass
        
        
        
        
        
        
        
        
        
        
        
        
        
        
        
        
        
        
        
        
        
        
        
        
        
        
        