# pyfield / simulation.py

from multiprocessing import Process, Queue, current_process
import numpy as np
import h5py
from pyfield import Field
import common as cm

def work(in_queue, out_queue, script):
    
    try:
       
        def_script = __import__(script)
        
        f2 = Field()
        f2.field_init(-1, current_process().name + '_log.txt')
        #f2.field_init(-1) # must have diary output for worker to join properly 
        # for some strange reason
        (tx_aperture, rx_aperture) = def_script.get_apertures(f2)
        
        for data in iter(in_queue.get, 'STOP'):
            
            points = data[:,0:3]
            amp = data[:,3]
            
            (scat, t0) = f2.calc_scat_multi(tx_aperture, rx_aperture, 
                points, amp)
                
            out_queue.put((scat, t0))
        
        f2.xdc_free(tx_aperture)
        if not rx_aperture == tx_aperture:
            f2.xdc_free(rx_aperture)
        f2.field_end()
     
    except Exception as e:
        
        out_queue.put(e)
        #out_queue.put("failed on %s with: %s" % (current_process().name,
        #    e.message))

def align_write(dataset, array1, t1, frame):
    
    fs = dataset.attrs.get('sample_frequency')
    t0 = dataset.attrs.get('start_time')
    dims0 = dataset.shape
    
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
    nsample0 = dims0[0] + fpad0    
    nsample1 = array1.shape[0] + fpad1

    if nsample1 > nsample0:
        bpad1, bpad0 = 0, nsample1 - nsample0
    elif nsample1 < nsample0:
        bpad1, bpad0 = nsample0 - nsample1, 0
    else:
        bpad1, bpad0 = 0, 0
    
    # determine depth backpad for dim 2 (frame no)
    dpad0 = frame + 1 - dims0[2]
    if dpad0 < 0: dpad0 = 0
    
    # resize dataset if necessary
    dataset.resize(dataset.shape[0] + fpad0 + bpad0, axis=0)
    dataset.resize(dataset.shape[2] + dpad0, axis=2)
    
    pad_width0 = [(fpad0, bpad0), (0, 0), (0, dpad0)]
    pad_width1 = [(fpad1, bpad1), (0, 0)]

    dataset[:] = np.pad(dataset[0:dims0[0],:,0:dims0[2]], pad_width0, 
        mode='constant')
    
    dataset[:,:,frame] = np.pad(array1, pad_width1, mode='constant')
    dataset.attrs.create('start_time', min(t0, t1))
    
def collect(out_queue, res_queue, fs):
    
    try:
        
        item = out_queue.get()
        
        if isinstance(item, Exception):
            raise item
        
        (scat_t, t0_t) = item
        
        for item in iter(out_queue.get, 'STOP'):
            
            if isinstance(item, Exception):
                raise item
            
            (scat, t0) = item
            
            (scat_t, t0_t) = cm.align_and_sum(scat_t, t0_t, scat, t0, fs)
            
        res_queue.put((scat_t, t0_t))
    
    except Exception as e:
        
        res_queue.put(e)
                  
class Simulation():
    
    def __init__(self, script=None):
        self.workers = []
        self.collector = []
        self.script = script
        self.result = None
    
    def reset(self):
        self.workers = []
        self.collector = []
    
    def start(self, nproc=1, maxtargetsperchunk=5000, frame=None):
            
        # check that script and dataset are defined
        if self.script is None:
            raise Exception('Simulation script not set')
        
        self.reset()
        in_queue = Queue() # queue that sends data to workers
        out_queue = Queue() # queue that sends data to collector
        res_queue = Queue() # queue that sends data to main process
        
        # open input file and read dataset
        root = h5py.File(self.input_path[0], 'r')
        targets = root[self.input_path[1]]
        
        # get metadata from dataset
        target_prms = dict()
        for key, val in targets.attrs.iteritems():
            target_prms[key] = val
        
        # get field ii parameters
        def_script = __import__(self.script)
        field_prms = def_script.get_prms()
        
        ntargets = targets.shape[0]
        
        if frame is None:
            frame = 0
            self.frame_no = 0
        else:
            self.frame_no = frame
            
        if len(targets.shape) < 3:
            frame = Ellipsis
        
        targets_per_chunk = min(np.floor(ntargets/nproc).astype(int), 
            maxtargetsperchunk)
            
        try: 
            
            # start collector process
            collector = Process(target=collect, args=(out_queue, res_queue, 
                field_prms['sample_frequency']), name='collector')
            collector.start()
            self.collector.append(collector)
            
            # start worker processes
            for j in xrange(nproc):
                worker = Process(target=work, args=(in_queue, out_queue, 
                    self.script), name=('worker'+str(j)))
                worker.start()
                self.workers.append(worker)
            
            # put data chunks into the input queue
            for idx in cm.chunks(range(ntargets), targets_per_chunk):
                in_queue.put(targets[(idx),:,frame])
            
            # put poison pills into the input queue
            for w in self.workers:
                in_queue.put('STOP')
            
            root.close()
            
            self.out_queue = out_queue
            self.res_queue = res_queue
            self.field_prms = field_prms
            self.target_prms = target_prms
     
        except:
            
            root.close()           
            raise
    
    def load_data(self, path=()):
        self.input_path = path
        
    def write_data(self, path=(), frame=None):
        
        if frame is None:
            frame = self.frame_no
            
        try:
            # open output file and write results
            root = h5py.File(path[0], 'a')
            dataset = path[1]
            
            dims = self.result[0].shape
            
            # if dataset doesn't exist, create a new dataset
            if dataset not in root:
                
                rfdata = root.create_dataset(dataset, 
                    shape=(dims[0], dims[1], frame+1),
                    maxshape=(None, dims[1], None), dtype='double', 
                    compression='lzf')
                
                rfdata[0:dims[0],:,frame] = self.result[0]
                
            else:
                
                rfdata = root[dataset]
                align_write(rfdata, self.result[0], self.result[1], frame)
            
            # set data attributes
            rfdata.attrs.create('start_time', self.result[1])
            
            # copy target parameters to data attributes
            for key, val in self.target_prms.iteritems():
                rfdata.attrs.create(key, val)
            
            # copy field ii parameters to data attributes
            for key, val in self.field_prms.iteritems():
                rfdata.attrs.create(key, val)
            
            root.close()
            
        except:
            
            root.close()
            raise
            
    def join(self, timeout=None):
        
        # wait for workers to join--input and output queues will be flushed
        for w in self.workers:
            w.join(timeout)
        
        # put poison pill for collector
        self.out_queue.put('STOP')
        
        # get result from collector and close input file
        item = self.res_queue.get()
        
        if isinstance(item, Exception):
            raise item
        
        self.result = item
        self.collector[0].join(timeout)
    
    def terminate(self):
        
        for w in self.workers:
            w.terminate()
            w.join()
        
        for c in self.collector:
            c.terminate()
            c.join()
    
        
        
        
        
        
        
            
    