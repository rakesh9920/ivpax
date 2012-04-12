%% works
warning off

% texo
mex texo_activateProbeConnector.cpp texo.lib
mex texo_addTGC.cpp texo.lib
mex texo_addTransmit.cpp texo.lib
mex texo_beginSequence.cpp texo.lib
mex texo_clearTGCs.cpp texo.lib
mex texo_constructor.cpp texo.lib
mex texo_destructor.cpp texo.lib
mex texo_endSequence.cpp texo.lib
mex texo_isImaging.cpp texo.lib
mex texo_init.cpp texo.lib
mex texo_isInitialized.cpp texo.lib
mex texo_setPower.cpp texo.lib
mex texo_setSyncSignals.cpp texo.lib
mex texo_shutdown.cpp texo.lib

%% texoTransmitParams
mex texoTransmitParams_constructor.cpp texo.lib
mex texoTransmitParams_destructor.cpp texo.lib
mex texoTransmitParams_getter.cpp texo.lib
mex texoTransmitParams_setter.cpp texo.lib

% texoReceiveParams
mex texoReceiveParams_constructor.cpp texo.lib
mex texoReceiveParams_destructor.cpp texo.lib
mex texoReceiveParams_getter.cpp texo.lib
mex texoReceiveParams_setter.cpp texo.lib

%% testing
warning off

mex texo_addLine.cpp texo.lib
mex texo_addReceive.cpp texo.lib
mex texo_runImage.cpp texo.lib
mex texo_stopImage.cpp texo.lib

