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
            
            os.environ['PATH'] = os.environ['PATH'] + ';.\\bin\\;'
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
        f2.f2_field_init.restype = None
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
        f2.f2_xdc_get.restype = _ArrayInfo
        f2.f2_xdc_get.argtypes =[ct.c_double, ct.c_char_p]
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
        f2.f2_xdc_focused_array.restype = ct.c_int
        f2.f2_xdc_focused_array.argtypes = [ct.c_int, ct.c_double, ct.c_double,
            ct.c_double, ct.c_double, ct.c_int, ct.c_int, 
            ct.POINTER(_ArrayInfo)]
        f2.f2_calc_scat.restype = _ArrayInfo
        f2.f2_calc_scat.argtypes = [ct.c_int, ct.c_int, ct.POINTER(_ArrayInfo),
            ct.POINTER(_ArrayInfo)]
        f2.f2_calc_scat_multi.restype = _ArrayInfo
        f2.f2_calc_scat_multi.argtypes = [ct.c_int, ct.c_int, 
            ct.POINTER(_ArrayInfo), ct.POINTER(_ArrayInfo)]
        f2.f2_calc_scat_all.restype = _ArrayInfo
        f2.f2_calc_scat_all.argtypes = [ct.c_int, ct.c_int, 
            ct.POINTER(_ArrayInfo), ct.POINTER(_ArrayInfo), ct.c_int]
        f2.f2_calc_h.restype = _ArrayInfo
        f2.f2_calc_h.argtypes = [ct.c_int, ct.POINTER(_ArrayInfo)]
        f2.f2_calc_hhp.restype = _ArrayInfo
        f2.f2_calc_hhp.argtypes = [ct.c_int, ct.c_int, ct.POINTER(_ArrayInfo)]
        f2.f2_calc_hp.restype = _ArrayInfo
        f2.f2_calc_hp.argtypes = [ct.c_int, ct.POINTER(_ArrayInfo)]
        
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
        
        return self.libf2.f2_xdc_rectangles(ct.byref(_getArrayInfo(rect)),
            ct.byref(_getArrayInfo(centers)), ct.byref(_getArrayInfo(focus)))
    
    def xdc_linear_array(self, nele, width, height, kerf, nsubx, nsuby, focus):
        
        focus = _checkArray(focus, orient="row")
        
        return self.libf2.f2_xdc_linear_array(nele, width, height, kerf, nsubx, 
            nsuby, ct.byref(_getArrayInfo(focus)))
            
    def xdc_focused_array(self, nele, width, height, kerf, rfocus, nsubx,
        nsuby, focus):
        
        focus = _checkArray(focus, orient="row")
        
        return self.libf2.f2_xdc_focused_array(nele, width, height, kerf, 
            rfocus, nsubx, nsuby, ct.byref(_getArrayInfo(focus)))  
            
    def xdc_concave(self, radius, focus, elsize):
        
        return self.libf2.f2_xdc_concave(radius, focus, elsize)
    
    def xdc_focus_times(self, aperture, times, delays):
        
        # check and convert input arrays for compatibility with libf2
        times = _checkArray(times, orient="col")
        delays = _checkArray(delays, orient="row")
        
        self.libf2.f2_xdc_focus_times(aperture, ct.byref(_getArrayInfo(times)),
            ct.byref(_getArrayInfo(delays)))
            
    def calc_h(self, aperture, points):
        
        # check and convert input arrays for compatibility with libf2
        points = _checkArray(points, orient="row")
            
        # get array info and call libf2
        scatinfo = self.libf2.f2_calc_h(aperture, 
            ct.byref(_getArrayInfo(points)))
    
        # copy result to python memory and delete from dll memory
        scat, t0 = _copyArray(scatinfo)
        self._deleteArray(scatinfo)
        
        return scat, t0
        
    def calc_hhp(self, aperture1, aperture2, points):

        # check and convert input arrays for compatibility with libf2
        points = _checkArray(points, orient="row")
            
        # get array info and call libf2
        scatinfo = self.libf2.f2_calc_hhp(aperture1, aperture2, 
            ct.byref(_getArrayInfo(points)))
    
        # copy result to python memory and delete from dll memory
        scat, t0 = _copyArray(scatinfo)
        self._deleteArray(scatinfo)
        
        return scat, t0
        
    def calc_hp(self, aperture, points):

        # check and convert input arrays for compatibility with libf2
        points = _checkArray(points, orient="row")
            
        # get array info and call libf2
        scatinfo = self.libf2.f2_calc_hp(aperture, 
            ct.byref(_getArrayInfo(points)))
    
        # copy result to python memory and delete from dll memory
        scat, t0 = _copyArray(scatinfo)
        self._deleteArray(scatinfo)
        
        return scat, t0
        
    def calc_scat(self, txaperture, rxaperture, points, amplitudes):
        
        # check and convert input arrays for compatibility with libf2
        points = _checkArray(points, orient="row")
        amplitudes = _checkArray(amplitudes, orient="column")
            
        # get array info and call libf2
        scatinfo = self.libf2.f2_calc_scat(txaperture, 
            rxaperture, ct.byref(_getArrayInfo(points)), 
            ct.byref(_getArrayInfo(amplitudes)))
    
        # copy result to python memory and delete from dll memory
        scat, t0 = _copyArray(scatinfo)
        self._deleteArray(scatinfo)
        
        return scat, t0
        
    def calc_scat_multi(self, txaperture, rxaperture, points, amplitudes):
        
        # check and convert input arrays for compatibility with libf2
        points = _checkArray(points, orient="row")
        amplitudes = _checkArray(amplitudes, orient="column")
            
        # get array info and call libf2
        scatinfo = self.libf2.f2_calc_scat_multi(txaperture, 
            rxaperture, ct.byref(_getArrayInfo(points)), 
            ct.byref(_getArrayInfo(amplitudes)))
    
        # copy result to python memory and delete from dll memory
        scat, t0 = _copyArray(scatinfo)
        self._deleteArray(scatinfo)
        
        return scat, t0
    
    def calc_scat_all(self, txaperture, rxaperture, points, amplitudes, dec):
        
        # check and convert input arrays for compatibility with libf2
        points = _checkArray(points, orient="row")
        amplitudes = _checkArray(amplitudes, orient="column")
            
        # get array info and call libf2
        scatinfo = self.libf2.f2_calc_scat_all(txaperture, 
            rxaperture, ct.byref(_getArrayInfo(points)), 
            ct.byref(_getArrayInfo(amplitudes)), dec)
    
        # copy result to python memory and delete from dll memory
        scat, t0 = _copyArray(scatinfo)
        self._deleteArray(scatinfo)
        
        return scat, t0
    
    # Reference for xdc_get:
    # number of elements = size(Info, 2);
    # physical element no. = Info(1,:);
    # mathematical element no. = Info(2,:);
    # element width = Info(3,:);
    # element height = Info(4,:);
    # apodization weight = Info(5,:);
    # mathematical element center = Info(8:10,:);
    # element corners = Info(11:22,:);
    # delays = Info(23,:);
    # physical element position = Info(24:26,:);
    
    # Reference for xdc_rectangles:
    # physical element no = Rect(1,:)
    # rectangle coords = Rect(2:13,:)
    # apodization = Rect(14,:)
    # width = Rect(15,:)
    # height = Rect(16,:)
    # center = Rect(17:19,:)  

    def xdc_save(self, file_path, aperture):
        
        info = self.xdc_get(aperture, 'rect')
        focus = self.xdc_get(aperture, 'focus')
        np.savez(file_path, info=info, focus=focus)
    
    def xdc_load(self, file_path):
        
        with np.load(file_path) as varz:
            
            info = varz['info']
            focus = varz['focus']
            
            rect = np.zeros((19, info.shape[1]))
            rect[0,:] = info[0,:]
            rect[1:13,:] = info[10:22,:]
            rect[13,:] = info[4,:]
            rect[14,:] = info[2,:]
            rect[15,:] = info[3,:]
            rect[16:19,:] = info[7:10,:]
            
            centers = info[23:26,:].T
            
            focus_times = focus[:,0]
            focus_delays = focus[:,1:]
            
            aperture = self.xdc_rectangles(rect, centers, np.array([[0,0,300]]))
            self.xdc_focus_times(aperture, focus_times, focus_delays)
        
        return aperture
     
