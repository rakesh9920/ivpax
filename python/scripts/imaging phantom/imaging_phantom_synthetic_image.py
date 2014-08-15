# scripts / carotid_phantom_synthetic_image.py

import h5py
import numpy as np
from matplotlib import pyplot as plt
from mpl_toolkits.axes_grid1 import make_axes_locatable

from pyfield.beamform import envelope, imdisp

file_path = '/data/bshieh/imaging_phantom_data3.h5'
bf_key = 'bfdata/synthetic_0db/full'
#file_path = './data/psf_data.h5'
#bf_key = 'bfdata/psf_192_wide_apod/full'

if __name__ == '__main__':

    with h5py.File(file_path, 'r') as root:
        bfdata = root[bf_key][:]
    
    envdata = envelope(bfdata[:,:,0])
    
    img = envdata[:,50].reshape((161, 161))
    
    plt.rc('mathtext', fontset='stix', default='regular')
    plt.rc('axes', linewidth = 0.6)
    
    fig = plt.figure(figsize=(3.5,3.5), dpi=100, tight_layout=True)
    ax = fig.add_subplot(111)
    
    imax = imdisp(img.T, dyn=60, ax=ax, interp='bicubic')
    
    #ax.invert_yaxis()
    ax.set_xticks([0, 80, 161])
    ax.set_xticklabels(['-2','0','2'], fontsize=9)
    ax.set_yticks([0, 80, 160])
    ax.set_yticklabels(['0','2','4'], fontsize=9)
    #ax.set_xticks([])
    #ax.set_yticks([])
    #ax.set_axis_bgcolor('black')
    #ax.set_ylim((5.4, 0.7))
    #ax.set_xlim((-3.2, 3.2))
    ax.set_xlabel('Lateral (cm)', fontsize=9)
    ax.set_ylabel('Axial (cm)', fontsize=9)
    ax.tick_params(labelsize=9)
    
    #ax.text(0, 3, 'RA', color='white')
    
    divider = make_axes_locatable(ax)
    cax = divider.append_axes("right", size="5%", pad=0.05)
    cbar = fig.colorbar(imax, cax=cax)
    cbar.set_ticks([0, -20, -40, -60])
    cbar.set_label('dB (re max)', fontsize=9)
    cbar.ax.tick_params(labelsize=9)
    
    ax.set_title('192 elem, 150 $\mu m$ pitch, \n 5 MHz, hann apod', fontsize=10)

    fig.show()
