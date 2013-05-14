function [VectVelEst] = orthoestimate(RxSigMat, TxPos, RxPos, FieldPos, nCompare, delta)

[nSig nSample nFrame] = size(RxSigMat);
nFieldPos = size(FieldPos, 2);

if mod(nCompare, 2) == 0
    nCompare = nCompare + 1;
end

% global constants
global SOUND_SPEED SAMPLE_FREQUENCY PULSE_REPITITION_RATE
if isempty(SOUND_SPEED)
    SOUND_SPEED = 1500;
end
if isempty(SAMPLE_FREQUENCY)
    SAMPLE_FREQUENCY = 40e6;
end
if isempty(PULSE_REPITITION_RATE)
    PULSE_REPITITION_RATE = 60;
end


BfPointList = zeros(3, nCompare*3);
deltaR = -(nCompare - 1)/2*delta:delta:(nCompare - 1)/2*delta;
VelEst = zeros(3, nFrame - 1);
VectVelEst = zeros(3, nFieldPos, nFrame - 1);

for pos = 1:nFieldPos
    

    for dir = 1:3
        
        Del = zeros(3, size(deltaR, 2));
        Del(dir,:) = deltaR;
        
        front = (dir - 1)*nCompare + 1;
        back = front + nCompare - 1;
        BfPointList(:,front:back) = bsxfun(@plus, FieldPos(:,pos), Del);
    end
 
    BfSigMat = gfbeamform2(RxSigMat, TxPos, RxPos, BfPointList, 150);
    
    for dir = 1:3
        
        front = (dir - 1)*nCompare + 1;
        back = front + nCompare - 1;
        VelEst(dir,:) = ftdoppler2(BfSigMat(:,front:back,:), BfPointList(:,front:back), (nCompare+1)/2);
    end
    
    VectVelEst(1,pos,:) = VelEst(1,:);
    VectVelEst(2,pos,:) = VelEst(2,:);
    VectVelEst(3,pos,:) = VelEst(3,:);
end

end

