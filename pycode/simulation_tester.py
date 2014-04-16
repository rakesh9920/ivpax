from pyfield import Simulation
import h5py
import numpy as np

sim = Simulation()

data = h5py.File('testdata.hdf5', 'w')

targ = data.create_dataset('field/targets/set0', (100, 4), compression='lzf')
targ[:,0:2] = np.zeros((100,2))
targ[:,2] = np.linspace(0.001, 0.05, 100)
targ[:,3] = np.ones((100,))
targ.attrs.create('frame_no', 1)
targ.attrs.create('sample_frequency', 100e6)

data.close()

sim.script = 'linear_array_128_5mhz'
sim.indata = ('testdata.hdf5', 'field/targets/set0')
sim.outdata = ('testdata.hdf5', 'field/rf/set0')

if __name__ == '__main__':
    
    sim.jobs = []
    res = sim.start_sim(nproc=1)


