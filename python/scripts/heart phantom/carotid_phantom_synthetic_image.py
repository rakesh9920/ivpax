# scripts / carotid_phantom_synthetic_image.py

import h5py

file_path = '/data/bshieh/carotid_phantom_data.h5'
bf_key = 'bfdata/tx'




if __name__ == '__main__':

    with h5py.File(file_path, 'r') as root:
        
        bfdata_t = root[bf_key + str(0)][:]
        
        for tx in xrange(1, 128):
            
            print tx
            bfdata_t += root[bf_key + str(tx)][:]
