# scripts / custombsc_scatter_plot

from pyfield.field import xdc_load_info, sct_sphere, xdc_draw
from matplotlib import pyplot as plt
from mpl_toolkits.mplot3d import Axes3D
import numpy as np



if __name__ == '__main__':
    
    target_pos = sct_sphere((0.015, 0.025), (0, np.pi), (0, np.pi/2), 
        ns=20*1000**3)
    ntarget = target_pos.shape[0]
    
    info = xdc_load_info('./pyfield/field/focused_piston_f4.npz')


    