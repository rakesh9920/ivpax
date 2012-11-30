#include "texo.h"
#include <mex.h>
  
void mexFunction(int nlhs, mxArray * plhs[],
int nrhs, const mxArray * prhs[]) { 
  
    // read prhs
    
    int numFrames = (int) mxGetScalar(prhs[0]);
    bool suc = true;
    
	if(texoIsImaging())
		suc = false;

	if(!texoRunImage()) 
		suc = false;

	while (texoGetCollectedFrameCount() >= 1)
		;
	while (texoGetCollectedFrameCount() < numFrames)
		;

	if(!texoStopImage()) 
		suc = false;
    
	// create plhs
    plhs[0] = mxCreateLogicalScalar(suc);
}
