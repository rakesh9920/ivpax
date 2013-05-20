function [VelEst] = instaxialest(RxSigMat, TxPos, RxPos, ...
    FieldPos, nSum, nWindowSample, varargin)
% velocity estimate along axial direction
%
% Optional:
%   progress = (true, =false) | show progress bar
%   beamformType (='time', 'frequency') | choose beamformer type

import beamform.gfbeamform3 beamform.gtbeamform
import flow.instdoppler

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

switch beamformType
    case 'time'
        BfSigMat = gtbeamform(RxSigMat, TxPos, RxPos, FieldPos, ...
            nWindowSample, 'plane', plane, 'progress', progress);
    case 'frequency'
        BfSigMat = gfbeamform3(RxSigMat, TxPos, RxPos, FieldPos, ...
            nWindowSample, 'plane', plane, 'progress', progress);
end

BfSigMat = bsxfun(@times, BfSigMat, win);

VelEst = shiftdim(instdoppler(BfSigMat, nSum), -1);

end
