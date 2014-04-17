# pyfield / testers / pooledsimulation_tester.py

from pyfield import PooledSimulation
import h5py
import numpy as np
import scipy as sp

sim = PooledSimulation()

root = h5py.File('testdata.hdf5', 'w')

targets = root.create_dataset('field/targets/set0', (50000, 4), dtype='double',
    compression='lzf')
targets[:,0:2] = np.zeros((50000,2))
targets[:,2] = sp.rand(1,50000)*0.01 + 0.001
targets[:,3] = np.ones((50000,))
targets.attrs.create('frame_no', 1)

root.close()

sim.script = 'linear_array_128_5mhz'
sim.indata = ('testdata.hdf5', 'field/targets/set0')
sim.outdata = ('testdata.hdf5', 'field/rf/set0')

if __name__ == '__main__':
    
    sim.start_sim(nproc=2)


