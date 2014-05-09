#include "daq.h"
#include "daq_def.h"
#include <mex.h>

void mexFunction(int nlhs, mxArray * plhs[],
int nrhs, const mxArray * prhs[]) { 

    char path [50];
    
    // read prhs
    mxGetString(prhs[0], path, mxGetN(prhs[0])+ 1);
    
    #ifdef MEX_OUTPUT_CHECK
        mexPrintf("path = %s\n", path);
    #endif
    
	// create plhs
    bool suc = daqDownload(path);
    plhs[0] = mxCreateLogicalScalar(suc);
}