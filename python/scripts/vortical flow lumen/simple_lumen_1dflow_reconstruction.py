# scripts / simple_lumen_1dflow_reconstruction.py

from pyfield.flow import Reconstructor

######################### SET SCRIPT PARAMETERS HERE ###########################
file_path = './data/simple lumen flow/simple_lumen_data.hdf5'
input_key = 'bfdata/fluid2_full'
output_key = 'flowdata/inst_phase/fluid2_full'
coeff_key = ''
opts = { 'method': 'inst_phase',
         'ensemble': 8,
         'gate': 1,
         'interleave': 1,
         'interpolate': 40,
         'resample': 2,
         'threshold': 0,
         'retcoeff': False }
################################################################################

if __name__ == '__main__':
    
    rec = Reconstructor()
    
    rec.file_path = file_path
    rec.input_key = input_key
    rec.output_key = output_key
    rec.coeff_key = coeff_key
    rec.set_options(**opts)

    rec.start()
    
            
    
    
    
    