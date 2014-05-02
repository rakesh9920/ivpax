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
        case 0: { plhs[0] = mxCreateNumericMatrix(1, 1, mxINT32_CLASS, mxREAL); *((int *) mxGetData(plhs[0])) = tx->centerElement; break; }
        case 1: { plhs[0] = mxCreateNumericMatrix(1, 1, mxINT32_CLASS, mxREAL); *((int *) mxGetData(plhs[0])) = tx->aperture; break; }
        case 2: { plhs[0] = mxCreateNumericMatrix(1, 1, mxINT32_CLASS, mxREAL); *((int *) mxGetData(plhs[0])) = tx->focusDistance; break; }
        case 3: { plhs[0] = mxCreateNumericMatrix(1, 1, mxINT32_CLASS, mxREAL); *((int *) mxGetData(plhs[0])) = tx->angle; break; }
        case 4: { plhs[0] = mxCreateNumericMatrix(1, 1, mxINT32_CLASS, mxREAL); *((int *) mxGetData(plhs[0])) = tx->frequency; break; }
        case 5: { plhs[0] = mxCreateString(tx->pulseShape); break; }
        case 6: { plhs[0] = mxCreateNumericMatrix(1, 1, mxINT32_CLASS, mxREAL); *((int *) mxGetData(plhs[0])) = tx->speedOfSound; break; }
        case 7: { plhs[0] = mxCreateNumericMatrix(1, 1, mxINT32_CLASS, mxREAL); *((int *) mxGetData(plhs[0])) = tx->useManualDelays; break; }
        case 8: { plhs[0] = mxCreateNumericMatrix(1, 1, mxINT32_CLASS, mxREAL); *((int *) mxGetData(plhs[0])) = tx->tableIndex; break; }
        case 9: { plhs[0] = mxCreateNumericMatrix(1, 1, mxINT32_CLASS, mxREAL); *((int *) mxGetData(plhs[0])) = tx->useDeadElements; break; }
        case 10: { plhs[0] = mxCreateNumericMatrix(1, 128, mxINT32_CLASS, mxREAL);
        int * ptr = (int *) mxGetData(plhs[0]);
        for (int i = 0; i < 128; i++)
            ptr[i] = (tx->deadElements)[i];
        break; }
        case 11: { plhs[0] = mxCreateNumericMatrix(1, 1, mxINT32_CLASS, mxREAL); *((int *) mxGetData(plhs[0])) = tx->trex; break; }
        default: ;
    }
}
