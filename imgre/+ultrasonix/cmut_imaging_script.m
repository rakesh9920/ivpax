%% ADDPATHS

import maq.*
import mexo.*
import imager.*
addpath './bin/'

%% TEXO OBJECT INIT

tx = texoTransmitParams();
rx = texoReceiveParams();
apr = texoCurve();

apr.top = 10;
apr.mid = 50;
apr.btm = 100;
apr.vmid = 50;

tx.centerElement = 24;
tx.aperture = 16;
tx.angle = 0;
tx.focusDistance = 300000;
tx.frequency = 10000000;
tx.pulseShape = '+-';
tx.speedOfSound = 1500;
tx.tableIndex = -1;
tx.useManualDelays = false;
tx.manualDelays = zeros(1,129);
tx.useMask = false;
tx.mask = zeros(1,128);
tx.sync = 1;

rx.centerElement = 8;
rx.aperture = 16;
rx.angle = 0;
rx.maxApertureDepth = 20000;
rx.acquisitionDepth = 20000;
rx.saveDelay = 0;
rx.speedOfSound = 1500;
rx.channelMask = [-1 -1];%[uint32(2^32) uint32(2^32)];%[uint32(0) uint32(2147483648)];
rx.applyFocus = true;
rx.useManualDelays = false;
rx.manualDelays = zeros(1,65);
rx.customLineDuration = 0;
rx.lgcValue = 0;
rx.tgcSel = 0;
rx.tableIndex = -1;
rx.decimation = 0;
rx.numChannels = 16;
rx.rxAprCrv = apr;
rx.weightType = 1;
rx.useCustomWindow = false;
rx.window = zeros(1,64);

%% TEXO INIT

if ~texoInit('./bin/dat/', 3, 4, 0, 64, 0, 128)
    error('texoInit failed');
end
texoClearTGCs();
if ~texoAddTGCFixed(1.0)
    error('texoAddTGCFixed failed');
end
texoSetSyncSignals(1,1,3);
texoActivateProbeConnector(0);
texoForceConnector(3);
texoEnableSyncNotify(false);

%% TEXO SEQUENCING 1 (SINGLE LINE)

pulseShape = '+-';
power = 1;

if ~texoBeginSequence()
    error('texoBeginSequence failed');
end

tx.pulseShape = pulseShape;
tx.aperture = 16;
rx.aperture = 16;
tx.centerElement = 23;  
rx.centerElement = 7;

% rxMask = zeros(1,64);
% rxMask(1:16) = 1;
% channelMask1 = int32(twos2dec(sprintf('%d',rxMask(1:32))));
% channelMask2 = int32(twos2dec(sprintf('%d',rxMask(33:64))));
% rx.channelMask = [channelMask1 channelMask2];

[success, lineSize, lineDuration] = texoAddLine(tx, rx);

% for line = 1:16
%     
%     tx.centerElement = 16 + (line - 1)
%     rx.centerElement = 0 + (line - 1)
%     [success, lineSize, lineDuration] = texoAddLine(tx, rx);
% end

if ~texoEndSequence()
    error('texoEndSequence failed');
end

texoSetPower(15, power, power);

lineSize
lineDuration
frameSize = texoGetFrameSize()
samplesPerFrame = frameSize/2

%% TEXO SEQUENCING 2

pulseShape = '+-';
power = 2;

if ~texoBeginSequence()
    error('texoBeginSequence failed');
end

tx.pulseShape = pulseShape;
tx.aperture = 16;
rx.aperture = 1;
tx.centerElement = 24;
rx.centerElement = 8;

[success, lineSize, lineDuration] = texoAddLine(tx, rx);

% for line = 1:16
%     
%     tx.centerElement = 16 + (line - 1)
%     rx.centerElement = 0 + (line - 1)
%     [success, lineSize, lineDuration] = texoAddLine(tx, rx);
% end

if ~texoEndSequence()
    error('texoEndSequence failed');
end

texoSetPower(15, power, power);

lineSize
lineDuration
frameSize = texoGetFrameSize()
samplesPerFrame = frameSize/2

%% SET IMAGING PARAMETERS
imgprms = containers.Map();

imgprms('pxwidth') = 245e-6/2;
imgprms('label') = false;
imgprms('cmap') = 'gray';

%% COLLECT FRAMES
texoCollectFrames(1);
BfMat = reshape(texoGetCine(samplesPerFrame),1, []);

%imager(BfMat, 20, imgprms);
plot(BfMat);

%% SHUTDOWN
texoShutdown()

