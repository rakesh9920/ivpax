%% INIT OBJECTS
tex = mexo();
tx = texoTransmitParams();
rx = texoReceiveParams();
%% INIT TEXO
tex.init('../dat/', 3, 3, 0, 64, 3, 128)
tex.clearTGCs();
tex.addFlatTGC(25);
tex.setPower(15,15,15);
tex.setSyncSignals(0,0,0);
tex.activateProbeConnector(0);
%% DEFINE SEQUENCE
tx.centerElement = 640;
tx.aperture = 64;
tx.focusDistance = 20000;
tx.frequency = 66000000;
tx.pulseShape = '+-';
tx.speedOfSound = 1482;
tx.tableIndex = -1;

rx.centerElement = 640;
rx.aperture = 64; %1
rx.angle = 0; %2
rx.maxApertureDepth = 60000; %3
rx.acquisitionDepth = 60000; %4
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

linesPerFrame = 128;

%% RUN

rfc = zeros(128, 3240, linesPerFrame,'int16');

for line = 1:128
    
    tex.beginSequence(); %% BEGIN SEQUENCING %%
    
    tx.centerElement = (line - 1)*10 + 5;
    
    rx.centerElement = 315;
    for c = 1:32
        rx.channelMask = [bitshift(uint32(1),mod(c-1,32)) uint32(0)];
        tex.addLine(texoDataFormat.rfData, tx, rx);
    end
    for c = 33:64
        rx.channelMask = [uint32(0) bitshift(uint32(1),mod(c-1,32))];
        tex.addLine(texoDataFormat.rfData, tx, rx);
    end
    
    rx.centerElement = 955;
    for c = 1:32
        rx.channelMask = [bitshift(uint32(1),mod(c-1,32)) uint32(0)];
        tex.addLine(texoDataFormat.rfData, tx, rx);
    end
    for c = 33:64
        rx.channelMask = [uint32(0) bitshift(uint32(1),mod(c-1,32))];
        tex.addLine(texoDataFormat.rfData, tx, rx);
    end
    
    tex.endSequence();  %% END SEQUENCING %%
    
    frameSize = tex.getFrameSize() - 4;
    samplesPerFrame = frameSize/2;
    samplesPerLine = samplesPerFrame/linesPerFrame;
    
    tic;
    fprintf(strcat('collecting frame ',num2str(line),' ... '));
    tex.collectFrames(1);
    fprintf('[ok]\n'); drawnow;
    rfc(line,:,:) = reshape(tex.getCine(samplesPerFrame),...
        samplesPerLine, linesPerFrame);
end

toc
%% DESTROY OBJECTS
delete(tex);
delete(tx);
delete(rx);

