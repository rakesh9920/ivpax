# pyfield / testers / simulation_tester.py

from pyfield.field import Simulation, SynthSimulation, sct_cube
import h5py
import numpy as np
    
if __name__ == '__main__': 
    
    file_path = './data/testdata.h5'
    input_key = 'field/targdata/tester'
    output_key = 'field/rfdata/tester'
    script_path = 'pyfield.field.linear_focused_array_128_12mhz'
    
    with h5py.File(file_path, 'a') as root:
    
        if input_key in root:
            del root[input_key]
            
        targdata = sct_cube((file_path, input_key),
            (0.01, 0.01, 0.01), (0,0,0.10), (0,0,0), 1, 1000**3, 1)
            
        amp = np.ones((targdata.shape[0], 1))
            
        root.create_dataset(input_key, data=np.c_[targdata, amp], 
            compression='gzip')
        
        root[input_key].attrs.create('target_density', 1000**3)
        
    #targ = root.create_dataset('field/targdata/0', shape=(1, 4, 1), 
        #dtype='double', compression='gzip')
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
    
    sim = SynthSimulation()
    
    sim.script_path = script_path
    sim.input_path = (file_path, input_key)
    sim.output_path = (file_path, output_key)
    
    opt = { 'maxtargetsperchunk': 100,
            'overwrite': True }
    sim.set_options(**opt)
    
    sim.start(nproc=1)
    print sim
    