from multiprocessing import Process, Queue, current_process
import h5py
import time
#
#from ..util import chunks, align_and_sum, Progress #!!!!!!!
import pyfield.util as util

def work(in_queue, out_queue, script):
    
    try:
       
        def_script = __import__(script, fromlist=['asdf'])
        
        f2 = Field()
        f2.field_init(-1, current_process().name + '_log.txt')
        #f2.field_init(-1) # must have diary output for worker to join properly 
        # for some strange reason
        (tx_aperture, rx_aperture) = def_script.get_apertures(f2)
        
        for data in iter(in_queue.get, 'STOP'):
            
            points = data[:,0:3]
            amp = data[:,3]
            
            (scat, t0) = f2.calc_scat_multi(tx_aperture, rx_aperture, 
                points, amp)
                
            out_queue.put((scat, t0))
        
        f2.xdc_free(tx_aperture)
        if not rx_aperture == tx_aperture:
            f2.xdc_free(rx_aperture)
        f2.field_end()
     
    except Exception as e:
        
        out_queue.put(e)
        #out_queue.put("failed on %s with: %s" % (current_process().name,
        #    e.message))

def align_write(dataset, array1, t1, frame):
    
    fs = dataset.attrs.get('sample_frequency')
    t0 = dataset.attrs.get('start_time')
    dims0 = dataset.shape
    
    # determine frontpad for dim 0 (time sample)
    s0 = round(t0*fs)
    s1 = round(t1*fs)
    
    if s0 > s1:
        fpad1, fpad0 = 0, s0 - s1             
    elif s0 < s1:
        fpad1, fpad0 = s1 - s0, 0
    else:
        fpad1, fpad0 = 0, 0
    
    # determine backpad for dim 0 (time sample)
    nsample0 = dims0[0] + fpad0    
    nsample1 = array1.shape[0] + fpad1

    if nsample1 > nsample0:
        bpad1, bpad0 = 0, nsample1 - nsample0
    elif nsample1 < nsample0:
        bpad1, bpad0 = nsample0 - nsample1, 0
    else:
        bpad1, bpad0 = 0, 0
    
    # determine depth backpad for dim 2 (frame no)
    dpad0 = frame + 1 - dims0[2]
    if dpad0 < 0: 
        dpad0 = 0
    
    # resize dataset if necessary
    dataset.resize(dataset.shape[0] + fpad0 + bpad0, axis=0)
    dataset.resize(dataset.shape[2] + dpad0, axis=2)
    
    pad_width0 = [(fpad0, bpad0), (0, 0), (0, dpad0)]
    pad_width1 = [(fpad1, bpad1), (0, 0)]

    #array0 = dataset[:dims0[0],:,:dims0[2]].copy()
    dataset[:] = np.pad(dataset[:dims0[0],:,:dims0[2]], pad_width0, 
        mode='constant')
    #dataset[:dims0[0],:,:dims0[2]] = np.pad(array0, pad_width0, 
    #    mode='constant')
    
    dataset[:,:,frame] = np.pad(array1, pad_width1, mode='constant')
    dataset.attrs.create('start_time', min(t0, t1))

