import beamform.*
import sirm.*
import ultrasonix.*
import flow.*
import tools.*

global PULSE_REPITITION_RATE;
PULSE_REPITITION_RATE = 2000;

RxPos = [((0:127).*300e-6 + 150e-6 - 64*300e-6); zeros(1,128); zeros(1,128)];
FieldPos = [0; 0; 0.02];
nWindowSample = 201;
nSum = 4; % smoothing after velocity estimates
averaging = 16; % smoothing before velocity estimates
interleave = 0; % frame interleaving

dirname = './data/short set 2/tx_2000/';

[header, ~] = readDAQ(dirname, ones(1,128), 1, true);

nChannel = header(1) + 1;
nFrame = 100;
nSample = header(3);

%% preprocessing for instantaneous estimate

Bfm = zeros(nWindowSample, 1, 2000);
averaging = 0;

for fs = 1:nFrame:2000

    frEnd = nFrame;
    Rfc = zeros(nChannel, nSample, frEnd, 'double');
    prog = upicbar('Reading DAQ data ...');
    for fr = 1:frEnd
        upicbar(prog, fr/frEnd);
        [~, rf] = readDAQ(dirname, ones(1,128), fs + fr - 1, true);
        Rfc(:,:,fr) = double(rf.');
    end
    
    Rfc = bandpass(Rfc, 6.6, 0.80, 40);
    
    [VelEstPart, BfSigMat] = instaxialest(Rfc, [], RxPos, FieldPos, nSum, nWindowSample, ...
        'progress', true, 'plane', true, 'beamformType', 'frequency', ...
        'interleave', interleave, 'averaging', 0);
    
    Bfm(:,:,(fs-0*2000):((fs+frEnd-1)-0*2000)) = BfSigMat;
end
%% instantaneous estimate

RxPos = [((0:127).*300e-6 + 150e-6 - 64*300e-6); zeros(1,128); zeros(1,128)];
FieldPos = [0; 0; 0.02];
nSum = 1; 
averaging = 16; 
interleave = 0; 

[VelEstInst, ~] = instaxialest([], [], RxPos, FieldPos, nSum, nWindowSample, ...
        'progress', true, 'plane', true, 'beamformType', 'frequency', ...
        'interleave', interleave, 'averaging', averaging, 'bfsigmat', Bfm);
    
figure; plot(squeeze(VelEstInst(:,1,:)),':.');

%% preprocessing for axial estimate

RxPos = [((0:127).*300e-6 + 150e-6 - 64*300e-6); zeros(1,128); zeros(1,128)];
FieldPos = [0; 0; 0.020];
nCompare = 51;
delta = 0.5e-6;
nWindowSample = 201;
averaging = 16;

Bfm = zeros(nWindowSample, nCompare, 2000);

for fs = 1:nFrame:2000

    frEnd = nFrame;
    Rfc = zeros(nChannel, nSample, frEnd, 'double');
    prog = upicbar('Reading DAQ data ...');
    for fr = 1:frEnd
        upicbar(prog, fr/frEnd);
        [~, rf] = readDAQ(dirname, ones(1,128), fs + fr - 1, true);
        Rfc(:,:,fr) = double(rf.');
    end
    
    Rfc = bandpass(Rfc, 6.6, 0.80, 40);
    
    [VelEstPart, BfSigMat, BfSigPoints] = axialest(Rfc, [], RxPos, FieldPos, ...
        nCompare, delta, nWindowSample, 'progress', true, 'plane', true, ...
        'interpolate', 0, 'window', 'hanning', 'beamformType', 'frequency');
    
    Bfm(:,:,(fs-0*2000):((fs+frEnd-1)-0*2000)) = BfSigMat;
end
%% axial estimate
global PULSE_REPITITION_RATE;
PULSE_REPITITION_RATE = 2000;

RxPos = [((0:127).*300e-6 + 150e-6 - 64*300e-6); zeros(1,128); zeros(1,128)];
FieldPos = [0; 0; 0.020];
nCompare = 51;
delta = 0.5e-6;
nWindowSample = 201;
averaging = 16;

velRes = delta*PULSE_REPITITION_RATE
velMax = velRes*floor(nCompare/2)

[VelEstZ, ~, BfPointList] = axialest(Rfc, [], RxPos, FieldPos, nCompare, delta, ...
    nWindowSample, 'progress', true, 'plane', true, 'interpolate', 64, ...
    'window', 'hanning', 'beamformType', 'frequency','averaging', averaging);

figure; plot(squeeze(VelEstZ),':.');
