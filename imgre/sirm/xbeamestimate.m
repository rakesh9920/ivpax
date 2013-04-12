function [VelEst] = xbeamestimate(RxSigMat, TxPos, RxPos, FieldPos, nCompare)


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








end

