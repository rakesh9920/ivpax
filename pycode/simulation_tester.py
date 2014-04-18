# pyfield / testers / simulation_tester.py

from pyfield import Simulation
import h5py
import numpy as np
import scipy as sp
   

def main():
    
    data = h5py.File('testdata.hdf5', 'w')
    
    targ = data.create_dataset('field/targets/set0', (2000, 4, 10), 
        dtype='double', compression='lzf')
    targ[:,0:2,:] = np.zeros((2000, 2, 10))
    targ[:,2,:] = sp.rand(1,2000,10)*0.01 + 0.001
    targ[:,3,:] = np.ones((2000, 10))
    
    data.close()
    
    sim = Simulation()
    
    sim.script = 'linear_array_128_5mhz'
    sim.load_data(('testdata.hdf5', 'field/targets/set0'))
    
    for f in xrange(10):
        sim.start(nproc=2, frame=f)
        sim.join()
        sim.write_data(('testdata.hdf5', 'field/rf/set1'))
    
if __name__ == '__main__': main()
    



