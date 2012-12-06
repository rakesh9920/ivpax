#include "texo.h"
#include <mex.h>
  
void mexFunction(int nlhs, mxArray * plhs[],
int nrhs, const mxArray * prhs[]) { 
  
    // read prhs
    double percent =  (mxGetScalar(prhs[0]));
    
	// create plhs
	bool suc = texoAddTGCFixed(percent);
    plhs[0] = mxCreateLogicalScalar(suc); 
}
