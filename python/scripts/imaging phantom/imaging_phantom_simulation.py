# scripts / imaging phantom / imaging_phantom_simulation.py

from pyfield.field import Simulation, SynthSimulation

from sys import stdout

######################### SET SCRIPT PARAMETERS HERE ###########################
# names = {'myocardium', 'blood'}
file_path = './data/imaging_phantom_data.h5'
input_group = 'field/targdata/'
output_group = 'field/rfdata/raw/synthetic/'
script_path = 'pyfield.field.ice_array_64_10mhz'
tissue_names = ['mat1']
#tissue_names = ['background', 'mat1', 'mat2', 'mat3', 'mat4']
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
        
        #sim.join()
        
        
    
    
    
    
    
