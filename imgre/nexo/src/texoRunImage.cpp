#include "texo.h"
#include <mex.h>
  
void mexFunction(int nlhs, mxArray * plhs[],
int nrhs, const mxArray * prhs[]) { 
    
	// create plhs
    bool suc = texoRunImage();
    plhs[0] = mxCreateLogicalScalar(suc); 
}
