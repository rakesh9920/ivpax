#include "dblBuffer.h"
#include <mex.h>
#include "texo.h"
#include "stdint.h"
  
void mexFunction(int nlhs, mxArray * plhs[],
int nrhs, const mxArray * prhs[]) { 
  
    // read prhs
	uint32_t * ptr1 = static_cast <uint32_t *> (mxGetData(prhs[0]));
    dblBuffer * buf = reinterpret_cast <dblBuffer *> (ptr1[0]);
    
    uint32_t * ptr2 = static_cast <uint32_t *> (mxGetData(prhs[1]));
    texo * tex = reinterpret_cast <texo *> (ptr2[0]);
    
    int numBytes = static_cast <int> (mxGetScalar(prhs[2]));
    
    buf->transferLine(tex->getCineStart(0), numBytes);
}
