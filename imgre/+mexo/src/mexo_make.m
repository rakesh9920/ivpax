%% texo
if ~strcmp(computer, 'PCWIN')
    error('must use 32-bit MATLAB and 32-bit C++ compiler');
end

warning off

mkdir ./mexw32/
options = '-outdir ./mexw32/'; %-DMEX_OUTPUT_CHECK';

eval(strcat(['mex texoActivateProbeConnector.cpp texo.lib' ' ' options]));
eval(strcat(['mex texoAddTGC.cpp texo.lib' ' ' options]));  
eval(strcat(['mex texoAddFlatTGC.cpp texo.lib' ' ' options]));
eval(strcat(['mex texoAddTGCFixed.cpp texo.lib' ' ' options])); 
eval(strcat(['mex texoEnableSyncNotify.cpp texo.lib' ' ' options])); 
eval(strcat(['mex texoForceConnector.cpp texo.lib' ' ' options])); 
eval(strcat(['mex texoClearTGCs.cpp texo.lib' ' ' options]));
eval(strcat(['mex texoInit.cpp texo.lib' ' ' options])); 
eval(strcat(['mex texoSetPower.cpp texo.lib' ' ' options])); 
eval(strcat(['mex texoSetSyncSignals.cpp texo.lib' ' ' options])); 
eval(strcat(['mex texoShutdown.cpp texo.lib' ' ' options])); 

eval(strcat(['mex texoBeginSequence.cpp texo.lib' ' ' options]));
eval(strcat(['mex texoCollectFrames.cpp texo.lib' ' ' options]));
eval(strcat(['mex texoEndSequence.cpp texo.lib' ' ' options]));
eval(strcat(['mex texoAddTransmit.cpp texo.lib' ' ' options])); 
eval(strcat(['mex texoAddLine.cpp texo.lib' ' ' options])); 
eval(strcat(['mex texoAddReceive.cpp texo.lib ' ' ' options]));
eval(strcat(['mex texoRunImage.cpp texo.lib' ' ' options])); 
eval(strcat(['mex texoStopImage.cpp texo.lib' ' ' options])); 

eval(strcat(['mex texoGetCine.cpp texo.lib' ' ' options]));
eval(strcat(['mex texoGetCineStart.cpp texo.lib' ' ' options]));
eval(strcat(['mex texoGetCollectedFrameCount.cpp texo.lib' ' ' options]));
eval(strcat(['mex texoGetFrameSize.cpp texo.lib' ' ' options])); 
eval(strcat(['mex texoGetMaxFrameCount.cpp texo.lib' ' ' options])); 
eval(strcat(['mex texoGetProbeCenterFreq.cpp texo.lib' ' ' options])); 

eval(strcat(['mex texoIsImaging.cpp texo.lib' ' ' options])); 
eval(strcat(['mex texoIsInitialized.cpp texo.lib' ' ' options])); 










