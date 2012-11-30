#include "daq.h"
#include "daq_def.h"
#include <mex.h>

void mexFunction(int nlhs, mxArray * plhs[],
int nrhs, const mxArray * prhs[]) { 

    char err [256];
    
    // read prhs
    daqGetLastError(err, 256);
    mexPrintf(err);
    mexPrintf("\n");
}
