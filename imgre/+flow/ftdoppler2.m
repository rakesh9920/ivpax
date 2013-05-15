function [VelocityEst] = ftdoppler2(BfSigMat, FieldPos, pointNo, varargin)
% Doppler flow estimate using full cross-correlation

import tools.upicbar tools.sqdistance

% read in optional arguments
if nargin > 4
    keys = varargin(1:2:end);
    values = varargin(2:2:end);   
    map = containers.Map(keys, values);    
else
    map = containers.Map;
end

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

% global constants
global SOUND_SPEED SAMPLE_FREQUENCY PULSE_REPITITION_RATE
if isempty(SOUND_SPEED)
    SOUND_SPEED = 1500;
end
if isempty(SAMPLE_FREQUENCY)
    SAMPLE_FREQUENCY = 40e6;
end
if isempty(PULSE_REPITITION_RATE)
    PULSE_REPITITION_RATE = 100;
end

[nSample nPoint nFrame] = size(BfSigMat);
VelocityEst = zeros(1, nFrame - 1);

TravelSpeed = sqrt(sqdistance(FieldPos(:,pointNo), ...
    FieldPos)).*PULSE_REPITITION_RATE;
TravelSpeed(1:(pointNo-1)) = -TravelSpeed(1:(pointNo-1));

if interpolate > 0
    TravelSpeedInterp = interp(TravelSpeed, interpolate);
end

XcorrList = zeros(1, nPoint);

if progress
    progressBar = upicbar('Calculating velocity...');
end

for frame = 1:(nFrame - 1)
    if progress
        upicbar(progressBar, frame/(nFrame - 1));
    end
    
    Signal1 = BfSigMat(:,pointNo,frame);
    
    for point = 1:nPoint
        Signal2 = BfSigMat(:,point,frame+1);
        XcorrList(point) = max(xcorr(Signal1, Signal2, 'coeff'));
    end
    
    if interpolate > 0
        XcorrListInterp = interp(XcorrList, 4);
        [maxValue, maxInd] = max(XcorrListInterp);
        VelocityEst(frame) = TravelSpeedInterp(maxInd);
    else
        [maxValue, maxInd] = max(XcorrList);
        VelocityEst(frame) = TravelSpeed(maxInd);
    end
    
    if maxValue < 0.9
        VelocityEst(frame) = 0;
        continue
    end
end

end
