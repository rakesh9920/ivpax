import beamform.*
import sirm.*
import ultrasonix.*
import flow.*
import tools.*
%% read in RAW daq data
dirname = './data/smallset 1/';

[header, ~] = readDAQ(dirname, ones(1,128), 1, true);

nChannel = header(1) + 1;
nFrame = 500;%header(2);
frameStart = 501;
nSample = header(3);

Rfc = zeros(nChannel, nSample, nFrame, 'double');

prog = upicbar('Reading DAQ data ...');

for fr = 1:nFrame
    upicbar(prog, fr/nFrame);
    [~, rf] = readDAQ(dirname, ones(1,128), frameStart + fr - 1, true);
    Rfc(:,:,fr) = double(rf.');
end

Rfc = bandpass(Rfc, 6.6, 0.80, 40);
%save rfc5 Rfc;
%% Plot raw channels
for i = 1:nFrame
    imagesc(20.*log10(abs(squeeze(Rfc(:,:,i)))./600).');
    title(num2str(i));
    pause(0.1);
end
%% Plot RF data
for i = 1:nFrame
    plot(Rfc(64,:,i));
    title(num2str(i));
    axis([250 1200 -100 100]);
    pause(0.1);
end
%% axial estimate
global PULSE_REPITITION_RATE;
PULSE_REPITITION_RATE = 500;

RxPos = [((0:127).*300e-6 + 150e-6 - 64*300e-6); zeros(1,128); zeros(1,128)];
FieldPos = [0; 0; 0.020];
nCompare = 200;
delta = 0.5e-7;
nWindowSample = 200;

velRes = delta*PULSE_REPITITION_RATE
velMax = velRes*floor(nCompare/2)

[VelEstZ, ~, BfPointList] = axialest(Rfc, [], RxPos, FieldPos, nCompare, delta, ...
    nWindowSample, 'progress', true, 'plane', true, 'interpolate', 8, ...
    'window', 'hanning', 'beamformType', 'frequency');

figure; plot(squeeze(VelEstZ),':.');
%% instantaneous axial estimate
%global PULSE_REPITITION_RATE;
PULSE_REPITITION_RATE = 500;

RxPos = [((0:127).*300e-6 + 150e-6 - 64*300e-6); zeros(1,128); zeros(1,128)];
FieldPos = [0; 0; 0.02];
%FieldPos = [zeros(1,11); zeros(1,11); linspace(0.015, 0.025, 11)];
%FieldPos = [0 0.0005 -0.0005 0 0 ; 0 0 0 0 0 ; 0.020 0.020 0.020 0.0205 0.0195];
%[X, Z] = meshgrid(linspace(0.015, 0.025, 11), linspace(0.015, 0.025, 11));
%FieldPos = [X(:).'; zeros(1,11*11); Z(:).'];
nWindowSample = 200;
nSum = 4; % smoothing after velocity estimates
averaging = 4; % smoothing before velocity estimates
interleave = 0; % frame interleaving

% [VelEstInst, ~] = instaxialest(Rfc, [], RxPos, FieldPos, nSum, nWindowSample, ...
%     'progress', true, 'plane', true, 'beamformType', 'frequency', ...
%     'interleave', interleave, 'averaging', averaging, 'bfsigmat', BfSigMat);
[VelEstInst, ~] = instaxialest(Rfc, [], RxPos, FieldPos, nSum, nWindowSample, ...
    'progress', true, 'plane', true, 'beamformType', 'frequency', ...
    'interleave', interleave, 'averaging', averaging);

figure; plot(squeeze(VelEstInst(:,1,:)),':.');
%% beamforming over sets
PULSE_REPITITION_RATE = 500;

RxPos = [((0:127).*300e-6 + 150e-6 - 64*300e-6); zeros(1,128); zeros(1,128)];
FieldPos = [0; 0; 0.02];
nWindowSample = 200;
nSum = 4; % smoothing after velocity estimates
averaging = 8; % smoothing before velocity estimates
interleave = 0; % frame interleaving
Bfc = zeros(201, 1, 500, 6);

for set = 1:6
    loadstr = ['load rfc' num2str(set)];
    eval(loadstr);
    [VelEstInst, BfSigMat] = instaxialest(Rfc, [], RxPos, FieldPos, nSum, nWindowSample, ...
        'progress', true, 'plane', true, 'beamformType', 'frequency', ...
        'interleave', interleave, 'averaging', averaging);
    Bfc(:,:,:,set) = BfSigMat;
    clear Rfc;
end

%% velocity estimate over sets
PULSE_REPITITION_RATE = 500;

RxPos = [((0:127).*300e-6 + 150e-6 - 64*300e-6); zeros(1,128); zeros(1,128)];
FieldPos = [0; 0; 0.02];
nWindowSample = 200;
nSum = 1; % smoothing after velocity estimates (none = 1)
averaging = 1; % smoothing before velocity estimates (none = 0 or 1)
interleave = 0; % frame interleaving (none = 0)
VelEst = zeros(500 - averaging - nSum + 1, 6, 64);
sd = zeros(1,64);
err = zeros((500 - averaging - nSum + 1)*6,64);

for averaging = 1:64
    for set = 1:6
        [VelEstInst, ~] = instaxialest([], [], RxPos, FieldPos, nSum, nWindowSample, ...
            'progress', true, 'plane', true, 'beamformType', 'frequency', ...
            'interleave', interleave, 'averaging', averaging, ...
            'bfsigmat', Bfc(:,:,:,set));
        VelEst(1:(500 - averaging - nSum + 1),set,averaging) = ...
            reshape(VelEstInst,[],1);
    end
    
    err1 = bsxfun(@minus, VelEst(:,:,averaging), mean(VelEst(:,:,averaging),2));
    err1 = err1;%./VelEst(:,:,averaging);
    err2 = err1(140:410,:);
    err(1:size(err2(:),1),averaging) = err2(:);
    sd(1,averaging) = std(err2(:));
end

figure; plot(VelEst(:,:,4), ':.');