def delegate(in_queue, out_queue, input_path, script_path, output_path, 
    options, nproc, frames, progress):
    
    input_file = input_path[0]
    input_key = input_path[1]
    output_file = output_path[0]
    output_key = output_path[1]
    
    # open input file
    input_root = h5py.File(input_file, 'a')
    targdata = input_root[input_key]
    ntarget = targdata.shape[0]
    
    # get parameters from field ii script
    field_prms = __import__(script_path, fromlist=['asdf']).get_prms()
    nchannel = field_prms['rx_positions'].shape[0]
    fs = field_prms['sample_frequency']
    
    # open output file
    if output_file == input_file:
        output_root = input_root
    else:
        output_root = h5py.File(output_file, 'a')
    
    try:
     
        if len(targdata.shape) == 3:
            nframe = targdata.shape[2]
        else:
            nframe = 1
        
        if frames is None:
            
            start_frame = 0
            stop_frame = nframe
            
        elif isinstance(frames, tuple):
            
            start_frame = frames[0]
            stop_frame = min(frames[1], nframe)
            
        else:
            
            start_frame = frames
            stop_frame = frames + 1
        
        targetsperchunk = min(np.ceil(float(ntarget)/nproc).astype(int), 
            options['maxtargetsperchunk'])
            
        nchunk = np.ceil(float(ntarget)/targetsperchunk).astype(int)
        
        progress.total.value = nchunk * (stop_frame - start_frame)
        progress.reset()
        
        for frame in xrange(start_frame, stop_frame):
            
            for targ_idx in util.chunks(range(ntarget), targetsperchunk):
                
                if len(targdata.shape) == 3:
                    in_queue.put(targdata[targ_idx,:,frame])
                else:
                    in_queue.put(targdata[targ_idx,:])
            
            item = out_queue.get()
            if isinstance(item, Exception):
                raise item
            
            scat_t, t0_t = item
            progress.increment()
            
            for chunk in xrange(nchunk - 1):
                
                item = out_queue.get()
                if isinstance(item, Exception):
                    raise item
            
                scat, t0 = item
                scat_t, t0_t = util.align_and_sum(scat_t, t0_t, scat, t0, fs)
                
                progress.increment()
            
            # behavior for first frame is special since dataset needs to be 
            # seeded
            if frame == start_frame:
                    
                if options['overwrite']:
                    
                    if output_key in output_root:
                        del output_root[output_key]
                    
                    rfdata = output_root.create_dataset(output_key, 
                        dtype='double', 
                        shape=(scat_t.shape[0], nchannel, frame + 1), 
                        maxshape=(None, nchannel, None), compression='gzip')
                
                    rfdata[:,:,frame] = scat_t
                    rfdata.attrs.create('start_time', t0_t)
                    rfdata.attrs.create('sample_frequency', fs)
                    
                else:
                    
                    if output_key in output_root:
                        
                        rfdata = output_root[output_key]
                        align_write(rfdata, scat_t, t0_t, frame)
                    
                    else:
                        
                        rfdata = output_root.create_dataset(output_key, 
                            dtype='double', 
                            shape=(scat_t.shape[0], nchannel, frame + 1), 
                            maxshape=(None, nchannel, None), compression='gzip')
                    
                        rfdata[:,:,frame] = scat_t
                        rfdata.attrs.create('start_time', t0_t)
                        rfdata.attrs.create('sample_frequency', fs)
  
            else:
                align_write(rfdata, scat_t, t0_t, frame)
 
        for proc in xrange(nproc):
            in_queue.put('STOP')
        
        # write rf data attributes
        for key, val in targdata.attrs.iteritems():
            rfdata.attrs.create(key, val)
        
        for key, val in field_prms.iteritems():
            rfdata.attrs.create(key, val)
    
    except Exception as e:
        out_queue.put(e)
        
    finally:
        
        input_root.close()
        
        if output_file != input_file:
            output_root.close()

             
