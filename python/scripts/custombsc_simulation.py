from pyfield.field import Simulation, sct_sphere
import h5py
import numpy as np


if __name__ == '__main__':
    
    sim = Simulation()
    
    file_path = './data/fieldii_bsc_experiments.hdf5'
    input_key = 'custombsc/field/targdata/00000'
    output_key = 'custombsc/field/rfdata/raw/'
    script_path = 'pyfield.field.focused_piston_f4'
    
    sim.input_path = (file_path, input_key)
    sim.script_path = script_path
    
    opt = { 'maxtargetsperchunk': 20000,
            'overwrite': True }
    sim.set_options(**opt)
    
    ns = 20*1000**3
    ninstance = 1
    
    for inst in xrange(ninstance):
        
        #target_pos = sct_sphere((0.015, 0.025), (0, 2*np.pi), (0, np.pi/2), 
        #    ns=ns)
        #ntarget = target_pos.shape[0]
        
        root = h5py.File(file_path, 'a')
        
        if sim.input_path[1] in root:
            del root[sim.input_path[1]]
            
        #targdata = root.create_dataset(input_key, shape=(ntarget, 4, 1),
        #    compression='gzip')
        targdata = root.create_dataset(input_key, 
            data=np.array([[0, 0, 0.02, 1]]), compression='gzip')
        
        #targdata[:,0:3, 0] = target_pos
        #targdata[:,3,0] = np.ones((ntarget,))
        
        #targdata.attrs.create('target_density', ns)
    
        root.close() 
        
        #sim.output_path = (file_path, output_key + '{:05d}'.format(inst))
        sim.output_path = (file_path, output_key + 'ref')
        
        sim.start(nproc=1)
        
        print sim
        
        sim.join()
        
        
    
    
    
    
    
