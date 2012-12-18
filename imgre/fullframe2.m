%%
addpath './maq/'
addpath './mexo 6.0.3/'
addpath './bin/'
%% OBJECT INIT
tx = texoTransmitParams();
rx = texoReceiveParams();
apr = texoCurve();
info = texoLineInfo();
seqprms = daqSequencePrms();
rlprms = daqRaylinePrms();

info.lineSize = 2678;
info.lineDuration = 70;

tx.centerElement = 640;
tx.aperture = 64; 
tx.angle = 0;
tx.focusDistance = 35000;
tx.frequency = 6600000;
tx.pulseShape = '+-';
tx.speedOfSound = 1494;
tx.tableIndex = -1;
tx.useManualDelays = 0;
tx.manualDelays = zeros(1,129);
tx.useMask = 0;
tx.mask = zeros(1,128);
tx.sync = 1;

rx.centerElement = 640;
rx.aperture = 64; 
rx.angle = 0; 
rx.maxApertureDepth = 30000; 
rx.acquisitionDepth = 30000;
rx.saveDelay = 0; 
rx.speedOfSound = 1494;  
rx.channelMask = [uint32(2^32) uint32(2^32)]; 
rx.applyFocus = 0; 
rx.useManualDelays = 0; 
rx.manualDelays = zeros(1,65); 
rx.customLineDuration = 0; 
rx.lgcValue = 0; 
rx.tgcSel = 0; 
rx.tableIndex = -1; 
rx.decimation = 0; 
rx.numChannels = 64; 
rx.rxAprCrv = apr;
rx.weightType = 0;
rx.useCustomWindow = 0;
rx.window = zeros(1,64);

seqprms.freeRun = false;
seqprms.hpfBypass = false;
seqprms.divisor = 0; % data size = 16GB / 2^divisor
seqprms.externalTrigger = true;
seqprms.externalClock = true;
seqprms.lnaGain = 1; % 16dB, 18dB, 21dB
seqprms.pgaGain = 1; % 21dB, 24dB, 27dB, 30dB
seqprms.biasCurrent = 1; % 0,1,2,...,7
seqprms.fixedTGC = true;
seqprms.fixedTGCLevel = 40;

rlprms.lineDuration = 70; % line duration in micro seconds
rlprms.numSamples = 2678; 
rlprms.gainOffset = 0;
rlprms.gainDelay = 0;
rlprms.rxDelay = 0;
rlprms.channels = [uint32(2^32) uint32(2^32) uint32(2^32) uint32(2^32)];
rlprms.decimation = 0;
rlprms.sampling = 40;

%% TEXO INIT
if ~texoInit('./bin/dat/', 3, 4, 0, 64, 3, 128)
    error('texoInit failed');
end
texoClearTGCs();
if ~texoAddTGCFixed(0.60)
    error('texoAddTGCFixed failed');
end
texoSetSyncSignals(1,1,3)
texoActivateProbeConnector(0)
texoForceConnector(3);
texoEnableSyncNotify(false)
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
for i = 0:10:1280
    tx.centerElement = 0;
    texoAddLine(tx, rx, info);
end
if ~texoEndSequence()
    error('texoEndSequence failed');
end
texoSetPower(15,15,15)
%% RUN TEST
if ~texoRunImage()
    error('texoRunImage failed');
end
pause(10)
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

