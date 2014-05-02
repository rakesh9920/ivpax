%%
tex = mexo();
tx = texoTransmitParams();
rx = texoReceiveParams();
%%
tex.init('../dat/', 3, 3, 0, 64, 3, 128)
tex.clearTGCs();
tex.addFlatTGC(20);
tex.setPower(15,15,15);
tex.setSyncSignals(0,0,0);
tex.activateProbeConnector(0);
%%
tx.centerElement = 640;
tx.aperture = 64;
tx.focusDistance = 20000;
tx.frequency = 6600000;
tx.pulseShape = '+-';
tx.speedOfSound = 1482;
tx.tableIndex = -1;

rx.centerElement = 640;
rx.aperture = 64; %1
rx.angle = 0; %2
rx.maxApertureDepth = 20000; %3
rx.acquisitionDepth = 60000; %4
rx.saveDelay = 0; %5
rx.speedOfSound = 1482;  %6
rx.channelMask = [uint32(2^32) uint32(2^32)]; %7
rx.applyFocus = 1; %8
rx.useManualDelays = 0; %9
rx.manualDelays = zeros(1,65, 'int32'); %10
rx.customLineDuration = 0; %11
rx.lgcValue = 0; %12
rx.tgcSel = 0; %13
rx.tableIndex = -1; %14
rx.decimation = 0; %15
rx.numChannels = 64; %16

linesPerFrame = 256;
tex.beginSequence();
for line = 1:linesPerFrame
    tx.centerElement = (line - 1)*5 + 5;
    rx.centerElement = (line - 1)*5 + 5;
    tex.addLine(texoDataFormat.rfData, tx, rx);
end
tex.endSequence();

frameSize = tex.getFrameSize() - 4;
samplesPerFrame = frameSize/2;

%%
dyn = 60;
NX = 128;
NY = ceil(1620*1482*25e-9/150e-6);
iptsetpref('ImshowAxesVisible','on');
iptsetpref('ImshowInitialMagnification',300);
iptsetpref('ImshowBorder','loose');
img = zeros(NX,NY);
fhandle = imshow(img, [-dyn 0],'XData',[0 NX.*150e-3],'YData',...
    [0 NY.*150e-3]);
xlabel('lateral [mm]');
ylabel('axial [mm]');
colormap('gray');

rfcs = zeros(2,3240,256,'int16');

for i = 1:2
    pause
    tex.collectFrames(1);
    rfc = buffer(tex.getCine(samplesPerFrame),3240);
    rfcs(i,:,:) = rfc;
    img = envelope(double(rfc'))';
    img = medfilt2(img,[2 2]);
    ref = max(max(img));
    img = 20*log10(img./ref);
    img(img < -200) = -200;
    img = imresize(img, [NY NX]);
    
    set(fhandle,'cdata',img);
    drawnow;
    %refresh(fig);
end


