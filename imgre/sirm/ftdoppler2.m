function [VelocityEst] = ftdoppler2(BfSigMat, FieldPos, pointNo)
% Doppler flow estimate using full cross-correlation

[nSample nPoint nFrame] = size(BfSigMat);
VelocityEst = zeros(1, 1, nFrame - 1);

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

TravelSpeed = sqrt(sqdistance(FieldPos(:,pointNo), FieldPos)).*PULSE_REPITITION_RATE;
TravelSpeed(1:(pointNo-1)) = -TravelSpeed(1:(pointNo-1));

XcorrList = zeros(1, nPoint);

progressBar = upicbar('Calculating velocity...');
for frame = 1:(nFrame - 1)
    
    upicbar(progressBar, frame/(nFrame - 1));
    
    Signal1 = BfSigMat(:,pointNo,frame);
    
    for point = 1:nPoint
       
        Signal2 = BfSigMat(:,point,frame+1);
        
        XcorrList(point) = max(xcorr(Signal1, Signal2, 'coeff'));
    end
    
    [~, maxInd] = max(XcorrList);
    
    VelocityEst(1, 1, frame) = TravelSpeed(maxInd);
end

end