class Simulation():
    
    workers = []
    delegator = []
    script_path = ''
    input_path = ''
    output_path = ''
    options = dict()
    
    def __init__(self):
        self.set_options()
        self.progress = util.Progress()
    
    def __str__(self):
        string = []
        string.append(repr(self) + '\n')
        
        rem_time = self.progress.time_remaining()
        string.append('\nPROGRESS:\n')
        string.append('percent done: {0:.0f}%\n'. \
            format(self.progress.fraction_done.value*100))
        string.append(('time remaining: {0:.0f}d {1:.0f}h {2:.0f}m {3:.0f}s\n')\
            .format(*rem_time))
        
        string.append('\nOPTIONS:\n')
        for k, v in self.options.iteritems():
            string.append('{0}: {1}\n'.format(k, v))
            
        string.append('\nDATA PATHS: \n')
        string.append('input data in {0} at {1}\n'.format(self.input_path[0], 
            self.input_path[1]))
        string.append('script in {0}\n'.format(self.script_path))
        string.append('output data in {0} at {1}\n'.format(self.output_path[0], 
            self.output_path[1]))
        
        string.append('\nWORKERS: \n')
        for w in self.workers:
            string.append(repr(w) + '\n')
        
        string.append('\nDELEGATOR: \n')
        for d in self.delegator:
            string.append(repr(d) + '\n')
        
        return ''.join(string)
    
    def set_options(self, **kwargs):
        
        self.options['maxtargetsperchunk'] = kwargs.get('maxtargetsperchunk',
            10000)
        self.options['overwrite'] = kwargs.get('overwrite', False) 
    
    def start(self, nproc=1, frames=None):
        
        self.reset()
        
        in_queue = Queue();
        out_queue = Queue();
        
        progress = util.Progress()
        # start worker processes
        for w in xrange(nproc):
            w = Process(target=work, name=('Worker' + str(w)), args=(in_queue, 
                out_queue, self.script_path))
            w.start()
            self.workers.append(w)  
            time.sleep(0.25)   
        
        # start delegator
        delegator = Process(target=delegate, args=(in_queue, out_queue,
            self.input_path, self.script_path, self.output_path, self.options, 
            nproc, frames, progress))
        delegator.start()
        self.delegator.append(delegator)
        
        self.progress = progress
        self.in_queue = in_queue
        self.out_queue = out_queue
                    
    def join(self, timeout=None):
        
        # wait for workers to join--input and output queues will be flushed
        for w in self.workers:
            w.join(timeout)
        
        for d in self.delegator:
            d.join(timeout)
    
    def terminate(self):
        
        for w in self.workers:
            w.terminate()
        
        for d in self.delegator:
            d.terminate()

        self.join()
    
    def reset(self):
        self.workers = []
        self.delegator = []
        

