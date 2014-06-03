# scripts / custombsc_scatter_plot

from pyfield.field import xdc_load_info, sct_sphere, xdc_draw
from pyfield.util import scatter3d
from matplotlib import pyplot as plt
from mpl_toolkits.mplot3d import Axes3D
import numpy as np



if __name__ == '__main__':
    
    plt.rc('mathtext', fontset='stix', default='regular')
    plt.rc('axes', linewidth = 0.6)
    
    target_pos = sct_sphere((0.015, 0.025), (0, np.pi), (0, np.pi/2), 
        ns=1*1000**3)
    ntarget = target_pos.shape[0]
    
    info = xdc_load_info('./pyfield/field/focused_piston_f4.npz')
    #
    vert_x = info['vert_x']*1000
    vert_y = info['vert_y']*1000
    vert_z = info['vert_z']*1000
    nelement = vert_x.shape[1]

    # make plot
    fig = plt.figure(figsize=(3.5, 2.7), dpi=100, tight_layout=True)
    
    ax = fig.add_subplot(111, projection='3d')
    
    for ele in xrange(nelement):
        
        ax.plot_wireframe(vert_x[:,ele].reshape((2,2)), 
            vert_y[:,ele].reshape((2,2)), vert_z[:,ele].reshape((2,2)), 
            color='r', edgecolor='r', linewidth=0.1)
            
    #xdc_draw('./pyfield/field/focused_piston_f4.npz', color='r', wireframe=True,
        #ax=ax)
    
    scatter3d(target_pos*1000, mask=2, size=1, ax=ax)
    
    ax.set_xlim((-25, 25))
    ax.set_ylim((-25, 25))
    ax.set_zlim((-12.5, 37.5))
    ax.tick_params(labelsize=8)
    ax.set_xticks(np.arange(-25, 30, 10))
    ax.set_yticks(np.arange(-25, 30, 10))
    ax.set_zticks(np.arange(0, 30, 10))
    ax.set_aspect('equal','box')

    ax.set_xlabel('x (mm)', fontsize=10)
    ax.set_ylabel('y (mm)', fontsize=10)
    ax.set_zlabel('z (mm)', fontsize=10)

    
    #ax.scatter(target_pos[:,0], target_pos[:,1], target_pos[:,2], s=0.01,
    #    c='blue', alpha=0.8, edgecolor='blue', linewidth=1)
    
    fig.show()
    
    
    
    