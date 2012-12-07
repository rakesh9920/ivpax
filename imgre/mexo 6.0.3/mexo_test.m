%% OBJECTS TEST
tx = texoTransmitParams();
rx = texoReceiveParams();
apr = texoCurve();
info = texoLineInfo();

info.lineSize = 1000;
info.lineDuration = 100;

tx.centerElement = 645;
tx.aperture = 64; 
tx.angle = 0;
tx.focusDistance = 25000;
tx.frequency = 6600000;
tx.pulseShape = '+-';
tx.speedOfSound = 1494;
tx.tableIndex = -1;
tx.useManualDelays = 0;
tx.manualDelays = zeros(1,129);
tx.useMask = 0;
tx.mask = zeros(1,128);
tx.sync = 0;

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
%% INITIALIZATION TEST
if ~texoInit('./dat/', 3, 4, 0, 64, 3, 128)
    error('texoInit failed');
end
texoClearTGCs();
if ~texoAddTGCFixed(0.80)
    error('texoAddTGCFixed failed');
end
texoSetSyncSignals(1,0,0)
texoActivateProbeConnector(0)
texoEnableSyncNotify(false)
%% SEQUENCING TEST
if ~texoBeginSequence()
    error('texoBeginSequence failed');
end
if ~texoAddTransmit(tx);
    error('texoAddTransmit failed');
end
if ~texoAddReceive(rx);
    error('texoAddReceive failed');
end
if ~texoAddLine(tx, rx, info)
    error('texoAddLine failed');
end
if ~texoEndSequence()
    error('texoEndSequence failed');
end
texoSetPower(15,15,15)
%% RUN TEST
if ~texoRunImage()
    error('texoRunImage failed');
end
pause(5);
if ~texoStopImage()
    error('texoStopImage failed');
end
texoGetCollectedFrameCount()
data = texoGetCine(1024*5);
plot(data);

