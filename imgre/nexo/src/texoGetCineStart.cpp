#include "texo.h"
#include <mex.h>
#include "stdint.h"
  
void mexFunction(int nlhs, mxArray * plhs[],
int nrhs, const mxArray * prhs[]) { 
  
    // read prhs
    uint32_t blockid = static_cast <uint32_t> (mxGetScalar(prhs[0]));
    
	// create plhs
    uint8_t * start = static_cast <uint8_t *> (texoGetCineStart(blockid));
    plhs[0] = mxCreateNumericMatrix(1, 1, mxUINT32_CLASS, mxREAL);
    *((uint32_t *) mxGetData(plhs[0])) = reinterpret_cast <uint32_t> (start);
}
