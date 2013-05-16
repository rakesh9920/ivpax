#include "daq.h"
#include "daq_def.h"
#include <mex.h>

void daqCallback(void *prm, int val, ECallbackSources src) {}

void mexFunction(int nlhs, mxArray * plhs[],
int nrhs, const mxArray * prhs[]) { 

    // read prhs
    int sampling80MHz = (int) mxGetScalar(prhs[0]);
    
    daqSetCallback(daqCallback,0);
    
    #ifdef MEX_OUTPUT_CHECK
        mexPrintf("sampling80MHz = %d\n", sampling80MHz);
    #endif
    
	// create plhs
    bool suc = daqInit(sampling80MHz);
    plhs[0] = mxCreateLogicalScalar(suc); 
}
