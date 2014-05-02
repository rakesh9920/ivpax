function [BfMat] = gfbeamform6(RxMat, TxPos, RxPos, FieldPos, ...
    nWinSample, varargin)
% General frequency beamformer (for synthetic RF data) with memory limit

import tools.sqdistance

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
if isKey(map, 'planetx')
    planetx = map('planetx');
else
    planetx = false;
end

% get global parameters
global SOUND_SPEED SAMPLE_FREQUENCY
if isempty(SOUND_SPEED)
    SOUND_SPEED = 1500;
end
if isempty(SAMPLE_FREQUENCY)
    SAMPLE_FREQUENCY = 40e6;
end

RxMat = double(RxMat);
nFieldPos = size(FieldPos, 1);
[nSample, nChannel, nFrame] = size(RxMat);
BfMat = zeros(nWinSample, nFrame, nFieldPos);

% calculate delays
if planetx
    TxDelay = abs(FieldPos(:,3))./SOUND_SPEED;
else
    TxDelay = sqrt(sqdistance(FieldPos, TxPos))./SOUND_SPEED;
end
RxDelay = sqrt(sqdistance(FieldPos, RxPos))./SOUND_SPEED;
TotalDelay = bsxfun(@plus, RxDelay, TxDelay);

if mod(nWinSample, 2) == 0
    nWinSample = nWinSample + 1;
end

% create 2-sided frequency vector
nFreq = 2^nextpow2(nSample + (nWinSample - 1)/2);
Freq = SAMPLE_FREQUENCY/2*linspace(0, 1, nFreq/2+1);
Freq2S = [Freq(1:end-1) -Freq(end) -fliplr(Freq(2:(end-1)))].';

% determine number of blocks needed to reduce memory usage
MEMORY_LIMIT_IN_BYTES = 2*1024*1024*1024;
frameSize = nChannel*nFreq*8*2;
framesPerBlock = floor(MEMORY_LIMIT_IN_BYTES/frameSize);
nBlock = ceil(nFrame/framesPerBlock);

% determine padding needed
frontPad = (nWinSample - 1)/2;
backPad = nFreq - frontPad - nSample;

for block = 1:nBlock
    
    blockFront = (block - 1)*framesPerBlock + 1;
    if block < nBlock
        blockBack = blockFront + framesPerBlock - 1;
    else
        blockBack = nFrame;
    end
    
    PadRxMat = padarray(RxMat(:,:,blockFront:blockBack), [frontPad 0 0], 'pre');
    PadRxMat = padarray(PadRxMat, [backPad 0 0], 'post');
    
    RxMatSpect = fft(PadRxMat, [], 1);
    %BfMatSpect = zeros(nFreq, nFieldPos);
    
    for point = 1:nFieldPos
        
        % remove delays that exceed signal length
        Delays = -TotalDelay(point,:);
        delidx = Delays > (nSample + (nWinSample - 1)/2)/SAMPLE_FREQUENCY;
        if all(delidx)
            continue
        end
        Delays(delidx) = [];
        
        Phase = exp(-2*pi*1i.*Freq2S*Delays);
        
        disp([num2str(block) '/' num2str(nBlock) ',' num2str(point)]);
        
        BfMatSpect = sum(bsxfun(@times, Phase, RxMatSpect(:,~delidx,:)), 2);
        
        BfSig = real(ifft(BfMatSpect, [], 1));
        WinBfSig = BfSig(1:nWinSample,1,:);
        
        BfMat(:,blockFront:blockBack,point) = reshape(WinBfSig, nWinSample, [], 1);
    end
    
%     BfSig = real(ifft(BfMatSpect, [], 1));
%     WinBfSig = BfSig(1:nWinSample,:,:);
%     
%     BfMat(:,blockFront:blockBack,:) = WinBfSig;
end

end

