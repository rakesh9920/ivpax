#include "texo.h"
#include <mex.h>
#include "stdint.h"
  
void mexFunction(int nlhs, mxArray * plhs[],
int nrhs, const mxArray * prhs[]) { 
  
    _texoCurve tgc;
    
    // read prhs
	const mxArray * curve = prhs[0];
    tgc.top = *((int *) mxGetData(mxGetProperty(curve, 0, "top")));
    tgc.mid = *((int *) mxGetData(mxGetProperty(curve, 0, "mid")));
    tgc.btm = *((int *) mxGetData(mxGetProperty(curve, 0, "btm")));
    tgc.vmid = *((int *) mxGetData(mxGetProperty(curve, 0, "vmid")));
    
    int depth =  (int) mxGetScalar(prhs[1]);
    
	// create plhs
    bool suc = texoAddTGC(&tgc, depth);
    plhs[0] = mxCreateLogicalScalar(suc); 
}
