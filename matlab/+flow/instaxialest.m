function [VelEst, BfSigMat] = instaxialest(RxSigMat, TxPos, RxPos, ...
    FieldPos, nSum, nWindowSample, varargin)
% velocity estimate along axial direction
%
% Optional:
%   progress = (true, =false) | show progress bar
%   bfmethod (='time', 'frequency') | choose beamformer type

import beamform.gfbeamform4 beamform.gtbeamform
import flow.instdoppler

% read in optional arguments
if nargin > 6
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

if isKey(map, 'beamformType')
    beamformType = map('beamformType');
else
    beamformType = 'time';
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

[nSig, nSample, nFrame] = size(RxSigMat);
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
            nWindowSample, map);
    case 'frequency'
        BfSigMat = gfbeamform4(RxSigMat, TxPos, RxPos, FieldPos, ...
            nWindowSample, map);
    case 'bypass'
        nFrame = size(BfSigMat, 3);
end

BfSigMatWin = bsxfun(@times, BfSigMat, win);

if averaging > 0
    BfSigMatAvg = zeros(nWindowSample, nFieldPos, nFrame - averaging + 1);
    
    for frame = 1:(nFrame - averaging + 1)
        BfSigMatAvg(:,:,frame) = sum(BfSigMatWin(:,:,frame:(frame+averaging-1)),3);
    end
    
    VelEst = shiftdim(instdoppler(BfSigMatAvg, nSum, map), -1);
else
    VelEst = shiftdim(instdoppler(BfSigMatWin, nSum, map), -1);
end




end
