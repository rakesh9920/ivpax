from pyfield.field import Simulation, sct_sphere
import h5py
import numpy as np


if __name__ == '__main__':
    
    sim = Simulation()
    
    sim.input_path = ('fieldii_bsc_experiments.h5py', 
        'custombsc/field/targdata/0')
    sim.script_path = 'focused_piston_f4.py'
    sim.output_path = ('fieldii_bsc_experiments.h5py', 
        'custombsc/field/rfdata/raw')
    
    opt = { 'maxtargetsperchunk': 100000,
            'overwrite': True }
    sim.set_options(**opt)
    
    ns = 20*1000**3
    ninstance = 1
    
    for inst in xrange(ninstance):
        
        target_pos = sct_sphere((0.015, 0.025), (0, 2*np.pi), (0, np.pi/2), ns=ns)
        
        root = h5py.File(sim.input_path[0], 'a')
        
        if sim.input_path[1] in root:
            del root[sim.input_path[1]]
            
        targdata = root.create_dataset(sim.input_path[1], data=target_pos,
        compression='gzip')
        
        targdata.attrs.create('target_density', ns)
    
        root.close() 
        
        sim.start(nproc=1, overwrite=True)
        
    
    
    
    
    
    
