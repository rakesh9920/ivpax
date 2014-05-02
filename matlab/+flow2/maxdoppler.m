function [VelMat, CorrMat] = maxdoppler(BfMat, deltaSample, nCompare, nWinSample,...
    varargin)
%MAXDOPPLER

import tools.prog

Argsin = inputParser;
Argsin.KeepUnmatched = true;
addOptional(Argsin, 'progress', false);
addOptional(Argsin, 'interpolate', 1);
addOptional(Argsin, 'threshold', 0);
addOptional(Argsin, 'resample', 1);
addOptional(Argsin, 'interleave', 0);
addOptional(Argsin, 'SOUND_SPEED', 1500);
addOptional(Argsin, 'SAMPLE_FREQUENCY', 40e6);
addOptional(Argsin, 'PULSE_REPITITION_RATE', 1000);
parse(Argsin, varargin{:});

progress = Argsin.Results.progress;
interpolate = Argsin.Results.interpolate;
threshold = Argsin.Results.threshold;
resample = Argsin.Results.resample;
interleave = Argsin.Results.interleave;

SOUND_SPEED = Argsin.Results.SOUND_SPEED;
SAMPLE_FREQUENCY = Argsin.Results.SAMPLE_FREQUENCY;
PULSE_REPITITION_RATE = Argsin.Results.PULSE_REPITITION_RATE;

BfMat = double(BfMat);

[nSample, nFrame, nFieldPos] = size(BfMat);

assert(nSample == (nCompare - 1)*deltaSample + nWinSample);
centerSample = (nSample + 1)/2;
pointNo = (nCompare + 1)/2;


VelMat = zeros(nFrame - interleave - 1, nFieldPos);
CorrList = zeros(1, nCompare);
CorrMat = zeros(nCompare, nFrame, nFieldPos);

% calculate physical spacing between candidate points (adjust sample
% frequency if resampling is desired)
if resample > 1
    deltaSpace = deltaSample/SAMPLE_FREQUENCY*SOUND_SPEED/2/resample;
else
    deltaSpace = deltaSample/SAMPLE_FREQUENCY*SOUND_SPEED/2;
end

% calculate travel speeds for each candidate point
TravelSpeed = ((1:nCompare) - pointNo).*deltaSpace.*PULSE_REPITITION_RATE....
    /(interleave + 1);

if interpolate > 1
    TravelSpeedInterp = interp(TravelSpeed, interpolate);
end

if progress
    [bar, cleanup] = prog('@maxdoppler');
end

% iterate over points of interest
for pos = 1:nFieldPos
    
    % iterate over each frame
    for frame = 1:(nFrame - interleave - 1)
        
        Signal1 = BfMat(:,pointNo,frame,pos);
        
        % iterate over candidate points
        for point = 1:nCompare
            
            Signal2 = BfMat(:,point,frame + interleave + 1,pos);
            
            CorrList(point) = max(xcorr(Signal1, Signal2,'coeff'));
        end
        
        CorrMat(:, pos, frame) = CorrList;
        
        if interpolate > 0
            
            XcorrListInterp = spline(TravelSpeed, CorrList, TravelSpeedInterp);
            
            [maxValue, maxInd] = max(XcorrListInterp);
            VelMat(frame,pos) = TravelSpeedInterp(maxInd);
            
        else
            
            [maxValue, maxInd] = max(CorrList);
            VelMat(frame,pos) = TravelSpeed(maxInd);% - TravelSpeed(pointNo);
        end
        
        if maxValue < threshold
            VelMat(frame,pos) = 0;
            continue
        end
    end
    
    if prog
        prog(bar, pos/nFieldPos);
    end
end

end
