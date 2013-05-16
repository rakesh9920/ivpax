#include "daq.h"
#include "daq_def.h"
#include <mex.h>

void mexFunction(int nlhs, mxArray * plhs[],
int nrhs, const mxArray * prhs[]) { 

    char firmwarePath [50];
    
    // read prhs
    mxGetString(prhs[0], firmwarePath, mxGetN(prhs[0])+ 1);
    
    #ifdef MEX_OUTPUT_CHECK
        mexPrintf("firmwarePath = %s\n", firmwarePath);
    #endif
    
	// create plhs
    daqSetFirmwarePath(firmwarePath);
}
