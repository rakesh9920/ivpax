#include "texo.h"
#include <mex.h>
#include "stdint.h"
  
void mexFunction(int nlhs, mxArray * plhs[],
int nrhs, const mxArray * prhs[]) { 
  
    // read prhs
	uint32_t * ptr1 = static_cast <uint32_t *> (mxGetData(prhs[0]));
    texo * tex = reinterpret_cast <texo *> (ptr1[0]);
    
    double percent =  (mxGetScalar(prhs[1]));
    
	// create plhs
    CURVE tgc1;
	tgc1.top = percent;
	tgc1.mid = percent;
	tgc1.btm = percent;
	tgc1.vmid = 50;
	bool suc = tex->addTGC(&tgc1, 100000);
    
    plhs[0] = mxCreateLogicalScalar(suc); 
}
