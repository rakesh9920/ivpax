function [VelEst] = axialest(RxSigMat, TxPos, RxPos, FieldPos, nCompare,...
    delta, varargin)
% velocity estimate along axial direction
%
% Optional:
%   progress = (true, =false) | show progress bar
%   beamformType (='time', 'frequency') | choose beamformer type

import beamform.gfbeamform2
import flow.ftdoppler2

% read in optional arguments
if nargin > 6
    keys = varargin(1:2:end);
    values = varargin(2:2:end);
    
    map = containers.Map(keys, values);
    
    if isKey(map, 'progress')
        progress = map('progress');
    else
        progress = false;
    end
    if isKey(map, 'beamformType')
        beamformType = map('beamformType');
    else
        beamformType = 'frequency';
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
nFieldPos = size(FieldPos, 2);

if mod(nCompare, 2) == 0
    nCompare = nCompare + 1;
end

DeltaZ = -(nCompare - 1)/2*delta:delta:(nCompare - 1)/2*delta;

VelEst = zeros(1, nFieldPos, nFrame - 1);

for pos = 1:nFieldPos
    BfPointList = bsxfun(@plus, FieldPos(:,pos), [zeros(1, nCompare); ...
        zeros(1, nCompare); DeltaZ]);
    
    switch beamformType
        case 'time'
            BfSigMat = gtbeamform(RxSigMat, TxPos, RxPos, BfPointList, ...
                150, 'plane', plane, 'progress', progress);
        case 'frequency'
            BfSigMat = gfbeamform2(RxSigMat, TxPos, RxPos, BfPointList, ...
                150, 'plane', plane, 'progress', progress);
    end
    
    VelEst(1,pos,:) = ftdoppler2(BfSigMat, BfPointList, (nCompare+1)/2,...
        'interpolate', interpolate);
end

end

