# beamformer.py

import numpy as np
import scipy as sp
from multiprocessing import Process, Queue
import h5py
from pyfield.util import chunks, distance, Progress

def delegate(in_queue, out_queue, input_path, view_path, output_path,
    nproc, frames, options, progress):
    
    try:
        
        maxpointsperchunk = options['maxpointsperchunk']
        maxframesperchunk = options['maxframesperchunk']
        nwin = options['nwin']
        overwrite = options['overwrite']
        
        input_file = input_path[0]
        input_key = input_path[1]
        view_file = view_path[0]
        view_key = view_path[1]
        output_file = output_path[0]
        output_key = output_path[1]

        # open input file and get rf data
        input_root = h5py.File(input_file, 'a')
        rfdata = input_root[input_key]
        
        if frames is None:          
            
            if len(rfdata.shape) == 3:
                nframe = rfdata.shape[2]
            else:
                nframe = 1
            
            start_frame = 0      
            
        elif isinstance(frames, tuple):
            
            nframe = min(frames[1] - frames[0], rfdata.shape[2])
            start_frame = frames[0]
            
        else:
            
            nframe = 1
            start_frame = frames
        
        # open view file and get field positions
        if view_file == input_file:
            view_root = input_root
        else:
            view_root = h5py.File(view_file, 'a')
        
        fieldpos = view_root[view_key]
        npos = fieldpos.shape[0]
        
        # open output file and create dataset 
        if output_file == input_file:
            output_root = input_root
        elif output_file == view_file:
            output_root = view_root
        else:
            output_root = h5py.File(output_file, 'a')
        
        if output_key not in output_root:
            
            bfdata = output_root.create_dataset(output_key, dtype='double',
                shape=(npos, nwin, nframe), compression='gzip')   
                
        else:
            
            if overwrite: 
                
                del output_root[output_key]
                bfdata = output_root.create_dataset(output_key, dtype='double',
                    shape=(npos, nwin, nframe), compression='gzip')
            
            bfdata = output_root[output_key]
        
        framesperchunk = min(nframe, maxframesperchunk)
        pointsperchunk = min(np.ceil(float(npos)/nproc).astype(int), 
            maxpointsperchunk)
        
        progress.total.value = int(np.ceil(float(nframe)/framesperchunk) * 
            np.ceil(float(npos)/pointsperchunk))
        progress.reset()
        
        # divide rf data into groups of frames for processing
        for frame_idx in iter(chunks(range(nframe), framesperchunk)):
            
            adjusted_idx = slice(start_frame + frame_idx.start, 
                start_frame + frame_idx.stop)
            
            rf = rfdata[:,:,adjusted_idx]
            nchunk = 0

            # divide field positions into chunks and send to workers
            for pos_idx in iter(chunks(range(npos), pointsperchunk)):
                
                pos = fieldpos[pos_idx,:]
                in_queue.put((rf, frame_idx, pos, pos_idx))
                nchunk += 1
            
            # write bf data for each chunk to file
            for x in xrange(nchunk):
                
                item = out_queue.get()
                if isinstance(item, Exception):
                    raise item
                    
                bf, frame_idx, pos_idx = item
                bfdata[pos_idx,:,frame_idx] = bf
                
                progress.increment()
        
        for w in xrange(nproc):
            in_queue.put('STOP')
        
        # write data attributes for beamformed data
        for key, val in input_root[input_key].attrs.iteritems():
            bfdata.attrs.create(key, val)
        
        bfdata.attrs.create('resample', options['resample'])
        bfdata.attrs.create('plane_transmit', options['planetx'])
        bfdata.attrs.create('channel_mask', options['chmask'])
        
        #bfdata.dims[0].label = 'position_no'
        #bfdata.dims[1].label = 'sample_no'
        #bfdata.dims[2].label = 'frame_no'
        
    except Exception as e:
        
        out_queue.put(e)
        
    finally:
        
        input_root.close()
        
        if view_file != input_file:
            view_root.close()
            
        if output_file != view_file or output_file != input_file:
            output_root.close()
    
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
    apod = attrs.get('apodization')
    useapod = attrs.get('useapodization')
    
    #if useapod:
        #maxapod = np.floor(apod.shape[0]/2) + 1
        
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
                if txpos.ndim == 1:
                    txpos = txpos[None,:]
                txdelay = distance(fieldpos, txpos)/c
            
            rxdelay = distance(fieldpos, rxpos)/c
            sdelay = np.round((txdelay + rxdelay - t0)*fs*resample).astype(int)
            
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
            
            bfdata = np.zeros((npos, nwin, nframe))
            
            # apply delays in loop over field points and channels
            for pos in xrange(npos):
                
                pdelay = sdelay[pos,:]
                valid_delay = (pdelay <= (nsample + nwinhalf)) & \
                    (pdelay >= -(nwinhalf + 1))
                
                if not np.any(valid_delay):
                    continue
                
                bfsig = np.zeros((nwin, nframe))
                
                #center_ch = np.argmin(fieldpos[pos,0] - rxpos[:,0])
                
                for ch in xrange(nchannel):
                    
                    if not valid_delay[ch]:
                        continue
                    
                    if not chmask[ch]:
                        continue
                    
                    delay = pdelay[ch] + nwin - nwinhalf
                    
                    if useapod:
                        bfsig += apod[ch]*rfdata[delay:(delay + nwin),ch,:]
                    else:
                        bfsig += rfdata[delay:(delay + nwin),ch,:]
                
                bfdata[pos,:,:] = bfsig
            
            out_queue.put((bfdata, frame_idx, pos_idx))
        
        except Exception as e:
            
            out_queue.put(e)
    
