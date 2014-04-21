# beamformer_tester.py

import numpy as np
import h5py
from beamformer import Beamformer, View

def write_view():
    
    xtick = np.arange(-0.02, 0.021, 0.001)
    ztick = np.arange(0, 0.041, 0.001)
    xx, yy, zz = np.meshgrid(xtick, 0, ztick)
    
    fieldpos = np.hstack((xx.ravel()[:,None], yy.ravel()[:,None], 
        zz.ravel()[:,None]))
        
    root = h5py.File('testfile.hdf5', 'a')
    root.create_dataset('views/view0', data=fieldpos, compression='gzip')
    root.close()
    
if __name__ == '__main__':
    
    bf = Beamformer()
    
    bf.set_options(nwin=101, resample=1, chmask=np.ones(128), planetx=False)
    bf.input_path = ('testfile.hdf5', 'field/rfdata/rf0')
    bf.output_path = ('testfile.hdf5', 'bfdata/bf0')
    bf.view_path = ('testfile.hdf5', 'views/view0')
    
    bf.start(nproc=1)