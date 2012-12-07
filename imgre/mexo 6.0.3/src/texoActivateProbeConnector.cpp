#include "texo.h"
#include <mex.h>
     
void mexFunction(int nlhs, mxArray * plhs[],
int nrhs, const mxArray * prhs[]) { 

    int probe = (int) mxGetScalar(prhs[0]);
    
    plhs[0] = mxCreateLogicalScalar(texoActivateProbeConnector(probe)); 
}
