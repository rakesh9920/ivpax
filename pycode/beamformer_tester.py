# beamformer_tester.py

import numpy as np
from beamformer import Beamformer, View

if __name__ == '__main__':
    
    
    
    
    
    bf = Beamformer()
    
    bf.options(nwin=101, resample=1, chmask=np.ones(128), planetx=False)
    bf.inpurt_path = ('testdata.hdf5/', 'field/rfdata/rf0')
    bf.output_path = ('testdata.hdf5', 'bfdata/bf0')
    bf.view_path = ('testdata.hdf5', 'views/view0')