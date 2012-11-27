#include "daq.h"
#include "daq_def.h"
#include <mex.h>
#include "stdint.h"

void mexFunction(int nlhs, mxArray * plhs[],
int nrhs, const mxArray * prhs[]) { 

    // read prhs
    int sampling80MHz = (int) mxGetScalar(prhs[0]);
    
	// create plhs
    bool suc = daqInit(sampling80MHz);
    plhs[0] = mxCreateLogicalScalar(suc); 
}
