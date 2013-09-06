function [VelEst] = instdoppler(BfSigMat, varargin)
%
% interleave, nsum, progress

import tools.upicbar tools.iqdemod

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
if isKey(map, 'ensemble')
    ensemble = map('ensemble');
else
    ensemble = 1;
end
if isKey(map, 'range gate')
    rangeGate = map('range gate');
else
    rangeGate = 1;
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

nEstimate = nFrame - ensemble - interleave;
VelEst = zeros(nFieldPos, nEstimate);
midSample = round(nSample/2);
deltaPhi = zeros(rangeGate, nEstimate);

for pos = 1:nFieldPos
    
    [hI, hQ] = iqdemod(squeeze(BfSigMat(:,pos,:)), 6.6e6, 5.2e6, 40e6);
    
    rangeStart = midSample - floor(rangeGate/2) + 2;
    rangeStop = rangeStart + rangeGate - 1;
    I = hI(rangeStart:rangeStop, :);
    Q = hQ(rangeStart:rangeStop, :);
    
    for est = 1:nEstimate
        
        for gate = 1:rangeGate
            
            ind1 = est:(est + ensemble - 1);
            ind2 = ind1 + interleave + 1;
            
            numer = sum(Q(gate,ind2).*I(gate,ind1) - I(gate,ind2).*Q(gate,ind1));
            denom = sum(I(gate,ind2).*I(gate,ind1) + Q(gate,ind2).*Q(gate,ind1));
            
            deltaPhi(gate,est) = mean(atan2(numer, denom));
        end
        
        VelEst(pos,est) = -mean(deltaPhi(:,est))/(interleave+1)*...
            PULSE_REPITITION_RATE*SOUND_SPEED/(4*pi*CENTER_FREQUENCY);
    end
end

end

