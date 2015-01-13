
import numpy as np
from matplotlib import pyplot as plt
import h5py

#with np.load('./data/xz_flow_data.npz') as data:
#    
#    #fdata_inst = data['fdata_inst']
#    fdata_corrlag = data['fdata_corrlag']
#    fdata_actual = data['fdata_actual']
#    x = data['x']
#    y = data['y']
#    z = data['z']

with h5py.File('./data/simple lumen flow/vortical_lumen_data.hdf5','r') as root:
    
    fdata_corrlag = root['flowdata/estimate_2sub'][:].reshape((20,20,30,3,-1))
    fdata_actual = root['flowdata/actual'][:]
    view = root['view/view0'][:].reshape((20,20,30, 3))
    x = view[...,0]
    y = view[...,1]
    z = view[...,2]
    
if __name__ == '__main__':

    
    #v = fdata_actual.reshape((20, 20, 30, 3))
    #actual = fdata_actual[...,0]
    actual = fdata_actual
    
    flow = fdata_corrlag[...,0]
    #flow = fdata_corrlag[...,0]
    error = flow - actual
    
    error_x = error[...,0].ravel()
    error_y = error[...,1].ravel()
    error_z = error[...,2].ravel()
    
    plt.rc('mathtext', fontset='stix', default='regular')
    plt.rc('axes', linewidth = 0.6)
    
    fig1 = plt.figure(figsize=(3.5,2.7), dpi=100, tight_layout=True)
    ax1 = fig1.add_subplot(111)
    h1, b1, _ = ax1.hist(error_x, 100, range=(-0.015, 0.015), alpha=0.5, lw=0.7, 
        histtype='stepfilled')
    h2, b2, _ = ax1.hist(error_y, 100, range=(-0.015, 0.015), alpha=0.5, lw=0.7, 
        histtype='stepfilled')
    h3, b3, _ = ax1.hist(error_z, 100, range=(-0.015, 0.015), alpha=0.5, lw=0.7, 
        histtype='stepfilled')
    ax1.legend(('x','y','z'), loc=2, fontsize=9, frameon=False)
    ax1.set_xlim(-0.015, 0.015)
    ax1.set_ylim(20, 4200)
    ax1.set_xticks(np.linspace(-0.02, 0.02, 5))
    ax1.tick_params(labelsize=9)
    ax1.set_xlabel('Velocity (m/s)', fontsize=9)
    ax1.set_ylabel('Number of occurrences', fontsize=9)
    fig1.show()

    #fig2 = plt.figure(figsize=(3.5,2.7), dpi=100, tight_layout=True)
    #ax2 = fig2.add_subplot(111)
    #ax2.plot(b1[:-1], h1, alpha=0.5)
    #ax2.plot(b2[:-1], h2, alpha=0.5)
    #ax2.plot(b3[:-1], h3, alpha=0.5)
    #ax2.legend(('x','y','z'), loc=2, fontsize=9, frameon=False)
    #ax2.set_xlim(-0.015, 0.005)
    #ax2.tick_params(labelsize=9)
    #ax2.set_xlabel('Velocity (m/s)', fontsize=9)
    #ax2.set_ylabel('Number of occurrences', fontsize=9)
    #fig2.show()
    
    print np.mean(error_x), np.std(error_x)
    print np.mean(error_y), np.std(error_y)
    print np.mean(error_z), np.std(error_z)
