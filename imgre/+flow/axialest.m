function [VelEst, BfSigMat, BfPointList] = axialest(RxSigMat, TxPos, RxPos, FieldPos, nCompare,...
    delta, nWindowSample, varargin)
% velocity estimate along axial direction
%
% Optional:
%   progress = (true, =false) | show progress bar
%   beamformType (='time', 'frequency') | choose beamformer type

import beamform.gfbeamform4 beamform.gtbeamform
import flow.ftdoppler2

% read in optional arguments
if nargin > 6
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
if isKey(map, 'beamformType')
    beamformType = map('beamformType');
else
    beamformType = 'time';
end
if isKey(map, 'interpolate')
    interpolate = map('interpolate');
else
    interpolate = 0;
end
if isKey(map, 'plane')
    plane = map('plane');
else
    plane = false;
end
if isKey(map, 'window')
    window = map('window');
else
    window = 'rectwin';
end
if isKey(map, 'bfsigmat')
    BfSigMat = map('bfsigmat');
    beamformType = 'bypass';
end
if isKey(map, 'averaging')
    averaging = map('averaging');
else
    averaging = 0;
end
if isKey(map, 'interleave')
    interleave = map('interleave');
else
    interleave = 0;
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

[nSig nSample nFrame] = size(RxSigMat);
if strcmp(beamformType,'bypass')
   nFrame = size(BfSigMat, 3); 
end
nFieldPos = size(FieldPos, 2);

if mod(nCompare, 2) == 0
    nCompare = nCompare + 1;
end
if mod(nWindowSample, 2) == 0
    nWindowSample = nWindowSample + 1;
end

switch window
    case 'hanning'
        win = hanning(nWindowSample);
    case 'gausswin'
        win = gausswin(nWindowSample);
    case 'rectwin'
        win = rectwin(nWindowSample);
end

DeltaZ = -(nCompare - 1)/2*delta:delta:(nCompare - 1)/2*delta;

if averaging > 0
    VelEst = zeros(1, nFieldPos, nFrame - averaging);
else
    VelEst = zeros(1, nFieldPos, nFrame - 1);
end

for pos = 1:nFieldPos
    BfPointList = bsxfun(@plus, FieldPos(:,pos), [zeros(1, nCompare); ...
        zeros(1, nCompare); DeltaZ]);
    
    switch beamformType
        case 'time'
            BfSigMat = gtbeamform(RxSigMat, TxPos, RxPos, BfPointList, ...
                nWindowSample, 'plane', plane, 'progress', progress);
        case 'frequency'
            BfSigMat = gfbeamform4(RxSigMat, TxPos, RxPos, BfPointList, ...
                nWindowSample, 'plane', plane, 'progress', progress);
        case 'bypass'
    end
    
    BfSigMatWin = bsxfun(@times, BfSigMat, win);
    
    if averaging > 0
        BfSigMatAvg = zeros(nWindowSample, nCompare, nFrame - averaging + 1);
        
        for frame = 1:(nFrame - averaging + 1)
            BfSigMatAvg(:,:,frame) = sum(BfSigMatWin(:,:,frame:(frame+averaging-1)),3);
        end
        
        VelEst(1,pos,:) = ftdoppler2(BfSigMatAvg, BfPointList, (nCompare+1)/2,...
            'interpolate', interpolate, 'progress', progress, 'interleave', interleave);
    else
        
        VelEst(1,pos,:) = ftdoppler2(BfSigMatWin, BfPointList, (nCompare+1)/2,...
            'interpolate', interpolate, 'progress', progress, 'interleave', interleave);
    end
    
    
end

end

