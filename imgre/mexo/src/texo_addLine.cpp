#include "texo.h"
#include <mex.h>
#include "stdint.h"
  
void mexFunction(int nlhs, mxArray * plhs[],
int nrhs, const mxArray * prhs[]) { 
  
    // read prhs
	uint32_t * ptr1 = static_cast <uint32_t *> (mxGetData(prhs[0]));
    texo * tex = reinterpret_cast <texo *> (ptr1[0]);
    
    texoDataFormat dataType = static_cast <texoDataFormat> ((int) mxGetScalar(prhs[1]));
    
    uint32_t * ptr2 = static_cast <uint32_t *> (mxGetData(prhs[2]));
    texoTransmitParams * tx = reinterpret_cast <texoTransmitParams *> (ptr2[0]);
    
    uint32_t * ptr3 = static_cast <uint32_t *> (mxGetData(prhs[3]));
    texoReceiveParams * rx = reinterpret_cast <texoReceiveParams *> (ptr3[0]);
    
	// create plhs
    int suc = tex->addLine(dataType, *tx, *rx);
    plhs[0] = mxCreateLogicalScalar(suc); 
}