def work_multi(in_queue, out_queue, script):
    
    try:
       
        def_script = __import__(script, fromlist=['asdf'])
        
        f2 = Field()
        f2.field_init(-1, current_process().name + '_log.txt')
        #f2.field_init(-1) # must have diary output for worker to join properly 
        # for some strange reason
        (tx_aperture, rx_aperture) = def_script.get_apertures(f2)
        
        for data in iter(in_queue.get, 'STOP'):
            
            points = data[:,0:3]
            amp = data[:,3]
            
            (scat, t0) = f2.calc_scat_multi(tx_aperture, rx_aperture, 
                points, amp)
                
            out_queue.put((scat, t0))
        
        f2.xdc_free(tx_aperture)
        if not rx_aperture == tx_aperture:
            f2.xdc_free(rx_aperture)
        f2.field_end()
     
    except Exception as e:
        
        out_queue.put(e)
        #out_queue.put("failed on %s with: %s" % (current_process().name,
        #    e.message))

def align_write_multi(dataset, array1, t1, frame):
    
    fs = dataset.attrs.get('sample_frequency')
    t0 = dataset.attrs.get('start_time')
    dims0 = dataset.shape
    
    # determine frontpad for dim 0 (time sample)
    s0 = round(t0*fs)
    s1 = round(t1*fs)
    
    if s0 > s1:
        fpad1, fpad0 = 0, s0 - s1             
    elif s0 < s1:
        fpad1, fpad0 = s1 - s0, 0
    else:
        fpad1, fpad0 = 0, 0
    
    # determine backpad for dim 0 (time sample)
    nsample0 = dims0[0] + fpad0    
    nsample1 = array1.shape[0] + fpad1

    if nsample1 > nsample0:
        bpad1, bpad0 = 0, nsample1 - nsample0
    elif nsample1 < nsample0:
        bpad1, bpad0 = nsample0 - nsample1, 0
    else:
        bpad1, bpad0 = 0, 0
    
    # determine depth backpad for dim 2 (frame no)
    dpad0 = frame + 1 - dims0[2]
    if dpad0 < 0: 
        dpad0 = 0
    
    # resize dataset if necessary
    dataset.resize(dataset.shape[0] + fpad0 + bpad0, axis=0)
    dataset.resize(dataset.shape[2] + dpad0, axis=2)
    
    pad_width0 = [(fpad0, bpad0), (0, 0), (0, dpad0)]
    pad_width1 = [(fpad1, bpad1), (0, 0)]

    #array0 = dataset[:dims0[0],:,:dims0[2]].copy()
    dataset[:] = np.pad(dataset[:dims0[0],:,:dims0[2]], pad_width0, 
        mode='constant')
    #dataset[:dims0[0],:,:dims0[2]] = np.pad(array0, pad_width0, 
    #    mode='constant')
    
    dataset[:,:,frame] = np.pad(array1, pad_width1, mode='constant')
    dataset.attrs.create('start_time', min(t0, t1))

