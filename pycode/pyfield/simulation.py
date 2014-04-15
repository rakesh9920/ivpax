from multiprocessing import Process, Queue, current_process
import numpy as np
from pyfield import Field
import h5py
from itertools import izip_longest

def grouper(iterable, n, fillvalue=None):
    "Collect data into fixed-length chunks or blocks"
    # grouper('ABCDEFG', 3, 'x') --> ABC DEF Gxx
    args = [iter(iterable)] * n
    return izip_longest(fillvalue=fillvalue, *args)
    
class Simulation():
    
    def __init__(self, script="", dataset=""):
        self.jobs = []
        self.script = script
        self.dataset = dataset
    
    def set_script(self, script):   
        self.script = script
        
    def set_dataset(self, dataset):
        self.dataset = dataset
    
    def worker(self, in_queue, out_queue):
        
        try:
            def_script = __import__(self.script)
            
            f2 = Field()
            
            f2.field_init(-1)
            
            (tx_aperture, rx_aperture) = def_script.run(f2)
            
            for i in iter(in_queue, 'STOP'):
                
                data = in_queue.get()
                points = data[...,0:3]
                amp = data[...,4]
                
                (scat, t0) = f2.calc_scat_multi(tx_aperture, rx_aperture, 
                    points, amp)
            
                out_queue.put(scat)
                
            f2.field_end()
            
        except Exception, e:
            out_queue.put("failed on %s with: %s" % (current_process().name,
                e.message))
        
        
    def start(self, nproc=1, ndiv=None):
        
        if ndiv is None:
            ndiv = nproc
        
        if self.script is None or self.dataset is None:
            return
        
        try:
            in_queue = Queue()
            out_queue = Queue()
            
            h5file = h5py.File(self.dataset, 'r')
            targets = h5file['targets']
            ntargets = targets.shape[0]
            end = np.floor(ntargets/ndiv).astype(int)
            
            for idx in grouper(range(ntargets), end):
                
                idx = [x for x in idx if x is not None]
                in_queue.put(targets[(idx),:])
    
            for j in xrange(nproc):
                proc = Process(target=self.worker, args=[in_queue, out_queue])
                proc.start()
                self.jobs.append(proc)
                in_queue.put('STOP')
            
            for j in self.jobs:
                j.join()
            
            h5file.close()
            
        except Exception, e:
            
            h5file.close()
            
            raise e

        return out_queue
        
        

        
            
            
            
        
        
        
        
        
        
        
        
            
    