#include "texo.h"
#include <mex.h>
  
void mexFunction(int nlhs, mxArray * plhs[],
int nrhs, const mxArray * prhs[]) { 
  
    // read prhs
    int power =  (int) (mxGetScalar(prhs[0])); 
    int maxPositive =  (int) (mxGetScalar(prhs[1]));
    int maxNegative =  (int) (mxGetScalar(prhs[2]));
    
	// create plhs
    bool suc = texoSetPower(power, maxPositive, maxNegative);
    plhs[0] = mxCreateLogicalScalar(suc); 
}