class Beamformer():
    
    def __init__(self):
    
        self.progress = Progress()
        self.workers = []
        self.delegator = []
        self.input_path = ('', '')
        self.output_path = ('', '')
        self.view_path = ('', '')
        self.options = dict()
        self.set_options()
    
    def __str__(self):
        string = []
        string.append(repr(self) + '\n')
        
        rem_time = self.progress.time_remaining()
        string.append('\nPROGRESS:\n')
        string.append('percent done: {0:.0f}%\n'. \
            format(self.progress.fraction_done.value*100))
        string.append(('time remaining: {0:.0f}d {1:.0f}h {2:.0f}m {3:.0f}s\n')\
            .format(*rem_time))
        
        string.append('\nOPTIONS:\n')
        for k, v in self.options.iteritems():
            string.append('{0}: {1}\n'.format(k, v))
            
        string.append('\nDATA PATHS: \n')
        string.append('input data in {0} at {1}\n'.format(self.input_path[0], 
            self.input_path[1]))
        string.append('view data in {0} at {1}\n'.format(self.view_path[0], 
            self.view_path[1]))
        string.append('output data in {0} at {1}\n'.format(self.output_path[0], 
            self.output_path[1]))
        
        string.append('\nWORKERS: \n')
        for w in self.workers:
            string.append(repr(w) + '\n')
        
        string.append('\nDELEGATOR: \n')
        for d in self.delegator:
            string.append(repr(d) + '\n')
        
        return ''.join(string)
        
    def set_options(self, **kwargs):
        
        self.options['nwin'] = kwargs.get('nwin')
        self.options['resample'] = kwargs.get('resample', 1)
        self.options['planetx'] = kwargs.get('planetx', False)
        self.options['chmask'] = kwargs.get('chmask', False)
        self.options['maxframesperchunk'] = kwargs.get('maxframesperchunk', 
            1000)
        self.options['maxpointsperchunk'] = kwargs.get('maxpointsperchunk',
            10000)
        self.options['overwrite'] = kwargs.get('overwrite', False)
        self.options['useapodization'] = kwargs.get('useapodization', False)
        self.options['apodization'] = kwargs.get('apodization', None)
        
    def start(self, nproc=1, frames=None):
        
        self.reset()
        
        # open input file and get needed attributes
        input_root = h5py.File(self.input_path[0], 'a')
        rfdata = input_root[self.input_path[1]]
        
        attrs = {'c': rfdata.attrs.get('sound_speed'),
                 'fs': rfdata.attrs.get('sample_frequency'),
                 't0': rfdata.attrs.get('start_time'),
                 'txpos': rfdata.attrs.get('tx_positions'),
                 'rxpos': rfdata.attrs.get('rx_positions')}
                    
        attrs.update(self.options)
        
        input_root.close()
        
        in_queue = Queue()
        out_queue = Queue()
        
        # start worker processes
        for x in range(nproc):
            w = Process(target=work, args=(in_queue, out_queue, attrs))
            w.start()
            self.workers.append(w)
        
        # start delegator process
        delegator = Process(target=delegate, args=(in_queue, out_queue, 
            self.input_path, self.view_path, self.output_path, nproc, frames,
            self.options, self.progress))     
        delegator.start() 
        self.delegator.append(delegator)
        
        self.in_queue = in_queue
        self.out_queue = out_queue
         
    def join(self, timeout=None):
        
        for w in self.workers:
            w.join(timeout)
        
        for d in self.delegator:
            d.join(timeout)
    
    def terminate(self):
        
        for w in self.workers:
            w.terminate()
        
        for d in self.delegator:
            d.terminate()
        
        self.join()
    
    def reset(self):
        
        self.workers = []
        self.delegator = []
        
