%%
tex = mexo();
tx = texoTransmitParams();

tx.centerElement = 640;
tx.aperture = 64;
tx.focusDistance = 300;
tx.frequency = 6600000;
tx.pulseShape = '00';
tx.speedOfSound = 1482;
tx.tableIndex = -1;


%%
tex.init('../dat/', 3, 3, 0, 64, 3, 128)

tex.clearTGCs()
tex.addTGC(0.8)
tex.setPower(15,15,15)
tex.setSyncSignals(0,0,0)
tex.activateProbeConnector(0)

%%
tex.beginSequence()
tex.addTransmit(tx)
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

