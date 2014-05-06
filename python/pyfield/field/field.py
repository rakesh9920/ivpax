# pyfield / field / field.py

# Fixes needed for linux/MCR to work (add to bash script before running python)
# export LD_LIBRARY_PATH=$LD_LIBRARY_PATH:~/code/python/bin/
# export LD_LIBRARY_PATH=$LD_LIBRARY_PATH:/usr/local/MATLAB/R2013b/sys/os/
# glnxa64/
# export LD_PRELOAD=/usr/local/MATLAB/R2013b/sys/os/glnxa64/libfreetype.so.6:
# /usr/local/MATLAB/R2013b/sys/os/glnxa64/libgfortran.so.3

import ctypes as ct
import numpy as np
import os

_c_double_p = ct.POINTER(ct.c_double)

class _ArrayInfo(ct.Structure):
        _fields_ = [("ptr", _c_double_p),
                    ("nrows", ct.c_int),
                    ("ncols", ct.c_int),
                    ("t0", ct.c_double)]

def _getArrayInfo(array):
    
    ptr = array.ctypes.data_as(_c_double_p)
    nrows = ct.c_int(array.shape[0])
    ncols = ct.c_int(array.shape[1])
    
    return _ArrayInfo(ptr, nrows, ncols, ct.c_double(0))
    
def _copyArray(info):
    
    nrows = info.nrows
    ncols = info.ncols
    
    array = np.array(info.ptr[0:nrows*ncols])
    array = array.reshape((nrows, ncols), order='F')
    
    t0 = info.t0
    
    return (array, t0)

def _checkArray(array, orient="row"):
    
    # distinguish between row or column vectors if ndim == 1
    if array.ndim == 1:
        if orient.lower() == "row":
            array = array.reshape((1, array.size))
        else:
            array = array.reshape((array.size, 1))
            
    # force array to be column-major order in memory and of type double
    if (not array.flags['F_CONTIGUOUS'] or
        not array.dtype == np.dtype("double")):
        array = np.asfortranarray(array, dtype="double")
    
    return array
        
