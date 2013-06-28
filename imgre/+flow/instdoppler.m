function [VelEst] = instdoppler(BfSigMat, nSum, varargin)
%

if nargin > 2
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
if isKey(map, 'interleave')
    interleave = map('interleave');
else
    interleave = 0;
end

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

nEstimate = nFrame - nSum - interleave;
VelEst = zeros(nFieldPos, nEstimate);
midSample = round(nSample/2);

for pos = 1:nFieldPos
    AnalyticSig = hilbert(squeeze(BfSigMat(:,pos,:)));
    I = real(AnalyticSig(midSample,:));
    Q = imag(AnalyticSig(midSample,:));
    
    %I = real(AnalyticSig(midSample-15:midSample+16,:));
    %Q = imag(AnalyticSig(midSample-15:midSample+16,:));
    
    for est = 1:nEstimate
        
        ind1 = est:(est + nSum - 1);
        ind2 = ind1 + interleave + 1;
        
        %         numer = 0;
        %         denom = 0;
        %         for s = 1:32
        %             numer = numer + Q(s,ind2).*I(s,ind1) - I(s,ind2).*Q(s,ind1);
        %             denom = denom + I(s,ind2).*I(s,ind1) + Q(s,ind2).*Q(s,ind1);
        %         end
        numer = -sum(Q(ind2).*I(ind1) - I(ind2).*Q(ind1));
        denom = sum(I(ind2).*I(ind1) + Q(ind2).*Q(ind1));
        
        deltaPhi = atan(numer/denom);
        
        VelEst(pos,est) = deltaPhi/(interleave+1)*PULSE_REPITITION_RATE*SOUND_SPEED/...
            (4*pi*CENTER_FREQUENCY);
    end
end

end

