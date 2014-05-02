# pyfield / util / util.py

import numpy as np
from multiprocessing import Value
import time

class Progress():
    
    def __init__(self, total=None):
        self.counter = Value('i', 0)
        self.total = Value('i', 0)
        self.init_time = None
        self.elapsed_time = Value('f', 0)
        self.fraction_done = Value('f', 0)
    
    def increment(self):
        
        with self.counter.get_lock():
            self.counter.value += 1
        
        with self.fraction_done.get_lock():
            self.fraction_done.value = self.counter.value/float(self.total.value)
        
        with self.elapsed_time.get_lock():
            self.elapsed_time.value = time.time() - self.init_time
            
    def time_remaining(self):
        
        if self.fraction_done.value == 0:
            rtime = (np.inf, np.inf, np.inf, np.inf)
        else:
            rtime = self.sec_to_dhms((1/self.fraction_done.value - 1) * \
                self.elapsed_time.value)
            
        return rtime
    
    def sec_to_dhms(self, seconds):
        
        m, s = divmod(seconds, 60)
        h, m = divmod(m, 60)
        d, h = divmod(h, 24)
        
        return (d, h, m, s)
    
    def reset(self):
        self.init_time = time.time()
        self.counter.value = 0
        self.fraction_done.value = 0

def chunks(items, nitems):
    
    if nitems < 1:
        nitems = 1
    return [slice(i, i + nitems) for i in xrange(0, len(items), nitems)]
    
def distance(a, b):
    
    a = a.T
    b = b.T
    
    return np.sqrt(np.sum(b*b, 0)[None,:] + np.sum(a*a, 0)[:,None] - \
        2*np.dot(a.T, b))
        
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
    
    pad_width1 = [(fpad1, bpad1)] + [(0,0) for x in range(array1.ndim - 1)]
    pad_width2 = [(fpad2, bpad2)] + [(0,0) for x in range(array2.ndim - 1)]
    sum_array = np.pad(array1, pad_width1, mode='constant') + \
        np.pad(array2, pad_width2, mode='constant') 
    
    return (sum_array, min(t1, t2))
