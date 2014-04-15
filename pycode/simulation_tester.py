from pyfield import Simulation
import h5py
import numpy as np

sim = Simulation()

data = h5py.File('testdata.hdf5', 'w')

targ = data.create_dataset('targets', (100, 4))
targ[:,0:2] = np.zeros((100,2))
targ[:,2] = np.linspace(0.001, 0.05, 100)
targ[:,3] = np.ones((100,))

data.close()

sim.set_script('linear_array_128_5mhz')
sim.set_dataset('testdata.hdf5')

res = sim.start(nproc=1)


