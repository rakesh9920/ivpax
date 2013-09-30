function [VelEst, Coeff] = lagdoppler(BfSigMat, varargin)
%
% interleave, progress

import tools.upicbar

% read in optional arguments
if nargin > 1
    if isa(varargin{1}, 'containers.Map')
        map = varargin{1};
    else
        keys = varargin(1:2:end);
        values = varargin(2:2:end);
        map = containers.Map(keys, values);
    end
else
    map = containers.Map;
end

if isKey(map, 'progress')
    progress = map('progress');
    map('progress') = false;
else
    progress = false;
end
if isKey(map, 'interleave')
    interleave = map('interleave');
else
    interleave = 0;
end
if isKey(map, 'interpolate')
    interpolate = map('interpolate');
else
    interpolate = 0;
end
if isKey(map, 'resample')
    resample = map('resample');
else
    resample = 1;
end
if isKey(map, 'threshold')
    threshold = map('threshold');
else
    threshold = 0;
end

% global constants
global SOUND_SPEED SAMPLE_FREQUENCY PULSE_REPITITION_RATE
if isempty(SOUND_SPEED)
    SOUND_SPEED = 1500;
end
if isempty(PULSE_REPITITION_RATE)
    PULSE_REPITITION_RATE = 100;
end


[nSample, nFieldPos, nFrame] = size(BfSigMat);

nEstimate = nFrame - interleave - 1;
VelEst = zeros(nFieldPos, nEstimate);
Coeff = zeros(nFieldPos, nEstimate);

nCorrSample = 2*nSample - 1;

if interpolate > 0
    Lag = 1:nCorrSample;
    LagInterp = interp(Lag, interpolate);
end

for pos = 1:nFieldPos
    
    for est = 1:nEstimate
        
        Signal1 = BfSigMat(:,pos,est);
        Signal2 = BfSigMat(:,pos,est + interleave + 1);
        
        CrossCorr = xcorr(Signal1, Signal2, 'coeff');
        
        if all(isnan(CrossCorr))
           VelEst(pos,est) = 0;
           continue
        end
        
        if interpolate > 0
            
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

