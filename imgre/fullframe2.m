%%
addpath './maq/'
addpath './mexo 6.0.3/'
addpath './bin/'
%% OBJECT INIT
tx = texoTransmitParams();
rx = texoReceiveParams();
apr = texoCurve();

tx.centerElement = 64.5;
tx.aperture = 64; 
tx.angle = 0;
tx.focusDistance = 35000;
tx.frequency = 6600000;
tx.pulseShape = '+-';
tx.speedOfSound = 1540;
tx.tableIndex = -1;
tx.useManualDelays = false;
tx.manualDelays = zeros(1,129);
tx.useMask = false;
tx.mask = zeros(1,128);
tx.sync = 1;

rx.centerElement = 64.5;
rx.aperture = 64; 
rx.angle = 0; 
rx.maxApertureDepth = 50000; 
rx.acquisitionDepth = 50000;
rx.saveDelay = 0; 
rx.speedOfSound = 1540;  
rx.channelMask = [-1 -1];%[uint32(2^32) uint32(2^32)];%[uint32(0) uint32(2147483648)];  
rx.applyFocus = true; 
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
%%
seqprms = daqSequencePrms();
rlprms = daqRaylinePrms();

seqprms.freeRun = false;
seqprms.hpfBypass = false;
seqprms.divisor = 10; % data size = 16GB / 2^divisor
seqprms.externalTrigger = true;
seqprms.externalClock = true;
seqprms.lnaGain = 2; % 16dB, 18dB, 21dB
seqprms.pgaGain = 2; % 21dB, 24dB, 27dB, 30dB
seqprms.biasCurrent = 0; % 0,1,2,...,7
seqprms.fixedTGC = true;
seqprms.fixedTGCLevel = 60;

rlprms.lineDuration = 70; % line duration in micro seconds
rlprms.numSamples = 2678; 
rlprms.gainOffset = 0;
rlprms.gainDelay = 0;
rlprms.rxDelay = 0;
rlprms.channels = [uint32(2^32) uint32(2^32) uint32(2^32) uint32(2^32)];
rlprms.decimation = 0;
rlprms.sampling = 40;

%% TEXO INIT
if ~texoInit('./bin/dat/', 3, 4, 0, 64, 0, 128)
    error('texoInit failed');
end
texoClearTGCs();
if ~texoAddTGCFixed(0.60)
    error('texoAddTGCFixed failed');
end
texoSetSyncSignals(1,1,3);
texoActivateProbeConnector(0);
texoForceConnector(3);
texoEnableSyncNotify(false);
%% DAQ INIT
daqSetFirmwarePath('./bin/fw/');
daqConnect(0);
if ~daqInit(0)
    error('daqInit failed');
end
if ~daqRun(seqprms,rlprms)
    error('daqRun failed');
end
%% SEQUENCING TEST
if ~texoBeginSequence()
    error('texoBeginSequence failed');
end
%texoAddLine(tx, rx, info);
for i = 0:127
    tx.centerElement = i + 0.5;
    rx.centerElement = i + 0.5;
    [success, lineSize, lineDuration] = texoAddLine(tx, rx);
end
lineSize
lineDuration
if ~texoEndSequence()
    error('texoEndSequence failed');
end
texoSetPower(12,12,12);
%% RUN TEST
if ~texoRunImage()
    error('texoRunImage failed');
end
pause(5)
if ~texoStopImage()
    error('texoStopImage failed');
end
texoGetCollectedFrameCount()
%% DAQ DOWNLOAD
daqStop()
daqDownload('D:/data/')

%% SHUTDOWN
texoShutdown()
daqShutdown()

