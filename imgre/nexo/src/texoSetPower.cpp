#include "texo.h"
#include <mex.h>
#include "stdint.h"
  
void mexFunction(int nlhs, mxArray * plhs[],
int nrhs, const mxArray * prhs[]) { 
  
    // read prhs
    int power =  static_cast <int>(mxGetScalar(prhs[0]));
    int maxPositive =  static_cast <int>(mxGetScalar(prhs[1]));
    int maxNegative =  static_cast <int>(mxGetScalar(prhs[2]));
    
	// create plhs
    bool suc = texoSetPower(power, maxPositive, maxNegative);
    plhs[0] = mxCreateLogicalScalar(suc); 
}
