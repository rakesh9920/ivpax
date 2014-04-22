# beamformer_tester.py

import numpy as np
import h5py
import scipy as sp
from beamformer import Beamformer, View

def distance(a, b):
    
    a = a.T
    b = b.T
    
    return np.sqrt(np.sum(b*b, 0)[None,:] + np.sum(a*a, 0)[:,None] - \
        2*np.dot(a.T, b))
    
def work_tester(rfdata, fieldpos, attrs):
    
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
            
            delay = pdelay[ch] + nwin - nwinhalf
            
            bfsig += rfdata[delay:(delay + nwin),ch,:]
        
        bfdata[:,:,pos] = bfsig
    
    return bfdata

 
def write_view():
    
    xtick = np.arange(-0.02, 0.021, 0.0005)
    ztick = np.arange(0, 0.041, 0.0005)
    xx, yy, zz = np.meshgrid(xtick, 0, ztick)
    
    fieldpos = np.hstack((xx.ravel()[:,None], yy.ravel()[:,None], 
        zz.ravel()[:,None]))
        
    root = h5py.File('testfile.hdf5', 'a')
    
    if 'views/view0' in root:
        del root['views/view0']
        
    root.create_dataset('views/view0', data=fieldpos, compression='gzip')
    root.close()
    
if __name__ == '__main__':
    pass
    #bf = Beamformer()
    #
    #bf.set_options(nwin=101, resample=1, chmask=False, planetx=True)
    #bf.input_path = ('testfile.hdf5', 'field/rfdata/rf0')
    #bf.output_path = ('testfile.hdf5', 'bfdata/bf0')
    #bf.view_path = ('testfile.hdf5', 'views/view0')
    #
    #bf.start(nproc=1)