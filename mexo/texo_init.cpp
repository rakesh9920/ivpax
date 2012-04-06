#include "texo.h"
#include <mex.h>
  
void mexFunction(int nlhs, mxArray * plhs[],
int nrhs, const mxArray * prhs[]) { 

    // variable init
    int pci, usm, hv, channels, tx, szCine;
    char firmwarePath [50];
    
    // read prhs
	unsigned long * ptr = (unsigned long *) mxGetData(prhs[0]);
    texo * tex = (texo *) ptr[0];
    mxGetString(prhs[1], firmwarePath, mxGetN(prhs[1])+ 1);
    pci = (int) mxGetScalar(prhs[2]);
    usm = (int) mxGetScalar(prhs[3]);
    hv = (int) mxGetScalar(prhs[4]);
    channels = (int) mxGetScalar(prhs[5]);
    tx = (int) mxGetScalar(prhs[6]);
    szCine = (int) mxGetScalar(prhs[7]);
    
	// create plhs
    bool suc = tex->init(firmwarePath, pci, usm, hv, channels, tx, szCine);
    plhs[0] = mxCreateLogicalScalar(suc); 
}
