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
    
    def start(self, nproc=1, maxtargetsperchunk=5000):
        
        # check that script and dataset are defined
        if self.script is None:
            raise Exception('Simulation script not set')
            
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
                in_queue.put(targets[(idx),:])
            
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
        
    def write_data(self, path=()):
        
        try:
            # open output file and write results
            root = h5py.File(path[0], 'a')
            dataset = path[1]
            
            # delete current dataset, if it exists
            if dataset in root:
                del root[dataset]
                
            rfdata = root.create_dataset(dataset, data=self.result[0], 
                dtype='double', compression='lzf')
            
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
    
    
    
        
            
            
            
        
        
        
        
        
        
        
        
            
    