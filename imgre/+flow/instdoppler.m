function [VelEst] = instdoppler(BfSigMat, nSum, varargin)
%

% global constants
global SOUND_SPEED SAMPLE_FREQUENCY PULSE_REPITITION_RATE CENTER_FREQUENCY
if isempty(SOUND_SPEED)
    SOUND_SPEED = 1500;
end
if isempty(SAMPLE_FREQUENCY)
    SAMPLE_FREQUENCY = 40e6;
end
if isempty(PULSE_REPITITION_RATE)
    PULSE_REPITITION_RATE = 100;
end
if isempty(CENTER_FREQUENCY)
    CENTER_FREQUENCY = 6.6e6;
end

[nSample nFieldPos nFrame] = size(BfSigMat);
% VelEst = zeros(nFieldPos, nFrame - 1);
nEstimate = nFrame - nSum;
VelEst = zeros(nFieldPos, nEstimate);

midSample = round(nSample/2);
%t = ((0:nFrame-1)./(500)).';
for pos = 1:nFieldPos
    AnalyticSig = hilbert(squeeze(BfSigMat(:,pos,:)));
    I = real(AnalyticSig(midSample,:));
    Q = imag(AnalyticSig(midSample,:));
    
    for est = 1:nEstimate

        ind1 = est:(est + nSum - 1);
        ind2 = ind1 + 1;
        numer = -sum(Q(ind2).*I(ind1) - I(ind2).*Q(ind1));
        denom = sum(I(ind2).*I(ind1) + Q(ind2).*Q(ind1));
        
        deltaPhi = atan(numer/denom);

        VelEst(pos,est) = deltaPhi*PULSE_REPITITION_RATE*SOUND_SPEED/(4*pi*CENTER_FREQUENCY);
    end
end

end

