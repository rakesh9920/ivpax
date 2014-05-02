# pyfield / pooledsimulation.py

from multiprocessing import Pool, current_process
import numpy as np
import h5py
from functools import partial
from . import Field
from pyfield.util import chunks, align_and_sum
   
def work(targets, script):
    
    def_script = __import__(script)
    
    f2 = Field()
    f2.field_init(-1, current_process().name + 'log.txt')
    (tx, rx) = def_script.get_apertures(f2)
                
    points = targets[:,0:3]
    amp = targets[:,3]
    
    (scat, t0) = f2.calc_scat_multi(tx, rx, points, amp)
    
    f2.field_end()
    
    return (scat, t0)
      
class PooledSimulation():
    
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
            raise Exception('simulation variables not set')
        
        work_abbr = partial(work, script=self.script)
        
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
        
        if targets_per_group > 5000:
            targets_per_group = 5000
            
        try: 
            
            pool = Pool(nproc, maxtasksperchild=1)
            
            results = pool.imap_unordered(work_abbr, 
                [targets[x,:] for x in chunks(range(ntargets), 
                targets_per_group)])

            infile.close()

        except:
            
            infile.close()           
            raise
        
        pool.close()
        pool.join()
        
        fs = field_prms['sample_frequency']
        
        (scat_t, t0_t) = results.next()
        for scat, t0 in results:
            (scat_t, t0_t) = align_and_sum(scat_t, t0_t, scat, t0, fs)
    
        # open output file and write results
        root = h5py.File(self.outdata[0], 'a')
        path = self.outdata[1]
        
        # delete current dataset, if it exists
        if path in root:
            del root['path']
            
        data = root.create_dataset(path, data=scat_t, dtype='double',
            compression='lzf')
        
        # set data attributes
        data.attrs.create('start_time', t0)
        
        # copy target parameters to data attributes
        for key, val in target_prms.iteritems():
            data.attrs.create(key, val)
        
        # copy field ii parameters to data attributes
        for key, val in field_prms.iteritems():
            data.attrs.create(key, val)
        
        root.close()
 
        
            
            
            
        
        
        
        
        
        
        
        
            
    