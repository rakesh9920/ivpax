# flow / algorithms.py

from pyfield.signal import xcorr, iqdemod
import numpy as np
from scipy.interpolate import interp1d

def corr_lag_doppler(bfdata, c=None, fs=None, prf=None, interleave=1, 
    interpolate=1, resample=1, threshold=0, retcoeff=False):

    if bfdata.ndim == 3:
        npos, nsample, nframe = bfdata.shape
    else:
        nsample, nframe = bfdata.shape
        npos = 1
    
    nestimate = nframe - interleave 
    
    velocity = np.zeros(npos, nestimate)
    if retcoeff:
        coeff = np.zeros(velocity.shape)
    
    lags = np.linspace(-nsample, nsample, 2*nsample + 1)/(fs*resample*2)*c
    
    if interpolate > 1:
        slags = np.linspace(-nsample*interpolate, nsample*interpolate, 
            2*nsample*interpolate + 1)/(fs*resample*2)*c
    
    for pos in xrange(npos):
        
        for est in xrange(nestimate):
            
            signal1 = bfdata[pos,:,est]
            signal2 = bfdata[pos,:,est + 1 + interleave - 1]
            
            correlation = xcorr(signal1, signal2, norm=True)
            
            if np.all(np.isnan(correlation)):
                velocity[pos, est] = 0
                continue
            
            if interpolate > 1:
                
                interp = interp1d(lags, correlation, kind='cubic')
                scorrelation = interp(slags)
                
                maxcorr = np.max(scorrelation)
                maxlag = slags(np.argmax(scorrelation))
                
                coeff[pos,est] = maxcorr
                
                if maxcorr > threshold:
                    velocity[pos,est] = maxlag*prf/interleave
                else:
                    velocity[pos,est] = 0
            
            else:
                
                maxcorr = np.max(correlation)
                maxlag = lags(np.argmax(correlation))
                
                coeff[pos,est] = maxcorr
                
                if maxcorr > threshold:
                    velocity[pos,est] = maxlag*prf/interleave
                else:
                    velocity[pos,est] = 0
    
    if retcoeff:
        return velocity, coeff
    else:
        return velocity

def inst_phase_doppler(bfdata, fc=None, bw=None, fs=None, c=None, prf=None, 
    interleave=1, ensemble=1, gate=1):
    
    if bfdata.ndim == 3:
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