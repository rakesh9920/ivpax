#include "texo.h"
#include <mex.h>
  
void mexFunction(int nlhs, mxArray * plhs[],
int nrhs, const mxArray * prhs[]) { 
  
    // read prhs
    double percent =  (mxGetScalar(prhs[0]));
    
    #ifdef MEX_OUTPUT_CHECK
        mexPrintf("TGC percent = %f\n", percent);
    #endif
    
	// create plhs
	bool suc = texoAddTGCFixed(percent);
    plhs[0] = mxCreateLogicalScalar(suc); 
}
