#include "texo.h"
#include <mex.h>

        
void mexFunction(int nlhs, mxArray * plhs[],
int nrhs, const mxArray * prhs[]) { 

	plhs[0] = mxCreateNumericMatrix(1, 1, mxUINT32_CLASS, mxREAL);
	double * ptr = mxGetPr(plhs[0]);
    //texo * tex = new texo();
    ptr[0] = (unsigned long) new texo();
}

