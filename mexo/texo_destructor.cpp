#include "texo.h"
#include <mex.h>
     
void mexFunction(int nlhs, mxArray * plhs[],
int nrhs, const mxArray * prhs[]) { 

	unsigned long * ptr = (unsigned long *) mxGetData(prhs[0]);
	delete (texo *) ptr[0];
}
