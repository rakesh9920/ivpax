# scripts / imaging phantom / imaging_phantom_simulation.py

from pyfield.field import Simulation, SynthSimulation

from sys import stdout

######################### SET SCRIPT PARAMETERS HERE ###########################
file_path = '/data/bshieh/imaging_phantom_data3.h5'
input_group = 'field/targdata/'
output_group = 'field/rfdata/raw/synthetic/'
script_path = 'pyfield.field.linear_focused_array_192_6mhz'
#tissue_names = ['mat3']
#tissue_names = ['background']
tissue_names = ['mat1','mat2','mat4']
nproc = 24
frames = None
opt = { 'maxtargetsperchunk': 5000,
        'maxframesperchunk': 1000,
        'overwrite': True }
################################################################################

if __name__ == '__main__':
    
    for tissue in tissue_names:
        
        input_key = input_group + tissue
        output_key = output_group + tissue
        
        #sim = Simulation()
        sim = SynthSimulation()
        sim.input_path = (file_path, input_key)
        sim.output_path = (file_path, output_key)
        sim.script_path = script_path
        sim.set_options(**opt)
    
        sim.start(nproc=nproc, frames=frames)
        print sim
        stdout.flush()
        
        sim.join()
        
        
    
    
    
    
    
