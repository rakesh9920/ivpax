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
%% DEFINE SEQUENCE
tx.centerElement = 645;
tx.aperture = 0;
tx.focusDistance = 300000;
tx.frequency = 6600000;
tx.pulseShape = '00';
tx.speedOfSound = 1494;
tx.tableIndex = -1;

rx.centerElement = 640;
rx.aperture = 64;
rx.angle = 0;
rx.maxApertureDepth = 40000;
rx.acquisitionDepth = 40000;
rx.saveDelay = 20000;
rx.speedOfSound = 1494;
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

linesPerFrame = 64;

tex.beginSequence();

rx.centerElement = 635;
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

numberOfFrames = 250;
numberOfParts = 4;
dGain = 1000;

no = 1;
for x = 0:0.5:5
    mcset(x,0); pause(23.0);
    for y = 0:0.5:5
        tic;
        mcset(x,y);
        rfc = zeros(samplesPerLine, linesPerFrame);
        for part = 1:numberOfParts
            tex.collectFrames(numberOfFrames);
            stream = reshape(tex.getCine(samplesPerFrame*numberOfFrames),...
                samplesPerLine, linesPerFrame, numberOfFrames);
            rfc = rfc + mean(dGain.*stream,3)./numberOfParts;
        end
        clear stream;
        name = strcat('Z:\home\Bernie Shieh\Data\Raster2d\rfc',num2str(no));
        save(name,'rfc');
        save lastcoords x y;
        fprintf('no: %d | x: %0.1f | y: %0.1f | time: %0.2f\n', no, x, y, toc);
        drawnow;
        no = no + 1;
    end
end
%%
delete(tex);
delete(tx);
delete(rx);