def delegate_multi(in_queue, out_queue, input_path, script_path, output_path, 
    options, nproc, frames, progress):
    
    input_file = input_path[0]
    input_key = input_path[1]
    output_file = output_path[0]
    output_key = output_path[1]
    
    # open input file
    input_root = h5py.File(input_file, 'a')
    targdata = input_root[input_key]
    ntarget = targdata.shape[0]
    
    # get parameters from field ii script
    field_prms = __import__(script_path, fromlist=['asdf']).get_prms()
    nchannel = field_prms['rx_positions'].shape[0]
    fs = field_prms['sample_frequency']
    
    # open output file
    if output_file == input_file:
        output_root = input_root
    else:
        output_root = h5py.File(output_file, 'a')
    
    try:
     
        if len(targdata.shape) == 3:
            nframe = targdata.shape[2]
        else:
            nframe = 1
        
        if frames is None:
            
            start_frame = 0
            stop_frame = nframe
            
        elif isinstance(frames, tuple):
            
            start_frame = frames[0]
            stop_frame = min(frames[1], nframe)
            
        else:
            
            start_frame = frames
            stop_frame = frames + 1
        
        targetsperchunk = min(np.ceil(float(ntarget)/nproc).astype(int), 
            options['maxtargetsperchunk'])
            
        nchunk = np.ceil(float(ntarget)/targetsperchunk).astype(int)
        
        progress.total.value = nchunk * (stop_frame - start_frame)
        progress.reset()
        
        for frame in xrange(start_frame, stop_frame):
            
            for targ_idx in util.chunks(range(ntarget), targetsperchunk):
                
                if len(targdata.shape) == 3:
                    in_queue.put(targdata[targ_idx,:,frame])
                else:
                    in_queue.put(targdata[targ_idx,:])
            
            item = out_queue.get()
            if isinstance(item, Exception):
                raise item
            
            scat_t, t0_t = item
            progress.increment()
            
            for chunk in xrange(nchunk - 1):
                
                item = out_queue.get()
                if isinstance(item, Exception):
                    raise item
            
                scat, t0 = item
                scat_t, t0_t = util.align_and_sum(scat_t, t0_t, scat, t0, fs)
                
                progress.increment()
            
            # behavior for first frame is special since dataset needs to be 
            # seeded
            if frame == start_frame:
                    
                if options['overwrite']:
                    
                    if output_key in output_root:
                        del output_root[output_key]
                    
                    rfdata = output_root.create_dataset(output_key, 
                        dtype='double', 
                        shape=(scat_t.shape[0], nchannel, frame + 1), 
                        maxshape=(None, nchannel, None), compression='gzip')
                
                    rfdata[:,:,frame] = scat_t
                    rfdata.attrs.create('start_time', t0_t)
                    rfdata.attrs.create('sample_frequency', fs)
                    
                else:
                    
                    if output_key in output_root:
                        
                        rfdata = output_root[output_key]
                        align_write(rfdata, scat_t, t0_t, frame)
                    
                    else:
                        
                        rfdata = output_root.create_dataset(output_key, 
                            dtype='double', 
                            shape=(scat_t.shape[0], nchannel, frame + 1), 
                            maxshape=(None, nchannel, None), compression='gzip')
                    
                        rfdata[:,:,frame] = scat_t
                        rfdata.attrs.create('start_time', t0_t)
                        rfdata.attrs.create('sample_frequency', fs)
  
            else:
                align_write(rfdata, scat_t, t0_t, frame)
 
        for proc in xrange(nproc):
            in_queue.put('STOP')
        
        # write rf data attributes
        for key, val in targdata.attrs.iteritems():
            rfdata.attrs.create(key, val)
        
        for key, val in field_prms.iteritems():
            rfdata.attrs.create(key, val)
    
    except Exception as e:
        out_queue.put(e)
        
    finally:
        
        input_root.close()
        
        if output_file != input_file:
            output_root.close()

             
