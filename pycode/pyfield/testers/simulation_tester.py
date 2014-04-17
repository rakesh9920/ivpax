# pyfield / testers / simulation_tester.py

from pyfield import Simulation
import h5py
import numpy as np
import scipy as sp

def main():
    
    data = h5py.File('testdata.hdf5', 'w')
    
    targ = data.create_dataset('field/targets/set0', (10000, 4), dtype='double',
        compression='lzf')
    targ[:,0:2] = np.zeros((10000,2))
    targ[:,2] = sp.rand(1,10000)*0.01 + 0.001
    targ[:,3] = np.ones((10000,))
    targ.attrs.create('frame_no', 1)
    
    data.close()
    
    sim = Simulation()
    
    sim.script = 'linear_array_128_5mhz'
    sim.load_data(('testdata.hdf5', 'field/targets/set0'))
    
    sim.start(nproc=2)
    sim.join()
    print sim.result
    sim.write_data(('testdata.hdf5', 'field/rf/set0'))
    
if __name__ == '__main__': main()
    
    


