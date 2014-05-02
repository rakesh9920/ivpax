#include "texo.h"
#include <mex.h>
#include "stdint.h"
  
void mexFunction(int nlhs, mxArray * plhs[],
int nrhs, const mxArray * prhs[]) { 
  
    // read prhs
    int input =  static_cast <int>(mxGetScalar(prhs[0]));
    int output =  static_cast <int>(mxGetScalar(prhs[1]));
    int output2 =  static_cast <int>(mxGetScalar(prhs[2]));
    
	// create plhs
    texoSetSyncSignals(input, output, output2);
}
