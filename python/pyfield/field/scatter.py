# pyfield / field / scatter.py
import h5py
import numpy as np
import scipy as sp

def sct_cube(outpath, dims=None, center=None, vel=None, nframe=None, ns=None, 
    prf=None):
    
    center = np.array(center)
    vel = np.array(vel)
    
    ntarget = int(round(dims[0]*dims[1]*dims[2]*ns))
    
    x = sp.rand(ntarget, 1)*dims[0]
    y = sp.rand(ntarget, 1)*dims[1]
    z = sp.rand(ntarget, 1)*dims[2]
    
    target_pos = (np.concatenate((x, y, z), axis=1) - np.array(dims)[None,:]/2 + 
        center)
    #amp = np.ones((ntarget, 1))
    
    #root = h5py.File(outpath[0], 'a')
    #
    #try:
    #    
    #    path = outpath[1]
    #    
    #    if path in root:
    #        del root[path]
    #    
    #    dset = root.create_dataset(path, shape=(ntarget, 4, nframe), 
    #        dtype='double', compression='gzip')
    #    
    #    dset[:,:,0] = np.concatenate((pos, amp), axis=1)
    #    
    #    for f in xrange(1, nframe):
    #        
    #        new_pos = pos + vel/prf*f
    #        dset[:,:,f] = np.concatenate((new_pos, amp), axis=1)
    #
    #finally:
    #    
    #    root.close()
    
    return target_pos

def sct_rectangle(range_x, range_y, range_z, origin=None, ns=None):
    
    if origin is None:
        origin = np.zeros((1,3))
    
    length_x = range_x[1] - range_x[0]
    length_y = range_y[1] - range_y[0]
    length_z = range_z[1] - range_z[0]
    
    org = np.array([[length_x/2 + range_x[0], length_y/2 + range_y[0], 
        length_z/2 + range_z[0]]])
    
    ntarget = np.round(length_x*length_y*length_z*ns)
    
    pos_x = sp.rand(ntarget, 1)*length_x
    pos_y = sp.rand(ntarget, 1)*length_y
    pos_z = sp.rand(ntarget, 1)*length_z    
    
    target_pos = (np.concatenate((pos_x, pos_y, pos_z), axis=1) - 
        np.array([[length_x/2, length_y/2, length_z/2]]) + org + origin)
        
    return target_pos    

def sct_sphere(rrange, trange, prange, origin=None, ns=None):
    
    if origin is None:
        origin = np.zeros((1,3))
        
    length = 2*rrange[1]
    ntarget = np.round((length)**3*ns)
    
    xpos = sp.rand(ntarget, 1)*length
    ypos = sp.rand(ntarget, 1)*length
    zpos = sp.rand(ntarget, 1)*length
    
    target_pos = np.concatenate((xpos, ypos, zpos), axis=1) - length/2
    
    # remove points outside radius range
    r = np.sqrt(target_pos[:,0]**2 + target_pos[:,1]**2 + target_pos[:,2]**2)
    mask = (r >= rrange[0]) & (r <= rrange[1])
    
    target_pos = target_pos[mask,:]
    r = r[mask]
    
    # remove points outside theta range
    theta = sp.arctan2(target_pos[:,1], target_pos[:,0])
    theta[theta < 0] = theta[theta < 0] + 2*np.pi
    mask = (theta >= trange[0]) & (theta <= trange[1])
    
    target_pos = target_pos[mask,:]
    r = r[mask]
    
    # remove points outside phi range
    phi = np.arccos(target_pos[:,2]/r)
    mask = (phi >= prange[0]) & (phi <= prange[1])
    target_pos = target_pos[mask,:]
    
    target_pos += origin.reshape((1,3))
    
    return target_pos

