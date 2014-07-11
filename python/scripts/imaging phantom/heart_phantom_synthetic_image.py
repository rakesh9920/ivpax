# scripts / carotid_phantom_synthetic_image.py

import h5py
import numpy as np
from matplotlib import pyplot as plt
from mpl_toolkits.axes_grid1 import make_axes_locatable

from pyfield.beamform import envelope, imdisp

file_path = './data/heart_phantom_data.h5'
bf_key = 'bfdata/synthetic/full'

if __name__ == '__main__':

    with h5py.File(file_path, 'r') as root:
        bfdata = root[bf_key][:]
    
    envdata = envelope(bfdata[:,:,0])
    
    img = envdata[:,50].reshape((280, 400))
    
    r = np.arange(0.001, 0.071, 0.00025)*100
    phi = np.linspace(-np.pi/4, np.pi/4, 400, endpoint=True)
    
    rstart = 28
    rstop = 210
    phistart = 40
    phistop = 360
    
    plt.rc('mathtext', fontset='stix', default='regular')
    plt.rc('axes', linewidth = 0.6)
    
    fig = plt.figure(figsize=(3.5,2.39), tight_layout=True)
    ax = fig.add_subplot(111)
    
    pc = imdisp(img[rstart:rstop, phistart:phistop], r=r[rstart:rstop], 
        phi=phi[phistart:phistop], dyn=40, ax=ax, interp=True)
        
    ax.invert_yaxis()
    ax.set_xticks([-3, -1, 1, 3])
    ax.set_yticks([1, 3, 5])
    #ax.set_xticks([])
    #ax.set_yticks([])
    ax.set_axis_bgcolor('black')
    ax.set_ylim((5.4, 0.7))
    ax.set_xlim((-3.2, 3.2))
    ax.set_xlabel('lateral (cm)', fontsize=9)
    ax.set_ylabel('axial (cm)', fontsize=9)
    ax.tick_params(labelsize=9)
    
    ax.text(0, 3, 'RA', color='white')
    
    divider = make_axes_locatable(ax)
    cax = divider.append_axes("right", size="5%", pad=0.05)
    cbar = fig.colorbar(pc, cax=cax)
    cbar.set_ticks([0, -20, -40])
    cbar.set_label('dB (re max)', fontsize=9)
    cbar.ax.tick_params(labelsize=9)
        

