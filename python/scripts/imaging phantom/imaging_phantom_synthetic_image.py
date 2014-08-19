# scripts / carotid_phantom_synthetic_image.py

import h5py
import numpy as np
from matplotlib import pyplot as plt
from mpl_toolkits.axes_grid1 import make_axes_locatable

from pyfield.beamform import envelope, imdisp

#file_path = '/data/bshieh/imaging_phantom_data3.h5'
#bf_key = 'bfdata/synthetic_10db/full'
#file_path = './data/psf_data.h5'
#bf_key = 'bfdata/psf_192_wide_apod/full'
file_path = './data/imaging_phantom_bfdata.npz'
bf_key = 'bf10db'

if __name__ == '__main__':

    #with h5py.File(file_path, 'r') as root:
        #bfdata = root[bf_key][:]
    
    with np.load(file_path) as root:
        bfdata = root[bf_key]
    
    envdata = envelope(bfdata[:,:,0])
    
    img = envdata[:,50].reshape((161, 161))
    
    plt.rc('mathtext', fontset='stix', default='regular')
    plt.rc('axes', linewidth = 0.6)
    
    fig = plt.figure(figsize=(2,2.4), dpi=100, tight_layout=True)
    ax = fig.add_subplot(111)
    
    imax = imdisp(img.T, dyn=60, ax=ax, interp='bicubic')
    
    #ax.invert_yaxis()
    ax.set_xticks([40, 120])
    ax.set_xticklabels(['-1','1'], fontsize=8)
    ax.set_yticks([40, 120])
    ax.set_yticklabels(['1','3'], fontsize=8)
    #ax.set_xticks([])
    #ax.set_yticks([])
    #ax.set_axis_bgcolor('black')
    #ax.set_ylim((5.4, 0.7))
    #ax.set_xlim((-3.2, 3.2))
    ax.set_xlabel('Lateral (cm)', fontsize=8)
    ax.set_ylabel('Axial (cm)', fontsize=8)
    ax.tick_params(labelsize=8, top=False, right=False)
    
    #ax.text(0, 3, 'RA', color='white')
    
    divider = make_axes_locatable(ax)
    cax = divider.append_axes("top", size="5%", pad=0.05)
    cbar = fig.colorbar(imax, cax=cax, orientation='horizontal')
    cbar.set_ticks([0, -20, -40, -60])
    cbar.ticklocation = 'top'
    cax.set_xlabel('dB (re max)', fontsize=8, labelpad=-30)
    cbar.ax.tick_params(labelsize=8, labeltop=True, labelbottom=False)
    #
    #ax.set_title('192 elem, 150 $\mu m$ pitch, \n 5 MHz, hann apod', fontsize=10)

    fig.show()
