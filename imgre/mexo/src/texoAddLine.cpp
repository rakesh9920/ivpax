#include "texo.h"
#include <mex.h>
#include "stdint.h"
#include <cstring>

void mexFunction(int nlhs, mxArray * plhs[],
        int nrhs, const mxArray * prhs[]) {
    
    _texoTransmitParams tx;
    _texoReceiveParams rx;
    _texoLineInfo lineInfo;
    _texoCurve rxAprCrv;
    
    // copy transmit parameters
    tx.centerElement = *((double *) mxGetData(mxGetProperty(prhs[0], 0, "centerElement")));
    tx.aperture = *((int *) mxGetData(mxGetProperty(prhs[0], 0, "aperture")));
    tx.focusDistance = *((int *) mxGetData(mxGetProperty(prhs[0], 0, "focusDistance")));
    tx.angle = *((int *) mxGetData(mxGetProperty(prhs[0], 0, "angle")));
    tx.frequency = *((int *) mxGetData(mxGetProperty(prhs[0], 0, "frequency")));
    
    mxArray * ps = mxGetProperty(prhs[0], 0, "pulseShape");
    mxGetString(ps, tx.pulseShape, mxGetN(ps)+1);

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
    rx.centerElement = *((double *) mxGetData(mxGetProperty(prhs[1], 0, "centerElement")));
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
        rx.window[i] = (unsigned char) win[i];
    
    #ifdef MEX_OUTPUT_CHECK
        mexPrintf("tx.centerElement = %d\n", tx.centerElement);
        mexPrintf("tx.aperture = %d\n", tx.aperture);
        mexPrintf("tx.focusDistance = %d\n", tx.focusDistance);
        mexPrintf("tx.frequency = %d\n", tx.frequency);
        mexPrintf("tx.pulseShape = "); mexPrintf(tx.pulseShape); 
        mexPrintf("\n");
        mexPrintf("tx.speedOfSound = %d\n", tx.speedOfSound);
        mexPrintf("tx.tableIndex = %d\n", tx.tableIndex);
        mexPrintf("tx.useManualDelays = %d\n", tx.useManualDelays);
        //mexPrintf("tx.manualDelays = %d\n", tx.manualDelays);
        mexPrintf("tx.useMask = %d\n", tx.useMask);
        mexPrintf("tx.mask = ");
        for (int i = 0; i < 128; i++)
            mexPrintf("%d", tx.mask[i]);
        mexPrintf("\n");
        mexPrintf("tx.sync = %d\n", tx.sync);
        mexPrintf("rx.centerElement = %d\n", rx.centerElement);
        mexPrintf("rx.aperture = %d\n", rx.aperture);
        mexPrintf("rx.angle = %d\n", rx.angle);
        mexPrintf("rx.maxApertureDepth = %d\n", rx.maxApertureDepth);
        mexPrintf("rx.acquisitionDepth = %d\n", rx.acquisitionDepth);
        mexPrintf("rx.saveDelay = %d\n", rx.saveDelay);
        mexPrintf("rx.speedOfSound = %d\n", rx.speedOfSound);
        mexPrintf("rx.channelMask = [%d %d]\n", rx.channelMask[0], rx.channelMask[1]);
        mexPrintf("rx.applyFocus = %d\n", rx.applyFocus);
        mexPrintf("rx.useManualDelays = %d\n", rx.useManualDelays);
        //mexPrintf("rx.manualDelays = %d\n", rx.manualDelays);
        mexPrintf("rx.customLineDuration = %d\n", rx.customLineDuration);
        mexPrintf("rx.lgcValue = %d\n", rx.lgcValue);
        mexPrintf("rx.tgcSel = %d\n", rx.tgcSel);
        mexPrintf("rx.tableIndex = %d\n", rx.tableIndex);
        mexPrintf("rx.decimation = %d\n", rx.decimation);
        mexPrintf("rx.numChannels = %d\n", rx.numChannels);
        mexPrintf("rx.rxAprCrv: top %d, mid %d, btm %d, vmid %d\n",
                rx.rxAprCrv.top, rx.rxAprCrv.mid, rx.rxAprCrv.btm, rx.rxAprCrv.vmid);
        mexPrintf("rx.weightType = %d\n", rx.weightType);
        mexPrintf("rx.useCustomWindow = %d\n", rx.useCustomWindow);
        //mexPrintf("rx.window = %d\n", rx.window);
    #endif
                  
    // create plhs
    int suc = texoAddLine(tx, rx, lineInfo);
    plhs[0] = mxCreateLogicalScalar(suc);
    plhs[1] = mxCreateNumericMatrix(1, 1, mxINT32_CLASS, mxREAL);
    plhs[2] = mxCreateNumericMatrix(1, 1, mxINT32_CLASS, mxREAL);
    
    *(static_cast <int32_t *> (mxGetData(plhs[1]))) = lineInfo.lineSize;
    *(static_cast <int32_t *> (mxGetData(plhs[2]))) = lineInfo.lineDuration;
}
