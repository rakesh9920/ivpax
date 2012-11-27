#include "daq.h"
#include "daq_def.h"
#include <mex.h>
#include "stdint.h"

void mexFunction(int nlhs, mxArray * plhs[],
int nrhs, const mxArray * prhs[]) { 

    daqStopInit();
}
