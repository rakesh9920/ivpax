if ~strcmp(computer, 'PCWIN')
    error('must use 32-bit MATLAB and 32-bit C++ compiler');
end

warning off

mex daqInit.cpp daq.lib
mex daqStopInit.cpp daq.lib
mex daqConnect.cpp daq.lib
mex daqDisconnect.cpp daq.lib
mex daqSetFirmwarePath.cpp daq.lib
mex daqIsConnected.cpp daq.lib
mex daqIsDownloading.cpp daq.lib
mex daqIsRunning.cpp daq.lib
mex daqIsInitialized.cpp daq.lib
mex daqIsInitializing.cpp daq.lib
mex daqRun.cpp daq.lib
mex daqStop.cpp daq.lib
mex daqStopDownload.cpp daq.lib
mex daqDownload.cpp daq.lib
mex daqShutdown.cpp daq.lib