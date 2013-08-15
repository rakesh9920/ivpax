%% ADDPATHS
import maq.*
import mexo.*
addpath './bin/'
%% TEXO OBJECT INIT
tx = texoTransmitParams();
rx = texoReceiveParams();
apr = texoCurve();

apr.top = 10;
apr.mid = 50;
apr.btm = 100;
apr.vmid = 50;

tx.centerElement = 8.5;
tx.aperture = 16; 
tx.angle = 0;
tx.focusDistance = 300000;
tx.frequency = 6000000;
tx.pulseShape = '+-+-';
tx.speedOfSound = 1500;
tx.tableIndex = -1;
tx.useManualDelays = false;
tx.manualDelays = zeros(1,129);
tx.useMask = true;
tx.mask = zeros(1,128);
tx.sync = 1;

rx.centerElement = 8.5;
rx.aperture = 16; 
rx.angle = 0; 
rx.maxApertureDepth = 50000; 
rx.acquisitionDepth = 50000;
rx.saveDelay = 0; 
rx.speedOfSound = 1500;  
rx.channelMask = [-1 -1];%[uint32(2^32) uint32(2^32)];%[uint32(0) uint32(2147483648)];  
rx.applyFocus = false; 
rx.useManualDelays = false; 
rx.manualDelays = zeros(1,65); 
rx.customLineDuration = 0; 
rx.lgcValue = 0; 
rx.tgcSel = 0; 
rx.tableIndex = -1; 
rx.decimation = 0; 
rx.numChannels = 64; 
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
%% TEXO SEQUENCING

pulseShape = '+-';
power = 11;
centerElement = 15;
tx.aperture = 1; 
txChannel = 2;
rxChannel = 1;


if ~texoBeginSequence()
    error('texoBeginSequence failed');
end

txMask = zeros(1,128);
txMask(1:128) = 1;
tx.mask = txMask;
tx.pulseShape = pulseShape;
tx.centerElement = centerElement;


% rxMask = zeros(1,64);
% rxMask(rxChannel) = 1;
% channelMask1 = int32(twos2dec(sprintf('%d',rxMask(1:32))));
% channelMask2 = int32(twos2dec(sprintf('%d',rxMask(33:64))));
% rx.channelMask = [channelMask1 channelMask2];
rx.centerElement = centerElement;

[success, lineSize, lineDuration] = texoAddLine(tx, rx);

lineSize
lineDuration
if ~texoEndSequence()
    error('texoEndSequence failed');
end
texoSetPower(15, power, power);

%% RUN TEST
if ~texoRunImage()
    error('texoRunImage failed');
end
pause
if ~texoStopImage()
    error('texoStopImage failed');
end
texoGetCollectedFrameCount()

%% SHUTDOWN
texoShutdown()

