# scripts / simple_lumen_make_scatterers.py

from pyfield.field import sct_rectangle

import h5py
import numpy as np
import scipy as sp
from scipy.integrate import ode

######################### SET SCRIPT PARAMETERS HERE ###########################
file_path = './data/diagonal_lumen_data.h5'
out_key = 'field/targdata/fluid0'
ns = 20*1000**3
nframe = 10
prf = 1000
range_x = (-0.01, 0.01)
range_y = (-0.01, 0.01)
range_z = (0.01, 0.04)
################################################################################
    
#def velocity_field(x, y, z, cat=False):
#    
#    omega = 1.33 # angular velocity in rad/s
#    r_cutoff = 0.0075
#    
#    theta = sp.arctan2(y, x)
#    r = np.sqrt(x**2 + y**2)
#    
#    vel_x = (-omega*r*sp.sin(theta))#[:,None]
#    vel_y = (omega*r*sp.cos(theta))#[:,None]
#    vel_z = np.ones_like(vel_x)*0.01
#    
#    #mask = (r > r_cutoff)
#    #vel_x[mask] = 0
#    #vel_y[mask] = 0
#    #vel_z[mask] = 0
#    
#    if cat:
#        return np.concatenate((vel_x, vel_y, vel_z), axis=1)
#    else:
#        return vel_x, vel_y, vel_z
        
def flow_field_viz(x, y, z, t):
    
    f = lambda x: flow_field(t, x)

    dim = x.ndim
    r = np.concatenate([x[...,None], y[...,None], z[...,None]], axis=dim)
    
    vel = np.apply_along_axis(f, dim, r)
    
    return vel[...,0], vel[...,1], vel[..., 2]
    
    
def flow_field(t, r):
    
    omega = 1.33 # angular velocity in rad/s
    
    theta = sp.arctan2(r[1], r[0])
    r = np.sqrt(r[0]**2 + r[1]**2)
    
    vel_x = -omega*r*sp.sin(theta)
    vel_y = omega*r*sp.cos(theta)
    vel_z = 0.01
    
    return [vel_x, vel_y, vel_z]

def flow_field2(t, r):
    
    vel_x = 0.01 #-omega*r*sp.sin(theta)
    vel_y = 0.01 #omega*r*sp.cos(theta)
    vel_z = 0.01
    
    return [vel_x, vel_y, vel_z]
    
def trajectory(ipos, dt, nstep, ode_obj):
    
    ode_obj.set_initial_value(ipos, t=0.0)
    
    pos = np.zeros((3, nstep))
    pos[:,0] = ipos
    
    for n in xrange(1, nstep):
        
        ode_obj.integrate(n*dt)
        pos[:,n] = ode_obj.y
    
    return pos

def trajectory2(ipos, t, ode_obj):
    
    ode_obj.set_initial_value(ipos, t=0.0)
    
    ode_obj.integrate(t)
    
    return ode_obj.y
        
if __name__ == '__main__':
    
    # set script parameters
    # lumen dia = 15mm, lumen thickness = 3mm, height = 30mm
    #file_path = './data/simple lumen flow/simple_lumen_experiments.hdf5'
    #out_key = 'field/targdata/fluid2'
    #ns = 20*1000**3
    #nframe = 2
    #prf = 1000
    #range_x = (-0.01, 0.01)
    #range_y = (-0.01, 0.01)
    #range_z = (0.01, 0.04)
    
    out_path = (file_path, out_key)

    fluid = sct_rectangle(range_x, range_y, range_z, ns=ns)
    fluid_ntarget = fluid.shape[0]
    fluid_amp = np.ones((fluid_ntarget, 1))
    
    solver = ode(flow_field2)
    solver.set_integrator('dopri5')
    
    with h5py.File(out_path[0], 'a') as root:

        key = out_path[1]
        
        if key in root:
            del root[key]
    
        fluid_dset = root.create_dataset(key, shape=(fluid_ntarget, 4, nframe), 
            dtype='double', compression='gzip')
            
        fluid_dset[:,:,0] = np.concatenate((fluid, fluid_amp), axis=1)
        
        #for r in xrange(fluid_ntarget):
        #    
        #    ipos = fluid[r,:]
        #    pos = trajectory(ipos, 1/prf, nframe, solver)
        #    
        #    fluid_dset[r,0:3,:] = pos
        #
        #fluid_dset[:,3,:] = np.ones((fluid_ntarget, nframe))
        
        #for f in xrange(1, nframe):
        #    
        #    new_fluid = fluid + flow_field_viz(fluid[:,0], fluid[:,1], 
        #        fluid[:,2], 0)/prf
        #        
        #    fluid_dset[:,:,f] = np.concatenate((new_fluid, fluid_amp), axis=1)
        #    
        #    fluid = new_fluid

        for f in xrange(1, nframe):
            
            print f
            new_fluid = np.apply_along_axis(trajectory2, 1, fluid, 
                float(f)/prf, solver)
            fluid_dset[:,:,f] = np.concatenate((new_fluid, fluid_amp), axis=1)
            
        fluid_dset.attrs['target_density'] = ns
        fluid_dset.attrs['pulse_repitition_frequency'] = prf
