# scripts / simple_lumen_apply_bsc.py

from pyfield.field import apply_bsc

import h5py

######################### SET SCRIPT PARAMETERS HERE ###########################
file_path = './data/simple lumen flow/simple_lumen_data.hdf5'
bsc_key = 'field/bsc/blood_shung_hmtc8'
raw_key = 'field/rfdata/raw/fluid2'
out_key = 'field/rfdata/blood/fluid2'
################################################################################

if __name__ == '__main__':
   
    with h5py.File(file_path, 'a') as root:   
        bsc = root[bsc_key][:].copy()

    apply_bsc((file_path, raw_key), (file_path, out_key), bsc=bsc, write=True, 
        method='fir')