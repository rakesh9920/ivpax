from multiprocessing import Process, Queue, current_process
import numpy as np
import scipy as sp
from pyfield import Field
import h5py
from itertools import izip_longest

def grouper(iterable, n, fillvalue=None):
    "Collect data into fixed-length chunks or blocks"
    # grouper('ABCDEFG', 3, 'x') --> ABC DEF Gxx
    args = [iter(iterable)] * n
    return izip_longest(fillvalue=fillvalue, *args)

def work(in_queue, out_queue, script):
    
    try:
        
        def_script = __import__(script)
        
        f2 = Field()
        f2.field_init(-1)
        (tx_aperture, rx_aperture) = def_script.run(f2)
        
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
    
    (scat_t, t0_t) = out_queue.get()
    
    for scat, t0 in iter(out_queue.get, 'STOP'):
        
        (scat_t, t0_t) = align_and_sum(scat_t, t0_t, scat, t0, fs)
    
    res_queue.put((scat_t, t0_t))
        
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
            
class Simulation():
    
    def __init__(self, script="", dataset=""):
        self.jobs = []
        self.script = script
        self.dataset = dataset
    
    def set_script(self, script):   
        self.script = script
        
    def set_dataset(self, dataset):
        self.dataset = dataset
     
    def start_sim(self, nproc=1, ndiv=None):
        
        if ndiv is None:
            ndiv = nproc
        
        if self.script is None or self.dataset is None:
            raise Exception
        
        try:
            
            in_queue = Queue()
            out_queue = Queue()
            res_queue = Queue()
            
            h5file = h5py.File(self.dataset, 'r')
            targets = h5file['targets']
            ntargets = targets.shape[0]
            end = np.floor(ntargets/ndiv).astype(int)
            
            collector = Process(target=collect, args=(out_queue, res_queue, 
                100e6))
            collector.start()
            
            for idx in grouper(range(ntargets), end):
                
                idx = [x for x in idx if x is not None]
                in_queue.put(targets[(idx),:])
    
            for j in xrange(nproc):
                
                in_queue.put('STOP')
                worker = Process(target=work, args=(in_queue, out_queue, 
                    'linear_array_128_5mhz'))
                worker.start()
                self.jobs.append(worker)
            
            in_queue.close()
            
            for j in self.jobs:
                j.join()
                
            #in_queue.join_thread()
            #out_queue.put('STOP')
            #out_queue.close()
            #out_queue.join_thread()
            
            out_queue.put('STOP')
            out_queue.close()
            
            res = res_queue.get()
            collector.join()
            
            h5file.close()
            
            return res
            
        except:
            
            #out_queue.put('STOP')
            h5file.close()
            raise

        
            
            
            
        
        
        
        
        
        
        
        
            
    