# scripts / tissue_bsc_power_fits

import h5py
import numpy as np
from matplotlib import pyplot as plt

file_path = './data/tissue_bsc_data.h5'
tissue_names = ['aorta_normal_landini','aorta_calcified_landini',
    'blood_hmtc8_shung','dermis_wrist_raju','fat_wrist_raju',
    'heart_dog_odonnell']
exp_group = 'bsc/experimental/'
powerfit_group = 'bsc/powerfit/'
colors = ['b','g','r','y','c','k']

if __name__ == '__main__':

    fig = plt.figure()    
    ax = fig.add_subplot(111)
    lines = []
    
    with h5py.File(file_path, 'a') as root:
        
        for name, color in zip(tissue_names, colors):
            
            exp = root[exp_group + name][:]
            powerfit = root[powerfit_group + name][:]
            
            ax.plot(exp[:,0]/1e6, 10*np.log10(exp[:,1]), color + '.')
            l = ax.plot(powerfit[:,0]/1e6, 10*np.log10(powerfit[:,1]), 
                color + '-')
            
            lines.append(l[0])
    
    ax.set_xlim(0, 20)
    ax.legend(lines, tissue_names, loc=4)
    ax.set_xlabel('Frequency (MHz)')
    ax.set_ylabel('Backscattered Power (dB re 1W)')
    fig.show()
    