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
    texoTransmitParams * tx = reinterpret_cast <texoTransmitParams *> (ptr[0]);
    field = (int) mxGetScalar(prhs[1]);
    
    switch (field) {
        case 0: { int value = (int) mxGetScalar(prhs[2]); tx->centerElement = value; break; }
        case 1: { int value = (int) mxGetScalar(prhs[2]); tx->aperture = value; break; }
        case 2: { int value = (int) mxGetScalar(prhs[2]); tx->focusDistance = value; break; }
        case 3: { int value = (int) mxGetScalar(prhs[2]); tx->angle = value; break; }
        case 4: { int value = (int) mxGetScalar(prhs[2]); tx->frequency = value; break; }
        case 5: { char value [MAXPULSESHAPESZ];
        mxGetString(prhs[2], value, mxGetN(prhs[2])+1);
        strcpy(tx->pulseShape, value); break; }
        case 6: { int value = (int) mxGetScalar(prhs[2]); tx->speedOfSound = value; break; }
        case 7: { bool value = (bool) mxGetScalar(prhs[2]); tx->useManualDelays = value; break; }
        case 8: { int * value = static_cast <int *> (mxGetData(prhs[2]));
            memcpy(tx->manualDelays, value, sizeof(int)*129); break; }
        case 9: { int value = (int) mxGetScalar(prhs[2]); tx->tableIndex = value; break; }
        case 10: { bool value = (bool) mxGetScalar(prhs[2]); tx->useDeadElements = value; break; }
        case 11: { int * value = static_cast <int *> (mxGetData(prhs[2]));
        memcpy(tx->deadElements, value, sizeof(int)*128); break; }
        case 12: { bool value = (bool) mxGetScalar(prhs[2]); tx->trex = value; break; }
        default: ;
    }
}
