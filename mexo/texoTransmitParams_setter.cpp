#include "texo.h"
#include <mex.h>

void mexFunction(int nlhs, mxArray * plhs[],
        int nrhs, const mxArray * prhs[]) {
    
    // variable init
    int field, value;
    
    // read prhs
    unsigned long * ptr = (unsigned long *) mxGetData(prhs[0]);
    texoTransmitParams * tx = (texoTransmitParams *) ptr[0];
    field = (int) mxGetScalar(prhs[1]);
    value = (int) mxGetScalar(prhs[2]);
    
    
    switch (field) {
        case 0: tx->centerElement = value; break;
        //default: ;
    }
}