class SimulationMulti():
    
    workers = []
    delegator = []
    script_path = ''
    input_path = ''
    output_path = ''
    options = dict()
    
    def __init__(self):
        self.set_options()
        self.progress = util.Progress()
    
    def __str__(self):
        string = []
        string.append(repr(self) + '\n')
        
        rem_time = self.progress.time_remaining()
        string.append('\nPROGRESS:\n')
        string.append('percent done: {0:.0f}%\n'. \
            format(self.progress.fraction_done.value*100))
        string.append(('time remaining: {0:.0f}d {1:.0f}h {2:.0f}m {3:.0f}s\n')\
            .format(*rem_time))
        
        string.append('\nOPTIONS:\n')
        for k, v in self.options.iteritems():
            string.append('{0}: {1}\n'.format(k, v))
            
        string.append('\nDATA PATHS: \n')
        string.append('input data in {0} at {1}\n'.format(self.input_path[0], 
            self.input_path[1]))
        string.append('script in {0}\n'.format(self.script_path))
        string.append('output data in {0} at {1}\n'.format(self.output_path[0], 
            self.output_path[1]))
        
        string.append('\nWORKERS: \n')
        for w in self.workers:
            string.append(repr(w) + '\n')
        
        string.append('\nDELEGATOR: \n')
        for d in self.delegator:
            string.append(repr(d) + '\n')
        
        return ''.join(string)
    
    def set_options(self, **kwargs):
        
        self.options['maxtargetsperchunk'] = kwargs.get('maxtargetsperchunk',
            10000)
        self.options['overwrite'] = kwargs.get('overwrite', False) 
    
    def start(self, nproc=1, frames=None):
        
        self.reset()
        
        in_queue = Queue();
        out_queue = Queue();
        
        progress = util.Progress()
        # start worker processes
        for w in xrange(nproc):
            w = Process(target=work, name=('Worker' + str(w)), args=(in_queue, 
                out_queue, self.script_path))
            w.start()
            self.workers.append(w)  
            time.sleep(0.25)   
        
        # start delegator
        delegator = Process(target=delegate, args=(in_queue, out_queue,
            self.input_path, self.script_path, self.output_path, self.options, 
            nproc, frames, progress))
        delegator.start()
        self.delegator.append(delegator)
        
        self.progress = progress
        self.in_queue = in_queue
        self.out_queue = out_queue
                    
    def join(self, timeout=None):
        
        # wait for workers to join--input and output queues will be flushed
        for w in self.workers:
            w.join(timeout)
        
        for d in self.delegator:
            d.join(timeout)
    
    def terminate(self):
        
        for w in self.workers:
            w.terminate()
        
        for d in self.delegator:
            d.terminate()

        self.join()
    
    def reset(self):
        self.workers = []
        self.delegator = []       
        
            
    