# scripts / carotid_phantom_apply_bsc

from pyfield.field import apply_bsc

import h5py

######################### SET SCRIPT PARAMETERS HERE ###########################
file_path = './data/carotid_phantom_data.h5'
bsc_key = 'bsc/powerfit/dermis_wrist_raju'
raw_key = 'field/rfdata/raw/dermis'
out_key = 'field/rfdata/tissue/dermis'
################################################################################

if __name__ == '__main__':
   
    with h5py.File(file_path, 'a') as root:   
        bsc = root[bsc_key][:].copy()

    apply_bsc((file_path, raw_key), (file_path, out_key), bsc=bsc, write=True, 
        method='fir')