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
#colors = ['b','g','r','y','c','k']
colors = ["#66c2a5","#fc8d62","#8da0cb","#e78ac3","#a6d854","#ffd92f"]
syms = ['o','^','s','v','*','d']
lstyle = ['-','--','-.',':','-','--']

if __name__ == '__main__':

    plt.rc('mathtext', fontset='stix', default='regular')
    plt.rc('axes', linewidth = 0.6)
    
    fig = plt.figure(figsize=(3.5,2.6), dpi=100, tight_layout=True)
    ax = fig.add_subplot(111)
    ax.tick_params(labelsize=9)
    lines = []
    
    with h5py.File(file_path, 'a') as root:
        
        for name, color, sym in zip(tissue_names, colors, syms):
            
            exp = root[exp_group + name][:]
            powerfit = root[powerfit_group + name][:]
            
            if name in ['aorta_normal_landini', 'aorta_calcified_landini']:
                exp = exp[::4,:]
            
            if name in ['heart_dog_odonnell']:
                exp = exp[::2,:]
                
            #ax.plot(10*np.log10(exp[:,0]/1e6), 10*np.log10(exp[:,1]), color=color, 
            #    marker=sym, alpha=0.9, ls='none')
            #l = ax.plot(10*np.log10(powerfit[:,0]/1e6), 10*np.log10(powerfit[:,1]), 
            #    color=color, ls='-')
            
            l = ax.plot(powerfit[:,0]/1e6, powerfit[:,1], 
                color=color, ls='-')  
            ax.plot(exp[:,0]/1e6, exp[:,1], color=color, 
                marker=sym, alpha=0.9, ls='none')
         
            lines.append(l[0])
            
    #ax.set_xscale('log')
    ax.set_yscale('log')
    ax.set_xlim(3, 20)
    ax.set_ylim(10e-5, 100)
    ax.set_yticks([10e-5, 10e-3, 10e-1, 10e1])
    ax.set_xticks([5, 10, 15, 20])
    #ax.legend(lines, tissue_names, loc=4)
    ax.set_xlabel('Frequency (MHz)', fontsize=9)
    ax.set_ylabel('BSC ($m^{-1} Sr^{-1}$)', fontsize=9)
    #ax.set_ylabel('$\eta(f)$ ($m^{-1} Sr^{-1}$)', fontsize=9)
    fig.show()
    