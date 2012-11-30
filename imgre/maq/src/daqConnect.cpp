#include "daq.h"
#include "daq_def.h"
#include <mex.h>

void mexFunction(int nlhs, mxArray * plhs[],
int nrhs, const mxArray * prhs[]) { 

    // read prhs
    int index = (int) mxGetScalar(prhs[0]);
    
	// create plhs
    bool suc = daqConnect(index);
    plhs[0] = mxCreateLogicalScalar(suc); 
}