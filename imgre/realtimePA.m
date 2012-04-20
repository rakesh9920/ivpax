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
rx.aperture = 64; 
rx.angle = 0; 
rx.maxApertureDepth = 7500; 
rx.acquisitionDepth = 30000; 
rx.saveDelay = 0; 
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
for line = 1:linesPerFrame
    tx.centerElement = (line - 1)*10 + 5;
    rx.centerElement = (line - 1)*10 + 5;
    tex.addLine(texoDataFormat.rfData, tx, rx);
end
tex.endSequence();

frameSize = tex.getFrameSize() - 4;
samplesPerFrame = frameSize/2;
samplesPerLine = samplesPerFrame/linesPerFrame;

%%
dyn = 40;
NX = 128;
NY = ceil(1620*1482*25e-9/300e-6);
iptsetpref('ImshowAxesVisible','on');
img = zeros(NX,NY);
imshow(img, [-dyn 0],'XData',[0 NX.*300e-3],'YData',...
    [0 NY.*300e-3],'InitialMagnification',200);
xlabel('lateral [mm]');
ylabel('axial [mm]');
colormap('hot');


numberOfFrames = 100;
while true
    avg = zeros(samplesPerLine, linesPerFrame);
    for part = 1:1
        tex.collectFrames(numberOfFrames);
        rfc = reshape(tex.getCine(samplesPerFrame*numberOfFrames),...
            samplesPerLine, linesPerFrame, numberOfFrames);
        avg = avg + mean(1000.*rfc,3);
    end
    
    img = envelope(double(avg'))';
    img = medfilt2(img,[2 2]);
    ref = max(max(img));
    img = 20*log10(img./ref);
    img(img < -200) = -200;
    img = imresize(img, [NY NX]);
    
    imshow(img, [-dyn 0],'XData',[0 NX.*300e-3],'YData',...
        [0 NY.*300e-3],'InitialMagnification',400);
    drawnow;
end

