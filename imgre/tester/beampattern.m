%
%
addpath ../simulator/
addpath ../beamformer/

% define sensor geometry
numofchannels = 128;
pitch = 300e-6;
sensorGeom = zeros(numofchannels,3);
sensorGeom(:,1) = ((-numofchannels/2*pitch+pitch/2:pitch:(numofchannels/2)*pitch-pitch/2))';

numoflines = 1;
rfc = zeros(numoflines,2161,numofchannels,12);

bfmopt = bfmset( ...
    'ArrayPitch', pitch, ...
    'RxCurveBtm', 128, ...
    'RxCurveMid', 128, ... %68
    'RxCurveTop', 128, ...%4
    'RxCurveVmid', 50, ...
    'SampleFreq', 40e6, ...
    'SoundSpeed', 1482, ...
    'Photoacoustic', true ...
    );

sourceGeom = zeros(24,3);
sourceGeom(:,3) = (0.00125:0.00125:0.03)';

for f = 1:24
    for line = 1:numoflines
        
        simopt = simset( ...
            'Amplitude', 1, ...
            'Frequency', 6.6e6, ...
            'GaussFractBandwidth', 1.0, ...
            'NoiseSnr', 0, ...
            'PulseType', 'PureTone', ...
            'SampleFreq', 40e6, ...
            'SensorGeom', sensorGeom, ...
            'SoundSpeed', 1482, ...
            'SourceGeom', sourceGeom(f,:), ...
            'TimeLength', 2160*25e-9 ...
            );
        
        rfc(line,:,:,f) = simulation(simopt);
    end
end

start = 17;
for f = 1:24
    stop = start + 33;
    bfm(:,start:stop) = bmbeamform(rfc(:,start:stop,:,f),bfmopt);
    start = stop + 1;
end
%rfc_b = bandpass(rfc,6.6,5.28,40);
%bfm_b = bmbeamform(rfc_b, bfmopt);

%clear sensorGeom numofchannels pitch sourceGeom
