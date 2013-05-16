#include "texo.h"
#include <mex.h>
     
void mexFunction(int nlhs, mxArray * plhs[],
int nrhs, const mxArray * prhs[]) { 

    // read prhs
    int enable =  (int) (mxGetScalar(prhs[0])); 
    texoEnableSyncNotify(enable);
}
