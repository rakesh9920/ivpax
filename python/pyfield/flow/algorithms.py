# flow / algorithms.py

from pyfield.signal import xcorr, iqdemod
import numpy as np
from scipy.interpolate import interp1d
import h5py

def corr_lag_doppler(bfdata, c=None, fs=None, prf=None, interleave=1, 
    interpolate=1, resample=1, threshold=0, retcoeff=False, hdf5=False,
    vel_key=None, coeff_key=None, **kwargs):
    
    if isinstance(bfdata, tuple):
        hdf5 = True
        root = h5py.File(bfdata[0], 'a')
        bfdata = root[bfdata[1]][:] # copy all bfdata to memory... more memory
            # intensive but much much faster than looped access
    
    try:
        if len(bfdata.shape) == 3:
            npos, nsample, nframe = bfdata.shape
        else:
            nsample, nframe = bfdata.shape
            npos = 1
        
        nestimate = nframe - interleave 
        
        # pre-allocate velocity and coeff arrays, use hdf5 file if specified
        if hdf5:
            if vel_key in root:
                del root[vel_key]
                
            velocity = root.create_dataset(vel_key, shape=(npos, nestimate), 
                dtype='float', compression='gzip')
            
            if retcoeff:
                if coeff_key in root:
                    del root[coeff_key]
                
                coeff = root.create_dataset(coeff_key, shape=(npos, nestimate), 
                    dtype='float', compression='gzip')
        else:
            velocity = np.zeros(npos, nestimate) 
            
            if retcoeff:
                coeff = np.zeros(velocity.shape)
        
        lags = (np.linspace(-nsample + 1, nsample - 1, 2*nsample - 1) /
            (fs*resample*2)*c)
        
        if interpolate > 1:
            slags = np.linspace(-nsample + 1, nsample - 1, 
                2*nsample*interpolate - 2*interpolate + 1)/(fs*resample*2)*c
        
        for pos in xrange(npos):
            
            print pos
            
            for est in xrange(nestimate):
                
                signal1 = bfdata[pos,:,est]
                signal2 = bfdata[pos,:,est + 1 + interleave - 1]
                
                correlation = xcorr(signal1, signal2, norm=True)
                
                if np.all(np.isnan(correlation)):
                    velocity[pos, est] = 0
                    continue
                
                maxcorr = np.max(correlation)
                maxarg = np.argmax(correlation)
                
                if interpolate > 1:
                    
                    argb = max(maxarg - 2, 0)
                    arge = min(maxarg + 2, 2*nsample - 1)
                    
                    interp = interp1d(lags[argb:(arge + 1)], 
                        correlation[argb:(arge + 1)], kind='cubic')
                    
                    slags = np.linspace(lags[argb], lags[arge], 
                        4*interpolate + 1)
                        
                    scorrelation = interp(slags)
                    smaxcorr = np.max(scorrelation)
                    smaxlag = slags[np.argmax(scorrelation)]
                    
                    #interp = interp1d(lags, correlation, kind='cubic')
                    #scorrelation = interp(slags)
                    #
                    #maxcorr = np.max(scorrelation)
                    #maxlag = slags[np.argmax(scorrelation)]
                    
                    if retcoeff:
                        coeff[pos,est] = smaxcorr
                    
                    if maxcorr > threshold:
                        velocity[pos,est] = -smaxlag*prf/interleave
                    else:
                        velocity[pos,est] = 0
                
                else:
                    
                    #maxcorr = np.max(correlation)
                    maxlag = lags[maxarg]
                    
                    if retcoeff:
                        coeff[pos,est] = maxcorr
                    
                    if maxcorr > threshold:
                        velocity[pos,est] = -maxlag*prf/interleave
                    else:
                        velocity[pos,est] = 0
        
        if not hdf5:
            if retcoeff:
                return velocity, coeff
            else:
                return velocity
    
    finally:
        root.close()

def inst_phase_doppler(bfdata, fc=None, bw=None, fs=None, c=None, prf=None, 
    interleave=1, ensemble=1, gate=1, **kwargs):
    
    if len(bfdata.shape) == 3:
        npos, nsample, nframe = bfdata.shape
    else:
        nsample, nframe = bfdata.shape
        npos = 1
    
    midsample = np.floor(nsample/2).astype(int)
    gate_start = midsample - np.floor(gate/2.0)
    gate_stop = gate_start + gate
    
    nestimate = nframe - interleave - ensemble + 1
    
    velocity = np.zeros(npos, nestimate)
    
    for pos in xrange(npos):
        
        I, Q = iqdemod(bfdata[pos,:,:], fc, bw, fs, axis=0)
        
        I1 = I[gate_start:gate_stop,:]
        Q1 = Q[gate_start:gate_stop,:]
        
        delta_phi = np.zeros((gate, nestimate))
        for est in xrange(nestimate):
            
            idx1 = np.arange(est, est + ensemble)
            idx2 = idx1 + interleave

            for g in xrange(gate):
                
                numer = np.sum(Q1(g,idx2)*I1(g,idx1) - I1(g,idx2)*Q1(g,idx1))
                denom = np.sum(I1(g,idx2)*I1(g,idx1) + Q1(g,idx2)*Q1(g,idx1))
            
                delta_phi[g,est] += np.mean(np.arctan2(numer, denom))
        
        
            velocity[pos,est] = -np.mean(delta_phi[:,est])/interleave * \
                prf*c/(4*np.pi*fc)
    
    return velocity                

def corr_match_doppler():
	pass		