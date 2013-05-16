#include "daq.h"
#include "daq_def.h"
#include <mex.h>

void mexFunction(int nlhs, mxArray * plhs[],
int nrhs, const mxArray * prhs[]) { 
  
	// create plhs
    bool suc = daqIsInitialized();
    plhs[0] = mxCreateLogicalScalar(suc); 
}
