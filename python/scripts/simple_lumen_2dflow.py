# scripts / simple_lumen_2dflow

import h5py
import numpy as np
import numpy.linalg as la

file_path = './data/simple lumen flow/simple_lumen_data.hdf5'
u1_key = 'flowdata/fluid2_sub0'
u2_key = 'flowdata/fluid2_sub15'
u3_key = 'flowdata/fluid2_full'
view_key = 'view/view0'
output_key = 'flowdata/fluid2_3d_1'

def mag(x): return np.sqrt(x.dot(x))


if __name__ == '__main__':
    
    with h5py.File(file_path, 'a') as root:
        
        u1 = np.expand_dims(root[u1_key][:], 1)
        u2 = np.expand_dims(root[u2_key][:], 1)
        u3 = np.expand_dims(root[u3_key][:], 1)
        #u = np.concatenate((u1, u2, u3), axis=1)
        u = np.concatenate((u1, u2), axis=1)
        
        pos1 = root[u1_key].attrs['sub_rx_position']
        pos2 = root[u2_key].attrs['sub_rx_position']

        view = root[view_key][:]
        
        npos = u.shape[0]
        nframe = u.shape[2]
        
        vel = np.zeros((npos, 1, nframe))
        
        for pos in xrange(npos):
            
            fieldpos = view[pos,:]
            
            #v1 = ((fieldpos - pos1)/mag(fieldpos - pos1))[[0,2]]
            #v2 = ((fieldpos - pos2)/mag(fieldpos - pos2))[[0,2]]
            v1 = ((fieldpos - pos1)/mag(fieldpos - pos1))[0]
            v2 = ((fieldpos - pos2)/mag(fieldpos - pos2))[0]
            
            #transform = np.vstack((v1, v2, [0, 1]))
            transform = np.vstack((v1, v2))
            
            normal = np.dot(transform.T, transform)
            
            for frame in xrange(nframe):
                
                vel[pos,:,frame] = np.linalg.solve(normal, np.dot(transform.T, 
                    u[pos,:,frame]))
        
        #vel = np.insert(vel, 1, 0, axis=1)
        #vel[:,2,:] = -vel[:,2,:]
        vel = np.insert(vel, 1, 0, axis=1)
        vel = np.insert(vel, 1, 0, axis=1)
        vel[:,2,:] = -np.squeeze(u3)
        
        if output_key in root:
            del root[output_key]
        
        root.create_dataset(output_key, data=vel, compression='gzip')
                
                