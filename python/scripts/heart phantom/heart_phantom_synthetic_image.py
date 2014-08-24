# scripts / carotid_phantom_synthetic_image.py

import h5py
import numpy as np
from matplotlib import pyplot as plt
from mpl_toolkits.axes_grid1 import make_axes_locatable

from pyfield.beamform import envelope, imdisp

h5_file_path = './data/heart_phantom_data.h5'
bf_key = 'bfdata/synthetic/full'
npz_file_path = './data/heart_phantom_data.npz'

def savenpz():
    
    with h5py.File(h5_file_path, 'r') as root:
        bfdata = root[bf_key][:]
    
    envdata = envelope(bfdata[:,:,0])
    
    image = envdata[:,50].reshape((280, 400))
    r = np.arange(0.001, 0.071, 0.00025)*100
    phi = np.linspace(-np.pi/4, np.pi/4, 400, endpoint=True)
    
    npzvars = dict()
    
    npzvars['image'] = image
    npzvars['r'] = r
    npzvars['phi'] = phi
    
    np.savez(npz_file_path, **npzvars)
    
if __name__ == '__main__':

    
    with np.load(npz_file_path) as npzvars:
        
        r = npzvars['r']
        phi = npzvars['phi']
        image = npzvars['image']
        
    rstart = 28
    rstop = 210
    phistart = 40
    phistop = 360
    
    plt.rc('mathtext', fontset='stix', default='regular')
    plt.rc('axes', linewidth = 0.6)
    
    fig = plt.figure(figsize=(3.5,2.4), tight_layout=True)
    ax = fig.add_subplot(111)
    
    pc = imdisp(image[rstart:rstop, phistart:phistop], r=r[rstart:rstop], 
        phi=phi[phistart:phistop], dyn=50, ax=ax, interp=True)
        
    ax.invert_yaxis()
    ax.set_xticks([-3, -1, 1, 3])
    ax.set_yticks([1, 3, 5])
    #ax.set_xticks([])
    #ax.set_yticks([])
    ax.set_axis_bgcolor('black')
    ax.set_ylim((5.4, 0.7))
    ax.set_xlim((-3.2, 3.2))
    ax.set_xlabel('Lateral (cm)', fontsize=9)
    ax.set_ylabel('Axial (cm)', fontsize=9)
    ax.tick_params(labelsize=9)
    
    ax.text(-1.1, 1.4, 'RA', color='white', fontsize=12)
    ax.text(0.7, 3.2, 'LA', color='white', fontsize=12)
      
    ax.annotate('IAS', xy=(0.1, 1.5), xycoords='data', xytext=(1, 1.9), 
        textcoords='data', arrowprops=dict(arrowstyle='->', 
        connectionstyle='arc3', color='white'), color='white', fontsize=12)
            
    divider = make_axes_locatable(ax)
    cax = divider.append_axes("right", size="5%", pad=0.05)
    cbar = fig.colorbar(pc, cax=cax)
    cbar.set_ticks([0, -25, -50])
    cbar.set_label('dB (re max)', fontsize=9)
    cbar.ax.tick_params(labelsize=9)
        
    fig.show()
