#include "dblBuffer.h"
#include <mex.h>
#include "stdint.h"
     
void mexFunction(int nlhs, mxArray * plhs[],
int nrhs, const mxArray * prhs[]) { 

	uint32_t * ptr = static_cast <uint32_t *> (mxGetData(prhs[0]));
	delete reinterpret_cast <dblBuffer *> (ptr[0]);
}
