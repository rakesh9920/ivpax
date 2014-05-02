function [VelocityEst, XcorrMat] = ftdoppler(BfSigMat, deltaSample, pointNo, varargin)
% Doppler flow estimate using full cross-correlation
% progress, interpolate, threshold, interleave

import tools.upicbar

% read in optional arguments
if nargin > 3
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

% make deep copy of map for passing to other functions
mapOut = [map; containers.Map()] ;

% pull needed map values
if isKey(map, 'progress')
    progress = map('progress');
else
    progress = false;
end
if isKey(map, 'interpolate')
    interpolate = map('interpolate');
else
    interpolate = 0;
end
if isKey(map, 'threshold')
    threshold = map('threshold');
else
    threshold = 0;
end
if isKey(map, 'interleave')
    interleave = map('interleave');
else
    interleave = 0;
end
if isKey(map, 'resample')
    resample = map('resample');
else
    resample = 1;
end

% global constants
global PULSE_REPITITION_RATE SAMPLE_FREQUENCY SOUND_SPEED
if isempty(PULSE_REPITITION_RATE)
    PULSE_REPITITION_RATE = 100;
end
if isempty(SAMPLE_FREQUENCY)
    SAMPLE_FREQUENCY = 40e6;
end
if isempty(SOUND_SPEED)
    SOUND_SPEED = 1500;
end

[nWindowSample, nCompare, nFrame, nFieldPos] = size(BfSigMat);

VelocityEst = zeros(nFrame - interleave - 1, nFieldPos);
XcorrList = zeros(1, nCompare);
XcorrMat = zeros(nCompare, nFieldPos, nFrame);

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

if interpolate > 0
    TravelSpeedInterp = interp(TravelSpeed, interpolate);
end

if progress
    prog = upicbar('Calculating velocity...');
end

% Points = zeros(1, nFrame); %%

% iterate over points of interest
for pos = 1:nFieldPos
    
    % iterate over each frame
    for frame = 1:(nFrame - interleave - 1)
        
        Signal1 = BfSigMat(:,pointNo,frame,pos);
        
        % iterate over candidate points
        for point = 1:nCompare
            
            Signal2 = BfSigMat(:,point,frame + interleave + 1,pos);
            
            XcorrList(point) = max(xcorr(Signal1, Signal2,'coeff'));
        end
        
        XcorrMat(:, pos, frame) = XcorrList;
        
        if interpolate > 0
            
            XcorrListInterp = spline(TravelSpeed, XcorrList, TravelSpeedInterp);
            
            [maxValue, maxInd] = max(XcorrListInterp);
            VelocityEst(frame,pos) = TravelSpeedInterp(maxInd);
            
            %             VelocityEst(frame,pos) = (maxInd - (pointNo - 1)*interpolate)*...
            %                 deltaSpace/interpolate*PULSE_REPITITION_RATE;
            
            %             [~, maxInd2] = max(XcorrList); %%
            %             pointNo = maxInd2; %%
            %             Points(frame) = maxInd;%pointNo; %%
        else
            
            [maxValue, maxInd] = max(XcorrList);
            VelocityEst(frame,pos) = TravelSpeed(maxInd);% - TravelSpeed(pointNo);
        end
        
        if maxValue < threshold
            VelocityEst(frame,pos) = 0;
            continue
        end
    end
    
    if progress
        upicbar(prog, pos/nFieldPos);
    end
end

% save Points Points; %%
end
