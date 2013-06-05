import beamform.*
import sirm.*
import ultrasonix.*
import flow.*
import tools.*
%% read in RAW daq data
dirname = './data/dataset 2/tx10hz/';

[header, ~] = readDAQ(dirname, ones(1,128), 1, true);

nChannel = header(1) + 1;
nFrame = 500;%header(2);
nSample = header(3); 

Rfc = zeros(nChannel, nSample, nFrame, 'int16');

for fr = 1:nFrame
   [~, rf] = readDAQ(dirname, ones(1,128), fr, true);
   Rfc(:,:,fr) = rf.';
end

Rfc = bandpass(double(Rfc), 6.6, 0.80, 40);
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
%FieldPos = [0; 0; 0.02];
FieldPos = [zeros(1,11); zeros(1,11); linspace(0.015, 0.025, 11)];
%FieldPos = [0 0.0005 -0.0005 0 0 ; 0 0 0 0 0 ; 0.020 0.020 0.020 0.0205 0.0195];
%[X, Z] = meshgrid(linspace(0.015, 0.025, 11), linspace(0.015, 0.025, 11));
%FieldPos = [X(:).'; zeros(1,11*11); Z(:).'];
nWindowSample = 200;
nSum = 1;
interleave = 0;
averaging = 4;

[VelEstInst, BfSigMat] = instaxialest(Rfc, [], RxPos, FieldPos, nSum, nWindowSample, ...
    'progress', true, 'plane', true, 'beamformType', 'frequency', ...
    'interleave', interleave, 'averaging', averaging);

figure; plot(squeeze(VelEstInst(:,1,:)),':.');
%%
RxPos = [((0:127).*300e-6 + 150e-6 - 64*300e-6); zeros(1,128); zeros(1,128)];

nCompare = 401;
delta = 0.1e-6;
deltaR = -(nCompare - 1)/2*delta:delta:(nCompare - 1)/2*delta;

FieldPos2 = [ones(1, nCompare).*0; zeros(1, nCompare); 0.020 + deltaR];

BfSigMat2 = gtbeamform(FilteredRfc, [], RxPos, FieldPos2, 200, 'plane', true, ...
    'progress', true);

VelEst2 = ftdoppler2(BfSigMat2, FieldPos, 200, 'progress', true);

plot(squeeze(VelEst2),':.');
%% read in AVG daq data
[header, ~] = readDAQ('./rfdata/control/', ones(1,128), 1, true);

nChannel = header(1) + 1;
nFrame = 100;%header(2);
nSample = header(3);

Rfc = zeros(nChannel, nSample, nFrame, 'int16');

for fr = 1:nFrame
   [~, rf] = readDAQ('./rfdata/control/', ones(1,128), fr, true);
   Rfc(:,:,fr) = rf.';
end
%%
RfcAvg = zeros(nChannel, nSample, nFrame/10);
for i = 1:(nFrame/10)
   
    RfcAvg(:,:,i) = mean(FilteredRfc(:,:,i:(i+9)),3);
end
%%
for i = 1:(nFrame/10)
   plot(RfcAvg(64,:,i));
   title(num2str(i));
   pause(0.1);
end


