%%
tex = mexo();
tx = texoTransmitParams();
rx = texoReceiveParams();
%%
tx.centerElement = 640;
tx.aperture = 64;
tx.focusDistance = 15000;
tx.frequency = 6600000;
tx.pulseShape = '00';
tx.speedOfSound = 1482;
tx.tableIndex = -1;

rx.centerElement = 640;
rx.aperture = 64; %1
rx.angle = 0; %2
rx.maxApertureDepth = 15000; %3
rx.acquisitionDepth = 30000; %4
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
tex.clearTGCs();
tex.addFlatTGC(100);
tex.setPower(15,15,15);
tex.setSyncSignals(1,0,0);
tex.activateProbeConnector(0);

%%
linesPerFrame = 128;

tex.beginSequence();

rx.centerElement = 315;
for line = 1:32
    rx.channelMask = [bitshift(uint32(1),mod(line-1,32)) uint32(0)];
    tex.addLine(texoDataFormat.rfData, tx, rx);
end
for line = 33:64
    rx.channelMask = [uint32(0) bitshift(uint32(1),mod(line-1,32))];
    tex.addLine(texoDataFormat.rfData, tx, rx);
end

rx.centerElement = 955;
for line = 1:32
    rx.channelMask = [bitshift(uint32(1),mod(line-1,32)) uint32(0)];
    tex.addLine(texoDataFormat.rfData, tx, rx);
end
for line = 33:64
    rx.channelMask = [uint32(0) bitshift(uint32(1),mod(line-1,32))];
    tex.addLine(texoDataFormat.rfData, tx, rx);
end

tex.endSequence();

frameSize = tex.getFrameSize() - 4;
samplesPerFrame = frameSize/2;
samplesPerLine = samplesPerFrame/linesPerFrame;

%%
tic;
avg = zeros(samplesPerLine, linesPerFrame);
numberOfFrames = 250;
for part = 1:4
    tex.collectFrames(numberOfFrames);
    rfc = reshape(tex.getCine(samplesPerFrame*numberOfFrames),...
        samplesPerLine, linesPerFrame, numberOfFrames);
    avg = avg + mean(1000.*rfc,3)./2;
    name = strcat('avg', num2str(part));
    save(name, 'avg', '-v6');
end
toc


