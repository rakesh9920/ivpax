# pyfield / util / plotting.py

from mpl_toolkits.mplot3d import Axes3D
from matplotlib import pyplot as pp
import numpy as np

def scatter3d(x, y=None, z=None, mask=1, color='b', size=20, alpha=0.7, 
    marker='o', ax=None):
    
    if y is None:
        y = x[:,1]
        z = x[:,2]
        x = x[:,0]
    
    if ax is None:
        fig = pp.figure()
        ax = fig.add_subplot(111, projection='3d')
        
    if mask > 1:
        
        idx = np.random.permutation(x.shape[0])
        idx = idx[:np.round(x.shape[0]/mask)]
    
        ax.scatter(x[idx], y[idx], z[idx], c=color, s=size, alpha=alpha, 
            marker=marker, linewidth=1)
    else:
        
        ax.scatter(x, y, z, c=color, s=size, alpha=alpha, marker=marker, 
            linewidth=1)
            
    return ax