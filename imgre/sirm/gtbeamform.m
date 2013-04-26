function [BfSigMat] = gtbeamform(RxSigMat, TxPos, RxPos, FieldPos, ...
    nWinSample, varargin)
% General frequency beamformer (for synthetic RF data)

nFieldPos = size(FieldPos, 2);
[nSignal nSample nFrame] = size(RxSigMat);

global SOUND_SPEED SAMPLE_FREQUENCY
if isempty(SOUND_SPEED)
    SOUND_SPEED = 1500;
end
if isempty(SAMPLE_FREQUENCY)
    SAMPLE_FREQUENCY = 40e6;
end

if nargin >= 6
   if all(lower(varargin{1}) == 'plane')
       plane = true;
   else
       plane = false;
   end
end

if plane
    TxDelay = round(abs(FieldPos(3,:))./SOUND_SPEED.*SAMPLE_FREQUENCY);
else
    TxDelay = round(sqrt(sqdistance(TxPos, FieldPos))./SOUND_SPEED.*SAMPLE_FREQUENCY);
end
RxDelay = round(sqrt(sqdistance(RxPos, FieldPos))./SOUND_SPEED.*SAMPLE_FREQUENCY);
TotalDelay = bsxfun(@plus, RxDelay, TxDelay);

if mod(nWinSample, 2) == 0
    nWinSample = nWinSample + 1;
end

nWinSampleHalf = (nWinSample - 1)/2;

BfSigMat = zeros(nWinSample, nFieldPos, nFrame);

bar = upicbar('Beamforming ...');
for point = 1:nFieldPos
    
    upicbar(bar, point/nFieldPos);
    
    Delays = TotalDelay(:, point);
    delind = ((Delays + nWinSampleHalf) > nSample | (Delays - nWinSampleHalf) < 1);
    
    if all(delind)
        continue
    end
    
    BfSig = zeros(1, nWinSample, nFrame);
    for sig = 1:nSignal
        
       if delind(sig)
           continue
       end
       
       BfSig = bsxfun(@plus, BfSig, RxSigMat(sig,...
           (Delays(sig)-nWinSampleHalf):(Delays(sig)+nWinSampleHalf),:)); 
    end
    
    BfSigMat(:,point,:) = reshape(BfSig, nWinSample, 1, []);
end
end

