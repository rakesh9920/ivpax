#include "texo.h"
#include <mex.h>
#include "stdint.h"
  
void mexFunction(int nlhs, mxArray * plhs[],
int nrhs, const mxArray * prhs[]) { 
    
    _texoTransmitParams tx;
    _texoReceiveParams rx;
    _texoLineInfo lineInfo;
    _texoCurve rxAprCrv;
    
    // copy transmit parameters
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
    
    // copy receive parameters
    rx.centerElement = *((int *) mxGetData(mxGetProperty(prhs[1], 0, "centerElement")));
    rx.aperture = *((int *) mxGetData(mxGetProperty(prhs[1], 0, "aperture")));
    rx.angle = *((int *) mxGetData(mxGetProperty(prhs[1], 0, "angle")));
    rx.maxApertureDepth = *((int *) mxGetData(mxGetProperty(prhs[1], 0, "maxApertureDepth")));
    rx.acquisitionDepth = *((int *) mxGetData(mxGetProperty(prhs[1], 0, "acquisitionDepth")));
    rx.saveDelay = *((int *) mxGetData(mxGetProperty(prhs[1], 0, "saveDelay")));
    rx.speedOfSound = *((int *) mxGetData(mxGetProperty(prhs[1], 0, "speedOfSound")));
    
    int * cm = (int *) mxGetData(mxGetProperty(prhs[1], 0, "channelMask"));
    for (int i = 0; i < mxGetNumberOfElements(mxGetProperty(prhs[1], 0, "channelMask")); i++)
        rx.channelMask[i] = cm[i];
    
    rx.applyFocus = *((int *) mxGetData(mxGetProperty(prhs[1], 0, "applyFocus")));
    rx.useManualDelays = *((int *) mxGetData(mxGetProperty(prhs[1], 0, "useManualDelays")));
    
    int * rxmd = (int *) mxGetData(mxGetProperty(prhs[1], 0, "manualDelays"));
    for (int i = 0; i < mxGetNumberOfElements(mxGetProperty(prhs[1], 0, "manualDelays")); i++)
        rx.manualDelays[i] = rxmd[i];
    
    rx.customLineDuration = *((int *) mxGetData(mxGetProperty(prhs[1], 0, "customLineDuration")));
    rx.lgcValue = *((int *) mxGetData(mxGetProperty(prhs[1], 0, "lgcValue")));
    rx.tgcSel = *((int *) mxGetData(mxGetProperty(prhs[1], 0, "tgcSel")));
    rx.tableIndex = *((int *) mxGetData(mxGetProperty(prhs[1], 0, "tableIndex")));
    rx.decimation = *((int *) mxGetData(mxGetProperty(prhs[1], 0, "decimation")));
    rx.numChannels = *((int *) mxGetData(mxGetProperty(prhs[1], 0, "numChannels")));
    
    mxArray * curve = mxGetProperty(prhs[1], 0, "rxAprCrv");
    rxAprCrv.top = *((int *) mxGetData(mxGetProperty(curve, 0, "top")));
    rxAprCrv.mid = *((int *) mxGetData(mxGetProperty(curve, 0, "mid")));
    rxAprCrv.btm = *((int *) mxGetData(mxGetProperty(curve, 0, "btm")));
    rxAprCrv.vmid = *((int *) mxGetData(mxGetProperty(curve, 0, "vmid")));
    rx.rxAprCrv = rxAprCrv;

    rx.weightType = *((int *) mxGetData(mxGetProperty(prhs[1], 0, "weightType")));
    rx.useCustomWindow = *((int *) mxGetData(mxGetProperty(prhs[1], 0, "useCustomWindow")));
    
    mxChar * win = mxGetChars(mxGetProperty(prhs[1], 0, "window"));
    for (int i = 0; i < mxGetNumberOfElements(mxGetProperty(prhs[1], 0, "window")); i++)
        rx.window[i] = (unsigned char) ps[i];
    
    lineInfo.lineSize = *((int *) mxGetData(mxGetProperty(prhs[2], 0, "lineSize")));
    lineInfo.lineDuration = *((int *) mxGetData(mxGetProperty(prhs[2], 0, "lineDuration")));
    
	// create plhs
    int suc = texoAddLine(tx, rx, lineInfo);
    plhs[0] = mxCreateLogicalScalar(suc); 
}
