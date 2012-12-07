if ~strcmp(computer, 'PCWIN')
    error('must use 32-bit MATLAB and 32-bit C++ compiler');
end

warning off

mkdir ./mexw32/

% initialization functions
mex daqInit.cpp daq.lib -outdir ./mexw32/
mex daqStopInit.cpp daq.lib -outdir ./mexw32/
mex daqConnect.cpp daq.lib -outdir ./mexw32/
mex daqDisconnect.cpp daq.lib -outdir ./mexw32/
mex daqSetFirmwarePath.cpp daq.lib -outdir ./mexw32/

% status functions
mex daqIsConnected.cpp daq.lib -outdir ./mexw32/
mex daqIsDownloading.cpp daq.lib -outdir ./mexw32/
mex daqIsRunning.cpp daq.lib -outdir ./mexw32/
mex daqIsInitialized.cpp daq.lib -outdir ./mexw32/
mex daqIsInitializing.cpp daq.lib -outdir ./mexw32/
mex daqGetLastError.cpp daq.lib -outdir ./mexw32/

% control functions
mex daqRun.cpp daq.lib -outdir ./mexw32/
mex daqStop.cpp daq.lib -outdir ./mexw32/
mex daqStopDownload.cpp daq.lib -outdir ./mexw32/
mex daqDownload.cpp daq.lib -outdir ./mexw32/
mex daqShutdown.cpp daq.lib -outdir ./mexw32/