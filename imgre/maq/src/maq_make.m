if ~strcmp(computer, 'PCWIN')
    error('must use 32-bit MATLAB and 32-bit C++ compiler');
end
warning off

mkdir ./mexw32/
options = '-outdir ./mexw32/'; %-DMEX_OUTPUT_CHECK;

% initialization functions
eval(strcat(['mex daqInit.cpp daq.lib' ' ' options]));
eval(strcat(['mex daqInit.cpp daq.lib' ' ' options]));
eval(strcat(['mex daqStopInit.cpp daq.lib' ' ' options]));
eval(strcat(['mex daqConnect.cpp daq.lib' ' ' options]));
eval(strcat(['mex daqDisconnect.cpp daq.lib' ' ' options]));
eval(strcat(['mex daqSetFirmwarePath.cpp daq.lib' ' ' options]));

% status functions
eval(strcat(['mex daqIsConnected.cpp daq.lib' ' ' options]));
eval(strcat(['mex daqIsDownloading.cpp daq.lib' ' ' options]));
eval(strcat(['mex daqIsRunning.cpp daq.lib' ' ' options]));
eval(strcat(['mex daqIsInitialized.cpp daq.lib' ' ' options]));
eval(strcat(['mex daqIsInitializing.cpp daq.lib' ' ' options]));
eval(strcat(['mex daqGetLastError.cpp daq.lib' ' ' options]));

% control functions
eval(strcat(['mex daqRun.cpp daq.lib' ' ' options]));
eval(strcat(['mex daqStop.cpp daq.lib' ' ' options]));
eval(strcat(['mex daqStopDownload.cpp daq.lib' ' ' options]));
eval(strcat(['mex daqDownload.cpp daq.lib' ' ' options]));
eval(strcat(['mex daqShutdown.cpp daq.lib' ' ' options]));