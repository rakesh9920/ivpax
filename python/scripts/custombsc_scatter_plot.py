# scripts / custombsc_scatter_plot

from pyfield.field import xdc_load_info, sct_sphere, xdc_draw
from matplotlib import pyplot as plt
from mpl_toolkits.mplot3d import Axes3D
import numpy as np



if __name__ == '__main__':
    
    rc('mathtext', fontset='stix', default='regular')
    rc('axes', linewidth = 0.6)
    
    target_pos = sct_sphere((0.015, 0.025), (0, np.pi), (0, np.pi/2), 
        ns=1*1000**3)
    ntarget = target_pos.shape[0]
    
    info = xdc_load_info('./pyfield/field/focused_piston_f4.npz')
    
    vert_x = info['vert_x']
    vert_y = info['vert_y']
    vert_z = info['vert_z']
    nelement = vert_x.shape[1]

    # make plot
    fig = plt.figure(figsize=(3.5, 2.7), dpi=100)
    
    ax = fig.add_subplot(111, projection='3d')
    ax.set_xlim((-0.025, 0.025))
    ax.set_ylim((-0.025, 0.025))
    ax.set_zlim((0, 0.025))
    ax.tick_params(labelsize=8)
    #ax.set_aspect('equal')

    for ele in xrange(nelement):
        
        ax.plot_surface(vert_x[:,ele].reshape((2,2)), 
            vert_y[:,ele].reshape((2,2)), vert_z[:,ele].reshape((2,2)), 
            color='r', edgecolor='r')
    
    #ax.scatter(target_pos[:,0], target_pos[:,1], target_pos[:,2], s=0.01,
    #    c='blue', alpha=0.8, edgecolor='blue', linewidth=1)
    
    fig.show()
    
    
    
    