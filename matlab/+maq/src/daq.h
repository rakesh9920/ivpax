#pragma once

#ifdef EXPORT_DAQ
    #define daqL __declspec(dllexport)
#elif defined IMPORT_DAQ
    #define daqL __declspec(dllimport)
#else
    #define daqL
#endif

#include "daq_def.h"

#ifdef __cplusplus
extern "C" {
#endif

// initialization functions
daqL int daqInit(int sampling80MHz = 0);
daqL void daqStopInit();
// connection functions
daqL int daqGetDeviceList(int index, char* device, int sz);
daqL int daqConnect(int index);
daqL void daqDisconnect();
// other setup functions
daqL double daqGetDeviceVersion();
daqL int daqCheckUSB();
daqL void daqSetCallback(DAQ_CALLBACK, void*);
daqL void daqSetFirmwarePath(const char*);
daqL void daqShutdown();
daqL void daqGetLastError(char* err, int sz);
// status functions
daqL int daqIsConnected();
daqL int daqIsInitialized();
daqL int daqIsInitializing();
daqL int daqIsDownloading();
daqL int daqIsRunning();
// sequencing functions
daqL int daqRun(const daqSequencePrms&, const daqRaylinePrms&);
daqL int daqStop();
// TGC functions
daqL float daqTgcGetX(int index);
daqL float daqTgcGetY(int index);
daqL bool daqTgcSetX(int index, float value);
daqL bool daqTgcSetY(int index, float value);
// datastore/memory functions
daqL int daqDownload(const char* path);
daqL void daqStopDownload();
// led function
daqL int daqSetLEDs(ELedMode mode);
// advanced testing functions
daqL int daqDoAdvanced(EAdvancedFunction fn, int param1 = 0, int param2 = 0, int param3 = 0, int param4 = 0);
daqL int daqGetDeviceHealth(float* temperature, float* voltage);

#ifdef __cplusplus
}
#endif
