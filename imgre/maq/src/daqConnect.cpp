#include "daq.h"
#include "daq_def.h"
#include <mex.h>

void mexFunction(int nlhs, mxArray * plhs[],
int nrhs, const mxArray * prhs[]) { 

    // read prhs
    int index = (int) mxGetScalar(prhs[0]);
    
    #ifdef MEX_OUTPUT_CHECK
        mexPrintf("index = %d\n", index);
    #endif
    
	// create plhs
    bool suc = daqConnect(index);
    plhs[0] = mxCreateLogicalScalar(suc); 
}