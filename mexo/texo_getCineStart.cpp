#include "texo.h"
#include <mex.h>
#include "stdint.h"
  
void mexFunction(int nlhs, mxArray * plhs[],
int nrhs, const mxArray * prhs[]) { 
  
    // read prhs
	uint32_t * ptr1 = static_cast <uint32_t *> (mxGetData(prhs[0]));
    texo * tex = reinterpret_cast <texo *> (ptr1[0]);
    
    uint32_t blockid = static_cast <uint32_t> (mxGetScalar(prhs[1]));
    
	// create plhs
    uint32_t * start = reinterpret_cast <uint32_t *> (tex->getCineStart(blockid));
    plhs[0] = mxCreateNumericMatrix(1, 1, mxUINT32_CLASS, mxREAL);
    *((uint32_t *) mxGetData(plhs[0])) = reinterpret_cast <uint32_t> (start);
}
