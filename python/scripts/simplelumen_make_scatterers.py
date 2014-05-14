# scripts / make_simple_lumen_scatterers.py

from pyfield.field import sct_rectangle

import h5py
import numpy as np
import scipy as sp

def velocity_field(x, y, z, cat=False):
    
    omega = 15 # angular velocity in rad/s
    r_cutoff = 0.0075
    
    theta = sp.arctan2(y, x)
    r = np.sqrt(x**2 + y**2)
    
    vel_x = -omega*r*sp.sin(theta)
    vel_y = omega*r*sp.cos(theta)
    vel_z = np.ones_like(vel_x)*0.01
    
    mask = (r > r_cutoff)
    vel_x[mask] = 0
    vel_y[mask] = 0
    vel_z[mask] = 0
    
    if cat:
        return np.concatenate((vel_x, vel_y, vel_z), axis=1)
    else:
        return vel_x, vel_y, vel_z
    
if __name__ == '__main__':
      
    # lumen dia = 15mm, lumen thickness = 3mm, height = 30mm
    ns = 20*1000**3
    nframe = 1
    prf = 1000
    file_path = './data/simple_lumen_experiments.hdf5'
    out_key = 'field/targdata/'
    range_x = (-0.01, 0.01)
    range_y = (-0.01, 0.01)
    range_z = (0.01, 0.04)
    
    out_path = (file_path, out_key)

    fluid = sct_rectangle(range_x, range_y, range_z, ns=ns)
    fluid_ntarget = fluid.shape[0]
    fluid_amp = np.ones((fluid_ntarget, 1))
    
    with h5py.File(out_path[0], 'a') as root:

        key = out_path[1]
        
        if key in root:
            del root[key]

        fluid_dset = root.create_dataset(key + 'fluid',
            shape=(fluid_ntarget, 4, nframe), dtype='double',
            compression='gzip')
            
        fluid_dset[:,:,0] = np.concatenate((fluid, fluid_amp), axis=1)
        
        for f in xrange(1, nframe):
            
            new_fluid = fluid + velocity_field(fluid[:,0], fluid[:,1], 
                fluid[:,2], cat=True)*prf
                
            fluid_dset[:,:,f] = np.concatenate((new_fluid, fluid_amp), axis=1)
            
            fluid = new_fluid

        fluid_dset.attrs['target_density'] = ns
        fluid_dset.attrs['pulse_repitition_frequency'] = prf
