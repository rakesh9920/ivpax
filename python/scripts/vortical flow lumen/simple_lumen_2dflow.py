# scripts / simple_lumen_2dflow

import h5py
import numpy as np

file_path = './data/simple lumen flow/vortical_lumen_data.hdf5'
#u1_key = 'flowdata/corr_lag/fluid2_sub0_16'
#u2_key = 'flowdata/corr_lag/fluid2_sub15_16'
#u3_key = 'flowdata/corr_lag/fluid2_full'
u1_key = 'flowdata/corr_lag/fluid2_sub0_16'
u2_key = 'flowdata/corr_lag/fluid2_sub2_16'
u3_key = 'flowdata/corr_lag/fluid2_sub4_16'
u4_key = 'flowdata/corr_lag/fluid2_sub6_16'
u5_key = 'flowdata/corr_lag/fluid2_sub8_16'
u6_key = 'flowdata/corr_lag/fluid2_sub10_16'
u7_key = 'flowdata/corr_lag/fluid2_sub12_16'
u8_key = 'flowdata/corr_lag/fluid2_sub14_16'
u9_key = 'flowdata/corr_lag/fluid2_sub15_16'

view_key = 'view/view0'
output_key = 'flowdata/estimate_5sub'

def mag(x): return np.sqrt(x.dot(x))


if __name__ == '__main__':
    
    with h5py.File(file_path, 'a') as root:
        
        #u1 = np.expand_dims(root[u1_key][:], 1)
        #u2 = np.expand_dims(root[u2_key][:], 1)
        #u3 = np.expand_dims(root[u3_key][:], 1)
        #u = np.concatenate((u1, u2, u3), axis=1)
        #u = np.concatenate((u1, u2), axis=1)
        u1 = np.expand_dims(root[u1_key][:], 1)
        u2 = np.expand_dims(root[u2_key][:], 1)
        u3 = np.expand_dims(root[u3_key][:], 1)
        u4 = np.expand_dims(root[u4_key][:], 1)
        u5 = np.expand_dims(root[u5_key][:], 1)
        u6 = np.expand_dims(root[u6_key][:], 1)
        u7 = np.expand_dims(root[u7_key][:], 1)
        u8 = np.expand_dims(root[u8_key][:], 1)
        u9 = np.expand_dims(root[u9_key][:], 1)
        u = np.concatenate((u1, u2, u3, u4, u5, u6, u7, u8, u9), axis=1)
        
        #pos1 = root[u1_key].attrs['sub_rx_position']
        #pos2 = root[u2_key].attrs['sub_rx_position']
        #pos3 = root[u3_key].attrs['sub_rx_position']
        pos1 = root[u1_key].attrs['sub_rx_position']
        pos2 = root[u2_key].attrs['sub_rx_position']
        pos3 = root[u3_key].attrs['sub_rx_position']
        pos4 = root[u4_key].attrs['sub_rx_position']
        pos5 = root[u5_key].attrs['sub_rx_position']
        pos6 = root[u6_key].attrs['sub_rx_position']
        pos7 = root[u7_key].attrs['sub_rx_position']
        pos8 = root[u8_key].attrs['sub_rx_position']
        pos9 = root[u9_key].attrs['sub_rx_position']
        
        view = root[view_key][:]
        
        npos = u.shape[0]
        nframe = u.shape[2]
        
        vel = np.zeros((npos, 3, nframe))
        
        for pos in xrange(npos):
            
            fieldpos = view[pos,:]

            #v1 = ((fieldpos - pos1)/mag(fieldpos - pos1))
            #v2 = ((fieldpos - pos2)/mag(fieldpos - pos2))
            #v3 = ((fieldpos - pos3)/mag(fieldpos - pos3))
            #vz = np.array([0,0,1])   
            v1 = ((fieldpos - pos1)/mag(fieldpos - pos1))
            v2 = ((fieldpos - pos2)/mag(fieldpos - pos2))
            v3 = ((fieldpos - pos3)/mag(fieldpos - pos3))
            v4 = ((fieldpos - pos4)/mag(fieldpos - pos4))
            v5 = ((fieldpos - pos5)/mag(fieldpos - pos5))
            v6 = ((fieldpos - pos6)/mag(fieldpos - pos6))
            v7 = ((fieldpos - pos7)/mag(fieldpos - pos7))
            v8 = ((fieldpos - pos8)/mag(fieldpos - pos8))
            v9 = ((fieldpos - pos9)/mag(fieldpos - pos9))
            vz = np.array([0,0,1])  
            
            #transform = np.vstack(((v1 + v3)/2, (v2 + v3)/2, v3))
            #transform = np.vstack(((v1 + vz)/2, (v2 + vz)/2))
            #transform = np.vstack(((v1 + vz)/2, (v2 + vz)/2, (vz + vz)/2))
            transform = np.vstack((v1, v3, v5, v7, v9)) + vz
            transform /= 2.
            
            #normal = np.dot(transform.T, transform)
            pseudoinv = np.linalg.pinv(transform)
            
            for frame in xrange(nframe):
                
                #vel[pos,:,frame] = np.linalg.solve(normal, np.dot(transform.T, 
                    #u[pos,:,frame]))
                #vel[pos,:,frame] = pseudoinv.dot(u[pos,0:2,frame])
                vel[pos,:,frame] = pseudoinv.dot(u[pos,0::2,frame])
        
        #vel = np.insert(vel, 1, 0, axis=1)
        #vel[:,2,:] = -vel[:,2,:]
        #vel = np.insert(vel, 1, 0, axis=1)
        #vel = np.insert(vel, 1, 0, axis=1)
        #vel[:,2,:] = np.squeeze(u3)
        
        if output_key in root:
            del root[output_key]
        
        root.create_dataset(output_key, data=vel, compression='gzip')
                
                