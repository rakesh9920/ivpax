%% INIT OBJECTS
tex = mexo();
tx = texoTransmitParams();
rx = texoReceiveParams();
%% INIT TEXO
tex.init('../dat/', 3, 3, 0, 64, 3, 128)
tex.clearTGCs();
tex.addFlatTGC(100);
tex.setPower(0,0,0);
tex.setSyncSignals(1,0,0);
tex.activateProbeConnector(0);
%% BEAMFORMING ON
tx.centerElement = 640;
tx.aperture = 0;
tx.focusDistance = 35000;
tx.frequency = 6600000;
tx.pulseShape = '00';
tx.speedOfSound = 1482;
tx.tableIndex = -1;

rx.centerElement = 640;
rx.aperture = 64;
rx.angle = 0;
rx.maxApertureDepth = 40000;
rx.acquisitionDepth = 40000;
rx.saveDelay = 20000;
rx.speedOfSound = 1482;
rx.channelMask = [uint32(2^32) uint32(2^32)];
rx.applyFocus = 1;
rx.useManualDelays = 0;
rx.manualDelays = zeros(1,65, 'int32');
rx.customLineDuration = 0;
rx.lgcValue = 0;
rx.tgcSel = 0;
rx.tableIndex = -1;
rx.decimation = 0;
rx.numChannels = 64;

linesPerFrame = 500;
rx.centerElement = 640;

tex.beginSequence();
for line = 1:linesPerFrame
    tex.addLine(texoDataFormat.rfData, tx, rx);
end
tex.endSequence();

frameSize = tex.getFrameSize() - 4;
samplesPerFrame = frameSize/2;
samplesPerLine = samplesPerFrame/linesPerFrame;
%% BEAMFORMING OFF
tx.centerElement = 640;
tx.aperture = 0;
tx.focusDistance = 300000;
tx.frequency = 6600000;
tx.pulseShape = '00';
tx.speedOfSound = 1482;
tx.tableIndex = -1;

rx.centerElement = 640;
rx.aperture = 64;
rx.angle = 0;
rx.maxApertureDepth = 20000;
rx.acquisitionDepth = 20000;
rx.saveDelay = 0;
rx.speedOfSound = 1482;
rx.channelMask = [uint32(2^32) uint32(2^32)];
rx.applyFocus = 0;
rx.useManualDelays = 0;
rx.manualDelays = zeros(1,65, 'int32');
rx.customLineDuration = 0;
rx.lgcValue = 0;
rx.tgcSel = 0;
rx.tableIndex = -1;
rx.decimation = 0;
rx.numChannels = 64;

linesPerFrame = 500;
rx.centerElement = 640;
rx.channelMask = [uint32(0) bitshift(uint32(1),mod(33-1,32))];

tex.beginSequence();
for line = 1:linesPerFrame
    tex.addLine(texoDataFormat.rfData, tx, rx);
end
tex.endSequence();

frameSize = tex.getFrameSize() - 4;
samplesPerFrame = frameSize/2;
samplesPerLine = samplesPerFrame/linesPerFrame;

%% RUN
figure; fhandle = plot(zeros(1,samplesPerLine));
xlabel('sample');
ylabel('voltage');

numberOfFrames = 2;
while true
    tex.collectFrames(numberOfFrames);
    rfc = reshape(tex.getCine(samplesPerFrame*numberOfFrames),...
        samplesPerLine, linesPerFrame, numberOfFrames);
    %avg = mean(1000.*rfc,2);
    avg = mean(mean(1000.*rfc,3),2);
    avg_b = bandpass(avg', 6.6,5.28,40);
    %set(fhandle, 'cdata', avg);
    plot(avg_b);
    drawnow;
end
%% DESTROY OBJECTS
delete(tex);
delete(tx);
delete(rx);
