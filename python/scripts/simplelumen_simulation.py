# scripts / simplelumen_simulation.py

from pyfield.field import Simulation

import h5py
import numpy as np
from sys import stdout

if __name__ == '__main__':
    
    sim = Simulation()
    
    file_path = './data/simple_lumen_experiments.hdf5'
    input_key = 'field/targdata/fluid'
    output_key = 'field/rfdata/raw/00000'
    script_path = 'pyfield.field.linear_array_128_5mhz'
    
    sim.input_path = (file_path, input_key)
    sim.output_path = (file_path, output_key)
    sim.script_path = script_path
    
    opt = { 'maxtargetsperchunk': 20000,
            'overwrite': True }
    sim.set_options(**opt)
    
    ns = 20*1000**3
    
    sim.start(nproc=4, frames=(1,4))
    print sim
    stdout.flush()
    sim.join()
        
    
    
    
    
    
