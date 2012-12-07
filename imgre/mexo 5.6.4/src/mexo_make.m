% WORKING %
%% texo
if ~strcmp(computer, 'PCWIN')
    error('must use 32-bit MATLAB and 32-bit C++ compiler');
end

warning off
mex texo_activateProbeConnector.cpp texo.lib
mex texo_addLine.cpp texo.lib
mex texo_addReceive.cpp texo.lib
mex texo_addFlatTGC.cpp texo.lib
mex texo_addTGC.cpp texo.lib
mex texo_addTransmit.cpp texo.lib
mex texo_beginSequence.cpp texo.lib
mex texo_clearTGCs.cpp texo.lib
mex texo_collectFrames.cpp texo.lib
mex texo_constructor.cpp texo.lib
mex texo_destructor.cpp texo.lib
mex texo_endSequence.cpp texo.lib
mex texo_getCine.cpp texo.lib
mex texo_getCineStart.cpp texo.lib
mex texo_getCollectedFrameCount.cpp texo.lib
mex texo_getFrameSize.cpp texo.lib
mex texo_getMaxFrameCount.cpp texo.lib
mex texo_isImaging.cpp texo.lib
mex texo_init.cpp texo.lib
mex texo_isInitialized.cpp texo.lib
mex texo_runImage.cpp texo.lib
mex texo_setPower.cpp texo.lib
mex texo_setSyncSignals.cpp texo.lib
mex texo_shutdown.cpp texo.lib
mex texo_stopImage.cpp texo.lib


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








