%%
tex = mexo();
tx = texoTransmitParams();
rx = texoReceiveParams();

tx.centerElement = 640;
tx.aperture = 64;
tx.focusDistance = 300;
tx.frequency = 6600000;
tx.pulseShape = '00';
tx.speedOfSound = 1482;
tx.tableIndex = -1;

rx.centerElement = 640;
rx.aperture = 64; %1
rx.angle = 0; %2
rx.maxApertureDepth = 15000; %3
rx.acquisitionDepth = 15000; %4
rx.saveDelay = 0; %5
rx.speedOfSound = 1482;  %6
rx.channelMask = [uint32(2^32) uint32(2^32)]; %7
rx.applyFocus = 0; %8
rx.useManualDelays = 0; %9
rx.manualDelays = zeros(1,65, 'int32'); %10
rx.customLineDuration = 0; %11
rx.lgcValue = 0; %12
rx.tgcSel = 0; %13
rx.tableIndex = -1; %14
rx.decimation = 0; %15
rx.numChannels = 64; %16

%%
tex.init('../dat/', 3, 3, 0, 64, 3, 128)
%%
tex.clearTGCs()
tex.addTGC(0.8)
tex.setPower(15,15,15)
tex.setSyncSignals(0,0,0)
tex.activateProbeConnector(0)

%%
tex.beginSequence()
%tex.addTransmit(tx)
tex.addLine(texoDataFormat.rfData, tx, rx)
tex.endSequence()
%%
if ~tex.init('../dat/', 3, 3, 0, 64, 3, 128)
    error('texo init failed');
end

if ~tex.beginSequence()
    error('texo begin sequence failed');
end

if ~tex.addTransmit(tx)
    error('texo add transmit failed');
end

if ~tex.endSequence()
    error('texo end sequence failed');
end

