function [VelocityEst] = ftdoppler2(BfSigMat, delta, pointNo, varargin)
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

% global constants
global PULSE_REPITITION_RATE
if isempty(PULSE_REPITITION_RATE)
    PULSE_REPITITION_RATE = 100;
end

[nWindowSample, nCompare, nFrame, nFieldPos] = size(BfSigMat);

VelocityEst = zeros(nFrame - 1, nFieldPos);
XcorrList = zeros(1, nCompare);

TravelSpeed = ((1:nCompare) - pointNo).*delta.*PULSE_REPITITION_RATE;
% TravelSpeed = sqrt(sqdistance(FieldPos(:,pointNo), ...
%     FieldPos)).*PULSE_REPITITION_RATE;
% TravelSpeed(1:(pointNo-1)) = -TravelSpeed(1:(pointNo-1));

if interpolate > 0
    TravelSpeedInterp = interp(TravelSpeed, interpolate);
end

if progress
    prog = upicbar('Calculating velocity...');
end

for pos = 1:nFieldPos
    for frame = 1:(nFrame - interleave - 1)
        
        Signal1 = BfSigMat(:,pointNo,frame,pos);
        
        for point = 1:nCompare
            Signal2 = BfSigMat(:,point,frame + interleave + 1,pos);
            XcorrList(point) = max(xcorr(Signal1, Signal2, 'coeff'));
        end
        
        if interpolate > 0
            XcorrListInterp = spline(TravelSpeed, XcorrList, TravelSpeedInterp);
            [maxValue, maxInd] = max(XcorrListInterp);
            VelocityEst(frame,pos) = TravelSpeedInterp(maxInd);
        else
            [maxValue, maxInd] = max(XcorrList);
            VelocityEst(frame,pos) = TravelSpeed(maxInd);
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

end
