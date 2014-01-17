function [VelEst, Coeff] = lagdoppler(BfSigMat, varargin)
%
% interleave, progress

import tools.prog

Argsin = inputParser;
Argsin.KeepUnmatched = true;
addOptional(Argsin, 'interleave', 0);
addOptional(Argsin, 'interpolate', 1);
addOptional(Argsin, 'resample', 1);
addOptional(Argsin, 'threshold', 0);
addOptional(Argsin, 'progress', false);
addOptional(Argsin, 'SOUND_SPEED', 1500);
addOptional(Argsin, 'SAMPLE_FREQUENCY', 40e6);
addOptional(Argsin, 'CENTER_FREQUENCY', 5e6);
addOptional(Argsin, 'PULSE_REPITITION_RATE', 1000);
parse(Argsin, varargin{:});

interleave = Argsin.Results.interleave;
interpolate = Argsin.Results.interpolate;
resample = Argsin.Results.resample;
threshold = Argsin.Results.threshold;
SOUND_SPEED = Argsin.Results.SOUND_SPEED;
SAMPLE_FREQUENCY = Argsin.Results.SAMPLE_FREQUENCY;
PULSE_REPITITION_RATE = Argsin.Results.PULSE_REPITITION_RATE;

[nSample, nFieldPos, nFrame] = size(BfSigMat);

nEstimate = nFrame - interleave - 1;
VelEst = zeros(nFieldPos, nEstimate);
Coeff = zeros(nFieldPos, nEstimate);

nCorrSample = 2*nSample - 1;

if interpolate > 1
    Lag = 1:nCorrSample;
    LagInterp = interp(Lag, interpolate);
end

if progress
    [bar, cleanup] = prog('@instdoppler');
end

for pos = 1:nFieldPos
    
    if progress
        prog(bar, pos/nFieldPos);
    end
    
    for est = 1:nEstimate
        
        Signal1 = BfSigMat(:,pos,est);
        Signal2 = BfSigMat(:,pos,est + interleave + 1);
        
        CrossCorr = xcorr(Signal1, Signal2, 'coeff');
        
        if all(isnan(CrossCorr))
           VelEst(pos,est) = 0;
           continue
        end
        
        if interpolate > 1
            
            CrossCorrInterp = spline(Lag, CrossCorr, LagInterp);
            [maxVal, maxInd] = max(CrossCorrInterp);
            
            VelEst(pos,est) = -(maxInd - (nSample - 1)*interpolate)/...
                SAMPLE_FREQUENCY/resample/interpolate/2*SOUND_SPEED*...
                PULSE_REPITITION_RATE/(interleave+1);
            
            Coeff(pos,est) = maxVal;
            
            if abs(maxVal) < threshold
               VelEst(pos,est) = 0; 
            end
        else
            
            [maxVal, maxInd] = max(CrossCorr);
            VelEst(pos,est) = -(maxInd - nSample)/SAMPLE_FREQUENCY/resample/2*...
                SOUND_SPEED*PULSE_REPITITION_RATE/(interleave+1);
            
            Coeff(pos,est) = maxVal;
            
            if abs(maxVal) < threshold
               VelEst(pos,est) = 0; 
            end
        end
    end
end

end

