function [BfMat] = gtbeamform2(RxMat, TxPos, RxPos, FieldPos, ...
    nWinSample, varargin)
% General time beamformer (for synthetic RF data) with memory limit

import tools.sqdistance tools.prog

% set scheme for optional input arguments and parse
Argsin = inputParser;
Argsin.KeepUnmatched = true;
addOptional(Argsin, 'planetx', false);
addOptional(Argsin, 'interpolate', 1);
addOptional(Argsin, 'soundspeed', 1500);
addOptional(Argsin, 'samplefrequency', 40e6);
addOptional(Argsin, 'progress', true);
parse(Argsin, varargin{:});

planetx = Argsin.Results.planetx;
interpolate = Argsin.Results.interpolate;
progress = Argsin.Results.progress;
SOUND_SPEED = Argsin.Results.soundspeed;
SAMPLE_FREQUENCY = Argsin.Results.samplefrequency;

if progress
    [bar, cleanup] = prog('@gtbeamform2');
end

RxMat = double(RxMat);
nFieldPos = size(FieldPos, 1);
[nSample, nChannel, nFrame] = size(RxMat);

% calculate delays
if planetx
    TxDelay = abs(FieldPos(:,3))./SOUND_SPEED;
else
    TxDelay = sqrt(sqdistance(FieldPos, TxPos))./SOUND_SPEED;
end
RxDelay = sqrt(sqdistance(FieldPos, RxPos))./SOUND_SPEED;
TotalDelay = round(bsxfun(@plus, RxDelay, TxDelay).*SAMPLE_FREQUENCY.*interpolate) - interpolate + 1;

if mod(nWinSample, 2) == 0
    
    BfMat = zeros(nWinSample + 1, nFrame, nFieldPos);
    nWinSample = nWinSample*interpolate + 1;
else
    
    BfMat = zeros(nWinSample, nFrame, nFieldPos);
    nWinSample = (nWinSample - 1)*interpolate + 1;
end
nWinSampleHalf = (nWinSample - 1)/2;

% determine number of blocks needed to reduce memory usage
MEMORY_LIMIT_IN_BYTES = 2*1024*1024*1024;
frameSize = nChannel*(nSample + nWinSample)*8*interpolate;
framesPerBlock = floor(MEMORY_LIMIT_IN_BYTES/frameSize);
nBlock = ceil(nFrame/framesPerBlock);

for block = 1:nBlock
    
    blockFront = (block - 1)*framesPerBlock + 1;
    if block < nBlock
        blockBack = blockFront + framesPerBlock - 1;
    else
        blockBack = nFrame;
    end
    
    if interpolate > 1
        PadRxMat = resample(RxMat(:,:,blockFront:blockBack), interpolate, 1);
    else
        PadRxMat = RxMat(:,:,blockFront:blockBack);
    end
    
    PadRxMat = padarray(PadRxMat, [nWinSampleHalf 0 0], 'pre');
    PadRxMat = padarray(PadRxMat, [nWinSampleHalf 0 0], 'post');
    
    for point = 1:nFieldPos
        
        if progress
            prog(bar, (nFieldPos*(block - 1) + point)/(nFieldPos*nBlock));
        end
        
        % remove delays that exceed signal length
        Delays = TotalDelay(point,:);
        
        delidx = Delays > nSample*interpolate;
        if all(delidx)
            continue
        end
        
        disp([num2str(block) '/' num2str(nBlock) ',' num2str(point)]);
        
        % for each channel, delay, window, and then sum with cumulative sum
        BfSig = zeros(nWinSample, nFrame);
        
        for chan = 1:nChannel
            
            if delidx(chan)
                continue
            end
            
            BfSig = bsxfun(@plus, BfSig, ...
                PadRxMat(Delays(chan):(Delays(chan) + nWinSample - 1),chan,:));
            %             BfSig = BfSig + squeeze(...
            %                    PadRxMat(Delays(chan):(Delays(chan) + nWinSample - 1),chan,:));
        end
        
        if interpolate > 1
            BfMat(:,blockFront:blockBack,point) = resample(reshape(BfSig, ...
                nWinSample, [], 1), 1, interpolate);
        else
            BfMat(:,blockFront:blockBack,point) = reshape(BfSig, nWinSample, [], 1);
        end
    end
end

end

