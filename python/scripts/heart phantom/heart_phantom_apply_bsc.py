# scripts / carotid_phantom_apply_bsc

from pyfield.field import apply_bsc

import h5py

######################### SET SCRIPT PARAMETERS HERE ###########################
file_path = './data/carotid_phantom_data.h5'
bsc_group = 'bsc/powerfit/'
raw_group = 'field/rfdata/raw/'
output_group = 'field/rfdata/tissue/'
bsc_names = ['dermis_wrist_raju', 'fat_wrist_raju', 'aorta_normal_landini',
    'aorta_normal_landini', 'blood_hmtc8_shung']
tissue_names = ['dermis', 'fat', 'artery', 'plaque', 'blood']
################################################################################

if __name__ == '__main__':
   
    for bsc, tissue in zip(bsc_names, tissue_names):
       
        bsc_key = bsc_group + bsc
        raw_key = raw_group + tissue
        output_key = output_group + tissue
       
        with h5py.File(file_path, 'a') as root:   
            bscdata = root[bsc_key][:].copy()
    
        apply_bsc((file_path, raw_key), (file_path, output_key), bsc=bscdata, 
            write=True, method='fir')