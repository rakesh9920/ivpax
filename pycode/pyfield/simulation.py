from multiprocessing import Process, Queue, current_process
import numpy as np
from pyfield import Field
import h5py

def work(in_queue, out_queue, script):
    
    try:
        
        def_script = __import__(script)
        
        f2 = Field()
        f2.field_init(-1)
        (tx_aperture, rx_aperture) = def_script.get_apertures(f2)
        
        for data in iter(in_queue.get, 'STOP'):
            
            points = data[:,0:3]
            amp = data[:,3]
            
            (scat, t0) = f2.calc_scat_multi(tx_aperture, rx_aperture, 
                points, amp)
                
            out_queue.put((scat, t0))
            
        f2.field_end()
     
    except Exception, e:
        
        out_queue.put("failed on %s with: %s" % (current_process().name,
            e.message))

def collect(out_queue, res_queue, fs):
    
    try:
    
        (scat_t, t0_t) = out_queue.get()
        
        for scat, t0 in iter(out_queue.get, 'STOP'):
            
            (scat_t, t0_t) = align_and_sum(scat_t, t0_t, scat, t0, fs)
        
        res_queue.put((scat_t, t0_t))
    
    except Exception, e:
        
        res_queue.put("failed on %s with: %s" % (current_process().name,
            e.message))
        
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
    
    sum_array = np.pad(array1, ((fpad1, bpad1),(0, 0)), mode='constant') + \
        np.pad(array2, ((fpad2, bpad2),(0, 0)), mode='constant') 
    
    return (sum_array, min(t1, t2))

def chunks(items, nitems):
    
    if nitems < 1:
        nitems = 1
    return [slice(i, i + nitems) for i in xrange(0, len(items), nitems)]
    
            
class Simulation():
    
    def __init__(self, script=None, indata=(), outdata=()):
        self.jobs = []
        self.script = script
        self.indata = indata
        self.outdata = outdata
    
    def start_sim(self, nproc=1, ndiv=None):
        
        if ndiv is None:
            ndiv = nproc
        
        # check that script and dataset are defined
        if self.script is None or not self.indata or not self.outdata:
            raise Exception
        
        try:
            
            in_queue = Queue() # queue that sends data to workers
            out_queue = Queue() # queue that sends data to collector
            res_queue = Queue() # queue that sends data to main process
            
            # open input file and read dataset
            infile = h5py.File(self.indata[0], 'r')
            targets = infile[self.indata[1]]
            
            # get metadata from dataset
            target_prms = dict()
            for key, val in targets.attrs.iteritems():
                target_prms[key] = val
            
            # get field ii parameters
            def_script = __import__(self.script)
            field_prms = def_script.get_prms()
            
            ntargets = targets.shape[0]
            targets_per_group = np.floor(ntargets/ndiv).astype(int)
            
            # start collector process
            collector = Process(target=collect, args=(out_queue, res_queue, 
                field_prms['sample_frequency']))
            collector.start()
            
            # start worker processes
            for j in xrange(nproc):
                worker = Process(target=work, args=(in_queue, out_queue, 
                    self.script))
                worker.start()
                self.jobs.append(worker)
            
            # put data chunks into the input queue
            for idx in chunks(range(ntargets), targets_per_group):
                in_queue.put(targets[idx,:])
            
            # put poison pills into the input queue
            for j in self.jobs:
                in_queue.put('STOP')
    
            in_queue.close()
            
            # wait for workers to join--input and output queues will be flushed
            for j in self.jobs:
                j.join()
            
            # put poison pill for collector
            out_queue.put('STOP')
            out_queue.close()
            
            # get result from collector and close input file
            (res, t0) = res_queue.get()
            collector.join()
            infile.close()

        except:
            
            collector.terminate()            
            for j in self.jobs:
                j.terminate()
            infile.close()
            raise

        try:
            
            # open output file and write results
            outfile = h5py.File(self.outdata[0], 'a')
            path = self.outdata[1]
            
            # delete current dataset, if it exists
            if path in outfile:
                del outfile['path']
                
            data = outfile.create_dataset(path, data=res, dtype='double',
                compression='lzf')
            
            # set data attributes
            data.attrs.create('start_time', t0)
            
            # copy target parameters to data attributes
            for key, val in target_prms.iteritems():
                data.attrs.create(key, val)
            
            # copy field ii parameters to data attributes
            for key, val in field_prms.iteritems():
                data.attrs.create(key, val)
            
            outfile.close()
                
        except:
            
            outfile.close()
            raise
        
            
            
            
        
        
        
        
        
        
        
        
            
    