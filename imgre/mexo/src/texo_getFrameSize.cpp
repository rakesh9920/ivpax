#include "texo.h"
#include <mex.h>
#include "stdint.h"
     
void mexFunction(int nlhs, mxArray * plhs[],
int nrhs, const mxArray * prhs[]) { 

    // read prhs
	uint32_t * ptr = static_cast <uint32_t *> (mxGetData(prhs[0]));
    texo * tex = reinterpret_cast <texo *> (ptr[0]);
    
    // set plhs
    plhs[0] = mxCreateNumericMatrix(1, 1, mxINT32_CLASS, mxREAL);
    *(static_cast <int32_t *> (mxGetData(plhs[0]))) = tex->getFrameSize(); 
}
