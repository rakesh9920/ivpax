%% texo
if ~strcmp(computer, 'PCWIN')
    error('must use 32-bit MATLAB and 32-bit C++ compiler');
end

warning off

mkdir mexw32

mex texoActivateProbeConnector.cpp texo.lib -outdir ./mexw32/
mex texoAddFlatTGC.cpp texo.lib -outdir ./mexw32/
mex texoBeginSequence.cpp texo.lib -outdir ./mexw32/
mex texoClearTGCs.cpp texo.lib -outdir ./mexw32/
mex texoCollectFrames.cpp texo.lib -outdir ./mexw32/
mex texoEndSequence.cpp texo.lib -outdir ./mexw32/
mex texoGetCine.cpp texo.lib -outdir ./mexw32/
mex texoGetCineStart.cpp texo.lib -outdir ./mexw32/
mex texoGetCollectedFrameCount.cpp texo.lib -outdir ./mexw32/
mex texoGetFrameSize.cpp texo.lib -outdir ./mexw32/
mex texoGetMaxFrameCount.cpp texo.lib -outdir ./mexw32/
mex texoIsImaging.cpp texo.lib -outdir ./mexw32/
mex texoInit.cpp texo.lib -outdir ./mexw32/
mex texoIsInitialized.cpp texo.lib -outdir ./mexw32/
mex texoRunImage.cpp texo.lib -outdir ./mexw32/
mex texoSetPower.cpp texo.lib -outdir ./mexw32/
mex texoSetSyncSignals.cpp texo.lib -outdir ./mexw32/
mex texoShutdown.cpp texo.lib -outdir ./mexw32/
mex texoStopImage.cpp texo.lib -outdir ./mexw32/
mex texoAddTransmit.cpp texo.lib -outdir ./mexw32/
mex texoAddLine.cpp texo.lib -outdir ./mexw32/
mex texoAddReceive.cpp texo.lib -outdir ./mexw32/
mex texoAddTGC.cpp texo.lib -outdir ./mexw32/







