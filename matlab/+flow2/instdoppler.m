function [VelEst] = instdoppler(BfSigMat, varargin)
%INSTDOPPLER 
% interleave, ensemble, range gate

import sigproc.iqdemod tools.prog

Argsin = inputParser;
Argsin.KeepUnmatched = true;
addOptional(Argsin, 'interleave', 0);
addOptional(Argsin, 'ensemble', 1);
addOptional(Argsin, 'rangegate', 1);
addOptional(Argsin, 'progress', false);
addOptional(Argsin, 'SOUND_SPEED', 1500);
addOptional(Argsin, 'SAMPLE_FREQUENCY', 40e6);
addOptional(Argsin, 'CENTER_FREQUENCY', 5e6);
addOptional(Argsin, 'PULSE_REPITITION_RATE', 1000);
parse(Argsin, varargin{:});

interleave = Argsin.Results.interleave;
ensemble = Argsin.Results.ensemble;
rangegate = Argsin.Results.rangegate;
progress = Argsin.Results.progress;
SOUND_SPEED = Argsin.Results.SOUND_SPEED;
SAMPLE_FREQUENCY = Argsin.Results.SAMPLE_FREQUENCY;
CENTER_FREQUENCY = Argsin.Results.CENTER_FREQUENCY;
PULSE_REPITITION_RATE = Argsin.Results.PULSE_REPITITION_RATE;

[nSample, nFrame, nFieldPos] = size(BfSigMat);

nEstimate = nFrame - ensemble - interleave;
VelEst = zeros(nEstimate, nFieldPos);
midSample = round(nSample/2);
deltaPhi = zeros(rangegate, nEstimate);

if progress
    [bar, cleanup] = prog('@instdoppler');
end

for pos = 1:nFieldPos
    
    [hI, hQ] = iqdemod(squeeze(BfSigMat(:,:,pos)), CENTER_FREQUENCY, ...
        CENTER_FREQUENCY*2, SAMPLE_FREQUENCY);
    
    rangeStart = midSample - floor(rangegate/2) + 2;
    rangeStop = rangeStart + rangegate - 1;
    I = hI(rangeStart:rangeStop, :);
    Q = hQ(rangeStart:rangeStop, :);
    
    if progress
        prog(bar, pos/nFieldPos)
    end
    
    for est = 1:nEstimate
        
        for gate = 1:rangegate
            
            ind1 = est:(est + ensemble - 1);
            ind2 = ind1 + interleave + 1;
            
            numer = sum(Q(gate,ind2).*I(gate,ind1) - I(gate,ind2).*Q(gate,ind1));
            denom = sum(I(gate,ind2).*I(gate,ind1) + Q(gate,ind2).*Q(gate,ind1));
            
            deltaPhi(gate,est) = mean(atan2(numer, denom));
        end
        
        VelEst(est,pos) = -mean(deltaPhi(:,est))/(interleave+1)*...
            PULSE_REPITITION_RATE*SOUND_SPEED/(4*pi*CENTER_FREQUENCY);
    end
end

end

