# pyfield / extra.py

from pyfield.signal import wgn

from scipy import signal as sig
from scipy import fftpack as ft
from scipy.interpolate import interp1d
import numpy as np
import h5py
from matplotlib import pyplot as pp
from mpl_toolkits.mplot3d import Axes3D

def ffts(x, *args, **kwargs):
    
    fs = kwargs.pop('fs', 1)
    return ft.fftshift(ft.fft(x, *args, **kwargs)*fs)

def iffts(x, *args, **kwargs):
    
    fs = kwargs.pop('fs', 1)
    return ft.ifft(ft.ifftshift(x), *args, **kwargs)/fs

def bsc_to_filt(bsc, c=None, rho=None, area=None, ns=None, fs=None):
    
    #area = 1.9838392692290149e-05
    
    nfft = 2**13
    freq = ft.fftshift(ft.fftfreq(nfft, 1/fs))
    #fidx = np.argmin(np.abs(freq[nfft/2:,None] - bsc[None,:,0]), axis=0) + nfft/2
    
    f_interp = interp1d(bsc[:,0], bsc[:,1], kind='linear')
    
    freq_resp = 2*np.pi/(rho*c*area*np.sqrt(ns))*np.sqrt(f_interp(np.abs(freq)))
    
    filt = np.gradient(np.real(ft.ifftshift(iffts(freq_resp, fs=fs))), 1/fs)*fs

    return filt[(nfft/2-50):(nfft/2+50)]

def bsc_to_fir(bsc, c=None, rho=None, area=None, ns=None, fs=None, deriv=True,
    ntap=100):
    
    #area = 1.9838392692290149e-05
    
    bsc = bsc.reshape((-1, 2))
    
    freq_resp = 2*np.pi/(rho*c*area*np.sqrt(ns))*np.sqrt(np.abs(bsc[:,1]))

    imp_resp = sig.firwin2(ntap, bsc[:,0], freq_resp, nyq=fs/2.0, 
        antisymmetric=False, window='hamming')
    
    if deriv:
        return np.gradient(imp_resp, 1/fs)
    else:
        return imp_resp
        
def apply_bsc(inpath, outpath, bsc=None, method='fir', write=False, loop=False):
    
    inroot = h5py.File(inpath[0], 'a')
    indata = inroot[inpath[1]]
                    
    if outpath[0] != inpath[0]:
        outroot = h5py.File(outpath[0], 'a')
    else:
        outroot = inroot
    
    if write:
        
        if outpath[1] in outroot:
            del outroot[outpath[1]]
            
        outdata = outroot.create_dataset(outpath[1], shape=indata.shape, 
            dtype='double', compression='gzip')
            
    else:
        outdata = outroot[outpath]
    
    if bsc is None:
        bsc = indata.attrs.get('bsc_spectrum')
    
    keys = ['c', 'rho', 'area', 'ns', 'fs']
    attrs = ['sound_speed', 'density', 'area', 'target_density', 
        'sample_frequency']
    params = {k : indata.attrs.get(a) for k,a in zip(keys, attrs)}
    
    if method.lower() == 'ifft':
        filt = bsc_to_filt(bsc, **params)
    else:
        filt = bsc_to_fir(bsc, **params)
    
    #fs = params['fs']
    
    if loop:
        for f in xrange(indata.shape[2]):
            for c in xrange(indata.shape[1]):
                outdata[:,c,f] = sig.fftconvolve(indata[:,c,f], filt, 'same')
                #outdata[:,c,f] = sig.filtfilt(filt, 1, indata[:,c,f])
    else:
        outdata[:] = np.apply_along_axis(sig.fftconvolve, 0, indata[:], 
            filt, 'same')
        #outdata[:] = sig.filtfilt(filt, 1, indata[:], axis=0)
    
    for key, val in indata.attrs.iteritems():
        outdata.attrs.create(key, val)
      