def sct_cylinder(rrange, trange, zrange, origin=None, ns=None):
    
    if origin is None:
        origin = np.zeros((1,3))
        
    length_x = rrange[1]*2
    length_y = rrange[1]*2
    length_z = zrange[1] - zrange[0]
    
    ntarget = np.round(length_x*length_y*length_z*ns)
    
    pos_x = sp.rand(ntarget, 1)*length_x
    pos_y = sp.rand(ntarget, 1)*length_y
    pos_z = sp.rand(ntarget, 1)*length_z
    
    target_pos = (np.concatenate((pos_x, pos_y, pos_z), axis=1) - 
        np.array([[length_x/2, length_y/2, zrange[0]]]))
    
    # remove points outside radius range
    r = np.sqrt(target_pos[:,0]**2 + target_pos[:,1]**2)
    mask = (r >= rrange[0]) & (r <= rrange[1])
    
    target_pos = target_pos[mask,:]
    r = r[mask]
    
    # remove points outside theta range
    theta = sp.arctan2(target_pos[:,1], target_pos[:,0])
    theta[theta < 0] = theta[theta < 0] + 2*np.pi
    mask = (theta >= trange[0]) & (theta <= trange[1])
    
    target_pos = target_pos[mask,:]
    r = r[mask]
    
    # remove points outside zrange
    z = target_pos[:,2]
    mask = (z >= zrange[0]) & (z <= zrange[1])
    
    target_pos = target_pos[mask,:]  
    
    target_pos += origin.reshape((1,3))
    
    return target_pos

#from mayavi import mlab

#x, y, z = np.mgrid[-0.01:0.01:0.001, -0.01:0.01:0.001,0:0.02:0.001]
#src = mlab.pipeline.vector_field(x, y, z, velocity_field)
#vec = mlab.pipeline.vectors(src, scale_factor=0.0015)
#
#mask = vec.glyph.mask_points
#mask.maximum_number_of_points = 10000
#mask.on_ratio = 2
#vec.glyph.mask_input_points = True
#
#mlab.show()

def simple_lumen(out_path, ns=None, nframe=None, prf=None):
    
    def velocity_field(x, y, z):
        
        omega = 15 # angular velocity in rad/s
        
        theta = sp.arctan2(y, x)
        r = np.sqrt(x**2 + y**2)
        
        vel_x = -omega*r*sp.sin(theta)
        vel_y = omega*r*sp.cos(theta)
        vel_z = np.ones_like(vel_x)*0.01
            
        return np.array([[vel_x, vel_y, vel_z]])
    
    # lumen dia = 15mm, lumen thickness = 3mm, height = 30mm
    ns = 10*1000**3
    
    wall = sct_cylinder(rrange=(0.0075, 0.0105), trange=(0, 2*np.pi), 
        zrange=(0.01, 0.04), ns=ns)
    
    fluid = sct_cylinder(rrange=(0, 0.0075), trange=(0, 2*np.pi),
        zrange=(0.01, 0.04), ns=ns)
    
    wall_ntarget = wall.shape[0]
    fluid_ntarget = fluid.shape[0]
    wall_amp = np.ones((wall_ntarget, 1))
    fluid_amp = np.ones((fluid_ntarget, 1))
    
    with h5py.File(out_path[0], 'a') as root:

        key = out_path[1]
        
        if key in root:
            del root[key]
        
        wall_dset = root.create_dataset(key + 'wall', 
            data=np.concatenate((wall, wall_amp), axis=1), dtype='double', 
            compression='gzip')

        fluid_dset = root.create_dataset(key + 'fluid',
            shape=(fluid_ntarget, 4, nframe), dtype='double',
            compression='gzip')
            
        fluid_dset[:,:,0] = np.concatenate((fluid, fluid_amp), axis=1)
        
        for f in xrange(1, nframe):
            
            new_fluid = fluid + velocity_field(fluid[:,0], fluid[:,1], 
                fluid[:,2])*prf
                
            fluid_dset[:,:,f] = np.concatenate((new_fluid, fluid_amp), axis=1)
            
            fluid = new_fluid
        
        wall_dset.attrs['target_density'] = ns
        wall_dset.attrs['pulse_repitition_frequency'] = prf
        fluid_dset.attrs['target_density'] = ns
        fluid_dset.attrs['pulse_repitition_frequency'] = prf

