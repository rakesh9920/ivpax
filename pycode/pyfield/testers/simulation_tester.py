# pyfield / testers / simulation_tester.py

from pyfield.field import Simulation, sct_cube
import h5py
import numpy as np
import scipy as sp
    
if __name__ == '__main__': 
    
    #root = h5py.File('fieldii_bsc_experiments.hdf5', 'a')
    #
    #if 'field/targdata/0' in root:
    #    del root['field/targdata/0']
        
    targ = sct_cube(('fieldii_bsc_experiments.hdf5', 'field/targdata/0'),
        (0.01, 0.01, 0.01), (0,0,0.02), (0,0,0), 1, 1000**3, 1)
        
    #targ = root.create_dataset('field/targdata/0', shape=(1000, 4, 1), 
    #    dtype='double', compression='gzip')
    #targ[:,0:2,:] = np.zeros((1000, 2, 20))
    #targ[:,2,:] = sp.rand(1000, 20)*0.01 + 0.001
    #targ[:,3,:] = np.ones((1000, 20))
    #targ[0,:,:] = np.array([0, 0, 0.03, 1]).reshape((1,4,1))
    #targ[1,:,:] = np.array([0, 0, 0.02, 1]).reshape((1,4,1))
    #targ[2,:,:] = np.array([0, 0, 0.025, 1]).reshape((1,4,1))
    #targ[3,:,:] = np.array([0, 0, 0.015, 1]).reshape((1,4,1))
    #targ[4,:,:] = np.array([0, 0, 0.01, 1]).reshape((1,4,1))

    #targ.attrs.create('bsc_spectrum', np.ones((1,1024))) 
    #targ.attrs.create('target_density', 1e6)
        
    #root.close()
    
    sim = Simulation()
    
    sim.script_path = 'focused_piston_f4'
    sim.input_path = ('fieldii_bsc_experiments.hdf5', 'field/targdata/0')
    sim.output_path = ('fieldii_bsc_experiments.hdf5', 'field/rfdata/0')
    
    opt = { 'maxtargetsperchunk': 20000,
            'overwrite': True }
    sim.set_options(**opt)
    
    sim.start(nproc=1)
    print sim
    
    #sim.join()
    
    #root = h5py.File(sim.output_path[0], 'a')
    #rfdata = root[sim.output_path[1]][:]
    #root.close()