def apply_wgn(inpath, outpath, dbw=1, write=False, loop=False):
    
    inroot = h5py.File(inpath[0], 'a')
    indata = inroot[inpath[1]]
    
    if outpath[0] != inpath[0]:
        outroot = h5py.File(outpath[0], 'a')
    else:
        outroot = inroot
    
    if write:
        if outpath[1] in outroot:
            del outroot[outpath[1]]
        
        outdata = outroot.create_dataset(outpath[1], shape=indata.shape, 
            dtype='double', compression='gzip')
    
    else:
        outdata = outroot[outpath]
    
    if loop:
        
        for f in xrange(indata.shape[2]):
            outdata[:,:,f] = indata[:,:,f] + wgn(indata.shape[0:2], dbw)
            
    else:
        outdata[:] = indata[:] + wgn(indata.shape, dbw)
        
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

def xdc_draw(file_path, fig=None, wireframe=False):
    
    with np.load(file_path) as varz:
    
        info = varz['info']

        phys_no = info[0,:]
        vertices = info[10:22,:]
        #apod = info[4,:]
        #widths = info[2,:]
        #height = info[3,:]
        #centers = info[7:10,:]
    
    nelement = phys_no.shape[0]
    
    if fig is None:
        fig = pp.figure()
        
    ax = fig.add_subplot(111, projection='3d')
    
    vert_x = vertices[[0, 3, 9, 6],:]
    vert_y = vertices[[1, 4, 10, 7],:]
    vert_z = vertices[[2, 5, 11, 8],:]
    
    max_x = np.max(np.abs(vert_x))
    max_y = np.max(np.abs(vert_y))
    max_dim = max(max_x, max_y)
    
    colors = ('b', 'r', 'c')
    
    if wireframe:
        for ele in xrange(nelement):
            
            ax.plot_wireframe(vert_x[:,ele].reshape((2,2)), 
                vert_y[:,ele].reshape((2,2)), vert_z[:,ele].reshape((2,2)), 
                color='r', linewidths=0.2)
    else:
        for ele in xrange(nelement):
            
            ax.plot_surface(vert_x[:,ele].reshape((2,2)), 
                vert_y[:,ele].reshape((2,2)), vert_z[:,ele].reshape((2,2)),
                color=colors[int(phys_no[ele] % len(colors))])
     
    #ax.auto_scale_xyz([-max_dim, max_dim], [-max_dim, max_dim], [0, max_dim*2])
    #fig.show()

def xdc_load_info(file_path):
    
    with np.load(file_path) as varz:
    
        info = varz['info']

        phys_no = info[0,:]
        vertices = info[10:22,:]
        vert_x = vertices[[0, 3, 9, 6],:]
        vert_y = vertices[[1, 4, 10, 7],:]
        vert_z = vertices[[2, 5, 11, 8],:]
        apod = info[4,:]
        widths = info[2,:]
        heights = info[3,:]
        centers = info[7:10,:]
        
    return dict(phys_no=phys_no, vert_x=vert_x, vert_y=vert_y, vert_z=vert_z,
        apod=apod, widths=widths, heights=heights, centers=centers)
    
#def xdc_load_aperture(f2, file_path):
#    
#    with np.load(file_path) as varz:
#        
#        info = varz['info']
#        focus = varz['focus']
#        
#        rect = np.zeros((19, info.shape[1]))
#        rect[0,:] = info[0,:]
#        rect[1:13,:] = info[10:22,:]
#        rect[13,:] = info[4,:]
#        rect[14,:] = info[2,:]
#        rect[15,:] = info[3,:]
#        rect[16:19,:] = info[7:10,:]
#        
#        centers = info[23:26,:].T
#        
#        focus_times = focus[:,0]
#        focus_delays = focus[:,1:]
#        
#        aperture = f2.xdc_rectangles(rect, centers, np.array([[0,0,300]]))
#        f2.xdc_focus_times(aperture, focus_times, focus_delays)
#    
#    return aperture

def xdc_get_area(file_path):
    
    with np.load(file_path) as varz:
    
        info = varz['info']
        widths = info[2,:]
        heights = info[3,:]

    area = np.sum(widths*heights)
    
    return area




