#include "texo.h"
#include <mex.h>
#include "stdint.h"
#include <string.h>

void mexFunction(int nlhs, mxArray * plhs[],
        int nrhs, const mxArray * prhs[]) {
    
    // variable init
    int field;
    
    // read prhs
    uint32_t * ptr = static_cast <uint32_t *> (mxGetData(prhs[0]));
    texoReceiveParams * rx = reinterpret_cast <texoReceiveParams *> (ptr[0]);
    field = (int) mxGetScalar(prhs[1]);
    
    switch (field) {
        case 0: { int value = (int) mxGetScalar(prhs[2]); rx->centerElement = value; break; }
        case 1: { int value = (int) mxGetScalar(prhs[2]); rx->aperture = value; break; }
        case 2: { int value = (int) mxGetScalar(prhs[2]); rx->angle = value; break; }
        case 3: { int value = (int) mxGetScalar(prhs[2]); rx->maxApertureDepth = value; break; }
        case 4: { int value = (int) mxGetScalar(prhs[2]); rx->acquisitionDepth = value; break; }
        case 5: { int value = (int) mxGetScalar(prhs[2]); rx->saveDelay = value; break; }
        case 6: { int value = (int) mxGetScalar(prhs[2]); rx->speedOfSound = value; break; }
        case 7: { uint32_t * value = static_cast <uint32_t *> (mxGetData(prhs[2]));
            memcpy(rx->channelMask, value, sizeof(int)*2); break; }
        case 8: { bool value = (bool) mxGetScalar(prhs[2]); rx->applyFocus = value; break; }
        case 9: { bool value = (bool) mxGetScalar(prhs[2]); rx->useManualDelays = value; break; }
        case 10: { int * value = static_cast <int *> (mxGetData(prhs[2]));
            memcpy(rx->manualDelays, value, sizeof(int)*65); break; }
        case 11: { int value = (int) mxGetScalar(prhs[2]); rx->customLineDuration = value; break; }
        case 12: { int value = (int) mxGetScalar(prhs[2]); rx->lgcValue = value; break; }
        case 13: { int value = (int) mxGetScalar(prhs[2]); rx->tgcSel = value; break; }
        case 14: { int value = (int) mxGetScalar(prhs[2]); rx->tableIndex = value; break; }
        case 15: { int value = (int) mxGetScalar(prhs[2]); rx->decimation = value; break; }
        case 16: { int value = (int) mxGetScalar(prhs[2]); rx->numChannels = value; break; }
        default: ;
    }
}
