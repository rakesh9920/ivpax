#include "texo.h"
#include <mex.h>
#include "stdint.h"
  
void mexFunction(int nlhs, mxArray * plhs[],
int nrhs, const mxArray * prhs[]) { 
  
    _texoReceiveParams rx;
    _texoCurve rxAprCrv;
    
    rx.centerElement = *((int *) mxGetData(mxGetProperty(prhs[0], 0, "centerElement")));
    rx.aperture = *((int *) mxGetData(mxGetProperty(prhs[0], 0, "aperture")));
    rx.angle = *((int *) mxGetData(mxGetProperty(prhs[0], 0, "angle")));
    rx.maxApertureDepth = *((int *) mxGetData(mxGetProperty(prhs[0], 0, "maxApertureDepth")));
    rx.acquisitionDepth = *((int *) mxGetData(mxGetProperty(prhs[0], 0, "acquisitionDepth")));
    rx.saveDelay = *((int *) mxGetData(mxGetProperty(prhs[0], 0, "saveDelay")));
    rx.speedOfSound = *((int *) mxGetData(mxGetProperty(prhs[0], 0, "speedOfSound")));
    
    int * cm = (int *) mxGetData(mxGetProperty(prhs[0], 0, "channelMask"));
    for (int i = 0; i < mxGetNumberOfElements(mxGetProperty(prhs[0], 0, "channelMask")); i++)
        rx.channelMask[i] = cm[i];
    
    rx.applyFocus = *((int *) mxGetData(mxGetProperty(prhs[0], 0, "applyFocus")));
    rx.useManualDelays = *((int *) mxGetData(mxGetProperty(prhs[0], 0, "useManualDelays")));
    
    int * rxmd = (int *) mxGetData(mxGetProperty(prhs[0], 0, "manualDelays"));
    for (int i = 0; i < mxGetNumberOfElements(mxGetProperty(prhs[0], 0, "manualDelays")); i++)
        rx.manualDelays[i] = rxmd[i];
    
    rx.customLineDuration = *((int *) mxGetData(mxGetProperty(prhs[0], 0, "customLineDuration")));
    rx.lgcValue = *((int *) mxGetData(mxGetProperty(prhs[0], 0, "lgcValue")));
    rx.tgcSel = *((int *) mxGetData(mxGetProperty(prhs[0], 0, "tgcSel")));
    rx.tableIndex = *((int *) mxGetData(mxGetProperty(prhs[0], 0, "tableIndex")));
    rx.decimation = *((int *) mxGetData(mxGetProperty(prhs[0], 0, "decimation")));
    rx.numChannels = *((int *) mxGetData(mxGetProperty(prhs[0], 0, "numChannels")));
    
    mxArray * curve = mxGetProperty(prhs[0], 0, "rxAprCrv");
    rxAprCrv.top = *((int *) mxGetData(mxGetProperty(curve, 0, "top")));
    rxAprCrv.mid = *((int *) mxGetData(mxGetProperty(curve, 0, "mid")));
    rxAprCrv.btm = *((int *) mxGetData(mxGetProperty(curve, 0, "btm")));
    rxAprCrv.vmid = *((int *) mxGetData(mxGetProperty(curve, 0, "vmid")));
    rx.rxAprCrv = rxAprCrv;

    rx.weightType = *((int *) mxGetData(mxGetProperty(prhs[0], 0, "weightType")));
    rx.useCustomWindow = *((int *) mxGetData(mxGetProperty(prhs[0], 0, "useCustomWindow")));
    
    mxChar * win = mxGetChars(mxGetProperty(prhs[0], 0, "window"));
    for (int i = 0; i < mxGetNumberOfElements(mxGetProperty(prhs[0], 0, "window")); i++)
        rx.window[i] = (unsigned char) win[i];
    
	// create plhs
    bool suc = texoAddReceive(rx);
    plhs[0] = mxCreateLogicalScalar(suc); 
}