class View():
    
    def __init__():
        pass
    
    
def time_beamform(rfdata, fieldpos, **kwargs):
    
    # get data attribtues and beamforming options
    txpos = kwargs['txpos']
    rxpos = kwargs['rxpos']
    nwin = kwargs['nwin']
    fs = kwargs['fs']
    c = kwargs['c']
    resample = kwargs['resample']
    planetx = kwargs['planetx']
    chmask = kwargs['chmask']
    t0 = kwargs['t0']
    apod = kwargs['apodization']
    useapod = kwargs['useapodization']
        
    npos = fieldpos.shape[0]
    
    if rfdata.ndim == 3:
        nsample, nchannel, nframe = rfdata.shape
    elif rfdata.ndim == 2:
        nsample, nchannel = rfdata.shape
    
    if chmask is False:
        chmask = np.ones(nchannel)
    
    # calculate delays
    if planetx:
        txdelay = np.abs(fieldpos[:,2,None])/c
    else:
        if txpos.ndim == 1:
            txpos = txpos[None,:]
        txdelay = distance(fieldpos, txpos)/c
    
    rxdelay = distance(fieldpos, rxpos)/c
    sdelay = np.round((txdelay + rxdelay - t0)*fs*resample).astype(int)
    
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
    
    bfdata = np.zeros((npos, nwin, nframe))
    
    # apply delays in loop over field points and channels
    for pos in xrange(npos):
        
        pdelay = sdelay[pos,:]
        valid_delay = (pdelay <= (nsample + nwinhalf)) & \
            (pdelay >= -(nwinhalf + 1))
        
        if not np.any(valid_delay):
            continue
        
        bfsig = np.zeros((nwin, nframe))
        
        #center_ch = np.argmin(fieldpos[pos,0] - rxpos[:,0])
        
        for ch in xrange(nchannel):
            
            if not valid_delay[ch]:
                continue
            
            if not chmask[ch]:
                continue
            
            delay = pdelay[ch] + nwin - nwinhalf
            
            if useapod:
                bfsig += apod[ch]*rfdata[delay:(delay + nwin),ch,:]
            else:
                bfsig += rfdata[delay:(delay + nwin),ch,:]
        
        bfdata[pos,:,:] = bfsig
    
    return bfdata
        
        
        
        
        
        
        
        
        
        
        
        
        
        
        
        
        
        
        
        
        
        
        
        