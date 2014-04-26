# pyfield / testers / simulation_tester.py

from pyfield.field import Simulation
import h5py
import numpy as np
import scipy as sp
    
if __name__ == '__main__': 
    
    root = h5py.File('testfile.hdf5', 'a')
    
    if 'field/targets/tar0' in root:
        del root['field/targets/tar0']
    targ = root.create_dataset('field/targets/tar0', shape=(1000, 4, 20), 
        dtype='double', compression='gzip')
    targ[:,0:2,:] = np.zeros((1000, 2, 20))
    targ[:,2,:] = sp.rand(1000, 20)*0.01 + 0.001
    targ[:,3,:] = np.ones((1000, 20))
    #targ[:] = np.array([0, 0, 0.03, 1]).reshape((1,4,1))

    targ.attrs.create('bsc_spectrum', np.ones((1,1024))) 
    targ.attrs.create('target_density', 1e6)
        
    root.close()
    
    sim = Simulation()
    
    sim.script_path = 'linear_array_128_5mhz'
    sim.input_path = ('testfile.hdf5', 'field/targets/tar0')
    sim.output_path = ('testfile.hdf5', 'field/rfdata/rf0')
    
    opt = { 'maxtargetsperchunk': 1000,
            'overwrite': True }
    sim.set_options(**opt)
    
    sim.start(nproc=2, frames=5)
    
    print sim

