# scripts / make_carotid_phantom.py

from pyfield.field import sct_rectangle

from matplotlib.pylab import imread
import numpy as np

file_path = ''
key = ''
img = np.mean(imread('./data/carotid_artery_map.bmp'), axis=2)
levels = np.unique(img)
tissue = ('dermis', 'fat', 'artery wall', 'plaque', 'blood')
range_x = (-0.02, 0.02)
range_y = (-0.005, 0.005)
range_z = (0.001, 0.031)
target_density = 20*1000**3

if __name__ == '__main__':
    
    target_pos = sct_rectangle(range_x, range_y, range_z, ns=target_density)
    
    
    
    pass