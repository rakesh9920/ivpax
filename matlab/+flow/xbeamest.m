function [VectVelEst] = xbeamest(RxSigMat, TxPos, RxPos, FieldPos, nCompare, delta)

import beamform.gfbeamform2
import flow.ftdoppler2

% global constants
global SOUND_SPEED SAMPLE_FREQUENCY PULSE_REPITITION_RATE
if isempty(SOUND_SPEED)
    SOUND_SPEED = 1500;
end
if isempty(SAMPLE_FREQUENCY)
    SAMPLE_FREQUENCY = 40e6;
end
if isempty(PULSE_REPITITION_RATE)
    PULSE_REPITITION_RATE = 100;
end

[nSig nSample nFrame] = size(RxSigMat);
nFieldPos = size(FieldPos, 2);

if mod(nCompare, 2) == 0
    nCompare = nCompare + 1;
end

BfPointList = zeros(3, nCompare*nSig);
deltaR = -(nCompare - 1)/2*delta:delta:(nCompare - 1)/2*delta;
Theta = zeros(nSig, 1);
Phi = zeros(nSig, 1);
VelEst = zeros(nSig, nFrame - 1);
VectVelEst = zeros(3, nFieldPos, nFrame - 1);

for pos = 1:nFieldPos
    for rx = 1:nSig
        
        delPos = FieldPos(:,pos) - RxPos(:,rx);
        
        r = sqrt(sum(delPos.^2));
        theta = acos(delPos(3)/r);
        phi = atan2(delPos(2), delPos(1));
        
        X = deltaR.*sin(theta).*cos(phi);
        Y = deltaR.*sin(theta).*sin(phi);
        Z = deltaR.*cos(theta);
        
        Theta(rx) = theta;
        Phi(rx) = phi;
        
        front = (rx - 1)*nCompare + 1;
        back = front + nCompare - 1;
        BfPointList(:,front:back) = bsxfun(@plus, FieldPos(:,pos), [X; Y; Z]);
    end
 
    BfSigMat = gfbeamform2(RxSigMat, TxPos, RxPos, BfPointList, 150);
    
    for rx = 1:nSig
        
        front = (rx - 1)*nCompare + 1;
        back = front + nCompare - 1;
        VelEst(rx,:) = ftdoppler2(BfSigMat(:,front:back,:), BfPointList(:,front:back), (nCompare+1)/2);
    end
    
    VectVelEst(1,pos,:) = mean(bsxfun(@times, VelEst, sin(Theta).*cos(Phi)), 1);
    VectVelEst(2,pos,:) = mean(bsxfun(@times, VelEst, sin(Theta).*sin(Phi)), 1);
    VectVelEst(3,pos,:) = mean(bsxfun(@times, VelEst, cos(Theta)), 1);
end

end

