#include "texo.h"
#include <mex.h>
  
void mexFunction(int nlhs, mxArray * plhs[],
int nrhs, const mxArray * prhs[]) { 
  
    // read prhs
    double percent =  (mxGetScalar(prhs[0]));
    
	// create plhs
    _texoCurve tgc1;
	tgc1.top = percent;
	tgc1.mid = percent;
	tgc1.btm = percent;
	tgc1.vmid = 50;
	bool suc = texoAddTGC(&tgc1, 100000);
    
    plhs[0] = mxCreateLogicalScalar(suc); 
}
