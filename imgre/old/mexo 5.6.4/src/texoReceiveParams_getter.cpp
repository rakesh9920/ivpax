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
        case 0: { plhs[0] = mxCreateNumericMatrix(1, 1, mxINT32_CLASS, mxREAL); *((int *) mxGetData(plhs[0])) = rx->centerElement; break; }
        case 1: { plhs[0] = mxCreateNumericMatrix(1, 1, mxINT32_CLASS, mxREAL); *((int *) mxGetData(plhs[0])) = rx->aperture; break; }
        case 2: { plhs[0] = mxCreateNumericMatrix(1, 1, mxINT32_CLASS, mxREAL); *((int *) mxGetData(plhs[0])) = rx->angle; break; }
        case 3: { plhs[0] = mxCreateNumericMatrix(1, 1, mxINT32_CLASS, mxREAL); *((int *) mxGetData(plhs[0])) = rx->maxApertureDepth; break; }
        case 4: { plhs[0] = mxCreateNumericMatrix(1, 1, mxINT32_CLASS, mxREAL); *((int *) mxGetData(plhs[0])) = rx->acquisitionDepth; break; }
        case 5: { plhs[0] = mxCreateNumericMatrix(1, 1, mxINT32_CLASS, mxREAL); *((int *) mxGetData(plhs[0])) = rx->saveDelay; break; }
        case 6: { plhs[0] = mxCreateNumericMatrix(1, 1, mxINT32_CLASS, mxREAL); *((int *) mxGetData(plhs[0])) = rx->speedOfSound; break; }
        case 7: { plhs[0] = mxCreateNumericMatrix(1, 2, mxUINT32_CLASS, mxREAL); uint32_t * ptr = static_cast <uint32_t *> (mxGetData(plhs[0]));
        for (int i = 0; i < 2; i++)
            ptr[i] = (rx->channelMask)[i];
        break; }
        case 8: { plhs[0] = mxCreateNumericMatrix(1, 1, mxINT32_CLASS, mxREAL); *((bool *) mxGetData(plhs[0])) = rx->applyFocus; break; }
        case 9: { plhs[0] = mxCreateNumericMatrix(1, 1, mxINT32_CLASS, mxREAL); *((bool *) mxGetData(plhs[0])) = rx->useManualDelays; break; }
        case 10: { plhs[0] = mxCreateNumericMatrix(1, 65, mxINT32_CLASS, mxREAL); int * ptr = (int *) mxGetData(plhs[0]);
        for (int i = 0; i < 65; i++)
            ptr[i] = (rx->manualDelays)[i];
        break; }
        case 11: { plhs[0] = mxCreateNumericMatrix(1, 1, mxINT32_CLASS, mxREAL); *((int *) mxGetData(plhs[0])) = rx->customLineDuration; break; }
        case 12: { plhs[0] = mxCreateNumericMatrix(1, 1, mxINT32_CLASS, mxREAL); *((int *) mxGetData(plhs[0])) = rx->lgcValue; break; }
        case 13: { plhs[0] = mxCreateNumericMatrix(1, 1, mxINT32_CLASS, mxREAL); *((int *) mxGetData(plhs[0])) = rx->tgcSel; break; }
        case 14: { plhs[0] = mxCreateNumericMatrix(1, 1, mxINT32_CLASS, mxREAL); *((int *) mxGetData(plhs[0])) = rx->tableIndex; break; }
        case 15: { plhs[0] = mxCreateNumericMatrix(1, 1, mxINT32_CLASS, mxREAL); *((int *) mxGetData(plhs[0])) = rx->decimation; break; }
        case 16: { plhs[0] = mxCreateNumericMatrix(1, 1, mxINT32_CLASS, mxREAL); *((int *) mxGetData(plhs[0])) = rx->numChannels; break; }
        default: ;
    }
}
