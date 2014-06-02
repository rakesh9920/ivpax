# scripts / carotid_phantom_simulation.py

from pyfield.field import Simulation, SynthSimulation

from sys import stdout

######################### SET SCRIPT PARAMETERS HERE ###########################
# names = {'dermis', 'fat', 'artery', 'plaque', 'blood'}
file_path = './data/carotid_phantom_data.h5'
input_group = 'field/targdata/'
output_group = 'field/rfdata/raw/'
script_path = 'pyfield.field.linear_focused_array_256_6mhz'
tissue_names = ['dermis', 'fat', 'artery', 'plaque', 'blood']
#tissue_names = ['dermis']
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
        
        sim = Simulation()
        #sim = SynthSimulation()
        sim.input_path = (file_path, input_key)
        sim.output_path = (file_path, output_key)
        sim.script_path = script_path
        sim.set_options(**opt)
    
        sim.start(nproc=nproc, frames=frames)
        print sim
        stdout.flush()
        
        sim.join()
        
        
    
    
    
    
    
