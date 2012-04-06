#include "texo.h"
#include <mex.h>
     
void mexFunction(int nlhs, mxArray * plhs[],
int nrhs, const mxArray * prhs[]) { 

	unsigned long * ptr = (unsigned long *) mxGetData(prhs[0]);
    texo * tex = (texo *) ptr[0];
    int probe = (int) mxGetScalar(prhs[1]);
    
    plhs[0] = mxCreateLogicalScalar(tex->activateProbeConnector(probe)); 
}
