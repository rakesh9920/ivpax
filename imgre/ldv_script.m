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

dirname = './data/tx_2000/';

[header, ~] = readDAQ(dirname, ones(1,128), 1, true);

nChannel = header(1) + 1;
nFrame = 100;
nSample = header(3);

%%
Bfm = zeros(nWindowSample, 1, 4000);
averaging = 0;

for fs = 4000:nFrame:8000

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
    
    Bfm(:,:,fs:(fs+frEnd-1)) = BfSigMat;
end

%%

RxPos = [((0:127).*300e-6 + 150e-6 - 64*300e-6); zeros(1,128); zeros(1,128)];
FieldPos = [0; 0; 0.02];
nSum = 16; 
averaging = 16; 
interleave = 0; 

[VelEstInst, ~] = instaxialest([], [], RxPos, FieldPos, nSum, nWindowSample, ...
        'progress', true, 'plane', true, 'beamformType', 'frequency', ...
        'interleave', interleave, 'averaging', averaging, 'bfsigmat', Bfmt);
    
figure; plot(squeeze(VelEstInst(:,1,:)),':.');
