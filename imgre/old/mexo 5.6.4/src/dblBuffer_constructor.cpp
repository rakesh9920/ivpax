#include "dblBuffer.h"
#include <mex.h>
#include "stdint.h"
      
void mexFunction(int nlhs, mxArray * plhs[],
int nrhs, const mxArray * prhs[]) { 

	plhs[0] = mxCreateNumericMatrix(1, 1, mxUINT32_CLASS, mxREAL);
	uint32_t * ptr = static_cast <uint32_t *> (mxGetData(plhs[0]));
    ptr[0] = reinterpret_cast <uint32_t> (new dblBuffer());
}

