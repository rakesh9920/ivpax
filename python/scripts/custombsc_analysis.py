# scripts / custombsc_analysis.py

from pyfield.signal import ffts, iffts
from pyfield.field import apply_bsc


if __name__ == '__main__':
    
    file_path = 'fieldii_bsc_experiments.hdf5' 
    raw_key = 'custombsc/field/'
    ref_key = ''
    out_key = ''
    bsc = None
     
    apply_bsc((file_path, raw_key), (file_path, out_key), bsc=bsc, write=True)
    
    
    