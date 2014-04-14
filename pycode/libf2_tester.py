import ctypes as ct
import numpy as np
import scipy as sp
import matplotlib.pyplot as plt
import multiprocessing as mp
from sys import argv

c_double_p = ct.POINTER(ct.c_double)

class ArrayInfo(ct.Structure):
    _fields_ = [("ptr", c_double_p),
                ("nrows", ct.c_int),
                ("ncols", ct.c_int),
                ("t0", ct.c_double)]
                
def getArrayInfo(array):
    
    ptr = array.ctypes.data_as(c_double_p)
    nrows = ct.c_int(array.shape[0])
    ncols = ct.c_int(array.shape[1])
    
    #if array.ndim > 1:
    #    ncols = ct.c_int(array.shape[1])
    #else:
    #    ncols = ct.c_int(1)
    
    return ArrayInfo(ptr, nrows, ncols, ct.c_double(0))
    
def sim(results, p=0):
    
    f0 = 5e6
    fs = 100e6
    
    impulse_response = sp.sin(2*sp.pi*f0*np.arange(0, 1/f0 + 1/fs, 1/fs))
    impulse_response = impulse_response*(sp.hanning(np.size(impulse_response)))
    impulse_response.shape = (1, np.size(impulse_response)) # force row vector
    excitation = impulse_response.copy()
    
    f2 = ct.cdll.libf2
    
    # set function prototypes
    f2.f2_xdc_piston.restype = ct.c_int
    f2.f2_calc_scat.restype = ArrayInfo
    f2.f2_calc_scat.argtypes = [ct.c_int, ct.c_int, ct.POINTER(ArrayInfo),
        ct.POINTER(ArrayInfo)]
    f2.f2_xdc_impulse.argtypes = [ct.c_int, ct.POINTER(ArrayInfo)]
    f2.f2_xdc_excitation.argtypes = [ct.c_int, ct.POINTER(ArrayInfo)]
    
    # initialize libf2
    f2.initializeWithDiary("cout" + str(p) + ".txt") 
    f2.f2_field_init(0)
    
    # define apertures
    Th = f2.f2_xdc_piston(ct.c_double(0.01), ct.c_double(0.001))
    imp = getArrayInfo(impulse_response)
    f2.f2_xdc_impulse(Th, ct.byref(imp))
    exc = getArrayInfo(excitation)
    f2.f2_xdc_excitation(Th, ct.byref(exc))
     
    # define scatterers
    points = np.array([0, 0, 0.01], dtype="double")
    points.shape = (1, 3)
    amps = np.array([1], dtype="double")
    amps.shape = (1, 1)
    
    # call calc_scat
    p = getArrayInfo(points)
    a = getArrayInfo(amps)
    scatInfo = f2.f2_calc_scat(Th, Th, ct.byref(p), ct.byref(a))
    
    # copy output data to python's memory
    rf = np.array(scatInfo.ptr[0:(scatInfo.ncols*scatInfo.nrows)])
    rf.reshape((scatInfo.nrows, scatInfo.ncols), order='F')
    t0 = scatInfo.t0
    
    f2.cleanup(scatInfo.ptr)
    
    results.put(rf)
    #results.put(t0)
    #results.put(np.double(t0))
    #results.put(impulse_response)
    #results.put(excitation)
    
    # terminate libf2
    f2.f2_field_end()
    f2.shutdown()
    
if __name__ == '__main__':
    
    if argv and len(argv) == 2:
        nprocesses = int(argv[1])
    else:
        nprocesses = 1
 
    jobs = []
    results = mp.Queue()
    
    for p in range(0, nprocesses):
        jobs.append(mp.Process(target=sim, args=(results, p)))
        jobs[p].start()
    
    data = []
    t0 = []
        
    for j in jobs:
        j.join(20)
    
    for j in jobs:
        data.append(results.get())
        #t0.append(results.get())

    #plt.figure()
    #for d in data:
    #    plt.plot(d,'.-')
    #    #print t
    plt.figure()
    
    for d in data:
        plt.plot(d,'.')
        
    plt.show()

