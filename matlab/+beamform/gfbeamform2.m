function [BfSigMat] = gfbeamform2(RxSigMat, TxPos, RxPos, FieldPos, ...
    nWinSample, varargin)
% General frequency beamformer (for synthetic RF data)

import tools.sqdistance

% read in optional arguments
if nargin > 5
    keys = varargin(1:2:end);
    values = varargin(2:2:end);
    
    map = containers.Map(keys, values);
    
    if isKey(map, 'progress')
        progress = map('progress');
    end
    if isKey(map, 'plane')
        plane = true;
    end
end

% set defaults
if ~exist('progress', 'var')
    progress = false;
end
if ~exist('plane', 'var')
    plane = false;
end

global SOUND_SPEED SAMPLE_FREQUENCY
if isempty(SOUND_SPEED)
    SOUND_SPEED = 1500;
end
if isempty(SAMPLE_FREQUENCY)
    SAMPLE_FREQUENCY = 40e6;
end

nFieldPos = size(FieldPos, 2);
[nSignal nSample nFrame] = size(RxSigMat);

if plane
    TxDelay = abs(FieldPos(3,:))./SOUND_SPEED;
else
    TxDelay = sqrt(sqdistance(TxPos, FieldPos))./SOUND_SPEED;
end
RxDelay = sqrt(sqdistance(RxPos, FieldPos))./SOUND_SPEED;
TotalDelay = bsxfun(@plus, RxDelay, TxDelay);

if mod(nWinSample, 2) == 0
    nWinSample = nWinSample + 1;
end

BfSigMat = zeros(nWinSample, nFieldPos, nFrame);

nFreq = 2^nextpow2(nSample + nWinSample);
FrontPad = zeros(nSignal, floor((nFreq - nSample)/2), nFrame);
BackPad = zeros(nSignal, nFreq - nSample - size(FrontPad, 2), nFrame);
PadSigMat = [FrontPad RxSigMat BackPad];

RxSigMatSpect = fft(PadSigMat, [], 2);

Freq = SAMPLE_FREQUENCY/2*linspace(0, 1, nFreq/2+1);
Freq2S = [Freq(1:end-1) -Freq(end) -fliplr(Freq(2:(end-1)))];

winFront = size(FrontPad, 2) -(nWinSample-1)/2;
winBack = size(FrontPad, 2) + (nWinSample-1)/2;

if progress
    bar = upicbar('Beamforming ...');
end

for point = 1:nFieldPos
    if progress
        upicbar(bar, point/nFieldPos);
    end
    
    Delays = -TotalDelay(:, point);
    delind = (Delays > (nSample/SAMPLE_FREQUENCY)) | (Delays < -(nSample/SAMPLE_FREQUENCY));
    
    if all(delind)
        continue
    end
    Delays(delind) = [];
    
    BfSigSpect = bsxfun(@times, exp(-2*pi*1i.*Delays*Freq2S), RxSigMatSpect(~delind,:,:));
    BfSig = real(ifft(sum(BfSigSpect), [], 2));
    WinBfSig = BfSig(1,winFront:winBack,:);
    
    BfSigMat(:,point,:) = reshape(WinBfSig, nWinSample, 1, []);
end
end

