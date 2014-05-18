# scripts / simple_lumen_1dflow_reconstruction.py

from pyfield.flow import Reconstructor

######################### SET SCRIPT PARAMETERS HERE ###########################
file_path = './data/simple lumen flow/simple_lumen_experiments.hdf5'
input_key = 'bfdata/00000'
output_key = 'flowdata/00000'
coeff_key = ''
opts = { 'method': 'corr_lag',
         'ensemble': 1,
         'gate': 1,
         'interleave': 1,
         'interpolate': 10,
         'resample': 1,
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
    
            
    
    
    
    