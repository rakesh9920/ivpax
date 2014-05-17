# scripts / simple_lumen_apply_bsc.py

import h5py
from pyfield.field import apply_bsc

if __name__ == '__main__':


    file_path = './data/simple lumen flow/simple_lumen_experiments.hdf5'
    bsc_key = 'field/bsc/blood_shung_hmtc8'
    raw_key = 'field/rfdata/raw/00001'
    out_key = 'field/rfdata/blood/00001'
    
    with h5py.File(file_path, 'a') as root:   
        bsc = root[bsc_key][:].copy()

    apply_bsc((file_path, raw_key), (file_path, out_key), bsc=bsc, write=True, 
        method='fir')