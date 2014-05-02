#include "texo.h"
#include <mex.h>
#include "stdint.h"
  
void mexFunction(int nlhs, mxArray * plhs[],
int nrhs, const mxArray * prhs[]) { 
  
    // read prhs
	uint32_t * ptr1 = static_cast <uint32_t *> (mxGetData(prhs[0]));
    texo * tex = reinterpret_cast <texo *> (ptr1[0]);
    
    int numFrames = (int) mxGetScalar(prhs[1]);
    bool suc = true;
    
	if(tex->isImaging())
		suc = false;

	if(!tex->runImage()) 
		suc = false;

	while (tex->getCollectedFrameCount() >= 1)
		;
	while (tex->getCollectedFrameCount() < numFrames)
		;

	if(!tex->stopImage()) 
		suc = false;
    
	// create plhs
    plhs[0] = mxCreateLogicalScalar(suc);
}
