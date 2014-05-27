# scripts / carotid_phantom_simulation.py

from pyfield.field import Simulation

from sys import stdout

######################### SET SCRIPT PARAMETERS HERE ###########################
file_path = './data/carotid_phantom_data.hdf5'
input_key = 'field/targdata/dermis'
output_key = 'field/rfdata/raw/dermis'
script_path = 'pyfield.field.linear_array_128_5mhz'
nproc = 4
frames = None
opt = { 'maxtargetsperchunk': 20000,
        'maxframesperchunk': 1000,
        'overwrite': True }
################################################################################

if __name__ == '__main__':

    sim = Simulation()
    sim.input_path = (file_path, input_key)
    sim.output_path = (file_path, output_key)
    sim.script_path = script_path
    sim.set_options(**opt)

    sim.start(nproc=nproc, frames=frames)
    print sim
    stdout.flush()
        
    
    
    
    
    
