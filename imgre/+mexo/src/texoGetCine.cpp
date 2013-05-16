#include "texo.h"
#include <mex.h>
#include "stdint.h"
  
void mexFunction(int nlhs, mxArray * plhs[],
int nrhs, const mxArray * prhs[]) { 
  
    // read prhs
    int numSamples = static_cast <int> (mxGetScalar(prhs[0]));
    
	// create plhs
    int16_t * start = reinterpret_cast <int16_t *> (texoGetCineStart(0));
    plhs[0] = mxCreateNumericMatrix(1, numSamples, mxINT16_CLASS, mxREAL);
    int16_t * ptr = static_cast <int16_t *> (mxGetData(plhs[0]));
    
    for (int sample = 0; sample < numSamples; sample++) {
        ptr[sample] = start[sample];
    }
}
