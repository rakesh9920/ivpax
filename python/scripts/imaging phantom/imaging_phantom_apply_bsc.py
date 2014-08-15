# scripts / carotid_phantom_apply_bsc

from pyfield.field import apply_bsc

import h5py

######################### SET SCRIPT PARAMETERS HERE ###########################
file_path = '/data/bshieh/imaging_phantom_data3.h5'
bsc_path = './data/tissue_bsc_data.h5'
bsc_group = 'bsc/powerfit/'
raw_group = 'field/rfdata/raw/synthetic/'
output_group = 'field/rfdata/tissue/synthetic/'
#bsc_names = ['fat_wrist_raju', 'blood_hmtc8_shung', 'aorta_normal_landini', 
#    'heart_dog_odonnell', 'aorta_calcified_landini']
#tissue_names = ['background', 'mat1', 'mat2', 'mat3', 'mat4']
bsc_names = ['blood_hmtc8_shung', 'aorta_normal_landini', 
    'heart_dog_odonnell', 'aorta_calcified_landini']
tissue_names = ['mat1', 'mat2', 'mat3', 'mat4']
emtype = 'av'
################################################################################

if __name__ == '__main__':
   
    for bsc, tissue in zip(bsc_names, tissue_names):
       
        bsc_key = bsc_group + bsc
        raw_key = raw_group + tissue
        output_key = output_group + tissue
       
        with h5py.File(bsc_path, 'a') as root:   
            bscdata = root[bsc_key][:].copy()
    
        apply_bsc((file_path, raw_key), (file_path, output_key), bsc=bscdata, 
            write=True, method='fir', emtype= emtype)