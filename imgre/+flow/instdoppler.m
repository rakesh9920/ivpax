function [VelEst] = instdoppler(BfSigMat, varargin)
%
% interleave, nsum, progress

import tools.upicbar

% read in optional arguments
if nargin > 1
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
    map('progress') = false;
else
    progress = false;
end
if isKey(map, 'interleave')
    interleave = map('interleave');
else
    interleave = 0;
end
if isKey(map, 'nsum')
    nSum = map('nsum');
else
    nSum = 1;
end

% global constants
global SOUND_SPEED SAMPLE_FREQUENCY PULSE_REPITITION_RATE CENTER_FREQUENCY
if isempty(SOUND_SPEED)
    SOUND_SPEED = 1500;
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
%     AnalyticSig = hilbert(squeeze(BfSigMat(:,pos,:)));
%     I = real(AnalyticSig(midSample,:));
%     Q = imag(AnalyticSig(midSample,:));
    
    [hI, hQ] = tools.iqdemod(squeeze(BfSigMat(:,pos,:)), 6.6e6, 5.2e6, 40e6);
    
    I = hI(midSample, :);
    Q = hQ(midSample, :);
    
    for est = 1:nEstimate
        
        ind1 = est:(est + nSum - 1);
        ind2 = ind1 + interleave + 1;
        
        numer = sum(Q(ind2).*I(ind1) - I(ind2).*Q(ind1));
        denom = sum(I(ind2).*I(ind1) + Q(ind2).*Q(ind1));
        
%         z = I + 1i.*Q;
%         z1 = z(ind1).*z(ind2);
%         rx = real(sum(z1));
%         ry = imag(sum(z1));
%         
%         phi(est) = atan(ry/rx);
        deltaPhi(est) = atan(numer/denom);
        
        
%         r0 = sum(I(ind1).^2 + Q(ind1).^2);
%         stddev(est) = (1 - abs(sum(z1))/r0)*PULSE_REPITITION_RATE^2;
        
        VelEst(pos,est) = deltaPhi(est)/(interleave+1)*PULSE_REPITITION_RATE*SOUND_SPEED/...
            (4*pi*CENTER_FREQUENCY);
    end
end

end

