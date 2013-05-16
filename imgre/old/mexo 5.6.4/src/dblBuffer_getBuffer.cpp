#include "dblBuffer.h"
#include <mex.h>
#include "stdint.h"
  
void mexFunction(int nlhs, mxArray * plhs[],
int nrhs, const mxArray * prhs[]) { 
  
    // read prhs
	uint32_t * ptr1 = static_cast <uint32_t *> (mxGetData(prhs[0]));
    dblBuffer * tex = reinterpret_cast <dblBuffer *> (ptr1[0]);
    
    int numSamples = static_cast <int> (mxGetScalar(prhs[1]));
    
	// create plhs
    int16_t * start = reinterpret_cast <int16_t *> (tex->getBufferStart());
    plhs[0] = mxCreateNumericMatrix(1, numSamples, mxINT16_CLASS, mxREAL);
    int16_t * ptr = static_cast <int16_t *> (mxGetData(plhs[0]));
    
    for (int sample = 0; sample < numSamples; sample++) {
        ptr[sample] = start[sample];
    }
}
