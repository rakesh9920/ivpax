#include "texo.h"
#include <mex.h>
#include "stdint.h"
  
void mexFunction(int nlhs, mxArray * plhs[],
int nrhs, const mxArray * prhs[]) { 
  
    // read prhs
	uint32_t * ptr1 = static_cast <uint32_t *> (mxGetData(prhs[0]));
    texo * tex = reinterpret_cast <texo *> (ptr1[0]);
    int power =  static_cast <int>(mxGetScalar(prhs[1]));
    int maxPositive =  static_cast <int>(mxGetScalar(prhs[2]));
    int maxNegative =  static_cast <int>(mxGetScalar(prhs[3]));
    
	// create plhs
    bool suc = tex->setPower(power, maxPositive, maxNegative);
    plhs[0] = mxCreateLogicalScalar(suc); 
}
