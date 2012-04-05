#include "texo.h"
#include <mex.h>

        
void mexFunction(int nlhs, mxArray * plhs[],
int nrhs, const mxArray * prhs[]) { 

	double * ptr = mxGetPr(prhs[0]);
	delete &ptr[0];
}

