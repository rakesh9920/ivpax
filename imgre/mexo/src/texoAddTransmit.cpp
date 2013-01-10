#include "texo.h"
#include <mex.h>
#include "stdint.h"
  
void mexFunction(int nlhs, mxArray * plhs[],
int nrhs, const mxArray * prhs[]) { 
  
    _texoTransmitParams tx;
    
    tx.centerElement = *((int *) mxGetData(mxGetProperty(prhs[0], 0, "centerElement")));
    tx.aperture = *((int *) mxGetData(mxGetProperty(prhs[0], 0, "aperture")));
    tx.focusDistance = *((int *) mxGetData(mxGetProperty(prhs[0], 0, "focusDistance")));
    tx.angle = *((int *) mxGetData(mxGetProperty(prhs[0], 0, "angle")));
    tx.frequency = *((int *) mxGetData(mxGetProperty(prhs[0], 0, "frequency")));
    
    mxChar * ps = mxGetChars(mxGetProperty(prhs[0], 0, "pulseShape"));
    for (int i = 0; i < mxGetNumberOfElements(mxGetProperty(prhs[0], 0, "pulseShape")); i++)
        tx.pulseShape[i] = (char) ps[i];
    
    tx.speedOfSound = *((int *) mxGetData(mxGetProperty(prhs[0], 0, "speedOfSound")));
    tx.useManualDelays = *((int *) mxGetData(mxGetProperty(prhs[0], 0, "useManualDelays")));

    int * md = (int *) mxGetData(mxGetProperty(prhs[0], 0, "manualDelays"));
    for (int i = 0; i < mxGetNumberOfElements(mxGetProperty(prhs[0], 0, "manualDelays")); i++)
        tx.manualDelays[i] = md[i];

    tx.tableIndex = *((int *) mxGetData(mxGetProperty(prhs[0], 0, "tableIndex")));
    tx.useMask = *((int *) mxGetData(mxGetProperty(prhs[0], 0, "useMask")));
    
    int * mask = (int *) mxGetData(mxGetProperty(prhs[0], 0, "mask"));
    for (int i = 0; i < mxGetNumberOfElements(mxGetProperty(prhs[0], 0, "mask")); i++)
        tx.mask[i] = mask[i];
    
    tx.sync = *((int *) mxGetData(mxGetProperty(prhs[0], 0, "sync")));
    
	// create plhs
    bool suc = texoAddTransmit(tx);
    plhs[0] = mxCreateLogicalScalar(suc); 
}
