#include "texo.h"
#include <mex.h>
#include "stdint.h"
  
void mexFunction(int nlhs, mxArray * plhs[],
int nrhs, const mxArray * prhs[]) { 
  
    // read prhs
	uint32_t * ptr1 = static_cast <uint32_t *> (mxGetData(prhs[0]));
    texo * tex = reinterpret_cast <texo *> (ptr1[0]);
    
    uint32_t * ptr2 = static_cast <uint32_t *> (mxGetData(prhs[1]));
    texoReceiveParams * rx = reinterpret_cast <texoReceiveParams *> (ptr2[0]);
    
	// create plhs
    bool suc = tex->addReceive(*rx);
    plhs[0] = mxCreateLogicalScalar(suc); 
}
