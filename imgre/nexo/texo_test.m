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
%%
texoInit('./dat/', 3, 4, 0, 64, 3, 128)
texoClearTGCs()
texoAddFlatTGC(20)
texoSetPower(15,15,15)
texoSetSyncSignals(1,0,0)
texoActivateProbeConnector(0)
%%
texoAddLine(tx, rx, info);
