#include "texo.h"
#include <mex.h>
#include "stdint.h"
  
void mexFunction(int nlhs, mxArray * plhs[],
int nrhs, const mxArray * prhs[]) { 
  
    // read prhs
	uint32_t * ptr1 = static_cast <uint32_t *> (mxGetData(prhs[0]));
    texo * tex = reinterpret_cast <texo *> (ptr1[0]);
    
    int numSamples = static_cast <int> (mxGetScalar(prhs[1]));
    
	// create plhs
    int16_t * start = reinterpret_cast <int16_t *> (tex->getCineStart(0));
    plhs[0] = mxCreateNumericMatrix(1, numSamples, mxINT16_CLASS, mxREAL);
    int16_t * ptr = static_cast <int16_t *> (mxGetData(plhs[0]));
    
    for (int sample = 0; sample < numSamples; sample++) {
        ptr[sample] = start[sample];
    }
}
