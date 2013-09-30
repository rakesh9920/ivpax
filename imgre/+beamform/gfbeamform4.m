function [BfSigMat] = gfbeamform4(RxSigMat, TxPos, RxPos, FieldPos, ...
    nWinSample, varargin)
% General frequency beamformer (for synthetic RF data) with memory limit

import tools.sqdistance tools.upicbar

% read in optional arguments
if nargin > 5
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
else
    progress = false;
end
if isKey(map, 'planetx')
    planetx = map('planetx');
else
    planetx = false;
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

RxSigMat = double(RxSigMat);

if planetx
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

Freq = SAMPLE_FREQUENCY/2*linspace(0, 1, nFreq/2+1);
Freq2S = [Freq(1:end-1) -Freq(end) -fliplr(Freq(2:(end-1)))];

MEMORY_LIMIT_IN_BYTES = 200*1024*1024;

frameSize = nSignal*nFreq*8;
framesPerBlock = floor(MEMORY_LIMIT_IN_BYTES/frameSize);
nBlock = ceil(nFrame/framesPerBlock);

FrontPad = zeros(nSignal, floor((nFreq - nSample)/2), framesPerBlock);
BackPad = zeros(nSignal, nFreq - nSample - size(FrontPad, 2), framesPerBlock);

winFront = size(FrontPad, 2) - (nWinSample-1)/2 + 1;
winBack = size(FrontPad, 2) + (nWinSample-1)/2 + 1;

if progress
    bar = upicbar('Beamforming ...');
end

for point = 1:nFieldPos
    Delays = -TotalDelay(:, point);
    delind = (Delays > (nSample/SAMPLE_FREQUENCY)) | (Delays < -(nSample/SAMPLE_FREQUENCY));
    
    if all(delind)
        continue
    end
    Delays(delind) = [];
    
    Phase = exp(-2*pi*1i.*Delays*Freq2S);
    
    for block = 1:nBlock
        if progress
            upicbar(bar, ((point - 1)*nBlock + block)/(nBlock*nFieldPos));
        end
        
        blockFront = (block - 1)*framesPerBlock + 1;
        if block < nBlock
            blockBack = blockFront + framesPerBlock - 1;
        else
            blockBack = nFrame;
        end
        
        PadSigMat = [FrontPad(~delind,:,1:(blockBack-blockFront+1)) ...
            RxSigMat(~delind,:,blockFront:blockBack)...
            BackPad(~delind,:,1:(blockBack-blockFront+1))];
        RxSigMatSpect = fft(PadSigMat, [], 2);
        BfSigSpect = bsxfun(@times, Phase, RxSigMatSpect);
        
        BfSig = real(ifft(sum(BfSigSpect, 1), [], 2));
        WinBfSig = BfSig(1,winFront:winBack,:);
        
        BfSigMat(:,point,blockFront:blockBack) = reshape(WinBfSig, nWinSample, 1, []);
    end
end

end

