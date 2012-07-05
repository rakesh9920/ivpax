%% INIT OBJECTS
tex = mexo();
tx = texoTransmitParams();
rx = texoReceiveParams();
%% INIT TEXO
tex.init('../dat/', 3, 3, 0, 64, 3, 128)
tex.clearTGCs();
tex.addFlatTGC(20);
tex.setPower(15,15,15);
tex.setSyncSignals(1,0,0);
tex.activateProbeConnector(0);
%% DEFINE SEQUENCE
tx.centerElement = 645;
tx.aperture = 64; %0
tx.focusDistance = 25000;%25000
tx.frequency = 6600000;
tx.pulseShape = '+-';
tx.speedOfSound = 1494;
tx.tableIndex = -1;

rx.centerElement = 640;
rx.aperture = 64; %1
rx.angle = 0; %2
rx.maxApertureDepth = 30000; %40000
rx.acquisitionDepth = 30000; %40000
rx.saveDelay = 0; %20000
rx.speedOfSound = 1494;  %6
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
%% RUN
tic;
rfc = zeros(128, samplesPerLine, linesPerFrame, 'int16');

for tline = 1:128
    
    tex.beginSequence();
    tx.centerElement = (tline - 1)*10 + 5;
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

    fprintf('collecting frames ... ');
    tex.collectFrames(1);
    fprintf('[ok]\n'); drawnow;
    rfc(tline, :, :) = reshape(tex.getCine(samplesPerFrame),...
        samplesPerLine, linesPerFrame); 
end

toc
%% DESTROY OBJECTS
delete(tex);
delete(tx);
delete(rx);

