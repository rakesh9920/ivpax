#include "texo.h"
#include <mex.h>
  
void mexFunction(int nlhs, mxArray * plhs[],
int nrhs, const mxArray * prhs[]) { 

    // read prhs
    int pci, usm, hv, channels, tx, szCine;
	unsigned long * ptr = (unsigned long *) mxGetData(prhs[0]);
    texo * tex = (texo *) ptr[0];
    const char * firmwarePath = (const char *) mxGetData(prhs[1]);
    pci = * (int *) mxGetData(prhs[2]);
    usm = * (int *) mxGetData(prhs[3]);
    hv = * (int *) mxGetData(prhs[4]);
    channels = * (int *) mxGetData(prhs[5]);
    tx = * (int *) mxGetData(prhs[6]);
    szCine = * (int *) mxGetData(prhs[7]);
    
	// create plhs
    plhs[0] = mxCreateLogicalScalar(tex->init(firmwarePath, pci, usm, hv,
            channels, tx, szCine)); 
}