class Field:
    
    def __init__(self, f2=None):
        self.libf2 = f2
    
    def _initialize(self, diarypath=None):
         
        # load dll
        if os.name == 'nt':
            f2 = ct.cdll.LoadLibrary('libf2.dll')
        else:
            f2 = ct.cdll.LoadLibrary('libf2.so')
        
        # set dll function prototypes
        f2.initialize.restype = ct.c_int
        f2.initialize.argtypes = None
        f2.initializeWithDiary.restype = ct.c_int
        f2.initializeWithDiary.argtypes = [ct.c_char_p]
        f2.shutdownlib.restype = None
        f2.shutdownlib.argtypes = None
        f2.cleanup.restype = None
        f2.cleanup.argtypes = [_c_double_p]
        f2.f2_field_init.restype = ct.c_int
        f2.f2_field_init.argtypes = [ct.c_int]
        f2.f2_field_end.restype = None
        f2.f2_field_end.argtypes = None
        f2.f2_set_field.restype = None
        f2.f2_set_field.argtypes = [ct.c_char_p, ct.c_double]
        f2.f2_xdc_piston.restype = ct.c_int
        f2.f2_xdc_piston.argtypes = [ct.c_double, ct.c_double]
        f2.f2_xdc_excitation.restype = None
        f2.f2_xdc_excitation.argtypes = [ct.c_int, ct.POINTER(_ArrayInfo)]
        f2.f2_xdc_free.restype = None
        f2.f2_xdc_free.argtypes = [ct.c_int]
        f2.f2_xdc_impulse.restype = None
        f2.f2_xdc_impulse.argtypes = [ct.c_int, ct.POINTER(_ArrayInfo)]
        f2.f2_xdc_focus_times.restype = None
        f2.f2_xdc_focus_times.argtypes = [ct.c_int, ct.POINTER(_ArrayInfo),
            ct.POINTER(_ArrayInfo)]
        f2.f2_xdc_get.restype = ct.POINTER(_ArrayInfo)
        f2.f2_xdc_get.argtypes =[ct.c_int, ct.c_char_p]
        f2.f2_xdc_rectangles.restype = ct.c_int
        f2.f2_xdc_rectangles.argtypes =[ct.POINTER(_ArrayInfo), 
            ct.POINTER(_ArrayInfo), ct.POINTER(_ArrayInfo)]
        f2.f2_xdc_2d_array.restype = ct.c_int
        f2.f2_xdc_2d_array.argtypes = [ct.c_int, ct.c_int, ct.c_double, 
            ct.c_double, ct.c_double, ct.c_double, ct.POINTER(_ArrayInfo), 
            ct.c_int, ct.c_int, ct.POINTER(_ArrayInfo)]
        f2.f2_xdc_concave.restype = ct.c_int
        f2.f2_xdc_concave.argtypes = [ct.c_double, ct.c_double, ct.c_double]
        f2.f2_xdc_linear_array.restype = ct.c_int
        f2.f2_xdc_linear_array.argtypes = [ct.c_int, ct.c_double, ct.c_double,
            ct.c_double, ct.c_int, ct.c_int, ct.POINTER(_ArrayInfo)]
        f2.f2_calc_scat.restype = _ArrayInfo
        f2.f2_calc_scat.argtypes = [ct.c_int, ct.c_int, ct.POINTER(_ArrayInfo),
            ct.POINTER(_ArrayInfo)]
        f2.f2_calc_scat_multi.restype = _ArrayInfo
        f2.f2_calc_scat_multi.argtypes = [ct.c_int, ct.c_int, 
            ct.POINTER(_ArrayInfo), ct.POINTER(_ArrayInfo)]
        
        # initialize libf2
        if diarypath is None:
            success = f2.initialize()
        else:
            success = f2.initializeWithDiary(ct.c_char_p(diarypath))
        
        # set libf2 dll as class member
        self.libf2 = f2
        return success
             
    def _shutdown(self):
        self.libf2.shutdownlib()
        
    def _deleteArray(self, info):
        self.libf2.cleanup(info.ptr)
    
    def field_init(self, suppress=0, diarypath=None):
        
        self._initialize(diarypath)
        self.libf2.f2_field_init(ct.c_int(suppress))

    def field_end(self):
        
        self.libf2.f2_field_end()
        self._shutdown()
    
    def set_field(self, opt, val):
        self.libf2.f2_set_field(ct.c_char_p(opt), ct.c_double(val))
    
    def xdc_free(self, aperture):
        self.libf2.f2_xdc_free(aperture)
    
    def xdc_piston(self, radius, elsize):  
        return self.libf2.f2_xdc_piston(ct.c_double(radius), 
            ct.c_double(elsize))
    
    def xdc_excitation(self, aperture, excitation):
        
        # force excitation to be a row vector
        excitation = excitation.reshape((1, excitation.size))
        excitation = np.asfortranarray(excitation)
        
        # get array info and call libf2
        self.libf2.f2_xdc_excitation(aperture, 
            ct.byref(_getArrayInfo(excitation)))

    def xdc_impulse(self, aperture, impulse):
        
        # force impulse to be a row vector
        impulse = impulse.reshape((1, impulse.size))
        impulse = np.asfortranarray(impulse)
        
        # get array info and call libf2
        self.libf2.f2_xdc_impulse(aperture, 
            ct.byref(_getArrayInfo(impulse)))
    
    def xdc_get(self, aperture, opt):
        
        info = self.libf2.f2_xdc_get(aperture, ct.c_char_p(opt))
        (array, t0) = _copyArray(info)
        self._deleteArray(info)
        
        return array
        
    def xdc_2d_array(self, nelex, neley, width, height, kerfx, kerfy, enabled,
        nsubx, nsuby, focus):
        
        if nelex == 1:
            enabled = _checkArray(enabled, orient="row")
        else:
            enabled = _checkArray(enabled, orient="col")
        
        focus = _checkArray(focus, orient="row")
        
        return self.libf2.f2_xdc_2d_array(nelex, neley, width, height, kerfx, 
            kerfy, ct.byref(_getArrayInfo(enabled)), nsubx, nsuby, 
            ct.byref(_getArrayInfo(focus)))
        
    def xdc_rectangles(self, rect, centers, focus):
        
        rect = _checkArray(rect, orient="row")
        centers = _checkArray(centers, orient="row")
        focus = _checkArray(focus, orient="row")
        
        return self.libf2.f2_xdc_rectanges(ct.byref(_getArrayInfo(rect)),
            ct.byref(_getArrayInfo(centers)), ct.byref(_getArrayInfo(focus)))
    
    def xdc_linear_array(self, nele, width, height, kerf, nsubx, nsuby, focus):
        
        focus = _checkArray(focus, orient="row")
        
        return self.libf2.f2_xdc_linear_array(nele, width, height, kerf, nsubx, 
            nsuby, ct.byref(_getArrayInfo(focus)))
    
    def xdc_concave(self, radius, focus, elsize):
        
        return self.libf2.f2_xdc_concave(radius, focus, elsize)
    
    def xdc_focus_times(self, aperture, times, delays):
        
        # check and convert input arrays for compatibility with libf2
        times = _checkArray(times, orient="col")
        delays = _checkArray(delays, orient="row")
        
        self.libf2.f2_xdc_focus_times(aperture, ct.byref(_getArrayInfo(times)),
            ct.byref(_getArrayInfo(delays)))
        
    def calc_scat(self, txaperture, rxaperture, points, amplitudes):
        
        # check and convert input arrays for compatibility with libf2
        points = _checkArray(points, orient="row")
        amplitudes = _checkArray(amplitudes, orient="column")
            
        # get array info and call libf2
        scatinfo = self.libf2.f2_calc_scat(txaperture, 
            rxaperture, ct.byref(_getArrayInfo(points)), 
            ct.byref(_getArrayInfo(amplitudes)))
    
        # copy result to python memory and delete from dll memory
        (scat, t0) = _copyArray(scatinfo)
        self._deleteArray(scatinfo)
        
        return (scat, t0)
        
    def calc_scat_multi(self, txaperture, rxaperture, points, amplitudes):
        
        # check and convert input arrays for compatibility with libf2
        points = _checkArray(points, orient="row")
        amplitudes = _checkArray(amplitudes, orient="column")
            
        # get array info and call libf2
        scatinfo = self.libf2.f2_calc_scat_multi(txaperture, 
            rxaperture, ct.byref(_getArrayInfo(points)), 
            ct.byref(_getArrayInfo(amplitudes)))
    
        # copy result to python memory and delete from dll memory
        (scat, t0) = _copyArray(scatinfo)
        self._deleteArray(scatinfo)
        
        return (scat, t0)

     



