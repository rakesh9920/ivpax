#include "texo.h"
#include <mex.h>
#include "stdint.h"
  
void mexFunction(int nlhs, mxArray * plhs[],
int nrhs, const mxArray * prhs[]) { 
  
    // read prhs
	uint32_t * ptr1 = static_cast <uint32_t *> (mxGetData(prhs[0]));
    texo * tex = reinterpret_cast <texo *> (ptr1[0]);
    
    tex->clearTGCs();
}
