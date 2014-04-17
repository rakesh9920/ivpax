# pyfield / common.py

import numpy as np

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

def chunks(items, nitems):
    
    if nitems < 1:
        nitems = 1
    return [slice(i, i + nitems) for i in xrange(0, len(items), nitems)]