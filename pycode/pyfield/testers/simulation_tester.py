# pyfield / testers / simulation_tester.py

from pyfield import Simulation
import h5py
import numpy as np
import scipy as sp
    
if __name__ == '__main__': 
    
    data = h5py.File('testfile.hdf5', 'a')
    
    targ = data.create_dataset('field/targets/tar0', (1, 4, 20), 
        dtype='double', compression='gzip')
    #targ[:,0:2,:] = np.zeros((1, 2, 10))
    #targ[:,2,:] = sp.rand(1, 1, 10)*0.01 + 0.001
    #targ[:,3,:] = np.ones((1, 10))
    targ[:] = np.array([0, 0, 0.03, 1]).reshape((1,4,1))

    targ.attrs.create('bsc_spectrum', np.ones((1,1024))) 
    targ.attrs.create('target_density', 1e6)
        
    data.close()
    
    sim = Simulation()
    
    sim.script = 'linear_array_128_5mhz'
    sim.load_data(('testfile.hdf5', 'field/targets/tar0'))
    
    for f in xrange(20):
        sim.start(nproc=1, frame=f)
        sim.join()
        sim.write_data(('testfile.hdf5', 'field/rfdata/rf0'))

