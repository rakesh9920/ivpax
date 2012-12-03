% WORKING %
%% texo
if ~strcmp(computer, 'PCWIN')
    error('must use 32-bit MATLAB and 32-bit C++ compiler');
end

warning off
mex texoActivateProbeConnector.cpp texo.lib
mex texoAddFlatTGC.cpp texo.lib
mex texoBeginSequence.cpp texo.lib
mex texoClearTGCs.cpp texo.lib
mex texoCollectFrames.cpp texo.lib
mex texoEndSequence.cpp texo.lib
mex texoGetCine.cpp texo.lib
mex texoGetCineStart.cpp texo.lib
mex texoGetCollectedFrameCount.cpp texo.lib
mex texoGetFrameSize.cpp texo.lib
mex texoGetMaxFrameCount.cpp texo.lib
mex texoIsImaging.cpp texo.lib
mex texoInit.cpp texo.lib
mex texoIsInitialized.cpp texo.lib
mex texoRunImage.cpp texo.lib
mex texoSetPower.cpp texo.lib
mex texoSetSyncSignals.cpp texo.lib
mex texoShutdown.cpp texo.lib
mex texoStopImage.cpp texo.lib

%%
mex texo_addTGC.cpp texo.lib
mex texo_addTransmit.cpp texo.lib
mex texo_addLine.cpp texo.lib
mex texo_addReceive.cpp texo.lib


% texoTransmitParams
warning off
mex texoTransmitParams_constructor.cpp texo.lib
mex texoTransmitParams_destructor.cpp texo.lib
mex texoTransmitParams_getter.cpp texo.lib
mex texoTransmitParams_setter.cpp texo.lib

% texoReceiveParams
warning off
mex texoReceiveParams_constructor.cpp texo.lib
mex texoReceiveParams_destructor.cpp texo.lib
mex texoReceiveParams_getter.cpp texo.lib
mex texoReceiveParams_setter.cpp texo.lib

% TESTING %
%%
mex dblBuffer_constructor.cpp dblBuffer.cpp
mex dblBuffer_destructor.cpp dblBuffer.cpp
mex dblBuffer_transferData.cpp dblBuffer.cpp texo.lib
mex dblBuffer_getBuffer.cpp dblBuffer.cpp








