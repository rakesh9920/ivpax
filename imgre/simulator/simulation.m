function [signals, t] = simulation(options)
%SIMULATION
%

if ~isa(options,'struct')
    message(error('simulation: Options argument not a struct'));
end

sourceGeomDefault = [  0  0  1  ;
    0  0  2  ;
    0  0  3  ].*10^-2;

sensorGeomDefault = zeros(128, 3);
sensorGeomDefault(:,1) = (-64*300e-6):(300e-6):(63*300e-6);

sourceGeom = simget(options, 'SourceGeom', sourceGeomDefault);
sensorGeom = simget(options, 'SensorGeom', sensorGeomDefault);

nSources = size(sourceGeom,1);
nSensors = size(sensorGeom,1);

distances = zeros(nSources, nSensors);
for src = 1:nSources
    source = repmat(sourceGeom(src,:), nSensors, 1);
    distances(src,:) = sqrt(sum((source-sensorGeom).^2,2));
end

wavespeed = simget(options, 'SoundSpeed', 1482);
timeLength = simget(options, 'TimeLength', 10e-6);
sampleFreq = simget(options, 'SampleFreq', 40e6);
noiseSNR = simget(options, 'NoiseSnr', 0);

times = distances./wavespeed;
t = 0:1/sampleFreq:timeLength;
signals = zeros(nSensors, length(t));

for sens = 1:nSensors
    for src = 1:nSources
        options = simset(options, 'TimeDelay', times(src,sens));
        signals(sens,:) = signals(sens,:) + waveformgen(options)./distances(src,sens);
        %signals(sens,:) = signals(sens,:) + waveformgen(options);
    end
    
    if noiseSNR > 0
       signals(sens,:) = awgn(signals(sens,:), noiseSNR, 'measured'); 
    end
end

signals = shiftdim(signals', -1);


