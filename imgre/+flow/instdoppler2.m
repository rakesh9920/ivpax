function [VelEst] = instdoppler2(BfSigMat, varargin)
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
%midSample = round(nSample/2);

for pos = 1:nFieldPos
    AnalyticSig = hilbert(squeeze(BfSigMat(:,pos,:)));
%     I = real(AnalyticSig);
%     Q = imag(AnalyticSig);
    
    ind1 = 1:(nFrame-1);
    ind2 = ind1 + 1;
    
    z1 = AnalyticSig(:,ind1).*conj(AnalyticSig(:,ind2));
    
    for est = 1:(nFrame - 1)
        
        R = sum(z1(:,est));

        deltaPhi = angle(R);
        
        VelEst(pos,est) = deltaPhi/(interleave+1)*PULSE_REPITITION_RATE*SOUND_SPEED/...
            (4*pi*CENTER_FREQUENCY);
    end
end

end

