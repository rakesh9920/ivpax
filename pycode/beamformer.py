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
    
    return np.sqrt(np.sum(b*b, 0)[None,:] + np.sum(a*a, 0)[:,None] - \
        2*np.dot(a.T, b))

def delegate(in_queue, out_queue, input_path, view_path, output_path,
    maxpointsperchunk, maxframespergroup, nwin, nproc, write):
    
    try:
        
        infile = input_path[0]
        inkey = input_path[1]
        viewfile = view_path[0]
        viewkey = view_path[1]
        outfile = output_path[0]
        outkey = output_path[1]
        
        # open input file and get rf data
        inroot = h5py.File(infile, 'a')
        rfdata = inroot[inkey]
        nframe = rfdata.shape[2]
        
        # open view file and get field positions
        if viewfile == infile:
            viewroot = inroot
        else:
            viewroot = h5py.File(viewfile, 'a')
        
        fieldpos = viewroot[viewkey]
        npos = fieldpos.shape[0]
        
        # open output file and create dataset 
        # check if output file is already open
        if outfile == infile:
            outroot = inroot
        elif outfile == viewfile:
            outroot = viewroot
        else:
            outroot = h5py.File(outfile, 'a')
        
        if outkey not in outroot:
    
            outdata = outroot.create_dataset(outkey, dtype='double',
                shape=(npos, nwin, nframe), compression='gzip')
        else:
            
            if write: 
                del outroot[outkey]
                
            outdata = outroot[outkey]
    
        framespergroup = min(nframe, maxframespergroup)
        #nchunk = np.ceil(nframe/maxframespergroup)
        pointsperchunk = min(np.floor(npos/nproc).astype(int), maxpointsperchunk)
        
        # divide rf data into groups of frames for processing
        for group in iter(chunks(range(nframe), framespergroup)):
            
            rfgroup = rfdata[:,:,group]
            
            nchunk = 0
            
            # divide field positions into chunks for processing
            for chunk in iter(chunks(range(npos), pointsperchunk)):
                
                poschunk = fieldpos[chunk,:]
                in_queue.put((rfgroup, group, poschunk, chunk))
                nchunk += 1
            
            #for x in xrange(nchunk):
            #    
            #    item = out_queue.get()
            #    if isinstance(item, Exception):
            #        raise item
            #        
            #    bfdata, frame_idx, pos_idx = item
            #    outdata[pos_idx,:,frame_idx] = bfdata
        
        for w in xrange(nproc):
            in_queue.put('STOP')
        
        inroot.close()
        
        if viewfile != infile:
            viewroot.close()
            
        if outfile != viewfile or outfile != infile:
            outroot.close()
    
    except Exception as e:
        out_queue.put(e)
    

def work(in_queue, out_queue, attrs):
    
    # get data attribtues and beamforming options
    txpos = attrs.get('txpos')
    rxpos = attrs.get('rxpos')
    nwin = attrs.get('nwin')
    fs = attrs.get('fs')
    c = attrs.get('c')
    resample = attrs.get('resample')
    planetx = attrs.get('planetx')
    chmask = attrs.get('chmask')
    t0 = attrs.get('t0')
    
    # read rf data and field positions from input queue
    for rfdata, frame_idx, fieldpos, pos_idx in iter(in_queue.get, 'STOP'):

        try:
            
            npos = fieldpos.shape[0]
            nsample, nchannel, nframe = rfdata.shape
            
            if chmask is False:
                chmask = np.ones(nchannel)
            
            # calculate delays
            if planetx:
                txdelay = np.abs(fieldpos[:,2,None])/c
            else:
                txdelay = distance(fieldpos, txpos)/c
            
            rxdelay = distance(fieldpos, rxpos)/c
            sdelay = np.round((txdelay + rxdelay - t0)*fs*resample)
            
            # resample data
            if resample != 1:
                
                rfdata = sp.signal.resample(rfdata, nsample*resample)
                nsample = rfdata.shape[0]
            
            # pad data
            if not nwin % 2:
                nwin += 1
            
            nwinhalf = (nwin - 1)/2
            pad_width = ((nwin, nwin), (0, 0), (0, 0))
            rfdata = np.pad(rfdata, pad_width, mode='constant')
            
            bfdata = np.zeros((nwin, nframe, npos))
            
            # apply delays in loop over field points and channels
            for pos in xrange(npos):
                
                pdelay = sdelay[pos,:]
                valid_delay = (pdelay <= (nsample + nwinhalf)) & \
                    (pdelay >= -(nwinhalf + 1))
                
                if not np.any(valid_delay):
                    continue
                
                bfsig = np.zeros((nwin, nframe))
                
                for ch in xrange(nchannel):
                    
                    if not valid_delay[ch]:
                        continue
                    
                    if not chmask[ch]:
                        continue
                    
                    delay = pdelay[ch] + nwin + 1 - nwinhalf
        
                    bfsig += rfdata[delay:(delay + nwin),ch,:]
                
                bfdata[:,:,pos] = bfsig
            
            out_queue.put((bfdata, frame_idx, pos_idx))
        
        except Exception as e:
            
            out_queue.put(e)
    
class Beamformer():
    
    workers = []
    delegator = None
    input_path = ''
    output_path = ''
    view_path = ''
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
        
    def start(self, nproc=1, maxframespergroup=1000, maxpointsperchunk=1000,
        write=False):
        
        inroot = h5py.File(self.input_path[0], 'a')
        rfdata = inroot[self.input_path[1]]
        
        attrs = {'c': rfdata.attrs.get('sound_speed'),
                 'fs': rfdata.attrs.get('sample_frequency'),
                 't0': rfdata.attrs.get('start_time'),
                 'txpos': rfdata.attrs.get('tx_positions'),
                 'rxpos': rfdata.attrs.get('rx_positions')}
                    
        attrs.update(self.options)
        
        inroot.close()
        
        in_queue = Queue()
        out_queue = Queue()
        
        for x in range(nproc):
            w = Process(target=work, args=(in_queue, out_queue, attrs))
            w.start()
            self.workers.append(w)
            
        self.delegator = Process(target=delegate, args=(in_queue, out_queue, 
            self.input_path, self.view_path, self.output_path, 
            maxpointsperchunk, maxframespergroup, self.options['nwin'], 
            nproc, write))     
        self.delegator.start() 
        
        self.in_queue = in_queue
        self.out_queue = out_queue
        
    def join(self):
        
        for w in self.workers:
            w.join()
        
        self.delegator.join()
    
    def terminate(self):
        
        for w in self.workers:
            w.terminate()
        
        self.delegator.terminate()
        
class View():
    
    def __init__():
        pass
    
    
        
        
        
        
        
        
        
        
        
        
        
        
        
        
        
        
        
        
        
        
        
        
        
        
        