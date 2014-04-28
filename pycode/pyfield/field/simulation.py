# pyfield / field / simulation.py

from multiprocessing import Process, Queue, current_process
import numpy as np
import h5py
from . import Field
from pyfield.util import chunks, align_and_sum, Progress

def work(in_queue, out_queue, script):
    
    try:
       
        def_script = __import__(script)
        
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
    
#def collect(out_queue, res_queue, fs):
#    
#    try:
#        
#        item = out_queue.get()
#        
#        if isinstance(item, Exception):
#            raise item
#        
#        (scat_t, t0_t) = item
#        
#        for item in iter(out_queue.get, 'STOP'):
#            
#            if isinstance(item, Exception):
#                raise item
#            
#            (scat, t0) = item
#            
#            (scat_t, t0_t) = align_and_sum(scat_t, t0_t, scat, t0, fs)
#            
#        res_queue.put((scat_t, t0_t))
#    
#    except Exception as e:
#        
#        res_queue.put(e)

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
    field_prms = __import__(script_path).get_prms()
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
            
            for targ_idx in chunks(range(ntarget), targetsperchunk):
                
                if len(targdata.shape) == 3:
                    in_queue.put(targdata[targ_idx,:,frame])
                else:
                    in_queue.put(targdata[targ_idx,:])
            return
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
                scat_t, t0_t = align_and_sum(scat_t, t0_t, scat, t0, fs)
                
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
        self.progress = Progress()
    
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
        
        progress = Progress()
        # start worker processes
        for w in xrange(nproc):
            w = Process(target=work, args=(in_queue, out_queue, 
                self.script_path))
            w.start()
            self.workers.append(w)        
        
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
 
    #def start(self, nproc=1, maxtargetsperchunk=10000, frames=None):
    #        
    #    # check that script and dataset are defined
    #    if self.script is None:
    #        raise Exception('Simulation script not set')
    #    
    #    self.reset()
    #    in_queue = Queue() # queue that sends data to workers
    #    out_queue = Queue() # queue that sends data to collector
    #    res_queue = Queue() # queue that sends data to delegator
    #    
    #    # open input file and read dataset
    #    root = h5py.File(self.input_path[0], 'r')
    #    targets = root[self.input_path[1]]
    #    
    #    # get metadata from dataset
    #    target_prms = dict()
    #    for key, val in targets.attrs.iteritems():
    #        target_prms[key] = val
    #    
    #    # get field ii parameters
    #    def_script = __import__(self.script)
    #    field_prms = def_script.get_prms()
    #    
    #    ntargets = targets.shape[0]
    #    
    #    if frames is None:
    #        frames = 0
    #        self.frame_no = 0
    #    else:
    #        self.frame_no = frames
    #        
    #    if len(targets.shape) < 3:
    #        frames = Ellipsis
    #    
    #    targets_per_chunk = min(np.floor(ntargets/nproc).astype(int), 
    #        maxtargetsperchunk)
    #        
    #    try: 
    #        
    #        # start collector process
    #        collector = Process(target=collect, args=(out_queue, res_queue, 
    #            field_prms['sample_frequency']), name='collector')
    #        collector.start()
    #        self.collector.append(collector)
    #        
    #        # start worker processes
    #        for j in xrange(nproc):
    #            worker = Process(target=work, args=(in_queue, out_queue, 
    #                self.script), name=('worker'+str(j)))
    #            worker.start()
    #            self.workers.append(worker)
    #        
    #        # put data chunks into the input queue
    #        for idx in chunks(range(ntargets), targets_per_chunk):
    #            in_queue.put(targets[(idx),:,frames])
    #        
    #        # put poison pills into the input queue
    #        for w in self.workers:
    #            in_queue.put('STOP')
    #        
    #        root.close()
    #        
    #        self.out_queue = out_queue
    #        self.res_queue = res_queue
    #        self.field_prms = field_prms
    #        self.target_prms = target_prms
   
#    def write_data(self, path=(), frame=None):
#
#        if frame is None:
#            frame = self.frame_no
#            
#        try:
#            # open output file and write results
#            root = h5py.File(path[0], 'a')
#            dataset = path[1]
#            
#            dims = self.result[0].shape
#            
#            # if dataset doesn't exist, create a new dataset
#            if dataset not in root:
#                
#                rfdata = root.create_dataset(dataset, 
#                    shape=(dims[0], dims[1], frame+1),
#                    maxshape=(None, dims[1], None), dtype='double',
#                    compression='gzip')
#                     
#                rfdata[:,:,frame] = self.result[0].copy()
#               
#            else:
#                
#                rfdata = root[dataset]
#                align_write(rfdata, self.result[0], self.result[1], frame)
#            
#            # set data attributes
#            rfdata.attrs.create('start_time', self.result[1])
#            
#            # copy target parameters to data attributes
#            for key, val in self.target_prms.iteritems():
#                rfdata.attrs.create(key, val)
#            
#            # copy field ii parameters to data attributes
#            for key, val in self.field_prms.iteritems():
#                rfdata.attrs.create(key, val)
#            
#            root.close()
#            
#        except:
#            
#            root.close()
#            raise  
        
        
        
        
            
    