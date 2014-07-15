# scripts / simple_lumen_apply_bsc.py

from pyfield.field import apply_bsc, apply_wgn

import h5py

######################### SET SCRIPT PARAMETERS HERE ###########################
file_path = './data/diagonal_lumen_data.h5'
bsc_key = 'bsc/experimental/blood_hmtc8_shung'
raw_key = 'field/rfdata/raw/fluid0'
out_key = 'field/rfdata/blood/fluid0'
dbw = 1
################################################################################

if __name__ == '__main__':
   
    with h5py.File(file_path, 'a') as root:   
        bsc = root[bsc_key][:].copy()

    apply_bsc((file_path, raw_key), (file_path, out_key), bsc=bsc, write=True, 
        method='fir')
    
    apply_wgn((file_path, out_key), (file_path, out_key), dbw=dbw, 
        write=True)